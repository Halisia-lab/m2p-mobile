class StorageNotFoundException implements Exception {
  final String message;

  StorageNotFoundException(this.message);
}