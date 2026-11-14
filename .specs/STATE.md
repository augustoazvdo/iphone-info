# Project State

## Decisions

### AD-001
- **Decision**: The product name is Sonda. It does not use the CPU-x name, icon, strings, or artwork.
- **Reason**: The user chose "Manter o nome Sonda" on 2026-11-09. The reference app is a third-party App Store title.
- **Trade-off**: The app will not be recognized as CPU-x by name.
- **Scope**: All features.
- **Date**: 2026-11-09
- **Status**: superseded by AD-006 on 2026-11-14 (name only; the no-CPU-x-brand rule still holds)

### AD-002
- **Decision**: Iphone Info shows ads and does not sell a Pro upgrade.
- **Reason**: The user chose "somente anuncios" on 2026-11-09.
- **Trade-off**: Information that CPU-x locks behind Pro is free here. There is no purchase flow.
- **Scope**: All features.
- **Date**: 2026-11-09
- **Status**: active

### AD-003
- **Decision**: The spec describes the whole monitor. Implementation ships in phases, P1 first.
- **Reason**: The user chose "Spec completo, implementar em fases" on 2026-11-09.
- **Trade-off**: Speed test, device check, widgets, and tools wait for later tasks.
- **Scope**: Feature `sonda`.
- **Date**: 2026-11-09
- **Status**: active

### AD-004
- **Decision**: Git tracks `CPU-x.ipa`. It ignores `extracted/` and Xcode `build/`.
- **Reason**: The user chose "Quero o IPA versionado também" on 2026-11-09.
- **Trade-off**: The repository holds a third-party App Store package.
- **Scope**: Repository contents.
- **Date**: 2026-11-09
- **Status**: active

### AD-005
- **Decision**: Battery power, voltage, and current are labeled estimates. Live charge percent and charging state come from iOS.
- **Reason**: The user asked for battery wattage and the rest of the important figures on 2026-11-09. Public iOS APIs expose level and state only.
- **Trade-off**: The wattage row is not a measurement from the battery controller.
- **Scope**: Feature `sonda`, battery section.
- **Date**: 2026-11-09
- **Status**: active

### AD-006
- **Decision**: The product name is Iphone Info. The Xcode project is `IphoneInfo/IphoneInfo.xcodeproj`, the bundle id is `com.azvdo.iphoneinfo`, the GitHub repository is `augustoazvdo/iphone-info`, and the display name is "Iphone Info".
- **Reason**: The user asked to rename the project and repository to Iphone Info on 2026-11-14.
- **Trade-off**: Swift type names, file names, the `sonda_*` C symbols, and the `.specs/features/sonda` folder still say Sonda. The local folder `REA-CPUZ` keeps its name because the Cursor workspace depends on it. The bundle id change makes an old Sonda install a different app for iOS.
- **Scope**: All features. Replaces the name in AD-001.
- **Date**: 2026-11-14
- **Status**: active

## Handoff

- Feature `sonda`: spec approved 2026-11-09, user: "aprovado". Tasks approved 2026-11-09, user: "aprovado, depois configuro o git, por enquanto mantenha somente local o versionamento".
- Versioning stays local. The user sets `user.name` and `user.email` later. The agent does not set git config and does not push.
- Commits wait for that identity. Work is applied to the tree and recorded in tasks.md Handoff until then.
