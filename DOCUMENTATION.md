
# Nexia Chat – Technical Documentation

**Version:** 1.0  
**Repository:** https://github.com/undescoreF/nexia_chat_app



## Executive Summary

Nexia Chat is a cross-platform mobile messaging application built with Flutter. It provides real-time text chat, multimedia sharing, and peer-to-peer audio/video calls. The application integrates Firebase services for authentication, data storage, and file management, while WebRTC handles direct media streaming between users.

This document describes the existing architecture, component structure, and data flows. It also outlines security considerations and provides recommendations for future improvements.

---

## 1. Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.32.8 / Dart 3.8.1 |
| State Management | GetX 4.7.2 |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Real-time Calls | WebRTC (flutter_webrtc 1.2.1) |
| Localization | intl (RU/EN/FR) |
| Push Notifications | OneSignal |

---

## 2. Project Structure

```
lib/
├── app/
│   ├── data/
│   │   ├── models/           # Data models (User, Message, Chat, Call)
│   │   ├── providers/        # Firebase service wrappers
│   │   └── repositories/     # Business logic abstraction
│   ├── modules/
│   │   ├── auth/             # Authentication (login, registration)
│   │   ├── chat/             # Messaging and chat lists
│   │   ├── call/             # WebRTC call handling
│   │   ├── profile/          # User profile management
│   │   └── settings/         # App settings (language, theme)
│   ├── services/             # Global services (notifications, connectivity)
│   ├── utils/                # Helpers and constants
│   └── widgets/              # Reusable UI components
└── main.dart                 # Application entry point
```

Each module follows a consistent pattern:
- **bindings** – GetX dependency injection
- **controllers** – Business logic and state management
- **views** – UI screens and widgets
- **services** – Module-specific business logic

---

## 3. Architecture

### 3.1 Layered Design

The application follows a Repository pattern with clear separation of concerns:

```
UI (Views) → Controllers (GetX) → Repositories → Providers → Firebase
```

| Layer | Responsibility |
|-------|----------------|
| **UI** | Display data, capture user input |
| **Controllers** | Manage screen state, handle user actions |
| **Repositories** | Orchestrate use cases, abstract data sources |
| **Providers** | Direct Firebase SDK calls |

This architecture ensures testability, maintainability, and centralized security validation. All Firebase access passes through the provider layer—direct calls from UI are prohibited.

