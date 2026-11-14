# Sonda Specification

**Approved**: 2026-11-09 - user: "aprovado"
**Battery screen approved**: 2026-11-09 - user: "aprovado"

## Problem Statement

CPU-x shows a full hardware sheet for an iPhone: processor, memory, storage, battery power, display, system, network, and sensors. The App Store binary is FairPlay-encrypted, so Sonda cannot copy its code. Sonda is a clean-room app that shows the same classes of information with public iOS APIs, a device catalog, and labeled estimates where the system does not expose a live value.

## Goals

- [ ] The painel, dispositivo, and sensores screens show every important hardware figure listed in this spec.
- [ ] The battery card shows live charge, state, and catalog capacity. Tapping it opens a battery screen with estimated watts, volts, incoming current, and current in use. Incoming current equals current in use. Each estimate contains the word "estimativa".
- [ ] One banner ad sits on the painel. There is no purchase.

## Out of Scope

| Feature | Reason |
| --- | --- |
| CPU-x name, icon, strings, and artwork | AD-001. Third-party brand. |
| Pro purchase, StoreKit, rewarded-video unlock | AD-002. Ads only. |
| FairPlay decryption or shipping CPU-x code | The executable is encrypted. |
| Legacy Today extension | Apple removed that extension point in iOS 18. |
| Copying `Battery.plist` or `rank.plist` from the IPA | Those files are the other app's data. Sonda keeps its own catalog. |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Product name Sonda | Sonda | AD-001, user: "Manter o nome Sonda" | y |
| Ads, no purchase | One banner, no Pro | AD-002, user: "somente anuncios" | y |
| Delivery | Spec now, build P1 then later phases | AD-003, user: "Spec completo, implementar em fases" | y |
| IPA in git | Track `CPU-x.ipa`, ignore `extracted/` and `build/` | AD-004, user: "Quero o IPA versionado também" | y |
| Battery power formula | Unplugged: 1.2 + 4.0 × CPU fraction, one decimal. Charging: 12.0 W. Full: 0.5 W. Nominal voltage: 3.87 V. Current mA = watts / 3.87 × 1000, rounded to an integer. | AD-005. iOS does not expose watts. The user asked for the figure. The label "estimativa" keeps it from looking measured. | y |
| Unknown model | Capacity, watts, volts, and both currents show "Indisponível" | A number without a catalog row would be a guess about the wrong phone. | y |
| Two currents | Incoming current and current in use show the same estimated mA | User, 2026-11-09: "As duas iguais à corrente única que o painel já calcula hoje." | y |
| Battery card contents | Charge, state, and capacity stay on the card. Voltage, wattage, and both currents open on tap. | User, 2026-11-09: "O card fica só com carga, estado e capacidade. Voltagem, wattage e as duas correntes ficam na tela nova." | y |
| Input validation | N/A because P1 has no text the user types | Battery health entry is P3. | y |
| Persistence | Session traffic counters die with the process. No account. | Local monitor. | y |
| Auth and rate limits | N/A because the app calls no account API | Ads are a view, not a user login. | y |
| Concurrency | One sample per second on a background read, UI updates on the main actor | Matches the current monitor loop. | y |
| Observability | N/A because there is no server or log pipeline | Failures are on-screen strings. | y |
| External failure | IF the banner fails to load THEN the metrics stay and the banner reports "Anúncio indisponível" | Ads must not hide hardware data. | y |

**Open questions:** none. Defaults above are the ones to correct if the formula or the ad failure text is wrong.

---

## User Stories

### P1: Ficha ao vivo ⭐ MVP

**User Story**: As a phone owner, I want every important hardware figure on one app so that I can read the machine without the original CPU-x.

**Why P1**: The user asked for all important infos, including battery wattage. The glass painel, dispositivo, and sensores screens are the place those figures live.

**Acceptance Criteria**:

