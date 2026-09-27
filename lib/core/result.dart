/// Typed outcome of an operation that can fail with a known failure type [F].
sealed class Result<T, F> {
  const Result();
}

final class Ok<T, F> extends Result<T, F> {
  const Ok(this.value);

  final T value;
}

final class Err<T, F> extends Result<T, F> {
  const Err(this.failure);

  final F failure;
}
