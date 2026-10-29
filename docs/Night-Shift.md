# WarmShift and Night Shift

**Night Shift** is part of macOS. It makes the screen's colours warmer (more orange, less blue)
and has its own settings in System Settings → Displays → **Night Shift…**:

- **Schedule**: Off, Sunset to Sunrise, or Custom times.
- **Turn on until tomorrow**: an on/off switch.
- **Colour temperature**: a slider from *Less Warm* to *More Warm*.

On its own, Night Shift snaps to one fixed warmth when it turns on. WarmShift adds the missing
piece: it moves that slider gradually through the evening.

## What WarmShift changes

WarmShift only uses Night Shift's own three settings. It doesn't install anything, change your
display's colour profile, or draw anything over the screen.

| Setting | When WarmShift changes it |
|---|---|
| **Colour temperature** slider | Every 20 seconds during warming and holding, if it isn't already at the right value. Once more at the start of the day, back to the start warmth. |
| **On/off** | On when warming starts. Off when the day starts, only if *Turn Night Shift off during the day* is on. |
| **Schedule** | Set to **Off** whenever WarmShift is on (see below). |

When you pause WarmShift from the menu, or quit it, it changes nothing at all.

## Why Night Shift's schedule is set to Off

If Night Shift's own schedule were still running, the two would compete. At sunset, for example,
macOS would turn Night Shift on at full slider strength while WarmShift was trying to start in
the middle. And at the end of a custom schedule macOS would switch it off in the middle of
WarmShift's night.

So while WarmShift is switched on, it makes sure Night Shift's schedule is **Off** and does the
scheduling itself. It checks every 20 seconds, so if you set a schedule again in System
Settings, WarmShift switches it back. The settings window shows a note the first time this
happens:

> Switched Night Shift's own schedule to Off so it doesn't fight WarmShift.

## Going back

To let macOS run Night Shift again:

1. Click WarmShift's menu bar icon and turn the switch off (or choose **Quit**).
2. Open System Settings → Displays → **Night Shift…** and pick a **Schedule** again.

WarmShift doesn't remember which schedule you had before, so you'll need to set your times again.

## Privacy

WarmShift makes no network connections. Its settings are stored on your Mac in the standard
preferences store (`dev.gridloc.warmshift`). It reads nothing but Night Shift's state.

## How it talks to Night Shift

Apple doesn't offer a public way for apps to control Night Shift. WarmShift uses the same
internal macOS component that System Settings uses (`CBBlueLightClient` in the CoreBrightness
framework). This is common for Night Shift tools, but Apple could change it in a future macOS
update. If that happens, WarmShift notices and shows *Night Shift isn't available on this Mac*
in its menu instead of guessing; see [Troubleshooting](Troubleshooting.md).

---
Next: [Troubleshooting](Troubleshooting.md)
