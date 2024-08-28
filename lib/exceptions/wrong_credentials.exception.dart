class WrongCredentialsException implements Exception {
  final String message;

  WrongCredentialsException(this.message);
}