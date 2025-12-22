import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('ru'),
  ];

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_title;

  /// No description provided for @login_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get login_welcome;

  /// No description provided for @login_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get login_email_label;

  /// No description provided for @login_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get login_email_hint;

  /// No description provided for @login_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get login_email_invalid;

  /// No description provided for @login_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password_label;

  /// No description provided for @login_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get login_password_hint;

  /// No description provided for @login_password_min.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get login_password_min;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_button;

  /// No description provided for @login_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get login_no_account;

  /// No description provided for @login_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get login_register;

  /// No description provided for @login_email_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified yet. Check your inbox.'**
  String get login_email_not_verified;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get login_success;

  /// No description provided for @register_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register_title;

  /// No description provided for @register_full_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get register_full_name_label;

  /// No description provided for @register_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get register_email_label;

  /// No description provided for @register_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get register_email_hint;

  /// No description provided for @register_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get register_password_label;

  /// No description provided for @register_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get register_password_hint;

  /// No description provided for @register_confirm_password_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get register_confirm_password_label;

  /// No description provided for @register_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get register_password_mismatch;

  /// No description provided for @register_button.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register_button;

  /// No description provided for @register_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get register_have_account;

  /// No description provided for @register_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get register_login;

  /// No description provided for @register_email_sent.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to {email}. Please check before logging in.'**
  String register_email_sent(Object email);

  /// No description provided for @reset_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_title;

  /// No description provided for @reset_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get reset_email_label;

  /// No description provided for @reset_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get reset_email_hint;

  /// No description provided for @reset_button.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset_button;

  /// No description provided for @reset_email_sent.
  ///
  /// In en, this message translates to:
  /// **'A reset link has been sent to {email}.'**
  String reset_email_sent(Object email);

  /// No description provided for @error_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email.'**
  String get error_invalid_email;

  /// No description provided for @error_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get error_user_not_found;

  /// No description provided for @error_wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get error_wrong_password;

  /// No description provided for @error_email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get error_email_already_in_use;

  /// No description provided for @error_weak_password.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get error_weak_password;

  /// No description provided for @error_user_disabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get error_user_disabled;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get error_network;

  /// No description provided for @error_too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get error_too_many_requests;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get error_unknown;

  /// No description provided for @success_title.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success_title;

  /// No description provided for @error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_title;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @calls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get calls;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @recents.
  ///
  /// In en, this message translates to:
  /// **'Recents'**
  String get recents;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @assistance.
  ///
  /// In en, this message translates to:
  /// **'Assistance'**
  String get assistance;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get dark_theme;

  /// No description provided for @help_faq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get help_faq;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contact_support;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @choose_option.
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get choose_option;

  /// No description provided for @choose_from_photos.
  ///
  /// In en, this message translates to:
  /// **'Choose from photos'**
  String get choose_from_photos;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get take_photo;

  /// No description provided for @edit_photo.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get edit_photo;

  /// No description provided for @photo_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get photo_updated;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search_contact.
  ///
  /// In en, this message translates to:
  /// **'Search a contact'**
  String get search_contact;

  /// No description provided for @name_or_email.
  ///
  /// In en, this message translates to:
  /// **'Name or email'**
  String get name_or_email;

  /// No description provided for @type_to_search_user.
  ///
  /// In en, this message translates to:
  /// **'Type to search a user'**
  String get type_to_search_user;

  /// No description provided for @no_user_found.
  ///
  /// In en, this message translates to:
  /// **'No user found'**
  String get no_user_found;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @e2ee.
  ///
  /// In en, this message translates to:
  /// **'End-to-End Encrypted'**
  String get e2ee;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
