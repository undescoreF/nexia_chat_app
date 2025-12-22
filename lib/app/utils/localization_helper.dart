import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

String getLocalizedMessage(BuildContext context, String key, {String? email}) {
  final loc = AppLocalizations.of(context)!;

  switch (key) {
    case "register_email_sent":
      return loc.register_email_sent(email ?? "");
    case "invalid-email":
      return loc.error_invalid_email;
    case "user-not-found":
      return loc.error_user_not_found;
    case "wrong-password":
      return loc.error_wrong_password;
    case "login_email_not_verified":
      return loc.login_email_not_verified;
    case "email-already-in-use":
      return loc.error_email_already_in_use;
    case "login_success":
      return loc.login_success;
    default:
      return loc.error_unknown;
  }
}
