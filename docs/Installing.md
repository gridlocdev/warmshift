# Installing

WarmShift needs **macOS 14 Sonoma or later** on a Mac that supports Night Shift. If you can see
**Night Shift…** in System Settings → Displays, you're set.

There are no prebuilt downloads yet, so you build it from the source code. That needs two things:

- **Xcode**, from the Mac App Store. Open it once after installing so it can finish setting up.
- **[just](https://github.com/casey/just)**, a small command runner: `brew install just`.

Then, in Terminal:

```bash
git clone https://github.com/gridlocdev/warmshift.git
cd warmshift
just install
```

`just install` builds a release copy, puts **WarmShift.app** in `~/Applications`, and opens it.
Look for the sun icon in the menu bar.

## Starting it at login

Open WarmShift's settings (click the menu bar icon, then **Settings…**) and turn on
**Launch at login**. macOS may show a notification that a login item was added; that's expected.
You can also see and remove it in System Settings → General → Login Items.

Launch at login only works for the installed copy in `~/Applications`, not for a copy you run
straight from the build folder.

## Updating

Pull the latest code and run `just install` again. It quits the running copy, replaces it, and
starts the new one. Your settings are kept.

## Uninstalling

1. Turn off **Launch at login** in WarmShift's settings.
2. Click the menu bar icon and choose **Quit**.
3. Delete `~/Applications/WarmShift.app`.
4. If you want Night Shift to run on its own schedule again, set one in System Settings →
   Displays → Night Shift → **Schedule**. WarmShift switched it to Off; see
   [WarmShift and Night Shift](Night-Shift.md#going-back).

Your settings stay in the macOS preferences store under `dev.gridloc.warmshift`. To remove them
too: `defaults delete dev.gridloc.warmshift`.

---
Next: [Using the app](Using-the-App.md)