### 3.2 Entry Point (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  runApp(GetMaterialApp(
    locale: Locale('en'),
    getPages: AppRoutes.pages,
    home: RootScreen(),
  ));
}
```

Initialization sequence:
1. Flutter binding setup
2. Firebase initialization
3. GetX dependency registration
4. Theme and localization configuration
5. Route navigation (splash → auth or chat list)

---

## 4. Core Modules

### 4.1 Authentication

**Files:** `app/modules/auth/`

| Component | Description |
|-----------|-------------|
| `AuthController` | Manages login, registration, session state |
| `AuthProvider` | Wraps FirebaseAuth SDK calls |
| `AuthRepository` | Business logic (profile creation, email verification) |

**Flow:**
1. User submits credentials
2. `AuthController` calls `AuthProvider.signIn()`
3. On success, user profile is created/read from `users/{uid}`
4. Session persists via Firebase Auth
5. UI navigates to chat list

Email verification is required before first login. Session state is reactive—controllers listen to `authStateChanges()` for automatic UI updates.

### 4.2 Chat & Messaging

**Files:** `app/modules/chat/`

| Component | Description |
|-----------|-------------|
| `ChatController` | Manages chat list, active conversation, message stream |
| `ChatProvider` | Firestore operations for chats and messages |
| `ChatRepository` | Coordinates message sending (including file uploads) |
| `FileManagerController` | Handles file selection, validation, upload |

**Firestore Structure:**
```
users/{uid}                    # User profile
chats/{chatId}                 # Chat metadata
chats/{chatId}/messages/{msgId} # Messages in each chat
calls/{callId}                 # Call signaling data
```

**Message Model:**
```dart
{
  senderId: String,
  text: String?,
  fileUrl: String?,
  mimeType: String?,
  status: String,        // sending, sent, delivered, seen
  sentAt: Timestamp,
  receivedAt: Timestamp?,
  seenAt: Timestamp?
}
```

**Send Flow:**
1. User types message or selects media
2. `ChatController.sendMessage()` invoked
3. If media: upload to Storage, get download URL
4. Write message document to Firestore
5. Firestore listeners trigger UI update on both devices

Message status updates follow this sequence: **sent** (written to Firestore) → **delivered** (receiver's client acknowledges) → **seen** (receiver opens chat).

### 4.3 WebRTC Calls

**Files:** `app/modules/call/`

| Component | Description |
|-----------|-------------|
| `CallController` | Manages call state (idle, ringing, in-call) |
| `WebRTCService` | Handles RTCPeerConnection, media streams |
| `CallRepository` | Signaling via Firestore |

**Signaling Flow:**
1. Caller creates SDP offer via `RTCPeerConnection`
2. Offer written to `calls/{callId}` in Firestore
3. Callee's listener detects new call document
4. Callee creates SDP answer, writes back to Firestore
5. ICE candidates exchanged via `FieldValue.arrayUnion()`
6. P2P connection established, media flows directly

**ICE Configuration:**
- STUN: Google public servers (stun.l.google.com:19302)
- TURN: Metered.ca relay (fallback for restrictive NATs)

Media streams are encrypted via DTLS/SRTP. Signaling data (SDP, ICE candidates) passes through Firestore over HTTPS.

### 4.4 Localization & Theming

**Files:** `app/modules/settings/`, `lib/l10n/`

- **Languages:** Russian, English, French
- **Themes:** Light and dark modes
- **Implementation:** `intl` package with ARB files, GetX reactive updates
- **Persistence:** User preferences saved locally, applied without restart

---

## 5. Data Models

### 5.1 User Profile (`users/{uid}`)
```dart
{
  uid: String,
  name: String,
  email: String,
  profileImageUrl: String?,
  isOnline: bool,
  lastSeen: Timestamp,
  oneSignalPlayerIds: List<String>
}
```

### 5.2 Chat (`chats/{chatId}`)
```dart
{
  participants: List<String>,
  lastMessage: String,
  lastMessageTime: Timestamp,
  type: String  // "private" or "group"
}
```

### 5.3 Message (`chats/{chatId}/messages/{msgId}`)
```dart
{
  senderId: String,
  text: String?,
  fileUrl: String?,
  mimeType: String?,
  status: String,
  sentAt: Timestamp,
  receivedAt: Timestamp?,
  seenAt: Timestamp?
}
```

### 5.4 Call (`calls/{callId}`)
```dart
{
  callerId: String,
  calleeId: String,
  status: String,      // ringing, accepted, rejected, ended
  offer: String,       // SDP offer
  answer: String,      // SDP answer
  iceCandidates: List,
  createdAt: Timestamp,
  endedAt: Timestamp?
}
```

---

## 6. Security

### 6.1 Current Measures

| Protection | Implementation |
|------------|----------------|
| Authentication | Firebase Auth (email/password) |
| Data Access | Firestore Security Rules |
| Transport | HTTPS for all Firebase traffic |
| Media Streams | DTLS/SRTP for WebRTC |
| Permissions | Runtime requests (camera, microphone, storage) |
| Code Obfuscation | `flutter build --obfuscate` |

**Firestore Rules Example:**
```javascript
match /chats/{chatId} {
  allow read, write: if request.auth != null 
      && request.auth.uid in resource.data.participants;
}
```

### 6.2 Identified Vulnerabilities

| Issue | Risk | Status |
|-------|------|--------|
| Unencrypted local cache | Data extraction on rooted devices | Not mitigated |
| Hardcoded TURN credentials | Credential leakage via decompilation | Not mitigated |
| No SDP validation | Potential session manipulation | Not mitigated |
| No E2EE | Firebase can access message content | Not implemented |
| No App Check | Unauthorized clients can access resources | Not enabled |

### 6.3 Recommendations

| Priority | Action | Effort |
|----------|--------|--------|
| **High** | Generate temporary TURN tokens via Cloud Functions | Medium |
| **High** | Encrypt local cache (flutter_secure_storage) | Low |
| **Medium** | Enable Firebase App Check | Low |
| **Medium** | Add SDP input validation | Low |
| **Low** | Implement E2EE (Signal Protocol) | High |
| **Low** | Add MIME type validation for uploads | Low |

---

## 7. Performance & Testing

### 7.1 Measured Metrics

| Metric | Value |
|--------|-------|
| APK Size | 45.5 MB |
| Message Delivery | <500 ms (stable network) |
| Call Setup Time | 1–5 s (network dependent) |
| Call Success Rate | 100% (tested scenarios) |
| Test Group | 8 users, 1 month |

### 7.2 Code Quality Metrics

| Component | Reliability | Security |
|-----------|-------------|----------|
| Authentication | 95% | 90% |
| Messaging | 85% | 75% |
| Video Calls | 80% | 60% |
| File Handling | 90% | 70% |
| **Overall** | **87.5%** | **73.75%** |

Metrics based on OWASP MASVS methodology, covering error handling, input validation, and resource cleanup.

### 7.3 Testing Strategy

| Test Type | Tools | Coverage |
|-----------|-------|----------|
| Unit Tests | `flutter_test`, `cloud_firestore_mocks` | Controllers, repositories |
| Widget Tests | Flutter widget testing framework | UI components |
| Integration Tests | Flutter integration_test | End-to-end flows |
| Security Audit | Manual code review, CVE Details, MobSF | Dependencies, author code |

**GetX Testing Pattern:**
```dart
setUp(() {
  Get.testMode = true;
  // Inject mock dependencies
});
```

---

## 8. Deployment & Maintenance

### 8.1 Build Configuration

```bash
# Debug build
flutter run

