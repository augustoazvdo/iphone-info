# Iphone Info Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, the walk, check_proofs, the Verifier and the screens sub-agent).

**If the skill cannot be activated, STOP and tell the user - do not proceed without it.**

---

**Design**: `.specs/features/sonda/design.md`
**Status**: Approved
**Approved**: 2026-11-09 - user: "aprovado, depois configuro o git, por enquanto mantenha somente local o versionamento"

**Build**: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`
**Run unit**: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

---

## Test Coverage Matrix

> Generated from codebase, project guidelines, and spec - confirm before Execute. Guidelines found: none - strong defaults applied. The repo has no test target and no test docs. Domain rules are XCTest. SwiftUI files only bind those types, so they stay on the build gate.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| --- | --- | --- | --- | --- |
| Domain rule (`Monitoring/` pure types) | unit | All branches; 1:1 to the spec criteria the type owns; every listed edge case has a test | `IphoneInfo/IphoneInfoTests/*Tests.swift` | `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests` |
| SwiftUI view | none | Build gate. The view renders the type and does not recompute it. | `IphoneInfo/IphoneInfo/Views/*.swift` | build gate only |
| Widget view | none | Build gate. Values come from `WidgetSnapshot`. | `IphoneInfo/Widget/*.swift` | build gate only |
| Project config | none | Build gate only | `IphoneInfo/project.yml` | build gate only |

## Gate Check Commands

> Generated from codebase - confirm before Execute. No linter is configured. `xcodebuild build` is the type check.

| Gate Level | When to Use | Command |
| --- | --- | --- |
| Quick | After a domain task | `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests` |
| Full | After a domain task that also needs the app to link | `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests` |
| Build | After a view or config task | `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build` |

---

## Execution Plan

Phases run in order. Tasks inside a phase run in order.

### Phase 1: Battery domain

```
T1 → T2 → T3
```

### Phase 2: Painel

```
T4 → T5 → T6 → T7
```

### Phase 3: Device and sensors

```
T8 → T9 → T10 → T11
```

### Phase 4: Network and benchmarks

```
T12 → T13 → T14 → T15 → T16
T14 → T25
T15 → T26
T16 → T27
```

### Phase 5: Check and widget

```
T17 → T18 → T19 → T20
T17 → T28
```

### Phase 6: Meter, compass, tools

```
T21 → T22 → T23 → T24
T22 → T29
```

---

## Task Breakdown

### Phase 1: Battery domain

### T1: Add the unit test target

**What**: Add an iOS unit-test bundle `IphoneInfoTests` that hosts on `IphoneInfo` and can `@testable import IphoneInfo`.
**Where**: `IphoneInfo/project.yml`
**Depends on**: None
**Reuses**: The existing `IphoneInfo` application target
**Requirement**: SONDA-03

**Done when**:

- [ ] `IphoneInfo/project.yml` defines target `IphoneInfoTests` as `bundle.unit-test`, platform iOS, sources `IphoneInfoTests`, dependency `IphoneInfo`
- [ ] `ENABLE_TESTABILITY` is YES on the app target
- [ ] `xcodegen generate` recreates `IphoneInfo/IphoneInfo.xcodeproj`
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `build(sonda): add the unit test target`

---

### T2: Estimate battery power

**What**: Add `BatteryEstimate` with the watt, volt, and current rules, including monitoring off and an unknown state.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/BatteryEstimate.swift`
**Depends on**: T1
**Reuses**: None
**Requirement**: SONDA-03, SONDA-04, SONDA-05, SONDA-06, SONDA-07

**Done when**:

- [ ] Unplugged CPU fraction `0.25` produces `2.2 W estimativa`, `3.87 V estimativa`, and `568 mA estimativa`
- [ ] Charging produces `12.0 W estimativa` and `3101 mA estimativa`
- [ ] Full produces `0.5 W estimativa` and `129 mA estimativa`
- [ ] Unknown state does not apply the unplugged formula
- [ ] Monitoring off sets charge text to `—` and does not produce `5.2`
- [ ] A nil capacity sets capacity, watts, volts, and current to `Indisponível`
- [ ] Tests live in `IphoneInfo/IphoneInfoTests/BatteryEstimateTests.swift` under the method names in Checks C3, C4, C5, C6, C7, and C27
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): estimate battery watts from cpu and state`

---

### T3: Store catalog capacity

**What**: Add `capacityMilliampHours` to every existing `DeviceSpec`, using the table in `design.md`.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/DeviceCatalog.swift`
**Depends on**: T2
**Reuses**: `DeviceCatalog.spec(for:)`
**Requirement**: SONDA-02

**Done when**:

- [ ] `iPhone16,2` returns `4422`
- [ ] `iPhone99,9` returns nil
- [ ] The other identifiers in the design table return the listed mAh
- [ ] Test method `testIPhone15ProMaxCapacity` is in `IphoneInfo/IphoneInfoTests/DeviceCatalogTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): add catalog battery capacity`

---

### Phase 2: Painel

### T4: Build the painel sheet

**What**: Add `PainelSheet`, `CoreSelection`, `MonitorToggle`, and `SampleGate`.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/PainelSheet.swift`
**Depends on**: T3
**Reuses**: `BatteryEstimate`, `MemorySnapshot`, `StorageSnapshot`
**Requirement**: SONDA-01, SONDA-02, SONDA-11, SONDA-12

**Done when**:

- [ ] A fixture sheet contains the processor, memory, network, battery, thermal, and storage figures from SONDA-01, including `frequência estimada` and `Sem conexão` when the address is nil
- [ ] Model `iPhone16,2` shows `4422 mAh` and estimate rows that contain `estimativa`
- [ ] `CoreSelection.toggle(nil, 2) == 2`, `toggle(2, 2) == nil`, and `toggle(2, 1) == 1`
- [ ] Running title is `Pausar` and the next state is stopped. Stopped title is `Retomar` and the next state is running
- [ ] Empty cores produce `0%` and an empty core list
- [ ] `SampleGate.runs(active: false)` is false and `SampleGate.runs(active: true)` is true
- [ ] Test methods for C1, C2, C11, C12, C28, and C29 are in `IphoneInfo/IphoneInfoTests/PainelSheetTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): build the painel sheet from live samples`

---

### T5: Define the banner and block purchases

**What**: Add `BannerPresentation` and `Monetization` with an empty product list.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/Monetization.swift`
**Depends on**: T4
**Reuses**: None
**Requirement**: SONDA-13, SONDA-14, SONDA-15

**Done when**:

- [ ] The painel presentation has `regionVisible == true`
- [ ] A failed load sets the message to `Anúncio indisponível`
- [ ] `productIdentifiers` is empty and `purchaseControls` is empty
- [ ] Test methods for C13, C14, and C15 are in `IphoneInfo/IphoneInfoTests/MonetizationTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): define the banner and block purchases`

---

### T6: Link the ads SDK

**What**: Add the Google Mobile Ads package and the public test app id. Do not use the CPU-x publisher id.
**Where**: `IphoneInfo/project.yml`
**Depends on**: T5
**Reuses**: `Monetization`
**Requirement**: SONDA-13

**Done when**:

- [ ] `project.yml` depends on `https://github.com/googleads/swift-package-manager-google-mobile-ads` at the stable major that resolves
- [ ] The generated Info.plist uses app id `ca-app-pub-3940256099942544~1458002511`
- [ ] The banner unit constant in the app target is `ca-app-pub-3940256099942544/2934735716`
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `build(sonda): link the ads sdk with the test unit`

---

### T7: Show the sheet and the banner

**What**: Bind `DashboardView` to `PainelSheet` and one banner region.
**Where**: `IphoneInfo/IphoneInfo/Views/DashboardView.swift`
**Depends on**: T6
**Reuses**: `MetricCard`, `CoreGlassButton`, `HistoryChart`
**Requirement**: SONDA-01, SONDA-12, SONDA-13, SONDA-14, SONDA-15

**Done when**:

- [ ] Each sheet section is rendered inside the existing glass cards
- [ ] Core buttons call `CoreSelection.toggle`
- [ ] The toolbar uses `MonitorToggle.title`
- [ ] One banner region shows `BannerPresentation.message` when the load fails
- [ ] The view has no purchase button and no watt formula of its own
- [ ] `RootView` uses `SampleGate` when the scene phase changes
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): show the sheet and the banner on the painel`

---

### Phase 3: Device and sensors

### T8: Build the device sheet

**What**: Add `DeviceSheet.make(system:)` for the SONDA-08 fields.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/DeviceSheet.swift`
**Depends on**: T7
**Reuses**: `SystemInfo`
**Requirement**: SONDA-08

**Done when**:

- [ ] A catalogued fixture includes marketing name, identifier, device name, chip, process, max clock, logical cores, performance cores, efficiency cores, both caches, RAM, GPU name, family, ray tracing `Sim` or `Não`, recommended memory, pixel size, scale, max frames per second, OS version, build, kernel, and uptime
- [ ] A nil spec uses chip `Desconhecido` and omits process and max clock
- [ ] A nil GPU row is `Metal indisponível`
- [ ] Test method `testDeviceSheetListsHardware` is in `IphoneInfo/IphoneInfoTests/DeviceSheetTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): build the device sheet`

---

### T9: Bind the device screen

**What**: Render `DeviceSheet` from `DeviceView`.
**Where**: `IphoneInfo/IphoneInfo/Views/DeviceView.swift`
**Depends on**: T8
**Reuses**: `ValueRow`, `GlassBackdrop`
**Requirement**: SONDA-08

**Done when**:

- [ ] The list rows come from `DeviceSheet.make(system:)`
- [ ] The view does not format chip or cache values itself
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): bind the device screen to the sheet`

---

### T10: Build the sensor sheet

**What**: Add `SensorSheet` for present axes and the absence sentence.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/SensorSheet.swift`
**Depends on**: T9
**Reuses**: `Vector3`
**Requirement**: SONDA-09, SONDA-10

**Done when**:

- [ ] Present accelerometer, gyroscope, and magnetometer sections include X, Y, and Z, plus pitch, roll, yaw, pressure in kPa, and relative altitude in meters
- [ ] An absent sensor section contains `Indisponível neste aparelho` and the other sections still have values
- [ ] Test methods `testSensorsShowAxesWhenPresent` and `testAbsentSensorSaysIndisponivel` are in `IphoneInfo/IphoneInfoTests/SensorSheetTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): build the sensor sheet`

---

### T11: Bind the sensor screen

**What**: Render `SensorSheet` from `SensorsView`.
**Where**: `IphoneInfo/IphoneInfo/Views/SensorsView.swift`
**Depends on**: T10
**Reuses**: `MotionMonitor`
**Requirement**: SONDA-09, SONDA-10

**Done when**:

- [ ] Sections come from `SensorSheet`
- [ ] The view does not invent a second absence string
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): bind the sensor screen to the sheet`

---

### Phase 4: Network and benchmarks

### T12: Split session traffic

**What**: Count session bytes with `SessionTraffic` and add `SSIDLabel`.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/NetworkSampler.swift`
**Depends on**: T11
**Reuses**: `getifaddrs` counters already in the file
**Requirement**: SONDA-16, SONDA-17

**Done when**:

- [ ] `100` received bytes on `en0`, `50` on `pdp_ip0`, and `999` on `lo0` yield Wi-Fi `100`, cellular `50`, and ignore `lo0`
- [ ] Denied location returns `Indisponível` and does not clear the totals
- [ ] Test methods `testSessionTotalsSplitWifiAndCellular` and `testDeniedLocationHidesSsid` are in `IphoneInfo/IphoneInfoTests/SessionTrafficTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): split session traffic by interface`

---

### T13: Add the network screen

**What**: Show the four session totals and the SSID label.
**Where**: `IphoneInfo/IphoneInfo/Views/NetworkView.swift`
**Depends on**: T12
**Reuses**: `SessionTraffic`, `SSIDLabel`, glass list background
**Requirement**: SONDA-16, SONDA-17

**Done when**:

- [ ] The screen shows Wi-Fi download, Wi-Fi upload, cellular download, and cellular upload for the process session
- [ ] The SSID row uses `SSIDLabel`
- [ ] A tab or navigation control opens this screen from the painel
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): add the network screen`

---

### T14: List capture devices

**What**: Add `CameraInventory` for position, device type, and the empty sentence.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/CameraInventory.swift`
**Depends on**: T13
**Reuses**: None
**Requirement**: SONDA-18

**Done when**:

- [ ] An empty input yields `Nenhuma câmera` and no device row
- [ ] A non-empty input lists position and device type and does not contain `Nenhuma câmera`
- [ ] Test method `testEmptyCameraListSaysNenhumaCamera` is in `IphoneInfo/IphoneInfoTests/CameraInventoryTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): list capture devices`

---

### T15: Parse the speed test result

**What**: Add `SpeedTest` for a timed byte count and the failure sentence.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/SpeedTest.swift`
**Depends on**: T14
**Reuses**: None
**Requirement**: SONDA-19

**Done when**:

- [ ] `1000` bytes in `2` seconds is `500` bytes per second
- [ ] A failed request is `Teste falhou` and has no success rate
- [ ] Test method `testFailedSpeedTestIsNotZero` is in `IphoneInfo/IphoneInfoTests/SpeedTestTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): parse the speed test result`

---

### T16: Score the benchmarks

**What**: Add integer and floating CPU scores and memory read, write, and copy rates.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/Benchmarks.swift`
**Depends on**: T15
**Reuses**: None
**Requirement**: SONDA-20, SONDA-21

**Done when**:

- [ ] Both score labels equal `Pontuação Iphone Info` and neither contains `Geekbench`
- [ ] Allocation failure returns `Memória insuficiente` and no megabytes-per-second success value
- [ ] Test methods `testBenchmarkScoresAreIphoneInfoNotGeekbench` and `testMemoryAllocationFailure` are in `IphoneInfo/IphoneInfoTests/BenchmarksTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): score cpu and memory benchmarks`

---

### T25: Show the camera inventory

**What**: Render `CameraInventory` on a camera screen.
**Where**: `IphoneInfo/IphoneInfo/Views/CameraView.swift`
**Depends on**: T14
**Reuses**: `CameraInventory`
**Requirement**: SONDA-18

**Done when**:

- [ ] The screen lists each camera's position and device type
- [ ] An empty inventory shows `Nenhuma câmera`
- [ ] The view does not query `AVCaptureDevice` itself
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): show the camera inventory`

---

### T26: Show the speed test

**What**: Render `SpeedTest` on a speed screen.
**Where**: `IphoneInfo/IphoneInfo/Views/SpeedView.swift`
**Depends on**: T15
**Reuses**: `SpeedTest`
**Requirement**: SONDA-19

**Done when**:

- [ ] A success shows ping, download bytes per second, and upload bytes per second
- [ ] A failure shows `Teste falhou` and no zero rate
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): show the speed test`

---

### T27: Show the benchmarks

**What**: Render the CPU scores and the memory rates.
**Where**: `IphoneInfo/IphoneInfo/Views/BenchmarkView.swift`
**Depends on**: T16
**Reuses**: `Benchmarks`
**Requirement**: SONDA-20, SONDA-21

**Done when**:

- [ ] The screen shows the integer score, the floating score, and the `Pontuação Iphone Info` label
- [ ] The memory section shows read, write, and copy, or `Memória insuficiente`
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): show the benchmarks`

---

### Phase 5: Check and widget

### T17: Record the device check

**What**: Add the six-item device check with pass, fail, and unavailable words.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/DeviceCheck.swift`
**Depends on**: T16
**Reuses**: None
**Requirement**: SONDA-22

**Done when**:

- [ ] The keys are `display`, `touch`, `camera`, `microphone`, `speaker`, and `volume`
- [ ] Pass displays `Aprovado`, fail displays `Reprovado`, unavailable displays `Indisponível`
- [ ] Test method `testDeviceCheckRecordsPassFailUnavailable` is in `IphoneInfo/IphoneInfoTests/DeviceCheckTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): record the device check`

---

### T18: Format the widget snapshot

**What**: Add `WidgetSnapshot` with CPU percent, battery percent, and the watts label.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/WidgetSnapshot.swift`
**Depends on**: T17
**Reuses**: `BatteryEstimate.wattsText`
**Requirement**: SONDA-23

**Done when**:

- [ ] A snapshot exposes the CPU percent, the battery percent, and a watts string that contains `estimativa`
- [ ] Test method `testWidgetShowsCpuBatteryAndWatts` is in `IphoneInfo/IphoneInfoTests/WidgetSnapshotTests.swift`
- [ ] `LiveMonitor` writes the snapshot into app group `group.com.azvdo.iphoneinfo` when a sample completes
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): format the widget snapshot`

---

### T19: Add the widget extension target

**What**: Add a WidgetKit extension target that compiles `WidgetSnapshot` and the app-group entitlement.
**Where**: `IphoneInfo/project.yml`
**Depends on**: T18
**Reuses**: `WidgetSnapshot`
**Requirement**: SONDA-23

**Done when**:

- [ ] `project.yml` defines a WidgetKit extension with bundle id `com.azvdo.iphoneinfo.widget`
- [ ] App and widget share entitlement `group.com.azvdo.iphoneinfo`
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `build(sonda): add the widget extension target`

---

### T20: Show the widget

**What**: Render CPU, battery, and watts from `WidgetSnapshot` in the widget view.
**Where**: `IphoneInfo/Widget/WidgetView.swift`
**Depends on**: T19
**Reuses**: `WidgetSnapshot`
**Requirement**: SONDA-23

**Done when**:

- [ ] The widget view shows the three snapshot fields and no formula of its own
- [ ] A missing snapshot shows `—` for each field
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): show the widget from the snapshot`

---

### T28: Show the device check

**What**: Render the six device-check rows.
**Where**: `IphoneInfo/IphoneInfo/Views/DeviceCheckView.swift`
**Depends on**: T17
**Reuses**: `DeviceCheck`
**Requirement**: SONDA-22

**Done when**:

- [ ] The screen records `Aprovado`, `Reprovado`, or `Indisponível` for display, touch, camera, microphone, speaker, and volume
- [ ] The view does not invent a fourth word
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): show the device check`

---

### Phase 6: Meter, compass, tools

### T21: Format the floating meter

**What**: Add the PiP overlay model with CPU percent and battery percent.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/FloatingMeter.swift`
**Depends on**: T20
**Reuses**: `PainelSheet` percent text
**Requirement**: SONDA-24

**Done when**:

- [ ] The model exposes CPU percent and battery percent
- [ ] Test method `testFloatingMeterShowsCpuAndBattery` is in `IphoneInfo/IphoneInfoTests/FloatingMeterTests.swift`
- [ ] Starting the meter presents those two strings in a Picture in Picture controller fed by a generated sample buffer
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): format the floating meter`

---

### T22: Format the compass heading

**What**: Add `CompassReading` for granted degrees and the denied sentence.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/CompassReading.swift`
**Depends on**: T21
**Reuses**: None
**Requirement**: SONDA-25

**Done when**:

- [ ] Denied permission returns `Localização desligada`
- [ ] Granted heading `90` returns `90°`
- [ ] Test method `testCompassDeniedSaysLocalizacaoDesligada` is in `IphoneInfo/IphoneInfoTests/CompassReadingTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): format the compass heading`

---

### T23: Add the tool calculations

**What**: Add regex, decibel, ruler, and tone calculations, plus the four tool names.
**Where**: `IphoneInfo/IphoneInfo/Monitoring/ToolBench.swift`
**Depends on**: T22
**Reuses**: None
**Requirement**: SONDA-26

**Done when**:

- [ ] Pattern `a` over text `banana` returns `3`
- [ ] The offered names are `Decibel`, `Régua`, `Tom`, and `Regex`
- [ ] Test method `testRegexMatchCountAndFourTools` is in `IphoneInfo/IphoneInfoTests/ToolBenchTests.swift`
- [ ] Gate check passes: `xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build -only-testing:IphoneInfoTests`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(sonda): add the tool calculations`

---

### T24: Show the four tools

**What**: Add the tools screen that offers the four `ToolBench` tools.
**Where**: `IphoneInfo/IphoneInfo/Views/ToolsView.swift`
**Depends on**: T23
**Reuses**: `ToolBench`
**Requirement**: SONDA-26

**Done when**:

- [ ] The screen offers Decibel, Régua, Tom, and Regex
- [ ] Each control updates from `ToolBench` rather than a private formula
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): show the four tools`

---

### T29: Show the compass

**What**: Render `CompassReading` on a compass screen.
**Where**: `IphoneInfo/IphoneInfo/Views/CompassView.swift`
**Depends on**: T22
**Reuses**: `CompassReading`
**Requirement**: SONDA-25

**Done when**:

- [ ] Granted permission shows the heading degrees
- [ ] Denied permission shows `Localização desligada`
- [ ] Gate check passes: `xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath IphoneInfo/build build`

**Tests**: none
**Gate**: build
**Commit**: `feat(sonda): show the compass`

---

## Checks

**C1** - The painel sheet includes CPU total, one row per core, `frequência estimada`, memory used and total plus active, wired, compressed, inactive, and free, storage used and total, download and upload, Wi-Fi or `Sem conexão`, battery charge and state, and thermal state (SONDA-01, AC 1)
Proof: run unit | testPainelShowsLiveFigures passed

**C2** - Model `iPhone16,2` shows `4422 mAh` on the battery card, which has no watt, volt, or current row. The battery screen shows voltage, wattage, incoming current, and current in use, each containing `estimativa`, and the two currents are equal (SONDA-02, SONDA-27)
Proof: run unit | testCatalogModelShowsCapacityAndEstimate passed

**C3** - Unplugged CPU fraction `0.25` is `2.2 W estimativa` (SONDA-03, AC 3)
Proof: run unit | testUnpluggedQuarterIsTwoPointTwoWatts passed

**C4** - Charging power is `12.0 W estimativa` (SONDA-04, AC 4)
Proof: run unit | testChargingIsTwelveWatts passed

**C5** - Full power is `0.5 W estimativa` (SONDA-05, AC 5)
Proof: run unit | testFullIsHalfWatt passed

**C6** - Shown watts use `3.87 V estimativa`, and incoming current and current in use each equal `568 mA estimativa` for the `2.2` W case (SONDA-06, AC 6)
Proof: run unit | testVoltageAndCurrentFromWatts passed

**C7** - Identifier `iPhone99,9` shows `Indisponível` for capacity, watts, volts, incoming current, and current in use, and no watt number (SONDA-07, AC 7)
Proof: run unit | testUnknownModelHasNoWattage passed

**C8** - The device sheet lists the SONDA-08 fields, with chip `Desconhecido` when the catalog misses (SONDA-08, AC 1)
Proof: run unit | testDeviceSheetListsHardware passed

**C9** - Present sensors include accelerometer, gyroscope, and magnetometer X Y Z, pitch, roll, yaw, pressure in kPa, and altitude in meters (SONDA-09, AC 1)
Proof: run unit | testSensorsShowAxesWhenPresent passed

**C10** - An absent sensor shows `Indisponível neste aparelho` and the other sensors keep their values (SONDA-10, AC 1)
Proof: run unit | testAbsentSensorSaysIndisponivel passed

**C11** - Tapping core `2` selects it, tapping it again clears it, and tapping core `1` selects `1` (SONDA-11, AC 1)
Proof: run unit | testCoreTapSelectsAndClears passed

**C12** - A running monitor offers `Pausar` and then stops. A stopped monitor offers `Retomar` and then runs (SONDA-12, AC 1)
Proof: run unit | testPauseAndResumeLabels passed

**C13** - The painel banner region is visible (SONDA-13, AC 1)
Proof: run unit | testBannerRegionIsVisible passed

**C14** - A failed banner load shows `Anúncio indisponível` (SONDA-14, AC 1)
Proof: run unit | testBannerFailureSaysAnuncioIndisponivel passed

**C15** - The product list and the purchase controls are empty (SONDA-15, AC 1)
Proof: run unit | testNoPurchaseControls passed

**C16** - Session totals are Wi-Fi `100` and cellular `50` when `lo0` added `999` bytes (SONDA-16, AC 1)
Proof: run unit | testSessionTotalsSplitWifiAndCellular passed

**C17** - Denied location shows SSID `Indisponível` and keeps the byte totals (SONDA-17, AC 1)
Proof: run unit | testDeniedLocationHidesSsid passed

**C18** - An empty camera list shows `Nenhuma câmera` (SONDA-18, AC 1)
Proof: run unit | testEmptyCameraListSaysNenhumaCamera passed

**C19** - A failed speed test shows `Teste falhou` and has no success rate. `1000` bytes in `2` seconds is `500` bytes per second (SONDA-19, AC 1)
Proof: run unit | testFailedSpeedTestIsNotZero passed

**C20** - CPU scores are labeled `Pontuação Iphone Info` and the label does not contain `Geekbench` (SONDA-20, AC 1)
Proof: run unit | testBenchmarkScoresAreIphoneInfoNotGeekbench passed

**C21** - A failed memory allocation shows `Memória insuficiente` (SONDA-21, AC 1)
Proof: run unit | testMemoryAllocationFailure passed

**C22** - The six device-check keys record `Aprovado`, `Reprovado`, or `Indisponível` (SONDA-22, AC 1)
Proof: run unit | testDeviceCheckRecordsPassFailUnavailable passed

**C23** - The widget snapshot shows CPU percent, battery percent, and a watts label that contains `estimativa` (SONDA-23, AC 1)
Proof: run unit | testWidgetShowsCpuBatteryAndWatts passed

**C24** - The floating meter shows CPU percent and battery percent (SONDA-24, AC 1)
Proof: run unit | testFloatingMeterShowsCpuAndBattery passed

**C25** - Denied compass permission shows `Localização desligada` (SONDA-25, AC 1)
Proof: run unit | testCompassDeniedSaysLocalizacaoDesligada passed

**C26** - Pattern `a` over `banana` returns `3`, and the tools are Decibel, Régua, Tom, and Regex (SONDA-26, AC 1)
Proof: run unit | testRegexMatchCountAndFourTools passed

**C27** - Battery monitoring off shows charge `—` and does not apply the watt formula (edge)
Proof: run unit | testMonitoringOffSkipsWattFormula passed

**C28** - No CPU cores shows `0%` and no core controls (edge)
Proof: run unit | testNoCoresShowsZeroAndNoControls passed

**C29** - Background stops the sample loop and active starts it (edge)
Proof: run unit | testBackgroundStopsAndActiveStarts passed

---

## Handoff

**Settled mid-build:** T1–T29 implemented inline (no batch sub-agents). Test-host crash on first run was a simulator service issue; resolved by restarting the iPhone 17 simulator. Benchmarks memory guard corrected (no `free(malloc(0))`). Walk found "Zero KB" for a zero byte count and hyphenated battery labels; both fixed, and `FormatTests.testZeroBytesStayNumeric` covers the zero.
**Dispatched:** none
**Walked:** Battery card opens Bateria with Tensão, Potência, Corrente entrando, and Corrente em uso. On this simulator those four read Indisponível because iPhone18,3 is not in the catalog. Earlier walk: iPhone 17 simulator (iOS 27.2), app launched with no sign-in. Painel (tab Painel): live CPU, cores, "frequência estimada", memory, network, storage, glass core button selects N1, pause switches to play, Google test banner "Test mode". Battery reads "—" and "Indisponível" because this simulator reports no level and iPhone18,3 is not in the catalog. Dispositivo: model, chip "Desconhecido", cores, caches, GPU, RAM, screen, iOS 27.2, uptime. Sensores: "Indisponível neste aparelho" (no motion hardware). Mais opens Rede ("Sem conexão", cellular 0 bytes), Câmera ("Nenhuma câmera"), Velocidade ("Ainda não medido"), Benchmark ("Pontuação Iphone Info"), Checagem ("Não testado"), Bússola ("Aguardando…"), Medidor flutuante (CPU percent, battery "—", PiP toggle left off), Ferramentas (decibel, régua, 440 Hz, regex "a"/"banana" = 3). Widget home-screen add, PiP start, microphone, and tone were not exercised. SSID needs the Wi-Fi entitlement on a signed device.

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6

Phase 1:  T1 → T2 → T3
Phase 2:  T4 → T5 → T6 → T7
Phase 3:  T8 → T9 → T10 → T11
Phase 4:  T12 → T13 → T14 → T15 → T16
Phase 4:  T14 → T25
Phase 4:  T15 → T26
Phase 4:  T16 → T27
Phase 5:  T17 → T18 → T19 → T20
Phase 5:  T17 → T28
Phase 6:  T21 → T22 → T23 → T24
Phase 6:  T22 → T29
```

Execution is strictly sequential. One task at a time, in order.

**How phase-based execution works:**

At Execute, the agent counts total tasks and packs phases into task-budgeted batches of about 7 tasks, whole phases only. This feature has 29 tasks, so it packs into more than one batch. The agent offers batch sub-agents and waits for a yes before dispatching any.

When the whole feature fits a single batch, execution happens inline. This feature does not.
