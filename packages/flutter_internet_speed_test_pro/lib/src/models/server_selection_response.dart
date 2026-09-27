/// Response model for server selection operations.
///
/// Contains information about the client and available test targets.
class ServerSelectionResponse {
  /// Information about the client making the request.
  late final Client? client;

  /// List of available test targets/servers.
  late final List<Targets>? targets;

  /// Creates a new [ServerSelectionResponse] instance.
  ServerSelectionResponse({this.client, this.targets});

  /// Creates a [ServerSelectionResponse] from JSON data.
  ServerSelectionResponse.fromJson(Map<String, dynamic> json) {
    client = json['client'] != null ? Client.fromJson(json['client']) : null;
    targets = <Targets>[];
    if (json['targets'] != null) {
      json['targets'].forEach((v) {
        targets!.add(Targets.fromJson(v));
      });
    }
  }

  /// Converts the response to JSON format.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (client != null) {
      data['client'] = client!.toJson();
    }
    if (targets != null) {
      data['targets'] = targets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Represents client information for speed testing.
///
/// Contains details about the client's IP address, ISP, and location.
class Client {
  /// The client's IP address.
  late final String? ip;

  /// The Autonomous System Number (ASN).
  late final String? asn;

  /// The Internet Service Provider (ISP) name.
  late final String? isp;

  /// The client's geographical location.
  late final Location? location;

  /// Creates a new [Client] instance.
  Client({this.ip, this.asn, this.isp, this.location});

  /// Creates a [Client] from JSON data.
  Client.fromJson(Map<String, dynamic> json) {
    ip = json['ip'];
    asn = json['asn'];
    isp = json['isp'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
  }

  /// Converts the client data to JSON format.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ip'] = ip;
    data['asn'] = asn;
    data['isp'] = isp;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }
}

/// Represents geographical location information.
class Location {
  /// The city name.
  late final String? city;

  /// The country name.
  late final String? country;

  /// Creates a new [Location] instance.
  Location({this.city, this.country});

  /// Creates a [Location] from JSON data.
  Location.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    country = json['country'];
  }

  /// Converts the location data to JSON format.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['country'] = country;
    return data;
  }
}

/// Represents a test target/server.
///
/// Contains information about available speed test servers.
class Targets {
  /// The name of the target server.
  late final String? name;

  /// The URL endpoint for the target server.
  late final String? url;

  /// The geographical location of the target server.
  late final Location? location;

  /// Creates a [Targets] from JSON data.
  Targets.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
  }

  /// Converts the target data to JSON format.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }
}
