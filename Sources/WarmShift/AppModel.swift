import AppKit
import Observation
import ServiceManagement
import WarmShiftCore

struct Settings: Codable, Equatable {
    var schedule = Schedule()
    /// Master switch from the menu. Off: the app never touches Night Shift.
    var isActive = true
    /// At `resetAt`, turn Night Shift off as well as moving the slider back to `fromStrength`.
    var turnOffDuringDay = false
}

@MainActor @Observable
final class AppModel {
    var settings: Settings {
        didSet {
            guard settings != oldValue else { return }
            save()
            lastPhase = nil  // re-apply enter-phase actions with the new times
            tick()
        }
    }
    private(set) var phase: Schedule.Phase = .day
    private(set) var currentStrength: Double?
    private(set) var nightShiftAvailable: Bool
    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            } catch {
                loginError = error.localizedDescription
            }
        }
    }
    var loginError: String?
    /// Set when WarmShift switched Night Shift's built-in schedule to Off (shown in Settings).
    private(set) var overrodeSystemSchedule = false

    private let nightShift = NightShift()
    private var lastPhase: Schedule.Phase?
    private static let defaultsKey = "settings"

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.defaultsKey),
            let saved = try? JSONDecoder().decode(Settings.self, from: data)
        {
            settings = saved
        } else {
            settings = Settings()
        }
        nightShiftAvailable = nightShift.isAvailable
        currentStrength = nightShift.strength
        start()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }

    private func start() {
        tick()
        Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(20))
                self?.tick()
            }
        }
        // Timers don't fire while asleep; catch up straight away on wake.
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
    }

    /// Applies the schedule for now. Turning Night Shift on/off only happens when a phase
    /// starts, so turning it off by hand mid-evening sticks until the next phase change.
    func tick(now: Date = .now) {
        let schedule = settings.schedule
        phase = schedule.phase(atMinutes: TimeOfDay.minutes(of: now))
        defer {
            currentStrength = nightShift.strength
            lastPhase = phase
        }
        guard settings.isActive, nightShiftAvailable else { return }

        // Night Shift's own schedule would turn it on/off and fight the ramp, so keep it Off
        // while WarmShift is in charge. Checked every tick in case it's changed in Settings.
        if let mode = nightShift.scheduleMode, mode != .off {
            nightShift.setScheduleMode(.off)
            overrodeSystemSchedule = true
        }

        let entered = !samePhaseKind(lastPhase, phase)
        if let target = schedule.strength(at: now) {
            if entered, nightShift.isEnabled != true { nightShift.setEnabled(true) }
            if abs((nightShift.strength ?? -1) - target) > 0.002 { nightShift.setStrength(target) }
        } else if entered {
            nightShift.setStrength(schedule.fromStrength)
            if settings.turnOffDuringDay { nightShift.setEnabled(false) }
        }
    }

    private func samePhaseKind(_ a: Schedule.Phase?, _ b: Schedule.Phase) -> Bool {
        switch (a, b) {
        case (.day, .day), (.holding, .holding), (.ramping, .ramping): return true
        default: return false
        }
    }

    var statusText: String {
        guard nightShiftAvailable else { return "Night Shift isn't available on this Mac" }
        guard settings.isActive else { return "Paused" }
        let s = settings.schedule
        switch phase {
        case .day: return "Daytime · ramp starts at \(format(s.rampStart))"
        case .ramping: return "Warming · reaches \(percent(s.toStrength)) at \(format(s.rampEnd))"
        case .holding: return "Holding at \(percent(s.toStrength)) until \(format(s.resetAt))"
        }
    }
}

func percent(_ v: Double) -> String { "\(Int((v * 100).rounded()))%" }

func format(_ t: TimeOfDay) -> String {
    let date = Calendar.current.date(bySettingHour: t.hour, minute: t.minute, second: 0, of: .now) ?? .now
    return date.formatted(date: .omitted, time: .shortened)
}
