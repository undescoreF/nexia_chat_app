// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login_title => 'Login';

  @override
  String get login_welcome => 'Welcome back 👋';

  @override
  String get login_email_label => 'Email';

  @override
  String get login_email_hint => 'Enter your email';

  @override
  String get login_email_invalid => 'Invalid email';

  @override
  String get login_password_label => 'Password';

  @override
  String get login_password_hint => 'Enter your password';

  @override
  String get login_password_min => 'Minimum 6 characters';

  @override
  String get login_button => 'Login';

  @override
  String get login_no_account => 'Don\'t have an account?';

  @override
  String get login_register => 'Register';

  @override
  String get login_email_not_verified =>
      'Your email is not verified yet. Check your inbox.';

  @override
  String get login_success => 'Login successful!';

  @override
  String get register_title => 'Create Account';

  @override
  String get register_full_name_label => 'Full Name';

  @override
  String get register_email_label => 'Email';

  @override
  String get register_email_hint => 'Enter your email';

  @override
  String get register_password_label => 'Password';

  @override
  String get register_password_hint => 'Enter your password';

  @override
  String get register_confirm_password_label => 'Confirm Password';

  @override
  String get register_password_mismatch => 'Passwords do not match';

  @override
  String get register_button => 'Register';

  @override
  String get register_have_account => 'Already have an account?';

  @override
  String get register_login => 'Login';

  @override
  String register_email_sent(Object email) {
    return 'A verification email has been sent to $email. Please check before logging in.';
  }

  @override
  String get reset_title => 'Reset Password';

  @override
  String get reset_email_label => 'Email';

  @override
  String get reset_email_hint => 'Enter your email';

  @override
  String get reset_button => 'Reset';

  @override
  String reset_email_sent(Object email) {
    return 'A reset link has been sent to $email.';
  }

  @override
  String get error_invalid_email => 'Invalid email.';

  @override
  String get error_user_not_found => 'No user found with this email.';

  @override
  String get error_wrong_password => 'Invalid email or password.';

  @override
  String get error_email_already_in_use => 'This email is already in use.';

  @override
  String get error_weak_password => 'Password is too weak.';

  @override
  String get error_user_disabled => 'This account has been disabled.';

  @override
  String get error_network => 'Network error. Check your connection.';

  @override
  String get error_too_many_requests => 'Too many attempts. Try again later.';

  @override
  String get error_unknown => 'An unexpected error occurred.';

  @override
  String get success_title => 'Success';

  @override
  String get error_title => 'Error';

  @override
  String get chats => 'Chats';

  @override
  String get message => 'Message';

  @override
  String get calls => 'Calls';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get recents => 'Recents';

  @override
  String get name => 'Name';

  @override
  String get info => 'Info';

  @override
  String get email => 'Email';

  @override
  String get account => 'Account';

  @override
  String get privacy => 'Privacy';

  @override
  String get notifications => 'Notifications';

  @override
  String get appearance => 'Appearance';

  @override
  String get assistance => 'Assistance';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get dark_theme => 'Dark theme';

  @override
  String get help_faq => 'Help & FAQ';

  @override
  String get search => 'Search...';

  @override
  String get contact_support => 'Contact support';

  @override
  String get logout => 'Logout';

  @override
  String get choose_option => 'Choose an option';

  @override
  String get choose_from_photos => 'Choose from photos';

  @override
  String get take_photo => 'Take photo';

  @override
  String get edit_photo => 'Edit photo';

  @override
  String get photo_updated => 'Profile photo updated';

  @override
  String get undo => 'Undo';

  @override
  String get validate => 'Validate';

  @override
  String get cancel => 'Cancel';

  @override
  String get search_contact => 'Search a contact';

  @override
  String get name_or_email => 'Name or email';

  @override
  String get type_to_search_user => 'Type to search a user';

  @override
  String get no_user_found => 'No user found';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get online => 'Online';

  @override
  String get e2ee => 'End-to-End Encrypted';
}
