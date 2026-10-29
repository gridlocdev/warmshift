import Foundation

/// A time of day as minutes since midnight (0..<1440).
public struct TimeOfDay: Codable, Hashable, Sendable, Comparable {
    public var minutes: Int

    public init(minutes: Int) { self.minutes = ((minutes % 1440) + 1440) % 1440 }
    public init(hour: Int, minute: Int) { self.init(minutes: hour * 60 + minute) }

    public var hour: Int { minutes / 60 }
    public var minute: Int { minutes % 60 }

    public static func < (a: TimeOfDay, b: TimeOfDay) -> Bool { a.minutes < b.minutes }

    /// Minutes (with fractional seconds) since midnight for `date` in `calendar`'s time zone.
    public static func minutes(of date: Date, calendar: Calendar = .current) -> Double {
        let c = calendar.dateComponents([.hour, .minute, .second], from: date)
        return Double((c.hour ?? 0) * 60 + (c.minute ?? 0)) + Double(c.second ?? 0) / 60
    }
}

public enum Curve: String, Codable, CaseIterable, Sendable {
    case linear
    case easeInOut

    public func apply(_ t: Double) -> Double {
        let t = min(max(t, 0), 1)
        switch self {
        case .linear: return t
        case .easeInOut: return t * t * (3 - 2 * t)  // smoothstep
        }
    }
}

/// The evening ramp: warmth goes from `fromStrength` at `rampStart` to `toStrength` at
/// `rampEnd`, holds there until `resetAt` (next morning), then the day phase begins.
/// Strengths are Night Shift's slider: 0 = less warm, 1 = more warm.
public struct Schedule: Codable, Hashable, Sendable {
    public var rampStart: TimeOfDay
    public var rampEnd: TimeOfDay
    public var resetAt: TimeOfDay
    public var fromStrength: Double
    public var toStrength: Double
    public var curve: Curve

    public init(
        rampStart: TimeOfDay = .init(hour: 19, minute: 0),
        rampEnd: TimeOfDay = .init(hour: 22, minute: 0),
        resetAt: TimeOfDay = .init(hour: 7, minute: 0),
        fromStrength: Double = 0.5,
        toStrength: Double = 1.0,
        curve: Curve = .linear
    ) {
        self.rampStart = rampStart
        self.rampEnd = rampEnd
        self.resetAt = resetAt
        self.fromStrength = fromStrength
        self.toStrength = toStrength
        self.curve = curve
    }

    public enum Phase: Equatable, Sendable {
        /// Between `resetAt` and `rampStart`: the app leaves Night Shift alone.
        case day
        /// Ramping; `progress` is 0...1 through the ramp.
        case ramping(progress: Double)
        /// After `rampEnd`, before `resetAt`.
        case holding
    }

    /// Minutes from `rampStart` forward to `t`, wrapping past midnight.
    private func offset(_ t: Double) -> Double {
        let d = (t - Double(rampStart.minutes)).truncatingRemainder(dividingBy: 1440)
        return d < 0 ? d + 1440 : d
    }

    private var rampLength: Double { offset(Double(rampEnd.minutes)) }
    private var nightLength: Double {
        let n = offset(Double(resetAt.minutes))
        return n == 0 ? 1440 : n  // reset == start means "never reset"
    }

    /// Whether the times are in order: start → end → reset, going forward through the night.
    public var isValid: Bool { rampLength <= nightLength }

    public func phase(atMinutes t: Double) -> Phase {
        let d = offset(t)
        let ramp = min(rampLength, nightLength)
        if d < ramp { return .ramping(progress: d / ramp) }
        if d < nightLength { return .holding }
        return .day
    }

    /// Night Shift strength for minute-of-day `t`, or nil in the day phase.
    public func strength(atMinutes t: Double) -> Double? {
        switch phase(atMinutes: t) {
        case .day: return nil
        case .holding: return toStrength
        case .ramping(let p): return fromStrength + (toStrength - fromStrength) * curve.apply(p)
        }
    }

    public func strength(at date: Date, calendar: Calendar = .current) -> Double? {
        strength(atMinutes: TimeOfDay.minutes(of: date, calendar: calendar))
    }
}
