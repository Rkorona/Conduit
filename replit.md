# Conduit

A Flutter mobile app providing SSH, Mosh, SFTP, and local shell (Android arm64) capabilities — no account or cloud sync required. Available on the App Store, Google Play, and F-Droid.

## Stack

- **Flutter 3.44.1** (Dart SDK ^3.12.0) — targets Android & iOS
- **website/** — separate Nuxt 4 + Tailwind CSS marketing site

## Key directories

- `lib/` — Flutter app source
- `android/` / `ios/` — platform-specific native code
- `assets/` — fonts, icons
- `test/` — Flutter tests
- `website/` — Nuxt.js marketing website
- `fastlane/` — release automation & store screenshots
- `third_party/` — bundled binary licenses and GPL source-offer info
- `tools/` — build/dev tooling

## Notable dependencies

- `dartssh2` — custom fork (git, pinned commit) for SSH
- `conduit_vt` — custom VT/terminal renderer fork of xterm.dart
- `dart_mosh` — Mosh protocol support
- `flutter_pty` — PTY support for local shell (Android arm64 only)

## Running

This is a mobile app — it cannot be previewed in Replit's browser pane. To build:
- Flutter SDK 3.44.1+ required
- `flutter pub get` to install dependencies
- `flutter build apk` / `flutter build ios` for platform builds

The **website** can be run separately:
```
cd website && yarn install && yarn dev
```

## User preferences

(none yet)
