T except<T>(T? object, [String? message]) {
  if (object == null) {
    throw Exception(message);
  }
  return object;
}
