import Testing

@testable import WarmShiftCore

private func m(_ h: Int, _ min: Int = 0) -> Double { Double(h * 60 + min) }

@Test func defaultEveningRamp() {
    let s = Schedule()  // 19:00 → 22:00, reset 07:00, 0.5 → 1.0
    #expect(s.strength(atMinutes: m(12)) == nil)
    #expect(s.strength(atMinutes: m(18, 59)) == nil)
    #expect(s.strength(atMinutes: m(19)) == 0.5)
    #expect(s.strength(atMinutes: m(20, 30)) == 0.75)
    #expect(s.strength(atMinutes: m(22)) == 1.0)
    #expect(s.strength(atMinutes: m(2)) == 1.0)
    #expect(s.strength(atMinutes: m(6, 59)) == 1.0)
    #expect(s.strength(atMinutes: m(7)) == nil)
}

@Test func rampAcrossMidnight() {
    let s = Schedule(rampStart: .init(hour: 23, minute: 0), rampEnd: .init(hour: 1, minute: 0))
    #expect(s.isValid)
    #expect(s.strength(atMinutes: m(0)) == 0.75)
    #expect(s.strength(atMinutes: m(1)) == 1.0)
    #expect(s.strength(atMinutes: m(22)) == nil)
}

@Test func easeInOutKeepsEndsAndMidpoint() {
    let s = Schedule(curve: .easeInOut)
    #expect(s.strength(atMinutes: m(19)) == 0.5)
    #expect(s.strength(atMinutes: m(20, 30)) == 0.75)
    #expect(s.strength(atMinutes: m(19, 30))! < 0.5 + 0.25 / 3)  // slower start than linear
}

@Test func resetBeforeRampEndIsInvalid() {
    let s = Schedule(rampEnd: .init(hour: 8, minute: 0), resetAt: .init(hour: 7, minute: 0))
    #expect(!s.isValid)
}

@Test func timeOfDayWraps() {
    #expect(TimeOfDay(minutes: -30) == TimeOfDay(hour: 23, minute: 30))
    #expect(TimeOfDay(minutes: 1440 + 5).minutes == 5)
}
