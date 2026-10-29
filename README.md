# WarmShift

Warm up your Mac's screen slowly through the evening instead of all at once. WarmShift sits in
the menu bar and moves Night Shift's **Less Warm ↔ More Warm** slider from the middle to fully
warm over the hours you choose, keeps it there overnight, and sets it back in the morning.

<p align="center">
  <img src="docs/images/settings.webp" width="420" alt="WarmShift settings window: start, end and reset times, start and end warmth sliders, a curve picker, a 24-hour chart of warmth, and behavior options">
</p>

## What it does

- **Warms gradually.** Night Shift moves a little every 20 seconds, so you don't see a sudden
  shift in colour.
- **Runs on your schedule.** You pick when warming starts, when it should be fully warm, and when
  to reset in the morning. Schedules that run past midnight work too.
- **Lets you pick how warm.** Choose the start and end warmth, and a steady (linear) or gentle
  (ease in and out) curve. A chart shows the whole day at a glance.
- **Takes care of the conflict with Night Shift's own schedule.** While WarmShift is on, it keeps
  the built-in Night Shift schedule switched off so the two don't fight.
- **Stays out of the way.** No Dock icon, no windows unless you open Settings, nothing sent over
  the network. It can start when you log in.

## Requirements

macOS 14 Sonoma or later, on a Mac that supports Night Shift.

## Install

There are no prebuilt downloads yet. Building it takes one command once Xcode and
[just](https://github.com/casey/just) are installed:

```bash
just install
```

That puts **WarmShift.app** in `~/Applications` and opens it. The
[installing guide](docs/Installing.md) has the details.

## Documentation

**[Read the documentation](docs/Home.md)** for how to use the app and how it works, for example:

- [How does the schedule work, and what happens after midnight?](docs/Schedule.md)
- [Why did my Night Shift schedule change to Off?](docs/Night-Shift.md)
- [Night Shift came back on after I turned it off](docs/Troubleshooting.md)

## For developers

Building, testing and the code layout are covered in the
[developer guide](docs/Developer-Guide.md).

## License

[MIT](LICENSE)
