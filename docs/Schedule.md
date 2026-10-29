# How the schedule works

You set three times, and they split the day into three parts.

| Part | From → to | What WarmShift does |
|---|---|---|
| **Warming** | *Start warming at* → *Fully warm by* | Turns Night Shift on, then moves the slider from the start warmth to the end warmth |
| **Holding** | *Fully warm by* → *Reset in the morning at* | Keeps the slider at the end warmth |
| **Day** | *Reset in the morning at* → *Start warming at* | Moves the slider back to the start warmth once, then leaves Night Shift alone |

With the default settings (7:00 PM, 10:00 PM, 7:00 AM, 50% → 100%, linear):

| Time | Warmth |
|---|---|
| 6:59 PM | not touched (day) |
| 7:00 PM | 50% |
| 7:45 PM | 62.5% |
| 8:30 PM | 75% |
| 9:15 PM | 87.5% |
| 10:00 PM | 100% |
| 3:00 AM | 100% |
| 7:00 AM | back to 50% |

WarmShift updates Night Shift every 20 seconds while warming, so each step is far too small to
notice.

## Crossing midnight

Times are always read forward from **Start warming at**, so any part can run past midnight. These
all work:

- Start 11:00 PM, fully warm by 1:00 AM, reset 8:00 AM. At midnight the screen is halfway.
- Start 5:00 PM, fully warm by 12:00 AM, reset 7:00 AM (the screenshot in
  [Using the app](Using-the-App.md#the-settings-window)).
- Start 9:00 PM, fully warm by 9:00 PM: warmth jumps straight to the end value with no ramp.

The one rule: going forward from the start time, **Fully warm by** must come before (or at)
**Reset in the morning at**. Otherwise the night would end before the ramp finishes, and the
settings window shows a warning.

If you set the reset time equal to the start time, the night never ends: WarmShift holds the end
warmth around the clock until you change it.

## The curve

Both curves start and end at the same warmth and pass through the halfway point at the same
moment. They differ in how fast they get there.

| Through the ramp | Linear | Ease in and out |
|---|---|---|
| 0% | 50% | 50% |
| 25% | 62.5% | 57.8% |
| 50% | 75% | 75% |
| 75% | 87.5% | 92.2% |
| 100% | 100% | 100% |

*Ease in and out* changes very little at the start and end, so the first and last half hour of
the evening feel especially gentle.

## Warming down instead of up

The start warmth doesn't have to be lower than the end warmth. Set Start to 100% and End to 40%
and WarmShift will cool the screen through the evening instead.

## When the Mac is asleep, or WarmShift starts late

WarmShift always works out the right warmth for the current time; it doesn't need to have been
running all evening. If you wake your Mac or log in at 9:00 PM with the default schedule, the
screen goes straight to 87.5% (the 9:00 PM value) and carries on from there.

## When things happen only once

Two actions happen only at the **start** of a part of the day, not every 20 seconds:

- **Turning Night Shift on** when warming starts.
- **Moving the slider back** (and turning Night Shift off, if you chose that) when the day starts.

So if you turn Night Shift off by hand at 9:00 PM, it stays off until warming starts the next
evening. Changing any setting counts as a fresh start, so it re-applies these actions for the
current time.

The **slider value** is different: during warming and holding WarmShift keeps it on schedule, so
if you drag Night Shift's slider in System Settings, it moves back within 20 seconds. Pause
WarmShift from the menu first if you want to set it by hand.

---
Next: [WarmShift and Night Shift](Night-Shift.md)
