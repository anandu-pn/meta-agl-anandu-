# AGL Quiz App — Flutter Application

A Flutter application built for **Automotive Grade Linux (AGL)** as part of the GSoC 2026 quiz task.

## Features

1. **AGL Version Display** — Reads and displays the AGL version from `/etc/os-release`
2. **Developer Name** — Shows "Anandu P N" as the developer
3. **Show Picture Button** — Displays an automotive-themed image with smooth fade animation
4. **Play Sound Button** — Plays a notification sound using the `audioplayers` package

## Running Locally

### Linux Desktop (Development)
```bash
cd flutter-app
flutter pub get
flutter run -d linux
```

### AGL QEMU (via workspace-automation)
```bash
# Setup workspace-automation first
source setup_env.sh
run-agl-ivi-demo-flutter-qemu

cd /path/to/flutter-app
flutter run -d agl-qemu-master
```

## Building for AGL

This app is integrated into AGL via the Yocto recipe in `recipes-apps/agl-quiz-app/`.

## Dependencies

- `flutter` SDK >= 3.0.0
- `audioplayers` ^6.1.0 — for sound playback

## Author

**Anandu P N** — AGL GSoC 2026
