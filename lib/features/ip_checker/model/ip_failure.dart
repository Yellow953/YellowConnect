enum IpFailure {
  noConnection('No internet connection.'),
  timeout('Took too long to check. Try again.'),
  badResponse('Couldn\'t check your IP right now. Try again.');

  const IpFailure(this.message);

  final String message;
}
