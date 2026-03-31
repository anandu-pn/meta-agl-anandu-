# meta-agl-anandu- — AGL GSoC 2026 Quiz Submission

## Overview

This is a custom Yocto/OE layer (`meta-agl-anandu-`) created for the **AGL (Automotive Grade Linux) GSoC 2026** quiz task. It contains:

- A **Flutter application** (`agl-quiz-app`) that:
  - Displays the AGL version from `/etc/os-release`
  - Shows the developer's name (Anandu)
  - Button 1: Shows a picture
  - Button 2: Plays a sound
- A **Yocto recipe** to build and integrate the app into an AGL image
- A **bbappend** to include the app in the AGL IVI demo image

## Layer Structure

```
meta-agl-anandu-/
├── conf/
│   └── layer.conf                          # Layer configuration
├── recipes-apps/
│   └── agl-quiz-app/
│       └── agl-quiz-app_git.bb             # Yocto recipe for the Flutter app
├── recipes-platform/
│   └── images/
│       └── agl-ivi-demo-flutter.bbappend   # Append to include app in AGL image
├── flutter-app/                            # Flutter application source
│   ├── lib/
│   │   └── main.dart                       # Main application code
│   ├── assets/
│   │   └── sounds/
│   │       └── notification.wav            # Sound asset (placeholder)
│   ├── pubspec.yaml                        # Flutter dependencies
│   ├── analysis_options.yaml
│   └── README.md
└── README.md                               # This file
```

## Flutter App Details

The app (`agl-quiz-app`) is designed to run on AGL with the Flutter runtime. It:

1. **Reads `/etc/os-release`** to extract and display the AGL version
2. **Displays developer name** prominently
3. **Button 1 — "Show Picture"**: Displays an image (generates a colored pattern/uses bundled asset)
4. **Button 2 — "Play Sound"**: Plays a notification sound using the `audioplayers` package

### Screenshots

_TODO: Add screen capture/video of final result_

## Prerequisites

- Ubuntu 22.04 LTS (Jammy Jellyfish) — required for workspace-automation
- [workspace-automation](https://github.com/meta-flutter/workspace-automation) tool
- AGL master branch source

## Quick Start — Development (Linux Desktop)

```bash
# Clone workspace-automation
git clone https://github.com/meta-flutter/workspace-automation.git
cd workspace-automation

# Setup workspace with AGL QEMU support
./flutter_workspace.py --enable agl-ivi-demo-flutter-qemu-master

# Source environment
source setup_env.sh

# Navigate to the app
cd /path/to/meta-agl-anandu-/flutter-app

# Run on Linux desktop (for development)
flutter run -d linux

# Or run on AGL QEMU
run-agl-ivi-demo-flutter-qemu
flutter run -d agl-qemu-master
```

## Quick Start — AGL Image Build

```bash
# 1. Setup AGL build environment
source meta-agl/scripts/aglsetup.sh -m qemux86-64 agl-demo

# 2. Add this layer to bblayers.conf
bitbake-layers add-layer /path/to/meta-agl-anandu-

# 3. Build the AGL image
bitbake agl-ivi-demo-flutter

# 4. Run with QEMU
runqemu qemux86-64
```

## Layer Dependencies

This layer depends on:

- `meta-flutter` (provides `flutter-app` class)
- `meta-agl-demo` (provides the AGL demo image)
- `poky` (core Yocto/OE)

## Yocto Recipe

The recipe `agl-quiz-app_git.bb` inherits the `flutter-app` class from `meta-flutter` and:

- Fetches the Flutter app source from this GitHub repository
- Builds it using the Flutter AOT compilation
- Installs it into the target rootfs

## Development Notes

### Using workspace-automation

Per the [howto slides](https://docs.google.com/presentation/d/1D7Bv85STGw_OKF6n_ObIFJHAQNPwXy4B_vnQuRYZym8):

1. The workspace-automation tool sets up the Flutter SDK and AGL QEMU environment
2. Use `--enable agl-ivi-demo-flutter-qemu-master` for AGL master branch
3. After `source setup_env.sh`, Flutter is configured to target AGL
4. `flutter run -d agl-qemu-master` deploys to the running QEMU instance

### Build Environment Requirements

- **Disk**: ~200GB free space for full AGL build
- **RAM**: 16GB minimum (32GB recommended)
- **CPU**: Multi-core recommended (build takes 2-8 hours)
- **OS**: Ubuntu 22.04 LTS

## Author

**Anandu** — AGL GSoC 2026 Applicant

## License

MIT License — See individual files for details.

## References

- [AGL Documentation](https://docs.automotivelinux.org)
- [Yocto Project Documentation](https://docs.yoctoproject.org)
- [meta-flutter](https://github.com/meta-flutter/meta-flutter)
- [workspace-automation](https://github.com/meta-flutter/workspace-automation)
- [AGL Discord](https://discord.com/invite/ZztCaVeQVG)