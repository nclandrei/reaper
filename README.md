# Reaper

A native macOS menu bar app that simplifies Activity Monitor. See running apps with CPU/memory stats in a glassmorphism dropdown, kill them with one click.

## Features

- **Menu bar CPU indicator** — live system CPU% always visible
- **Process grouping** — apps with their helper processes nested together (e.g., Chrome with all its helpers)
- **One-click kill** — hover to reveal quit button, right-click for force quit
- **Search & sort** — filter by name, sort by CPU/Memory/Name
- **Glassmorphism UI** — frosted glass material with gradient borders
- **Lightweight** — no Dock icon, minimal resource usage

## Requirements

- macOS 14.0+ (Sonoma)
- Not sandboxed (requires `proc_pidinfo`/`sysctl` access)

## Build

```bash
# Generate Xcode project (requires xcodegen)
brew install xcodegen
cd projects/reaper
xcodegen generate
open Reaper.xcodeproj

# Or build from command line
xcodebuild build -project Reaper.xcodeproj -scheme Reaper -configuration Debug
```

## Architecture

MVVM + Service Layer:

- **Models** — `ProcessInfo`, `ProcessGroup`, `SortOrder`
- **Services** — `ProcessMonitor` (sysctl/proc_pidinfo), `ProcessKiller` (SIGTERM/SIGKILL), `SystemStats`
- **ViewModels** — `ProcessListViewModel` (timer, grouping, search, sort), `SettingsViewModel`
- **Views** — SwiftUI with `MenuBarExtra(.window)`, glassmorphism components

### Process Monitoring

- Enumerates PIDs via `sysctl(KERN_PROC_UID)`
- Gets CPU time + memory via `proc_pidinfo(PROC_PIDTASKINFO)`
- CPU% calculated as delta between samples (same approach as Activity Monitor)
- First refresh shows 0% (no prior sample)

### Process Grouping

- Apps identified via `NSWorkspace.shared.runningApplications`
- Helpers matched by walking parent PID chain upward
- Fallback: bundle ID prefix matching
- Cycle detection prevents infinite loops

## Settings

- **Refresh interval** — 1s, 2s, 3s, or 5s (default: 3s)
- **Launch at login** — via SMAppService

## License

MIT
