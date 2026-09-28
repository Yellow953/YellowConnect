import 'dart:async';

import 'package:flutter/services.dart';

import '../../../core/constants.dart';
import 'launch_action.dart';

/// Receives `yellowconnect://` deep links from the native side (home screen
/// widgets on Android and iOS).
class LaunchActionRepository {
  LaunchActionRepository([MethodChannel? channel])
    : _channel =
          channel ?? const MethodChannel(AppConstants.launchActionChannel);

  final MethodChannel _channel;
  final _actions = StreamController<LaunchAction>.broadcast();

  /// Actions that arrive while the app is already running.
  Stream<LaunchAction> get actions => _actions.stream;

  /// The action the app was cold-started with, if any. Also starts listening
  /// for later ones, so call it once at startup.
  Future<LaunchAction?> initialAction() async {
    _channel.setMethodCallHandler(_onCall);
    try {
      return LaunchAction.fromUri(
        await _channel.invokeMethod<String>('getInitialUri'),
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> _onCall(MethodCall call) async {
    if (call.method != 'onUri') return;
    if (LaunchAction.fromUri(call.arguments as String?) case final action?) {
      _actions.add(action);
    }
  }
}
