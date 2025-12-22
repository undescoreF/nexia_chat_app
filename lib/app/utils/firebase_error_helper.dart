import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

String firebaseErrorMessage(BuildContext context, String code) {
  final l = AppLocalizations.of(context)!;
  switch (code) {
    case 'invalid-email':
      return l.error_invalid_email;
    case 'user-not-found':
      return l.error_user_not_found;
    case 'wrong-password':
      return l.error_wrong_password;
    case 'email-already-in-use':
      return l.error_email_already_in_use;
    case 'weak-password':
      return l.error_weak_password;
    case 'network-request-failed':
      return l.error_network;
    default:
      return l.error_unknown;
  }
}
