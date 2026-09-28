import SwiftUI
import WidgetKit

/// Home screen widgets. Each tap opens the app with a
/// `yellowconnect://widget/<path>` action (see LaunchActionPlugin).
@main
struct YellowConnectWidgets: WidgetBundle {
  var body: some Widget {
    QuickActionsWidget()
  }
}

/// iOS has no 4x1 widget like Android, so the medium size holds a header and
/// the same row of two tiles, each its own tap target.
struct QuickActionsWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "QuickActionsWidget", provider: StaticProvider()) { _ in
      QuickActionsView()
    }
    .configurationDisplayName("Quick Actions")
    .description("Connect the VPN or start a speed test in one tap.")
    .supportedFamilies([.systemMedium])
  }
}

private enum Brand {
  static let black = Color(red: 0x0D / 255, green: 0x0D / 255, blue: 0x0F / 255)
  static let tile = Color(red: 0xF1 / 255, green: 0xF1 / 255, blue: 0xF3 / 255)
  static let gray = Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x8B / 255)
}

/// White card: a slim header, then two rounded tiles side by side, Connect
/// (dark, the primary action) and Speed (light), matching the Android widget.
struct QuickActionsView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 8) {
        Image(systemName: "shield.fill")
          .font(.system(size: 11, weight: .bold))
          .foregroundStyle(.white)
          .frame(width: 22, height: 22)
          .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous).fill(Brand.black)
          )
        Text("Yellow Connect")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(Brand.black)
        Spacer(minLength: 0)
        Text("Quick actions")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(Brand.gray)
      }
      .padding(.horizontal, 4)
      HStack(spacing: 8) {
        ActionTile(title: "Connect", symbol: "power", path: "vpn-connect", dark: true)
        ActionTile(title: "Speed", symbol: "speedometer", path: "speed-test", dark: false)
      }
    }
    .containerBackground(.white, for: .widget)
  }
}

private struct ActionTile: View {
  let title: String
  let symbol: String
  let path: String
  let dark: Bool

  var body: some View {
    Button(intent: LaunchActionIntent(path: path)) {
      HStack(spacing: 10) {
        Image(systemName: symbol)
          .font(.system(size: 13, weight: .bold))
          .foregroundStyle(dark ? .white : Brand.black)
          .frame(width: 30, height: 30)
          .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
              .fill(dark ? .white.opacity(0.15) : .white)
          )
        Text(title)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(dark ? .white : Brand.black)
          .lineLimit(1)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .fill(dark ? Brand.black : Brand.tile)
      )
    }
    .buttonStyle(.plain)
  }
}

/// The widgets show fixed content, so one entry that never refreshes.
struct StaticProvider: TimelineProvider {
  struct Entry: TimelineEntry {
    let date: Date
  }

  func placeholder(in context: Context) -> Entry { Entry(date: .now) }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    completion(Entry(date: .now))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    completion(Timeline(entries: [Entry(date: .now)], policy: .never))
  }
}
