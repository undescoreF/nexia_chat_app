enum AlertType { success, error, info }

class AuthResult {
  final String messageKey;
  final AlertType type;

  AuthResult({required this.messageKey, required this.type});
}