# Release build (Android)
flutter build apk --release --obfuscate --split-debug-info=build/symbols

# Release build (iOS)
flutter build ios --release
```

### 8.2 Environment Variables

Store sensitive configuration in `.env` (excluded from version control):
- Firebase project IDs
- OneSignal app ID
- TURN server credentials (to be moved to Cloud Functions)

### 8.3 Monitoring

Recommended Firebase integrations:
- **Crashlytics** – Crash reporting
- **Performance Monitoring** – App performance metrics
- **Analytics** – User behavior tracking

---

## 9. Repository & Resources

| Resource | Link |
|----------|------|
| Source Code | https://github.com/undescoreF/nexia_chat_app |
| Issue Tracker | GitHub Issues |
| Documentation | Repository README + this document |

---

## Appendix: File Reference

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, Firebase initialization |
| `lib/app/data/models/` | Data class definitions |
| `lib/app/data/providers/` | Firebase SDK wrappers |
| `lib/app/data/repositories/` | Business logic orchestration |
| `lib/app/modules/auth/` | Authentication screens and logic |
| `lib/app/modules/chat/` | Messaging feature |
| `lib/app/modules/call/` | WebRTC call feature |
| `lib/app/modules/profile/` | User profile management |
| `lib/app/modules/settings/` | Language, theme, app settings |
| `lib/app/services/` | Global services (notifications, connectivity) |
| `lib/app/widgets/` | Reusable UI components |
| `lib/l10n/` | Localization ARB files |
| `test/` | Unit and widget tests |

---

## Appendix: Security Implementation Checklist

- [ ] **E2EE:** Integrate Signal Protocol library for message encryption
- [ ] **App Check:** Enable Firebase App Check with Play Integrity/DeviceCheck
- [ ] **TURN Tokens:** Move credentials to Cloud Functions for dynamic generation
- [ ] **Cache Encryption:** Use flutter_secure_storage for local data
- [ ] **SDP Validation:** Add input sanitization for WebRTC signaling data
- [ ] **MIME Validation:** Verify file types before upload
- [ ] **Backup Disabled:** Set `android:allowBackup="false"` in manifest

---

<!--*This documentation reflects the current state of the Nexia Chat application as of March 2026. For questions or contributions, please open an issue on GitHub.*-->
```
