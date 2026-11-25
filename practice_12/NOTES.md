# Practice 12 — Survive a Restart — NOTES

> Fields marked `___` — fill from pub.dev (open each package page, ~2 min each)
> and from your own `pubspec.lock` / `flutter pub outdated` output.

## Level 1: six package verdicts (lecture order: publisher → last release →
## platforms → pub points → issues vs commits → dependencies → licence)

1. **shared_preferences** — verified publisher **flutter.dev** (the Flutter
   team), last release ___ (month year), Android/iOS/Linux/macOS/Web/Windows,
   ___ pub points, issues live in the big flutter/flutter tracker with commits
   every week, depends only on its own platform packages, BSD-3-Clause.
2. **flutter_secure_storage** — verified publisher **steenbakker.dev**
   (community, Julian Steenbakker), last release ___, Android/iOS/macOS/Linux/
   Windows/Web, ___ pub points, ___ open issues but active commits, depends on
   its own per-platform packages + meta, BSD-3-Clause.
3. **path_provider** — verified publisher **flutter.dev**, last release ___,
   all six platforms, ___ pub points, maintained by the Flutter team, depends
   only on its platform packages, BSD-3-Clause.
4. **image_picker** — verified publisher **flutter.dev**, last release ___,
   Android/iOS/Web/macOS/Windows/Linux, ___ pub points, maintained by the
   Flutter team, depends on its platform packages, BSD-3-Clause.
5. **permission_handler** — verified publisher **baseflow.com** (a company),
   last release ___, Android/iOS/Windows/Web, ___ pub points, ___ open issues
   with regular releases, depends on its platform packages, MIT.
6. **url_launcher** — verified publisher **flutter.dev**, last release ___,
   all six platforms, ___ pub points, maintained by the Flutter team, depends
   only on its platform packages, BSD-3-Clause.

### Versions and the caret
Command used:
```
flutter pub add shared_preferences flutter_secure_storage path_provider image_picker permission_handler url_launcher
```
- `http` in pubspec.yaml: `^___` — exact version resolved in pubspec.lock: `___`
- **`^1.2.0` accepts** `>=1.2.0 <2.0.0` — e.g. 1.2.0, 1.2.5, 1.6.0 (new
  features and fixes, no breaking changes by semver).
  **It refuses** `2.0.0` and above (a major version may break the API)
  and anything below `1.2.0`.
- **Why pubspec.lock is committed for an app:** it pins the exact versions,
  so every machine (mine, the teacher's, CI) builds the same code. The caret
  says what is *allowed*; the lock says what was *chosen*.
- **Break it on purpose:** `http: 1.2.0` (no caret) → `flutter pub get` pins
  exactly 1.2.0, `flutter pub outdated` shows newer versions as not
  resolvable. Caret put back.

### flutter pub outdated
- Package that could be newer: `___` (current `___`, latest `___`)
- Why not upgraded: `___` (e.g. the latest is a new major version, outside
  the caret range — needs `flutter pub upgrade --major-versions` and a check
  of the breaking changes; or another package constrains it).

## Level 2: settings
- `darkMode` and `cityFilter` live in shared_preferences
  (`SharedPreferencesAsync`). They are read in `main()` **before `runApp`**,
  so the first frame already has the right theme — no light flash.
- `setDark` calls `notifyListeners()` **first**, then writes to disk: the
  screen does not wait for the disk.
- Every read is nullable and gets a default with `??`.
- **Break it on purpose:** reading `getBool` inside SettingsModel later →
  one light frame, then dark. That flash is why the read is in `main()`.

## Level 3: where a token must NOT go
- `prefs.setString('token', …)` would put the token in a **plain,
  unencrypted file** in the app's folder:
  - Android: `shared_prefs/*.xml` (legacy API) or a DataStore file
    (`SharedPreferencesAsync`) under `/data/data/<package>/`
  - iOS: a `.plist` in `Library/Preferences/`
- **Who can read it:** a device backup (adb / iTunes / iCloud), anyone with
  root / jailbreak, anyone with the phone and a USB cable + debug tools.
- So the token goes to **flutter_secure_storage** → iOS **Keychain** /
  Android **Keystore**-encrypted storage.
- **Platform surprise 1 — iOS:** Keychain entries **survive an uninstall**.
  Reinstall the app → the old token is still there → "signed in" after a
  fresh install. Fix in `main()`: an `installed` flag in prefs (prefs ARE
  deleted on uninstall); if missing → `store.clear()`.
- **Platform surprise 2 — Android:** when the user **removes the lock
  screen** (or changes it), Keystore keys can be invalidated → the stored
  value can no longer be decrypted → read throws / returns null. Handled in
  `SecureStore.readToken()`: on `PlatformException` → clear → null → the
  login screen.
- The token is never printed; `log()` writes only method, path, status.

## Level 4: the offline list
- `UsersCache` writes `users.json` to `getApplicationDocumentsDirectory()`.
  Never a hard-coded path, never `getTemporaryDirectory()` (the OS may delete
  Temporary at any time — "Clear cache").
- `getAll()`: online → save + `fromCache: false`; `NoConnectionException` →
  saved list + `fromCache: true`; nothing saved → `rethrow` → honest Offline
  screen, not an empty list.
- **Break it on purpose:** file in Temporary + Settings → Apps → Storage →
  Clear cache → offline the list is gone, no error.

## Level 5: permissions
### Android (emulator)
1. Take photo → system dialog → **Don't allow** → `denied` → SnackBar.
2. Take photo → system dialog again → **Don't allow** → `permanentlyDenied`.
3. Take photo → **no system dialog**, our own dialog at once →
   "Open settings" → `openAppSettings()` → the app's permission page.

So on Android 11+: **two No's** → permanently denied.

### iOS
- The system asks **only once**. **One "Don't Allow"** → `permanentlyDenied`
  immediately; from then on only Settings can change it.
- Photos has a **fourth state: `limited`** ("Selected Photos" — the user
  shares only some photos), besides granted / denied / permanentlyDenied.
- Without `NSCameraUsageDescription` in Info.plist iOS **kills the app** the
  moment the camera is touched.

### url_launcher
- `launchUrl(Uri.parse('kbtu.edu.kz'))` → no scheme → `false`, nothing opens.
  `https://kbtu.edu.kz` → the browser opens.
- Android 11+ needs the `<queries>` block for https / tel / mailto.

### The sentence for the defence
Every device API answers like `showDialog`: an `await`, and a `null` / `false`
/ `denied` when the user backs out. No `!` after any of them. **Handle the No;
the app keeps working without the photo.**

Screenshots: `screenshot_offline_banner.png`, `screenshot_permission_dialog.png`.
