# Conduit

[![Latest release](https://img.shields.io/github/v/release/gwitko/Conduit)](https://github.com/gwitko/Conduit/releases/latest)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
![Flutter](https://img.shields.io/badge/Flutter-3.44.0-02569B?logo=flutter)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-2ea44f)

**A local-first SSH, Mosh, and SFTP workspace for Android and iOS.**

Conduit is a mobile terminal client built for people who need to reach real
machines from a phone without creating an account, syncing credentials through a
service, or paying a subscription to open a shell.

It supports regular SSH sessions and Mosh-powered roaming terminals, so a
session can stay usable across unreliable mobile networks, Wi-Fi handoffs, and
everyday phone connectivity changes when the remote host is configured for
Mosh.

It stores connection profiles, credentials, and trusted host keys on device,
supports device authentication when available, and provides a tabbed terminal
workspace with mobile-friendly modifier, navigation, and function keys.

> Screenshots and store-ready artwork are coming later. The app is already built
> around real mobile workflows: roaming Mosh sessions, saved machines, tabbed
> terminals, trusted keys, SFTP browsing, and terminal themes.

## Highlights

- **Mosh roaming** - keep terminal sessions usable through mobile network
  changes, flaky Wi-Fi, and high-latency links.
- **No accounts, no subscriptions** - your SSH profiles stay on your device.
- **Secure local storage** - saved hosts, credentials, and trusted host keys are
  stored with platform secure storage.
- **Tabbed terminal workspace** - keep multiple sessions open and switch between
  machines quickly.
- **Mobile terminal controls** - on-screen modifier keys, function keys,
  navigation keys, paste support, and fullscreen mode.
- **SFTP browser** - browse remote files and export them through the native file
  picker.
- **Trusted host key management** - review and manage remembered host keys.
- **App lock** - protect the app with device authentication when supported.
- **Terminal themes** - built-in palettes for comfortable dark and light usage.
- **Background keepalive** - keep live sessions alive while the app is
  backgrounded, subject to platform limits. Android is supported through a
  foreground service; iOS behavior still needs broader device testing.

## Why Conduit?

Most mobile SSH clients either feel like desktop tools squeezed onto a phone or
cloud products wrapped around a terminal. Conduit takes a narrower approach:

- Make common SSH and Mosh work fast on a phone.
- Treat roaming terminal sessions as a first-class mobile workflow.
- Keep private connection material local.
- Treat host key trust as part of the product, not an afterthought.
- Support terminal workflows that actually need mobile-specific controls.
- Avoid accounts, sync services, subscriptions, and unnecessary moving parts.

Conduit is not trying to be a full remote administration suite. It is a focused
tool for opening shells, keeping sessions reachable on mobile networks, moving
files, and getting work done from a mobile device.

## Features

### Saved Machines

Create reusable connection profiles with names, hosts, ports, usernames,
password or private-key authentication, tags, connection timeouts, and optional
Mosh settings.

Profiles are searchable and can be grouped with tags such as `prod`, `lab`,
`staging`, or `home`.

### Mosh Roaming

Conduit can route terminal sessions through Mosh for better behavior on mobile
networks. Mosh is built for roaming connections: it can tolerate network
changes, packet loss, latency spikes, suspended phones, and Wi-Fi-to-cellular
handoffs better than a plain SSH terminal.

This is one of Conduit's core mobile features. SSH remains available for normal
connections, while Mosh can be enabled per saved machine when the remote host
has `mosh-server` installed and reachable UDP ports.

Mosh support is currently marked experimental while
[`dart_mosh`](https://github.com/gwitko/dart_mosh), a clean-room Dart
implementation of the Mosh protocol features Conduit needs, continues to
mature.

### Terminal Workspace

Open SSH or Mosh machines in a tabbed terminal workspace. Conduit keeps active
sessions available from the machines screen, shows live connection status, and
provides a fullscreen terminal mode for more screen space.

The terminal uses a bundled Nerd Font variant and supports common mobile
terminal affordances such as modifier keys, function keys, navigation keys, and
paste handling.

### SFTP Browser

Open an SFTP browser from any saved machine, navigate remote directories, and
export files using the platform file picker.

### Host Key Trust

Conduit prompts before trusting unknown host keys and stores trusted keys
locally. A dedicated trusted-keys view lets you review and remove remembered
keys.

### Appearance

Conduit includes multiple terminal-oriented palettes, including Catppuccin,
Tokyo Night, Dracula, Nord, Gruvbox, Solarized, One Dark, Rosé Pine, Everforest,
Monokai, Ayu Dark, Kanagawa, Night Owl, Palenight, Synthwave, and GitHub Dark.

## Project Status

Conduit is under active development. The core app is usable, but the project is
still evolving around connection reliability, platform behavior, packaging, and
visual documentation.

Expected rough edges:

- Mobile operating systems, especially iOS, may limit long-running background
  network activity.
- Mosh requires `mosh-server` and compatible UDP access on the remote host.
- Some terminal programs may expose edge cases in keyboard input, resize
  handling, or escape-sequence behavior.

## Security Model

Conduit is designed as a local-first client:

- It does not require a Conduit account.
- It does not sync connection profiles through a Conduit service.
- It stores saved hosts and trusted host keys on device using platform secure
  storage.
- It supports app unlock through device authentication when available.

You are still responsible for normal SSH operational security: protecting your
device, using strong credentials or keys, verifying host keys, and removing
stale trusted keys.

## Build

This project targets **Flutter 3.44.1**.

```sh
flutter pub get
flutter build apk --split-per-abi
```

For iOS, open the generated Flutter iOS project with Xcode after fetching
dependencies:

```sh
flutter pub get
open ios/Runner.xcworkspace
```

## Test

```sh
flutter analyze
flutter test
```

## Repository Layout

```text
lib/
  core/                 Shared theme, presentation, and failure types
  features/
    app_lock/           Device authentication and lock screen
    hosts/              Saved machine profiles
    terminal/           SSH/Mosh terminal sessions and workspace UI
    sftp/               Remote file browsing and export
test/                   Unit and widget tests
assets/                 App icon and bundled terminal font
```

## Contributing

Contributions are welcome, especially around:

- terminal input and escape-sequence correctness
- Android and iOS lifecycle behavior
- SFTP workflows
- accessibility and small-screen ergonomics
- packaging, release automation, and documentation
- screenshots and visual assets

Before opening a larger change, prefer starting with an issue or discussion so
the scope stays aligned with the app's local-first, mobile-focused direction.

### iOS Maintainer Wanted

Conduit is developed primarily without regular access to Apple hardware. Help
from someone who can test on iPhone, validate iOS lifecycle behavior, and keep
the Xcode/App Store side healthy would be especially valuable. If that sounds
like you, open an issue or contact `gwitko@proton.me`.

## Third-Party Assets

The bundled terminal font is AtkynsonMono Nerd Font Mono from the
[Nerd Fonts v3.4.0 release](https://github.com/ryanoasis/nerd-fonts/releases/tag/v3.4.0).
Its license is included in `assets/fonts/LICENSE-AtkynsonMono.txt`.

## License

Conduit is distributed under the terms of the license in [`LICENSE`](LICENSE).
