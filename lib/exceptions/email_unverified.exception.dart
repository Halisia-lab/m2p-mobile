class EmailUnverifiedException implements Exception {
  final String message;

  EmailUnverifiedException(this.message);
}