1. WHEN the painel is visible THEN the system SHALL show CPU total percent, one control per logical core with that core's percent, estimated frequency in MHz or GHz labeled "frequência estimada", memory used and total plus active, wired, compressed, inactive, and free bytes, storage used and total, download and upload bytes per second, Wi-Fi IPv4 or the text "Sem conexão", battery charge percent, battery state, and thermal state.
2. WHEN the painel is visible AND the model is in the device catalog THEN the battery card SHALL show catalog capacity in mAh, and SHALL show charge and state, and SHALL NOT show watts, volts, or current.
3. WHILE the battery state is unplugged AND the model is in the catalog the system SHALL set estimated watts to `1.2 + 4.0 × cpuUsage`, rounded to one decimal, where `cpuUsage` is the current total CPU fraction from 0 to 1.
4. WHILE the battery state is charging AND the model is in the catalog the system SHALL show estimated power as 12.0 W.
5. WHILE the battery state is full AND the model is in the catalog the system SHALL show estimated power as 0.5 W.
6. WHEN the battery screen shows estimated watts THEN the system SHALL show voltage as 3.87 V, and incoming current and current in use SHALL each equal the integer nearest to `watts / 3.87 × 1000` mA, and the voltage, wattage, and both current rows SHALL each contain "estimativa".
7. IF the model identifier is absent from the catalog THEN the system SHALL show "Indisponível" for capacity, watts, volts, incoming current, and current in use, and SHALL NOT show a wattage number.
8. WHEN the dispositivo screen is visible THEN the system SHALL show marketing name or the model identifier, the model identifier, device name, chip name or "Desconhecido", process and max clock when the catalog has them, logical core count, performance core count and efficiency core count when sysctl reports them, L1 data cache and L2 cache when sysctl reports them, physical RAM bytes, GPU name, GPU family or its absence, ray tracing yes or no, recommended GPU memory, pixel width and height, scale, max frames per second, OS name and version, build, kernel, and uptime.
9. WHEN the sensores screen is visible AND the sensor exists THEN the system SHALL show accelerometer, gyroscope, and magnetometer X Y Z, pitch, roll, yaw, barometric pressure in kPa, and relative altitude in meters.
10. IF a sensor is absent on the device THEN the system SHALL show "Indisponível neste aparelho" for that sensor and SHALL keep the other sensors updating.
11. WHEN the user taps a core control THEN the system SHALL mark that core selected, and WHEN the user taps the selected core THEN the system SHALL clear the selection.
12. WHEN the user taps Pausar THEN the system SHALL stop sampling, and WHEN the user taps Retomar THEN the system SHALL sample again about once per second.
13. WHEN the painel is visible THEN the system SHALL show one banner ad region.
14. IF the banner fails to load THEN the system SHALL show the text "Anúncio indisponível" and SHALL keep every hardware figure visible.
15. The system SHALL NOT offer a price, a purchase button, or a restore-purchase action.
16. WHEN the user taps the battery card THEN the system SHALL open a battery screen that shows voltage, wattage, incoming current, and current in use.

**Independent Test**: Feed a known model identifier, a CPU fraction, and a battery state into the battery estimate and the catalog lookup. The numbers match criteria 3 through 7 without launching the app.

---

### P2: Rede, câmera e testes

**User Story**: As a phone owner, I want network detail, camera inventory, a speed test, and a short CPU and memory benchmark so that the sheet covers the measurements CPU-x adds beyond the live painel.

**Why P2**: These are real CPU-x sections. They are not required to read wattage and the live sheet.

**Acceptance Criteria**:

1. WHEN the user opens Rede THEN the system SHALL show Wi-Fi download total, Wi-Fi upload total, cellular download total, and cellular upload total for the current process session.
2. IF location permission is denied THEN the system SHALL show SSID as "Indisponível" and SHALL still show the byte totals.
3. WHEN the user opens Câmera THEN the system SHALL list each `AVCaptureDevice` with position and device type, and IF the list is empty THEN the system SHALL show "Nenhuma câmera".
4. WHEN the user runs the speed test THEN the system SHALL show ping in milliseconds, download bytes per second, and upload bytes per second, and IF the request fails THEN the system SHALL show "Teste falhou" and SHALL NOT show a zero as a successful result.
5. WHEN the user runs the CPU benchmark THEN the system SHALL show an integer score and a floating-point score, and the system SHALL label them as scores of this app, not as a Geekbench score.
6. WHEN the user runs the memory test THEN the system SHALL show read, write, and copy megabytes per second, and IF allocation fails THEN the system SHALL show "Memória insuficiente".

**Independent Test**: The speed-test parser turns a timed byte count into bytes per second, and a failed request produces the failure string rather than 0.

---

### P3: Checagem, widgets e ferramentas

**User Story**: As a phone owner, I want the interactive device check, a home-screen widget, a floating meter, and the small tools so that the app covers the remaining CPU-x sections.

**Why P3**: These are extra surfaces. The hardware sheet does not depend on them.

**Acceptance Criteria**:

