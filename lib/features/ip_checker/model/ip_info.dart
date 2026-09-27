class IpInfo {
  const IpInfo({
    required this.ip,
    required this.fetchedAt,
    this.city,
    this.country,
    this.flag,
    this.isp,
    this.timezone,
  });

  final String ip;
  final DateTime fetchedAt;
  final String? city;
  final String? country;
  final String? flag;
  final String? isp;
  final String? timezone;

  String? get location => switch ((city, country)) {
    (final c?, final k?) => '$c, $k',
    (final c?, null) => c,
    (null, final k?) => k,
    _ => null,
  };
}
