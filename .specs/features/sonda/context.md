# Iphone Info Context

**Gathered:** 2026-11-09
**Spec:** `.specs/features/sonda/spec.md`
**Status:** Ready for design

---

## Feature Boundary

Tapping the battery card opens a battery screen with voltage, wattage, incoming current, and the current the battery is using. The card itself keeps charge, state, and capacity.

---

## Implementation Decisions

### Two currents

- Incoming current and the current in use show the same estimated milliamp value the painel already calculates.
- User, 2026-11-09: "As duas iguais à corrente única que o painel já calcula hoje."

### Battery card

- The card shows charge, state, and capacity.
- Voltage, wattage, and both currents are on the screen opened by the tap.
- User, 2026-11-09: "O card fica só com carga, estado e capacidade. Voltagem, wattage e as duas correntes ficam na tela nova."

### Agent's Discretion

- The new screen is a push from the painel, with the same glass background as the other sheets.
- Labels: Tensão, Potência, Corrente entrando, Corrente em uso.
- Both current rows use the existing string, including "estimativa".

### Declined / Undiscussed Gray Areas → Assumptions

None.

---

## Specific References

The user asked to open a new panel from the battery card showing voltage, wattage, incoming current, and the current the battery is using.

---

## Deferred Ideas

None.
