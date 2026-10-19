// core/failures.dart

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
