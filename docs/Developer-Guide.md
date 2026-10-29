# Developer guide

WarmShift is Swift 6 and SwiftUI, built with Swift Package Manager. There's no Xcode project: you
can work in VS Code, or any editor, and build from the command line. The rules in `CLAUDE.md` at
the repository root apply to everyone working on it.

## Getting set up

You need Xcode (for its Swift toolchain and SDK) and [just](https://github.com/casey/just).

```bash
just build        # compile (debug)
just test         # run the schedule tests
just run          # build a debug WarmShift.app and open it
just run-attached # same, with logs in the terminal
just install      # release build into ~/Applications
just fmt          # format with swift-format
```

Recipes call `xcrun swift`, Xcode's toolchain. A toolchain installed with swiftly can fail
against the current macOS SDK, so don't use bare `swift`.

**Running the app changes your real Night Shift settings**, including switching its built-in
schedule to Off. Unit tests don't touch Night Shift.

### VS Code

Install the recommended extensions (Swift and just) when VS Code offers them, then choose the
Xcode toolchain: Command Palette → **Swift: Select Toolchain**. `.vscode/launch.json` has debug
and release launch configurations, but they run the bare executable, not the `.app` bundle, so
launch at login won't work from there.

## Layout

```
Sources/WarmShiftCore/      pure Swift, no AppKit: unit-testable
  Schedule.swift            TimeOfDay, Curve, Schedule (phases, interpolation, midnight wrap)
Sources/WarmShift/          the app
  WarmShiftApp.swift        MenuBarExtra + the settings Window scene
  AppModel.swift            settings (UserDefaults JSON), the 20 s tick, wake handling, login item
  NightShift.swift          CoreBrightness bridge
  MenuView.swift            menu bar popover
  SettingsView.swift        settings form and the 24 h chart (Swift Charts)
Tests/WarmShiftCoreTests/   Swift Testing tests for Schedule
Resources/Info.plist        bundle info; LSUIElement hides the Dock icon
Resources/icon.icns         app icon, generated from assets/icon.svg
assets/icon.svg             app icon source
scripts/bundle.sh           builds and signs build/WarmShift.app
scripts/make-icons.sh       renders the icon (just icons)
docs/                       these pages
```

## How a tick works

`AppModel.tick()` runs every 20 seconds, on wake (`NSWorkspace.didWakeNotification`), when the
menu opens, and after any settings change.

1. Work out the current phase (`day`, `ramping`, `holding`) from the local time.
2. If paused or Night Shift is unavailable, stop.
3. If Night Shift's built-in schedule isn't Off, set it to Off.
4. If this is a different phase from the last tick ("entered"):
   - night (ramping/holding): turn Night Shift on;
   - day: set the slider to the start warmth, and turn Night Shift off if the user asked.
5. During the night, set the slider if it's more than 0.002 away from the target.

Settings changes reset the remembered phase, so step 4 runs again with the new times.

## Schedule math

`Schedule` measures every time as minutes forward from `rampStart`, wrapping at 1440, which is
how midnight crossings work without special cases. `phase(atMinutes:)` and
`strength(atMinutes:)` are pure functions of the minute of day; put new schedule behaviour there
and cover it in `ScheduleTests.swift`.

## The Night Shift bridge

Night Shift has no public API. `NightShift.swift` loads
`/System/Library/PrivateFrameworks/CoreBrightness.framework`, creates a `CBBlueLightClient`, and
calls these Objective-C methods through `method(for:)` cast to `@convention(c)` function types:

| Selector | Use |
|---|---|
| `getStrength:` / `setStrength:commit:` | The Less Warm ↔ More Warm slider, 0…1. `commit: true` saves it as the user's value. |
| `setEnabled:` | Night Shift on/off. |
| `setMode:` | Built-in schedule: 0 Off, 1 Sunset to Sunrise, 2 Custom. |
| `getBlueLightStatus:` | Fills a status struct. Only `enabled` (byte 1) and `mode` (Int32 at byte 4) are read, from a deliberately oversized buffer. |

`isAvailable` checks that the class exists and responds to all five selectors. If any check
fails, the app shows *Night Shift isn't available* and makes no calls. When a macOS update comes
out, re-check these first.

## App icon

The icon is drawn by hand in `assets/icon.svg`: a white campfire on an orange gradient tile,
on Apple's 1024 icon grid (an 824-unit tile at 100,100 with a transparent margin). Since
WarmShift has no Dock icon, it mostly shows in Finder and in System Settings → Login Items.

After editing the SVG, run `just icons` (needs Inkscape: `brew install --cask inkscape`). It
regenerates `Resources/icon.icns`, which is committed so builds don't need Inkscape.

## Signing

`scripts/bundle.sh` signs with the first Apple Development or Developer ID identity in your
keychain, or ad-hoc (`-`) if there isn't one. Override with `SIGN_IDENTITY="…" just install`.
With ad-hoc signing, macOS may treat each rebuild as a new app, so the login item may need
switching off and on again.
