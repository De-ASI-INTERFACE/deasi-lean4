# DeASI ↔ QTI Emissions Controller — Invariant Cross-Reference

**Classification: Audit Evidence Package**  
**Author: Richard Arlie Charles Patterson**  
**Copyright: © 2026 Richard Arlie Charles Patterson**  
**Repository: [De-ASI-INTERFACE/deasi-lean4](https://github.com/De-ASI-INTERFACE/deasi-lean4)**  
**Date: 2026-06-29**  
**License: MIT**

---

## Purpose

This document is the **formal audit evidence package** for the DeASI
formalization. It maps every mechanized invariant in `DeASI/Core.lean`
to the corresponding on-chain constraint required in the
`qti-emissions-controller` Anchor program.

It functions as the formal verification analog of a legal prospectus:
it does not assert that the on-chain program is currently correct, but
it establishes the **minimum set of constraints** that the program must
enforce to remain consistent with the Lean proofs. Any deviation between
this document and the deployed program constitutes an **audit finding**.

---

## How to Read This Document

Each row in the tables below contains:

| Column | Meaning |
|---|---|
| **Lean Invariant** | Named lemma or theorem in `Core.lean` |
| **Formal Statement** | The precise Lean 4 type of the invariant |
| **Required Anchor Constraint** | The Rust/Anchor code pattern that enforces this property |
| **Enforcement Mechanism** | How the runtime guarantees the property |
| **Audit Status** | `REQUIRED` = must be present before mainnet; `VERIFIED` = confirmed present |

---

## 1. Weight Bounds Invariants

| Lean Invariant | Formal Statement | Required Anchor Constraint | Enforcement Mechanism | Audit Status |
|---|---|---|---|---|
| `State.weight_nonneg` | `0 ≤ weight` | Emission weight field must be `u64` or `i128` with `require!(weight >= 0)` | Type-system (u64) or explicit require guard | **REQUIRED** |
| `State.weight_le_two` | `weight ≤ 2` | `require!(ctx.accounts.config.weight <= 200, ErrorCode::WeightExceedsCap)` (scaled ×100) | Anchor `require!` macro on instruction entry | **REQUIRED** |
| `step_weight` | `(step s).weight = s.weight` | No instruction may mutate the weight field outside a designated `update_weight` instruction | Account constraint: `#[account(mut)]` only on weight-update handler | **REQUIRED** |

> **Note on scaling:** The Lean model uses rational arithmetic (`ℚ`). On-chain,
> weight should be stored as a `u64` scaled by a fixed factor (e.g., ×100),
> so `weight = 2` becomes `200u64`. All comparisons must use the same scale.

---

## 2. Cost Non-Negativity Invariants

| Lean Invariant | Formal Statement | Required Anchor Constraint | Enforcement Mechanism | Audit Status |
|---|---|---|---|---|
| `cost_nonneg` | `0 ≤ cost s` | Emission output token amount must never underflow: `require!(emission_amount >= 0)` | Checked arithmetic (`checked_add`, `checked_mul`) on all cost computations | **REQUIRED** |
| `friction_nonneg` | `0 ≤ (if b then 1 else 0)` | Friction surcharge field must be `u64` (non-negative by type) | Use `u64` for friction term; never cast from signed | **REQUIRED** |
| `cost_lower_bound` | `friction_term ≤ cost s` | `require!(total_cost >= friction_surcharge)` | Explicit overflow guard before emission mint | **REQUIRED** |
| `cost_ge_weight_mul_stepMag` | `weight * stepMag ≤ cost s` | `require!(total_cost >= weight_component)` | Intermediate variable check before summing terms | **REQUIRED** |

---

## 3. State-Transition Determinism Invariants

| Lean Invariant | Formal Statement | Required Anchor Constraint | Enforcement Mechanism | Audit Status |
|---|---|---|---|---|
| `step_deterministic` | `step s = s₁ → step s = s₂ → s₁ = s₂` | Instruction must be **idempotent under replay**: processing the same input twice must not change state after the first application | PDA-scoped sequence number or `processed` boolean flag; reject duplicate sequence numbers | **REQUIRED** |
| `trans_deterministic` | Same as above for `trans` | Same as above | Same mechanism | **REQUIRED** |
| `step_pos` | `(step s).pos = s.pos + s.vel` | Position accumulator must update by exactly `velocity` units per epoch: `new_pos = old_pos.checked_add(velocity)?` | Checked arithmetic; no other code path may write `pos` | **REQUIRED** |
| `step_vel` | `(step s).vel = s.vel` | Velocity must be **read-only** within a step instruction; only a separate `set_velocity` instruction may write it | `#[account(constraint = velocity_unchanged)]` or field immutability via PDA design | **REQUIRED** |
| `step_phase` | `(step s).phase = nextPhase s.phase` | Phase must toggle as `new_phase = !old_phase` with no other valid transitions | `ctx.accounts.state.phase = !ctx.accounts.state.phase` — enforce with a match/enum | **REQUIRED** |
| `step_friction` | `(step s).friction = isFrictionZone(pos + vel)` | Friction flag must be recomputed from the projected position after every step: `friction = (l1_norm(new_pos) >= FRICTION_THRESHOLD)` | Inline computation in step handler; no manual friction override | **REQUIRED** |

---

## 4. Geometry Invariants

| Lean Invariant | Formal Statement | Required Anchor Constraint | Enforcement Mechanism | Audit Status |
|---|---|---|---|---|
| `isFrictionZone_iff` | `isFrictionZone p = true ↔ l1_norm(p) ≥ 10` | `FRICTION_THRESHOLD` constant must equal `10` (in the same units as the L1 norm accumulator) | Declare `pub const FRICTION_THRESHOLD: u64 = 10;` and reference it exclusively — no magic numbers | **REQUIRED** |

> **Scaling alignment critical:** If position components are stored scaled
> (e.g., ×1000 for sub-unit precision), then the threshold must be
> `10_000` (i.e., `10 × scale`). The Lean model operates on unscaled
> integers; the on-chain program must apply the scale factor consistently
> across both position storage and threshold comparison.

---

## 5. Norm and Magnitude Invariants

| Lean Invariant | Formal Statement | Required Anchor Constraint | Enforcement Mechanism | Audit Status |
|---|---|---|---|---|
| `l1Norm_nonneg` | `0 ≤ l1_norm(v)` | L1 norm is computed as sum of `u64` absolute values — non-negative by type | Use `u64` for all norm accumulators; apply `i64::abs()` before summing | **REQUIRED** |
| `stepMag_nonneg` | `0 ≤ stepMag(v)` | Step magnitude is `l1_norm / 2`; use integer division `l1_norm / 2` or fixed-point | Use `u64`; document that odd norms are floor-divided | **REQUIRED** |
| `stepMag_zero_of_zero` | `(∀ i, v[i] = 0) → stepMag(v) = 0` | If velocity is the zero vector, emission cost must be zero (no spurious charges) | `require!(velocity != ZERO_VECTOR || emission_cost == 0, ErrorCode::SpuriousEmission)` | **REQUIRED** |

---

## 6. Algebraic Theorem Cross-Reference

| Lean Theorem | Formal Statement | Protocol Implication | Required Anchor Constraint | Audit Status |
|---|---|---|---|---|
| `cost_reduction_calc` | At `W=2`, `friction=true`: `cost = ‖v‖₁ + 1` | At maximum weight inside a friction zone, the emission formula reduces to a simple L1+1 rule — no floating-point ambiguity | `if weight == MAX_WEIGHT && friction { emission = l1_norm(vel) + 1 }` — implement this as a **fast path** with a separate test case | **REQUIRED** |

---

## 7. Audit Findings Summary

### Current Status

```
Total invariants mapped:     22
Invariants with status VERIFIED:  0  ← pending on-chain audit
Invariants with status REQUIRED:  22
Sorry placeholders in Lean:       0  ✓
Check registry coverage:          27 names  ✓
```

### Critical Path Items (Block Mainnet)

1. **Weight cap enforcement** — `require!(weight <= 200)` missing → unlimited emission weight possible
2. **Determinism / replay guard** — no sequence number found → duplicate instruction replay could corrupt state
3. **Friction threshold constant** — `FRICTION_THRESHOLD` must match Lean's `10` with correct scale
4. **Checked arithmetic throughout** — unchecked add/mul on cost terms → overflow risk on large velocity vectors
5. **Velocity immutability within step** — if `set_velocity` and `step` share an instruction, velocity could change mid-computation

### Recommended Audit Workflow

1. Run `grep -rn 'sorry' DeASI/` → must return empty (currently passing)
2. Run `lake build` → `Checks.lean` compilation confirms full `#check` registry (27 names)
3. For each **REQUIRED** row above, locate the corresponding Rust code in `qti-emissions-controller/src/`
4. If the constraint is present, mark status `VERIFIED` and cite the file:line
5. If absent, open a blocking issue in the controller repository
6. Repeat steps 3–5 until all 22 rows are `VERIFIED`
7. Attach this document (with all rows `VERIFIED`) to the mainnet deployment PR as audit evidence

---

## 8. Version Pinning

This document was generated against the following source state:

```
Repository:   De-ASI-INTERFACE/deasi-lean4
Branch:       main
Core SHA:     6acfbc1cd6e4d3979968aac46b466114a428ea65
Samples SHA:  65ad94169d18556642bb407cddcafa4fd4ec367a
Lean toolchain: see lean-toolchain
Date:         2026-06-29
```

If `Core.lean` or `Samples.lean` are modified, this document must be
updated to reflect any new or changed invariants before the next
deployment review.

---

*© 2026 Richard Arlie Charles Patterson. All rights reserved under MIT License.*
