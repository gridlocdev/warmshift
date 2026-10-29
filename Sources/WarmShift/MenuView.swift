import SwiftUI

struct MenuView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        @Bindable var model = model
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("WarmShift").font(.headline)
                Spacer()
                Toggle("", isOn: $model.settings.isActive).toggleStyle(.switch).labelsHidden()
            }
            Text(model.statusText).font(.callout).foregroundStyle(.secondary)

            if let strength = model.currentStrength {
                VStack(alignment: .leading, spacing: 4) {
                    Gauge(value: strength) {
                        EmptyView()
                    } currentValueLabel: {
                        EmptyView()
                    }
                    .tint(Gradient(colors: [.yellow, .orange]))
                    HStack {
                        Text("Less warm")
                        Spacer()
                        Text("Night Shift \(percent(strength))").monospacedDigit()
                        Spacer()
                        Text("More warm")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }

            Divider()
            HStack {
                Button("Settings…") {
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "settings")
                }
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
            }
        }
        .padding(14)
        .frame(width: 280)
        .onAppear { model.tick() }
    }
}
