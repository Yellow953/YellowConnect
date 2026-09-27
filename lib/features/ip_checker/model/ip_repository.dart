import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/constants.dart';
import '../../../core/result.dart';
import 'ip_failure.dart';
import 'ip_info.dart';

class IpRepository {
  IpRepository([http.Client? client]) : _client = client ?? http.Client();

  final http.Client _client;

  /// Looks up the IP with location details, falling back to a plain IP.
  Future<Result<IpInfo, IpFailure>> fetchPublicIp() async {
    try {
      return Ok(await _fetchDetails());
    } catch (_) {
      // Details service down or rate-limited; try the plain lookup.
    }
    try {
      return Ok(await _fetchPlain());
    } on TimeoutException {
      return const Err(IpFailure.timeout);
    } on SocketException {
      return const Err(IpFailure.noConnection);
    } on http.ClientException {
      return const Err(IpFailure.noConnection);
    } on FormatException {
      return const Err(IpFailure.badResponse);
    }
  }

  Future<IpInfo> _fetchDetails() async {
    final json = await _getJson(AppConstants.ipDetailsUrl);
    final ip = json['ip'];
    if (json['success'] != true || ip is! String) {
      throw const FormatException('ipwho.is lookup failed');
    }
    final flag = json['flag'];
    final connection = json['connection'];
    final timezone = json['timezone'];
    return IpInfo(
      ip: ip,
      fetchedAt: DateTime.now(),
      city: json['city'] as String?,
      country: json['country'] as String?,
      flag: flag is Map ? flag['emoji'] as String? : null,
      isp: connection is Map ? connection['isp'] as String? : null,
      timezone: timezone is Map ? timezone['id'] as String? : null,
    );
  }

  Future<IpInfo> _fetchPlain() async {
    final ip = (await _getJson(AppConstants.ipFallbackUrl))['ip'];
    if (ip is! String || ip.isEmpty) {
      throw const FormatException('ipify lookup failed');
    }
    return IpInfo(ip: ip, fetchedAt: DateTime.now());
  }

  Future<Map<String, dynamic>> _getJson(Uri url) async {
    final response = await _client
        .get(url)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw FormatException('HTTP ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}
