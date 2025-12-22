class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Storage exception']);

  @override
  String toString() => 'StorageException: $message';
}
