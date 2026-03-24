<p align="center">
  <img src="icon/reaper-icon-1024.png" width="128" height="128" alt="Reaper icon">
</p>

# Reaper

A lightweight macOS menu bar app for monitoring and killing processes. Like Activity Monitor, but faster.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-black?logo=apple)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white)
![MIT License](https://img.shields.io/badge/license-MIT-blue)

## Features

- **Process grouping** -- Apps and their helper processes are grouped together by walking the parent PID chain and matching bundle ID prefixes. Expand any group to see individual helpers.
- **One-click kill** -- Hover to reveal a quit button. Right-click for force quit (SIGKILL). Kill an entire process group at once.
- **9 menu bar indicator styles** -- Pill bar, segments, thin line, ring gauge, battery, dots, mini bars (history graph), dual stack (CPU + memory), and text only.
- **Per-metric indicator style** -- Set a different visual style for CPU vs. memory. Each metric remembers its own default.
- **Hide text option** -- Strip the percentage/memory label from the menu bar for a minimal footprint. The indicator graphic remains.
- **Global hotkey** -- Toggle the panel with a keyboard shortcut. Default is `Control+Option+Command+R`, configurable via an inline recorder using the [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) library.
- **Search and sort** -- Filter processes by name. Sort by CPU, memory, or name. Groups and their children are both sorted.
- **Paginated background processes** -- The "Background" catch-all group paginates children 10 at a time with a "Show more" button.
- **Auto-expand on search** -- When a search query is active, matching helper processes are shown automatically without needing to expand the group.
- **Settings** -- Configurable refresh interval (1s, 2s, 3s, 5s), launch at login via SMAppService.

## Install

### Homebrew

```
brew install --cask nclandrei/tap/reaper
```

### Manual

Download the latest `.dmg` from [Releases](https://github.com/nclandrei/reaper/releases) and drag Reaper to Applications.

## Build from Source

Requires [XcodeGen](https://github.com/yonaskolb/XcodeGen) and Xcode 15+.

```bash
brew install xcodegen
cd reaper
xcodegen generate
xcodebuild build \
  -project Reaper.xcodeproj \
  -scheme Reaper \
  -configuration Release
```

The built app will be in `DerivedData`. To run directly:

```bash
open DerivedData/Reaper/Build/Products/Release/Reaper.app
```

## Architecture

MVVM with a service layer, built entirely in SwiftUI.

| Layer | Components |
|-------|------------|
| **Models** | `ProcessInfo`, `ProcessGroup`, `SortOrder`, `MenuBarStyle`, `MenuBarMetric` |
| **Services** | `ProcessMonitor` (sysctl + proc_pidinfo), `ProcessKiller` (SIGTERM/SIGKILL), `SystemStats` (Mach host_statistics) |
| **ViewModels** | `ProcessListViewModel` (timer, grouping, search, sort), `SettingsViewModel` (refresh interval, launch at login) |
| **Views** | NSPopover-hosted SwiftUI tree, custom CoreGraphics menu bar renderers |

### Key implementation details

- Processes are enumerated via `sysctl(KERN_PROC_UID)` and enriched with `proc_pidinfo(PROC_PIDTASKINFO)` for CPU time and resident memory.
- CPU percentage is computed as a delta between consecutive samples, the same method Activity Monitor uses.
- The menu bar indicator is rendered to an `NSImage` using CoreGraphics, marked as a template image so it adapts to light and dark mode.
- The popover is managed through `NSStatusItem` and `NSPopover` rather than `MenuBarExtra`, which allows proper global hotkey integration and transient dismissal.
- Process grouping walks the parent PID chain with cycle detection, then falls back to bundle ID prefix matching for helpers that don't share a direct ancestry.
- The app runs as an `LSUIElement` (no Dock icon).

## Requirements

- macOS 14.0+ (Sonoma)
- Not sandboxed. Reaper needs direct access to `sysctl` and `proc_pidinfo` to enumerate and inspect processes, which is not possible under App Sandbox. Distributed outside the Mac App Store.

## License

[MIT](LICENSE)
