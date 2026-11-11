# NOTES — Practice 10: The Data Arrives Later

> Өзіңіз іске қосып тексеріп, нақты нәтижеге сәйкестендіріңіз
> (hash сияқты `#a1b2c` мәндері сізде басқа болады).

## Level 1 — event loop order

Code in `main()` before `runApp`:

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
```

**Predicted:** A, C, (first frame), then after 2 s: B, 6 students

**Actual:** A, `fetchStudents #1`, C, the first frame of the app; after 2 seconds — B, `6 students`.
Nothing waited for the timer: `main()` ran to the end, the loop drew the screen,
and the two callbacks came later as events.

Calling `fetchStudents()` three times in a row — the third one prints:

```
Unhandled Exception: Instance of 'NoConnectionException'
```

and the app keeps running as if nothing happened.

With `sleep(const Duration(seconds: 2))` instead of `await Future.delayed(...)`:
the app does not draw its first frame for two seconds — the loop is **blocked**, not waiting.

## Level 2 — setState after dispose

Without `if (!mounted) return;`, pressing Back during loading:

```
setState() called after dispose(): _StudentsScreenState#a1b2c(lifecycle state: defunct, not mounted)
```

## Level 5 — the Save that lies

```
Unhandled Exception: Bad state: server rejected 6
```

**The user saw a success.** The screen popped as if the save worked,
while the server actually rejected it and the error was lost in the console.

## Level 4 — countdown observations

- **Version B without `cancel()`:** Back at 7 → one second later
  `setState() called after dispose()`, and the console keeps printing
  `tick 6`, `tick 5` … all the way to `tick 0` with nobody on screen. That is the leak.
- **Version B with `cancel()`:** Back at 7 → the console stops at `tick 7`.
- **Version A (StreamBuilder), no cancel anywhere in my code:** Back at 7 →
  the console stops. StreamBuilder cancelled the subscription for me.
