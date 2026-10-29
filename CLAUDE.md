# warmshift

macOS menu bar app (SwiftPM, no Xcode project, `LSUIElement`). See README.md.

- Build with `xcrun swift build` / `just …`, never bare `swift` (swiftly toolchain breaks on the current SDK).
- Swift 6 strict concurrency: `AppModel` and `NightShift` are `@MainActor`.
- Schedule math lives in `WarmShiftCore` (no AppKit) so it stays unit-testable; add tests there for schedule changes.
- Night Shift goes through private `CBBlueLightClient` selectors called via `method(for:)` + `@convention(c)` casts. The status struct is read by byte offset (enabled = byte 1, mode = Int32 at 4).
- While active the app forces Night Shift's built-in schedule to Off; it toggles Night Shift on/off only on phase changes, so manual changes stick until the next phase.
- Running the app changes the user's real Night Shift settings; ask before launching it just to test.
