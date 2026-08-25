# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

"Set Your Intention" is a standalone watchOS app (no companion iPhone app required) for guided/unguided
mindful meditation sessions, backed by Apple HealthKit. It also ships a WidgetKit complication extension.
The `Intention App` and `Widget` directories are legacy leftover asset folders from a pre-standalone-watch
architecture and are not active build targets — the real code lives under `Intention Watch App/`,
`Complication/`, and `Shared/`.

## Build & test commands

This is an Xcode project (`Intention.xcodeproj`), not a Swift package — there is no `Package.swift`.

```bash
# List targets/schemes
xcodebuild -list -project Intention.xcodeproj

# Build the watch app for the simulator
xcodebuild -project Intention.xcodeproj -scheme "Intention Watch App" \
  -destination "platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)" build

# Run unit tests (scheme: "Intention Tests", target: Intention Tests)
xcodebuild -project Intention.xcodeproj -scheme "Intention Tests" \
  -destination "platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)" test

# Run a single test
xcodebuild -project Intention.xcodeproj -scheme "Intention Tests" \
  -destination "platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)" \
  -only-testing:"Intention Tests/ConverterTests/testTimeInterval" test
```

In practice, prefer opening `Intention.xcodeproj` in Xcode and running/testing from there — HealthKit
entitlements and simulator watch pairing make CLI simulator runs finicky. Real HealthKit reads/writes only
work on a physical Watch or a simulator with a mock health data source; do not expect HealthKit-dependent
code paths to be testable in a plain unit test.

## Architecture

The watch app is a small unidirectional-data-flow (Redux-style) app:

- **`Store` (`Store/Store.swift`)** — a singleton `ObservableObject` (`Store.shared`) that holds the single
  source of truth, `@Published var state: AppState`. Views call `await store.dispatch(action:)`; there is no
  other way to mutate state.
- **`Action` (`Reducer/Action.swift`)** — the closed set of events the app can respond to (setup, increment/
  decrement intention, request HealthKit permission, fetch mindful data, start/stop a meditation session, tick,
  toggle guided mode).
- **`Reducer` (`Reducer/Reducer.swift`)** — a single `func apply(action:to:) async -> AppState` that is the only
  place state transitions happen. It owns a `HealthStore` and a `MindfulSession` and is where haptics
  (`WKInterfaceDevice.current().play(...)`) are triggered as a side effect of a transition.
- **`AppState` (`State/AppState.swift`)** — holds `versionState: VersionState`, an `app: State` enum
  (`.loading`, `.onboarding`, `.meditating(Date)`, `.mindfulState(TimeInterval, [Statistic])`, `.error`), plus
  `intention` and `guided` — the latter two are computed properties backed directly by an app-group
  `UserDefaults` (`group.com.paulweichhart.Intention.appgroup`), not plain stored state, since they must be
  shared with the Complication extension process.
- **`RootView` (`IntentionApp.swift`)** switches on `store.state.app`: `.onboarding` shows `OnboardingView`;
  everything else shows a vertically-paged `TabView` (`IntentionView`, `StatsView`, `MeditationView`,
  `SetIntentionView`) that dispatches `.fetchMindfulTimeInterval` on `.task`.
- **`HealthStore` (`Store/HealthStore.swift`)** — the only HealthKit boundary. Async/await wrapper around
  `HKHealthStore` for requesting authorization and reading/writing `.mindfulSession` category samples. All
  failure modes collapse into `HealthStoreError` (`noDataAvailable`, `permissionDenied`, `savingFailed`,
  `unavailable`).
- **`VersionState` (`Shared/VersionState.swift`)** — encodes the app's multi-version migration history
  (v1 stored minutes as `Double` in standard `UserDefaults`; v2 introduced HealthKit; v3 introduced App
  Groups). `Reducer.apply(.setup)` reads these flags to decide whether to migrate old data or show onboarding.
  When touching onboarding/versioning logic, preserve this migration chain — real users still have v1/v2 data.
- **`Converter` (`Shared/Converter.swift`)** — all time-unit and progress-percentage math (minutes ⇄
  `TimeInterval`, mindful/intention progress ratio) goes through here; this is the file covered by the
  existing unit tests (`Tests/Intention Tests/ConverterTests.swift`).
- **Complication extension (`Complication/Complication.swift`)** — a separate WidgetKit target that reads the
  same app-group `UserDefaults` and HealthKit store to render complications; it does not go through `Store`/
  `Reducer` since it runs in a different process.
- **`Shared/`** is compiled into both the watch app and the complication extension (constants, colors, text,
  style helpers, `Converter`, `VersionState`) — anything added there must compile standalone without pulling
  in watch-app-only APIs (e.g. `WKInterfaceDevice`) unless guarded appropriately.

## Localization

User-facing strings live in `Localization/<lang>.lproj/Localizable.strings` for `en`, `de`, `es`, `fr`. When
adding new user-facing text, add the key to all four locale files (see `Shared/Texts.swift` for how keys are
wrapped).
