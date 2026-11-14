# Project State

## Decisions

### AD-001
- **Decision**: The product name is Sonda. It does not use the CPU-x name, icon, strings, or artwork.
- **Reason**: The user chose "Manter o nome Sonda" on 2026-11-09. The reference app is a third-party App Store title.
- **Trade-off**: The app will not be recognized as CPU-x by name.
- **Scope**: All features.
- **Date**: 2026-11-09
- **Status**: active

### AD-002
- **Decision**: Sonda shows ads and does not sell a Pro upgrade.
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

## Handoff

- Feature `sonda`: spec approved 2026-11-09, user: "aprovado". Tasks approved 2026-11-09, user: "aprovado, depois configuro o git, por enquanto mantenha somente local o versionamento".
- Versioning stays local. The user sets `user.name` and `user.email` later. The agent does not set git config and does not push.
- Commits wait for that identity. Work is applied to the tree and recorded in tasks.md Handoff until then.
