/// Represents either a success value or an error.
sealed class Result<T> {
  const Result();
}

/// Success wrapper for a [Result].
final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

/// Error wrapper for a [Result].
final class Err<T> extends Result<T> {
  final Object error;
  final StackTrace? stackTrace;
  const Err(this.error, [this.stackTrace]);
}
