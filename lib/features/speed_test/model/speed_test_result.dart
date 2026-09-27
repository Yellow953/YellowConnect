import '../../../core/services/network_info_service.dart';

class SpeedTestResult {
  const SpeedTestResult({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.networkType,
    required this.testedAt,
    this.isp,
  });

  final double downloadMbps;
  final double uploadMbps;
  final NetworkType networkType;
  final DateTime testedAt;
  final String? isp;

  Map<String, Object?> toJson() => {
    'download': downloadMbps,
    'upload': uploadMbps,
    'network': networkType.name,
    'testedAt': testedAt.toIso8601String(),
    'isp': isp,
  };

  static SpeedTestResult fromJson(Map<String, Object?> json) => SpeedTestResult(
    downloadMbps: (json['download'] as num).toDouble(),
    uploadMbps: (json['upload'] as num).toDouble(),
    networkType:
        NetworkType.values.asNameMap()[json['network']] ?? NetworkType.other,
    testedAt: DateTime.parse(json['testedAt'] as String),
    isp: json['isp'] as String?,
  );
}
