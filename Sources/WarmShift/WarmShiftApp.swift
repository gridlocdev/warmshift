import SwiftUI

@main
struct WarmShiftApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuView().environment(model)
        } label: {
            Image(systemName: model.phase == .day || !model.settings.isActive ? "sun.max" : "moon.stars")
        }
        .menuBarExtraStyle(.window)

        Window("WarmShift Settings", id: "settings") {
            SettingsView().environment(model)
        }
        .windowResizability(.contentSize)
    }
}