1. WHEN the user starts the device check THEN the system SHALL record a pass, a fail, or "Indisponível" for display, touch, camera preview, microphone, speaker, and volume buttons.
2. WHEN the user adds the widget THEN the system SHALL show CPU percent, battery percent, and the estimated watts label on the home screen.
3. WHEN the user starts the floating meter THEN the system SHALL show CPU percent and battery percent in a Picture in Picture window.
4. WHEN the user opens Bússola THEN the system SHALL show heading in degrees while location permission is granted, and IF permission is denied THEN the system SHALL show "Localização desligada".
5. The tools screen SHALL offer a decibel meter, a screen ruler, a speaker tone, and a regex match, each updating from its own input.

**Independent Test**: A regex match over a fixed pattern and text returns the expected match count with no device.

---

## Edge Cases

- IF battery monitoring is off THEN the system SHALL show charge percent as "—" and SHALL NOT apply the wattage formula.
- IF CPU sampling returns no cores THEN the system SHALL show total CPU as 0% and SHALL show no core controls.
- WHEN the app leaves the foreground THEN the system SHALL stop the sample loop, and WHEN it becomes active THEN the system SHALL start the loop again.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| SONDA-01 | P1: Ficha ao vivo | Tasks | T4, T7 |
| SONDA-02 | P1: Ficha ao vivo | Tasks | T3, T4 |
| SONDA-03 | P1: Ficha ao vivo | Tasks | T2 |
| SONDA-04 | P1: Ficha ao vivo | Tasks | T2 |
| SONDA-05 | P1: Ficha ao vivo | Tasks | T2 |
| SONDA-06 | P1: Ficha ao vivo | Tasks | T2 |
| SONDA-07 | P1: Ficha ao vivo | Tasks | T2 |
| SONDA-08 | P1: Ficha ao vivo | Tasks | T8, T9 |
| SONDA-09 | P1: Ficha ao vivo | Tasks | T10, T11 |
| SONDA-10 | P1: Ficha ao vivo | Tasks | T10, T11 |
| SONDA-11 | P1: Ficha ao vivo | Tasks | T4 |
| SONDA-12 | P1: Ficha ao vivo | Tasks | T4, T7 |
| SONDA-13 | P1: Ficha ao vivo | Tasks | T5, T6, T7 |
| SONDA-14 | P1: Ficha ao vivo | Tasks | T5, T7 |
| SONDA-15 | P1: Ficha ao vivo | Tasks | T5, T7 |
| SONDA-16 | P2: Rede, câmera e testes | Tasks | T12, T13 |
| SONDA-17 | P2: Rede, câmera e testes | Tasks | T12, T13 |
| SONDA-18 | P2: Rede, câmera e testes | Tasks | T14, T25 |
| SONDA-19 | P2: Rede, câmera e testes | Tasks | T15, T26 |
| SONDA-20 | P2: Rede, câmera e testes | Tasks | T16, T27 |
| SONDA-21 | P2: Rede, câmera e testes | Tasks | T16, T27 |
| SONDA-22 | P3: Checagem, widgets e ferramentas | Tasks | T17, T28 |
| SONDA-23 | P3: Checagem, widgets e ferramentas | Tasks | T18, T19, T20 |
| SONDA-24 | P3: Checagem, widgets e ferramentas | Tasks | T21 |
| SONDA-25 | P3: Checagem, widgets e ferramentas | Tasks | T22, T29 |
| SONDA-26 | P3: Checagem, widgets e ferramentas | Tasks | T23, T24 |
| SONDA-27 | P1: Ficha ao vivo | Execute | Battery detail screen |

**Coverage:** 27 total, 27 mapped, 0 unmapped.

---

## Differences from the source

No binding capture. CPU-x is a reference for which facts exist, not a layout source. Sonda uses its own name and glass controls (AD-001).

## Sources

- `evidence/achados.md` — REA inventory of CPU-x 1.9.1: imports, strings, assets, and the encrypted executable.
- User, 2026-11-09: "i also want the app to have ALL reasorces of the cpux, like battery wattage, and all important infos".
- User, 2026-11-09: "Manter o nome Sonda", "somente anuncios", "Spec completo, implementar em fases".
- User, 2026-11-09: tap the battery card to open voltage, wattage, incoming current, and the current the battery is using. Chosen: both currents equal the existing estimate; the card keeps charge, state, and capacity.

---

## Success Criteria

- [ ] On a catalogued iPhone, the battery card shows live charge, state, and capacity, and the battery screen shows a wattage row that contains "estimativa" and the formula result, with incoming current equal to current in use.
- [ ] On an unknown model identifier, capacity and wattage show "Indisponível".
- [ ] Dispositivo and sensores show the fields in SONDA-08 and SONDA-09, or "Indisponível" when the hardware is missing.
- [ ] The painel has a banner and no purchase control.
