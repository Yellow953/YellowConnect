import Flutter
import UIKit

/// Hands `yellowconnect://` deep links to Dart, whether they come from a URL
/// or from a widget button (LaunchActionIntent).
final class LaunchActionPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  private static let scheme = "yellowconnect"

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
    registrar.addSceneDelegate(instance)

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

  // Cold start: the link arrives with the scene's connection options.
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    guard let url = connectionOptions?.urlContexts.first?.url, Self.isOurs(url) else {
      return false
    }
    receive(url.absoluteString)
    return true
  }

  // Warm start: the app is already running.
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let url = URLContexts.first?.url, Self.isOurs(url) else { return false }
    receive(url.absoluteString)
    return true
  }

  private static func isOurs(_ url: URL) -> Bool { url.scheme == scheme }
}
