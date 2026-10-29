import Foundation
import ObjectiveC

/// Night Shift through `CBBlueLightClient` in the private CoreBrightness framework: the same
/// object System Settings uses. `strength` is the "Less Warm ↔ More Warm" slider (0...1).
/// No public API exists for this; if Apple changes it, `isAvailable` turns false.
@MainActor
final class NightShift {
    /// System Settings → Displays → Night Shift → Schedule.
    enum ScheduleMode: Int32 {
        case off = 0
        case sunsetToSunrise = 1
        case custom = 2
    }

    private let client: NSObject?

    private static let setStrengthSel = Selector(("setStrength:commit:"))
    private static let getStrengthSel = Selector(("getStrength:"))
    private static let setEnabledSel = Selector(("setEnabled:"))
    private static let setModeSel = Selector(("setMode:"))
    private static let statusSel = Selector(("getBlueLightStatus:"))

    init() {
        dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_NOW)
        let type = NSClassFromString("CBBlueLightClient") as? NSObject.Type
        client = type?.init()
    }

    var isAvailable: Bool {
        guard let client else { return false }
        return [Self.setStrengthSel, Self.getStrengthSel, Self.setEnabledSel, Self.setModeSel, Self.statusSel]
            .allSatisfy { client.responds(to: $0) }
    }

    var strength: Double? {
        guard isAvailable, let client else { return nil }
        typealias Fn = @convention(c) (NSObject, Selector, UnsafeMutablePointer<Float>) -> Bool
        let fn = unsafeBitCast(client.method(for: Self.getStrengthSel), to: Fn.self)
        var value: Float = 0
        return fn(client, Self.getStrengthSel, &value) ? Double(value) : nil
    }

    /// `commit: true` saves it as the user's slider value, so it shows in System Settings.
    func setStrength(_ value: Double) {
        guard isAvailable, let client else { return }
        typealias Fn = @convention(c) (NSObject, Selector, Float, Bool) -> Bool
        let fn = unsafeBitCast(client.method(for: Self.setStrengthSel), to: Fn.self)
        _ = fn(client, Self.setStrengthSel, Float(min(max(value, 0), 1)), true)
    }

    func setEnabled(_ on: Bool) {
        guard isAvailable, let client else { return }
        typealias Fn = @convention(c) (NSObject, Selector, Bool) -> Bool
        let fn = unsafeBitCast(client.method(for: Self.setEnabledSel), to: Fn.self)
        _ = fn(client, Self.setEnabledSel, on)
    }

    func setScheduleMode(_ mode: ScheduleMode) {
        guard isAvailable, let client else { return }
        typealias Fn = @convention(c) (NSObject, Selector, Int32) -> Bool
        let fn = unsafeBitCast(client.method(for: Self.setModeSel), to: Fn.self)
        _ = fn(client, Self.setModeSel, mode.rawValue)
    }

    /// The status struct starts `{ BOOL active; BOOL enabled; BOOL sunSchedulePermitted;
    /// int mode; … }`, so `enabled` is byte 1 and `mode` an Int32 at byte 4. The buffer is
    /// oversized on purpose since the rest of the struct isn't ours to rely on.
    private func status() -> (enabled: Bool, mode: ScheduleMode?)? {
        guard isAvailable, let client else { return nil }
        typealias Fn = @convention(c) (NSObject, Selector, UnsafeMutableRawPointer) -> Bool
        let fn = unsafeBitCast(client.method(for: Self.statusSel), to: Fn.self)
        var buffer = [UInt8](repeating: 0, count: 128)
        let ok = buffer.withUnsafeMutableBytes { fn(client, Self.statusSel, $0.baseAddress!) }
        guard ok else { return nil }
        let mode = buffer.withUnsafeBytes { $0.load(fromByteOffset: 4, as: Int32.self) }
        return (buffer[1] != 0, ScheduleMode(rawValue: mode))
    }

    var isEnabled: Bool? { status()?.enabled }
    var scheduleMode: ScheduleMode? { status()?.mode }
}
