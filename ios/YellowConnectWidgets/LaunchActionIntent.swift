import AppIntents
import Foundation

/// A widget button tap. Compiled into both the app and the widget extension;
/// because `openAppWhenRun` is set, `perform()` runs in the app, which hands
/// the deep link to LaunchActionPlugin through [LaunchActionInbox].
@available(iOS 17.0, *)
struct LaunchActionIntent: AppIntent {
  static var title: LocalizedStringResource = "Open Yellow Connect"
  static var openAppWhenRun = true
  static var isDiscoverable = false

  /// Last segment of the `yellowconnect://widget/<path>` deep link.
  @Parameter(title: "Action")
  var path: String

  init() {}

  init(path: String) {
    self.path = path
  }

  func perform() async throws -> some IntentResult {
    let uri = "yellowconnect://widget/\(path)"
    await MainActor.run { LaunchActionInbox.deliver(uri) }
    return .result()
  }
}

/// Holds a tapped action until the app's plugin is ready to take it.
enum LaunchActionInbox {
  static var handler: ((String) -> Void)?
  static var pending: String?

  static func deliver(_ uri: String) {
    if let handler {
      handler(uri)
    } else {
      pending = uri
    }
  }
}
