import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Local persistence failure (Hive / disk)
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Local storage error']);
}

/// Fallback failure for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
