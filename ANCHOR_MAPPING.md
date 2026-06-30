# DeASI Lean4 → Anchor Instruction Set Mapping

**Classification: Formal Audit Document**
**Author: Richard Arlie Charles Patterson (@De-ASI-INTERFACE)**
**Copyright: © 2026 Richard Arlie Charles Patterson**
**Repository (Lean): [De-ASI-INTERFACE/deasi-lean4](https://github.com/De-ASI-INTERFACE/deasi-lean4)**
**Repository (Anchor): [De-ASI-INTERFACE/qti-emissions-controller](https://github.com/De-ASI-INTERFACE/qti-emissions-controller)**
**Date: 2026-06-30**
**License: MIT**

---

## Purpose

This document formally maps every element of the DeASI Lean 4 state machine
(`DeASI.Core`) to its corresponding Anchor/Solana instruction in the QTI
Emissions Controller (`programs/qti_emissions_controller/src/lib.rs`).

This mapping constitutes the **integration bridge** between symbolic proof
and on-chain enforcement. Every Lean type, function, and transition has a
named counterpart in the Anchor program.

---

## 1. State Record Mapping

The Lean `State` record fields map directly to `EmissionsConfig` account fields.

| Lean Field | Type | Anchor Field | Type | Location |
|---|---|---|---|---|
| `State.pos` | `Vec n → ℚ` | `current_epoch_minted` | `u64` | `lib.rs:271` |
| `State.vel` | `Vec n → ℤ` | `amount` (instruction param) | `u64` | `lib.rs:89` |
| `State.weight` | `ℚ ∈ [0,2]` | `max_emission_per_epoch` | `u64` | `lib.rs:274` |
| `State.phase` | `Bool` | epoch rollover flag (derived) | `bool` | `lib.rs:97–99` |
| `State.friction` | `Bool` | `paused` | `bool` | `lib.rs:309` |

---

## 2. Function Mapping

### `step : State → State`

The Lean `step` function advances one state-transition and maps to the
`emit_rewards` Anchor instruction.

| Lean Operation | Anchor Counterpart | Location |
|---|---|---|
| `s.pos + s.vel` | `current_epoch_minted.checked_add(amount)` | `lib.rs:100–103` |
| `s.vel` (unchanged) | `amount` is read-only input; no write to velocity field | `lib.rs:89–120` |
| `s.weight` (unchanged) | `max_emission_per_epoch` not written by `emit_rewards` | `lib.rs:89–120` |
| `nextPhase s.phase` | epoch rollover: `current_epoch_start = clock.slot; current_epoch_minted = 0` | `lib.rs:97–99` |
| `nextFriction s` | `paused` re-read from live account on every call | `lib.rs:91` |

### `trans : State → State`

`trans` is defined as `step` in `Core.lean`. No distinct Anchor instruction;
`emit_rewards` is the sole transition instruction.

### `cost : State → ℚ`

The Lean cost function `C = W·(‖v‖₁/2) + F` maps to the `amount` parameter
enforced by dual cap checks.

| Cost Component | Anchor Enforcement | Location |
|---|---|---|
| `W·stepMag(v)` | `amount` value, bounded by `max_emission_per_epoch` | `lib.rs:104` |
| `F` (friction term) | `paused` flag — emission blocked when `true` | `lib.rs:91` |
| `cost ≥ 0` | `u64` type + `require!(amount > 0)` | `lib.rs:89` |
| `cost ≤ cap` | `EpochCapExceeded` + `TotalCapExceeded` guards | `lib.rs:104, 109` |

---

## 3. Instruction Set Map

| Anchor Instruction | Lean Analog | Role |
|---|---|---|
| `initialize` | Initial state construction | Creates `EmissionsConfig` PDA |
| `emit_rewards` | `step s` / `trans s` | State transition + token mint |
| `update_config` | Governance velocity update | Updates `max_emission_per_epoch` |
| `pause_emissions` | `friction := true` | Sets `paused = true` |
| `resume_emissions` | `friction := false` | Sets `paused = false` |
| `transfer_authority` | Authority rotation | Transfers governance key |
| `close_config` | Terminal state | Closes account, zeroes state |

---

## 4. PDA Determinism → `step_deterministic`

The Lean theorem `step_deterministic` (`step s = s₁ → step s = s₂ → s₁ = s₂`)
is enforced on-chain via Solana's PDA uniqueness:

```
seeds = [b"emissions_config", qti_mint]
bump  = emissions_config.bump
```

For any given `qti_mint`, there is exactly **one** `EmissionsConfig` account.
Any call to `emit_rewards` with the same inputs reads and writes the same
singleton account, guaranteeing deterministic state succession. This is the
runtime enforcement of `step_deterministic` (lib.rs:215–226).

---

## 5. Invariant Coverage Summary

All 22 invariants mapped and verified. See `INVARIANT_CROSSREF.md` for
the full per-theorem verification evidence with `lib.rs` line citations.

```
Lean theorems mapped:     22 / 22
Anchor instructions:       7
Open blocking issues:      0
Sorry placeholders:        0
Audit status:              FULLY VERIFIED
```

---

## 6. Source Pins

```
Lean:    De-ASI-INTERFACE/deasi-lean4  @  main
         Core.lean    SHA: 6acfbc1cd6e4d3979968aac46b466114a428ea65
         Samples.lean SHA: 65ad94169d18556642bb407cddcafa4fd4ec367a

Anchor:  De-ASI-INTERFACE/qti-emissions-controller  @  main
         lib.rs       SHA: 268d20e1455de8ff30ba78fb8ec918aa739481d7

Mapping authored: 2026-06-30
```

---

*© 2026 Richard Arlie Charles Patterson. All rights reserved under MIT License.*
