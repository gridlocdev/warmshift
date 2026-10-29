import Charts
import SwiftUI
import WarmShiftCore

struct SettingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Form {
            Section("Schedule") {
                timePicker("Start warming at", $model.settings.schedule.rampStart)
                timePicker("Fully warm by", $model.settings.schedule.rampEnd)
                timePicker("Reset in the morning at", $model.settings.schedule.resetAt)
                if !model.settings.schedule.isValid {
                    Label("Reset must come after \"Fully warm by\".", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }

            Section("Warmth") {
                strengthSlider("Start", $model.settings.schedule.fromStrength)
                strengthSlider("End", $model.settings.schedule.toStrength)
                Picker("Curve", selection: $model.settings.schedule.curve) {
                    Text("Linear").tag(Curve.linear)
                    Text("Ease in and out").tag(Curve.easeInOut)
                }
                ScheduleChart(schedule: model.settings.schedule)
                    .frame(height: 120)
            }

            Section("Behavior") {
                Toggle("Turn Night Shift off during the day", isOn: $model.settings.turnOffDuringDay)
                Toggle("Launch at login", isOn: $model.launchAtLogin)
                if let error = model.loginError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                if model.overrodeSystemSchedule {
                    Label("Switched Night Shift's own schedule to Off so it doesn't fight WarmShift.", systemImage: "info.circle")
                        .font(.caption)
                }
                Text(
                    "WarmShift turns Night Shift on when warming starts and drives its Less Warm ↔ More Warm slider. In the morning it puts the slider back to the start value. While the schedule is on, it keeps Night Shift's built-in schedule (System Settings → Displays → Night Shift) set to Off."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func timePicker(_ title: String, _ time: Binding<TimeOfDay>) -> some View {
        let date = Binding<Date>(
            get: {
                Calendar.current.date(bySettingHour: time.wrappedValue.hour, minute: time.wrappedValue.minute, second: 0, of: .now) ?? .now
            },
            set: {
                let c = Calendar.current.dateComponents([.hour, .minute], from: $0)
                time.wrappedValue = TimeOfDay(hour: c.hour ?? 0, minute: c.minute ?? 0)
            }
        )
        return DatePicker(title, selection: date, displayedComponents: .hourAndMinute)
    }

    private func strengthSlider(_ title: String, _ value: Binding<Double>) -> some View {
        LabeledContent(title) {
            HStack {
                Slider(value: value, in: 0...1, step: 0.05)
                Text(percent(value.wrappedValue)).monospacedDigit().frame(width: 40, alignment: .trailing)
            }
        }
    }
}

/// Warmth across 24 hours starting at noon, so the night reads left to right.
private struct ScheduleChart: View {
    let schedule: Schedule

    var body: some View {
        let points = stride(from: 0.0, through: 1440, by: 10).map { offset -> (Double, Double?) in
            (offset, schedule.strength(atMinutes: (offset + 720).truncatingRemainder(dividingBy: 1440)))
        }
        Chart {
            ForEach(points, id: \.0) { point in
                if let s = point.1 {
                    AreaMark(x: .value("Time", point.0), y: .value("Warmth", s))
                        .foregroundStyle(.orange.gradient.opacity(0.6))
                }
            }
        }
        .chartYScale(domain: 0...1)
        .chartXScale(domain: 0...1440)
        .chartXAxis {
            AxisMarks(values: [0, 360, 720, 1080, 1440]) { v in
                AxisGridLine()
                AxisValueLabel {
                    let minutes = Int(v.as(Double.self) ?? 0) + 720
                    Text(format(TimeOfDay(minutes: minutes)))
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 0.5, 1]) { v in
                AxisGridLine()
                AxisValueLabel { Text(percent(v.as(Double.self) ?? 0)) }
            }
        }
    }
}
