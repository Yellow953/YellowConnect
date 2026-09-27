import 'dart:ui';

import '../../../core/theme/app_colors.dart';
import '../model/connection_status.dart';

extension ConnectionStatusStyle on ConnectionStatus {
  String get label => switch (this) {
    ConnectionStatus.connected => 'Connected',
    ConnectionStatus.connecting => 'Connecting',
    ConnectionStatus.disconnecting => 'Disconnecting',
    ConnectionStatus.disconnected => 'Off',
  };

  /// Label for the button that changes this state.
  String get actionLabel => switch (this) {
    ConnectionStatus.connected => 'Disconnect',
    ConnectionStatus.connecting => 'Connecting…',
    ConnectionStatus.disconnecting => 'Disconnecting…',
    ConnectionStatus.disconnected => 'Connect',
  };

  Color get dotColor => switch (this) {
    ConnectionStatus.connected => AppColors.green,
    ConnectionStatus.connecting ||
    ConnectionStatus.disconnecting => AppColors.yellow,
    ConnectionStatus.disconnected => AppColors.text2,
  };

  bool get isLit => this == ConnectionStatus.connected;
}
