class AccountDisabledException implements Exception {
  final String message;

  AccountDisabledException(this.message);
}