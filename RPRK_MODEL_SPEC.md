# RPRK — Richard Patterson Reward Kernel

**Version: 1.0.0**
**Author: Richard Arlie Charles Patterson**
**Copyright: © 2026 Richard Arlie Charles Patterson**
**Identifier: RP-RPRK-DEASI-QTI-2026-0627-001**
**Repository: [De-ASI-INTERFACE/deasi-lean4](https://github.com/De-ASI-INTERFACE/deasi-lean4)**
**License: MIT**

---

## 1. Overview

The Richard Patterson Reward Kernel (RPRK) is the unified mathematical and
on-chain reward model connecting the DeASI deterministic state-transition
formalization to the QTI Emissions Controller. It defines how symbolic proof
state maps to token emission quantities, epoch scheduling, and
governance-gated rate control.

RPRK bridges two repositories:
- **[deasi-lean4](https://github.com/De-ASI-INTERFACE/deasi-lean4)** — Lean 4 mechanized proofs of cost, determinism, and norm properties
- **[qti-emissions-controller](https://github.com/De-ASI-INTERFACE/qti-emissions-controller)** — Anchor/Solana on-chain enforcement of emission caps and governance

---

## 2. Core Cost Identity

The kernel is anchored to the DeASI cost function proved in `DeASI.Core`:

```
C = W · (‖v‖₁ / 2) + F

where:
  W ∈ [0, 2]       entity weight (rational)
  v                velocity vector (integer components, dim n)
  ‖v‖₁             L1 norm of velocity
  F ∈ {0, 1}       friction term (1 if L1 ball radius ≥ 10)

At W = 2, F = 1:
  C = ‖v‖₁ + 1     ← canonical reduction (cost_reduction_calc)

Canonical example:
  v = (2, 2), W = 3/2, F = 0
  C = (3/2) · 2 + 0 = 3
```

---

## 3. Emission Mapping

RPRK maps cost state `C` to on-chain emission quantity `E` via:

```
E = floor(E_max · (1 - C / C_ceiling))

where:
  E_max        = max_emission_per_epoch  (QTI controller param)
  C_ceiling    = reference cost ceiling  (governance-set)
  C            = current DeASI cost      (proof-verified)

Boundary conditions:
  C = 0            → E = E_max     (maximum reward, zero friction)
  C = C_ceiling    → E = 0         (no reward, at ceiling)
  C > C_ceiling    → E = 0         (clamped, never negative)
```

---

## 4. Epoch Schedule

```
Epoch duration:   216,000 slots  (~24 hours at 2.5 slots/sec)
Per-epoch cap:    100,000 QTI    (6 decimals: 100_000_000_000 raw)
Lifetime cap:     1,000,000,000 QTI
Minimum epoch:    9,000 slots    (~1 hour)
Maximum epoch:    6,480,000 slots (~30 days)
```

Epoch rollover resets `current_epoch_minted` to zero at
`clock.slot ≥ current_epoch_start + epoch_duration_slots`.

---

## 5. Security Invariants

| Invariant | Enforcement |
|---|---|
| `E ≥ 0` always | `checked_add`, floor clamp |
| `epoch_minted ≤ max_emission_per_epoch` | `EpochCapExceeded` on-chain |
| `total_minted ≤ total_emission_cap` | `TotalCapExceeded` on-chain |
| No private key holds mint authority | `emissions_authority` PDA only |
| Total cap monotone decreasing | `update_config` rejects increases |
| Pause halts all emission instantly | `paused` flag, checked first |
| Authority rotation requires current sig | `require_keys_neq!` guard |

---

## 6. PDA Architecture

```
emissions_authority  PDA:  seeds = [b"emissions_authority"]
emissions_config     PDA:  seeds = [b"emissions_config", qti_mint]
Program ID:                EMiSCtRL1QTIDeASIInterface111111111111111111
Deployer:                  CuAjiyp7Rfj4vvjQ8JWVMLeXYYumaTYKpZf9oWs2A4my
```

---

## 7. Formal Guarantees (from DeASI Lean 4)

Proved mechanically in `De-ASI-INTERFACE/deasi-lean4`:

| Theorem | Statement |
|---|---|
| `cost_nonneg` | `0 ≤ cost s` for all states |
| `cost_lower_bound` | `F ≤ cost s` always |
| `cost_ge_weight_mul_stepMag` | `W · ‖v‖₁/2 ≤ cost s` |
| `cost_reduction_calc` | At W=2, F=1: `cost s = ‖v‖₁ + 1` |
| `step_deterministic` | Every state has exactly one successor |
| `trans_deterministic` | Transition function is injective |

---

## 8. Governance

All parameter changes require Squads vault PDA signature. Total emission
cap may only decrease. Emergency pause/resume controlled exclusively by
governance. Authority transfer is irreversible without the new authority's
private key.

---

## 9. Identity

```
Author:      Richard Arlie Charles Patterson
GitHub:      @De-ASI-INTERFACE
Org:         @QuantumTradingInfinity · @richy.ai
Repos:       deasi-lean4 · qti-emissions-controller
Version:     1.0.0
Date:        2026-06-27
Identifier:  RP-RPRK-DEASI-QTI-2026-0627-001
License:     MIT
```

---

*© 2026 Richard Arlie Charles Patterson. All rights reserved under MIT License.*
