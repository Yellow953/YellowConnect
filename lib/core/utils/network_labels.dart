import 'package:flutter/material.dart';

import '../services/network_info_service.dart';

extension NetworkTypeLabels on NetworkType {
  String get label => switch (this) {
    NetworkType.wifi => 'Wi-Fi',
    NetworkType.mobile => 'Mobile data',
    NetworkType.ethernet => 'Ethernet',
    NetworkType.none => 'Offline',
    NetworkType.other => 'Other',
  };

  IconData get icon => switch (this) {
    NetworkType.wifi => Icons.wifi_rounded,
    NetworkType.mobile => Icons.signal_cellular_alt_rounded,
    NetworkType.ethernet => Icons.settings_ethernet_rounded,
    NetworkType.none => Icons.wifi_off_rounded,
    NetworkType.other => Icons.lan_outlined,
  };
}
