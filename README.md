# Life Daily

A calm life app: goals, journal, money, and work in one place. First open is silent — no sign-up form.

## Auth

1. Anonymous session on launch (Firebase UID).
2. Use the app immediately.
3. Optional: **Continue with Google / Apple** to keep the same UID and open the same data on another phone.

## Layout

```
lib/features/auth|home|goals|journal|finance|work
lib/core  lib/shared  lib/app
```

Until a Firebase project is connected, the app uses a local fake auth so UI work can continue.

To connect Firebase, send a **project id** (existing or new). Then we add `flutterfire configure`, enable Anonymous + Google, and deploy rules.
