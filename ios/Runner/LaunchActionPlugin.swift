import Flutter
import UIKit

/// Hands widget button taps (LaunchActionIntent) to Dart as
/// `yellowconnect://` links. The scheme is deliberately not registered as a
/// URL type, so other apps and web pages can't trigger these actions.
final class LaunchActionPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  private var initialUri: String?
  /// Dart has asked for the initial link, so later ones go straight to it.
  private var dartReady = false

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "yellowconnect/launch_action",
      binaryMessenger: registrar.messenger()
    )
    let instance = LaunchActionPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)

    if let pending = LaunchActionInbox.pending {
      instance.initialUri = pending
      LaunchActionInbox.pending = nil
    }
    LaunchActionInbox.handler = { [weak instance] uri in instance?.receive(uri) }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getInitialUri" else {
      result(FlutterMethodNotImplemented)
      return
    }
    result(initialUri)
    initialUri = nil
    dartReady = true
  }

  private func receive(_ uri: String) {
    if dartReady {
      channel.invokeMethod("onUri", arguments: uri)
    } else {
      initialUri = uri
    }
  }
}
