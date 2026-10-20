# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Set Your Intention** is a standalone Apple Watch app (no iOS companion logic) that tracks daily Mindful Minutes via Apple Health, lets the user set a daily intention, run timed meditations, and shows progress in WidgetKit complications. Release names/versions are listed in `README.md`.

## Commands

Xcode project only (no SPM packages, no linter). Schemes: `Intention Watch App`, `ComplicationExtension`, `Intention Tests`.

```sh
# Build the watch app
xcodebuild -project Intention.xcodeproj -scheme "Intention Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 12 (46mm)' build

# Run all tests
xcodebuild -project Intention.xcodeproj -scheme "Intention Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 12 (46mm)' test

# Run a single test
xcodebuild ... test -only-testing:"Intention Tests/ConverterTests/testMinutes"
```

List available simulators with `xcrun simctl list devices available | grep -i watch`.

## Build settings to respect

- Swift 6 language mode with `SWIFT_STRICT_CONCURRENCY = complete`; deployment target watchOS 26.6. New code must compile cleanly under strict concurrency (e.g. HealthKit is imported with `@preconcurrency`, complication callbacks are `@Sendable`).
- Tests use `@testable import Intention_Watch_App`, so anything tested must be in the watch app target.

## Architecture

Redux-style unidirectional flow inside `Intention Watch App/`:

- `Store` (singleton `Store.shared`, `ObservableObject`) holds `AppState` and exposes `async dispatch(action:)`. Views get it via `@EnvironmentObject` and call `await store.dispatch(...)` inside `Task`s.
- `Action` enumerates every event; `Reducer.apply(action:to:)` is an `async` function that performs side effects directly (HealthKit calls, haptics via `WKInterfaceDevice`, extended runtime sessions) and returns the new state. There is no separate middleware/effects layer.
- `AppState.app` is the screen-level state machine (`loading`, `onboarding`, `meditating(Date)`, `mindfulState(TimeInterval)`, `error(HealthStoreError)`); `RootView` in `IntentionApp.swift` switches on it. The main UI is a vertical-page `TabView` of `IntentionView`, `MeditationView`, `SetIntentionView`.
- `intention` and `guided` are computed properties backed by **App Group `UserDefaults`** (`group.com.paulweichhart.Intention.appgroup`), not stored fields — so they persist and are readable from the complication.
- `MindfulSession` wraps `WKExtendedRuntimeSession` to keep meditations running; its delegate dispatches back into `Store.shared` on expiry/failure.
- `HealthStore` wraps `HKHealthStore` for the `mindfulSession` category: request permission, sum today's samples, save a session. Errors are mapped to `HealthStoreError`.

### Complication

`Complication/Complication.swift` is a separate WidgetKit extension target (kind = `Constants.complication`). It does not use the Store; it creates its own `HealthStore`, reads the intention from App Group defaults, and refreshes every 15 minutes. The app also calls `WidgetCenter.reloadTimelines` from `ExtensionDelegate.applicationDidEnterBackground`.

### Shared code

`Shared/` (`Constants`, `Converter`, `Texts`, `Colors`, `Style`, `VersionState`, `Extensions`) and `HealthStore.swift` are compiled into both the app and complication targets. When adding a file that both need, add it to both target memberships in the project.

- `Converter` handles all minutes ⇄ seconds conversion; intention and mindful values are stored as `TimeInterval` seconds everywhere.
- `Texts` is an enum of `LocalizedStringKey`s whose raw values are the English keys in `Localization/<lang>.lproj/Localizable.strings` (en, de, es, fr). Adding a user-facing string means adding a `Texts` case and an entry in all four `Localizable.strings` files.

### Version migration

`VersionState` + the `.setup` action implement onboarding and data migration across major versions (v1 stored minutes instead of seconds; v2 used standard `UserDefaults`; v3 moved to the App Group). Keep these `UserDefaults` keys in `Constants` stable — changing them breaks migration for existing users.
