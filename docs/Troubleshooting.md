# Troubleshooting

## Common questions

**I can't find WarmShift. There's no Dock icon or window.**
That's on purpose: it's a menu bar app. Look for a sun or moon icon near the clock. On a MacBook
with a notch, it may be hidden behind the notch if the menu bar is full. See
[Using the app](Using-the-App.md#the-menu-bar-icon).

**I turned Night Shift off, and it came back on.**
WarmShift turns Night Shift on when warming starts each evening. Turning it off by hand lasts
until then. To keep it off for a while, turn off the switch in WarmShift's menu. See
[How the schedule works](Schedule.md#when-things-happen-only-once).

**I moved the Night Shift slider in System Settings, and it jumped back.**
During warming and holding, WarmShift keeps the slider on schedule and corrects it within
20 seconds. Pause WarmShift from the menu first, or change the warmth in WarmShift's settings
instead.

**My Night Shift schedule keeps changing to Off.**
That's expected while WarmShift is on: it does the scheduling instead. See
[Why Night Shift's schedule is set to Off](Night-Shift.md#why-night-shifts-schedule-is-set-to-off)
and [Going back](Night-Shift.md#going-back).

**The screen didn't change when I woke my Mac.**
It should within a second of waking, and WarmShift re-checks the time every 20 seconds anyway.
If it still hasn't changed, check that the menu doesn't say *Paused*.

**Night Shift stays on all day.**
That's the default: in the morning WarmShift moves the slider back to the start warmth but leaves
Night Shift on. Turn on **Turn Night Shift off during the day** in settings if you'd rather it
switched off.

**The screen is warm at noon.**
Check the chart in settings: if it's coloured at midday, the reset time comes later than you
think, or it's set equal to the start time (which means "never reset"). See
[Crossing midnight](Schedule.md#crossing-midnight).

**A time field stays highlighted after I click away.**
That's normal for macOS. The highlighted field has keyboard focus, and clicking empty space
doesn't move focus. Press Tab or click another control.

**Launch at login doesn't work, or shows an error.**
It only works for the copy in `~/Applications` installed by `just install`. Check System
Settings → General → Login Items too. After rebuilding, you may need to switch the setting off
and on again.

## Messages

| Message | Where | Meaning |
|---|---|---|
| *Night Shift isn't available on this Mac* | Menu | WarmShift couldn't reach Night Shift. Either this Mac or display doesn't support Night Shift (check System Settings → Displays), or a macOS update changed how Night Shift works internally. WarmShift changes nothing while this shows. |
| *Paused* | Menu | The switch in the menu is off. WarmShift isn't changing anything. |
| *Reset must come after "Fully warm by".* | Settings | See [below](#reset-must-come-after-fully-warm-by). |
| *Switched Night Shift's own schedule to Off so it doesn't fight WarmShift.* | Settings | Information only. See [WarmShift and Night Shift](Night-Shift.md). |
| An error under **Launch at login** | Settings | macOS refused to add the login item. See the question above. |

### Reset must come after "Fully warm by"

Times are read forward from **Start warming at**, and here the reset comes before the
fully-warm time. For example: start 7:00 PM, fully warm by 8:00 AM, reset 7:00 AM.

Until you fix it, WarmShift squeezes the ramp so it finishes at the reset time, then the day
starts straight away. Move **Reset in the morning at** later, or **Fully warm by** earlier. See
[Crossing midnight](Schedule.md#crossing-midnight).
