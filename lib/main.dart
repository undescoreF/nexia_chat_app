import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sizer/sizer.dart';

import 'package:nexachat/app/modules/chat/views/chat_list_view.dart';
import 'package:nexachat/app/utils/app_theme.dart';
import 'app/modules/auth/views/login_page.dart';
import 'app/modules/auth/views/register_page.dart';
import 'app/modules/calls/controller/call_controllers.dart';
import 'app/modules/calls/controller/local_controll.dart';
import 'app/modules/chat/controller/notification_controller.dart';
import 'app/modules/settings/Controllers/theme_controller.dart';
import 'app/modules/settings/Controllers/languages_controller.dart';
import 'bottom_view.dart';
import 'data/providers/call_provider.dart';
import 'data/providers/notification_provider.dart';
import 'data/repositories/call_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      //cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      cacheSizeBytes: 2 * 1024 * 1024 * 1024,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  } catch (e, stackTrace) {
    debugPrint('Erreur d’initialisation : $e');
    debugPrintStack(stackTrace: stackTrace);
  } finally {
    FlutterNativeSplash.remove();
  }
  Get.put(LocalCallController());
  final callProvider = CallProvider();
  final callRepository = CallRepository(callProvider);
  Get.put(CallControllers(callRepository), permanent: true);
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  OneSignal.Notifications.requestPermission(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final languageController = Get.put(LanguageController());
    final themeController = Get.put(ThemeController());
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Obx(() {
          final currentLocale = languageController.getCurrentLocale();
          return GetMaterialApp(
            title: 'NexaChat',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            locale: currentLocale,
            fallbackLocale: const Locale('en', 'US'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: (user != null && user.emailVerified)
                ? BottomAppBarView()
                : LoginPage(),
            debugShowCheckedModeBanner: false,
          );
        });
      },
    );
  }
}
