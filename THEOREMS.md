# DeASI Theorem Index

**Author: Richard Arlie Charles Patterson**  
**Copyright: © 2026 Richard Arlie Charles Patterson**  
**Project: DeASI — Deterministic State-Transition Framework for Symbolic Reasoning**  
**Repository: [De-ASI-INTERFACE/deasi-lean4](https://github.com/De-ASI-INTERFACE/deasi-lean4)**

---

This document is the canonical index of all formally mechanized theorems and lemmas
in the DeASI Lean 4 formalization. Every entry corresponds to a named definition,
lemma, or theorem in `DeASI/Core.lean` or `DeASI/Samples.lean`.

---

## Core Theory (`DeASI.Core`)

### Norm and Magnitude

| Name | Statement | Location |
|---|---|---|
| `l1Norm_nonneg` | `0 ≤ (l1Norm v : ℚ)` for all `v : Vec n` | `Core.lean` |
| `stepMag_nonneg` | `0 ≤ stepMag v` for all `v : Vec n` | `Core.lean` |
| `stepMag_zero_of_zero` | If `∀ i, v i = 0` then `stepMag v = 0` | `Core.lean` |

### Geometry

| Name | Statement | Location |
|---|---|---|
| `isFrictionZone_iff` | `isFrictionZone p = true ↔ l1Norm p ≥ 10` | `Core.lean` |

### Dynamics

| Name | Statement | Location |
|---|---|---|
| `step_pos` | `(step s).pos = fun i => s.pos i + s.vel i` | `Core.lean` |
| `step_vel` | `(step s).vel = s.vel` | `Core.lean` |
| `step_weight` | `(step s).weight = s.weight` | `Core.lean` |
| `step_phase` | `(step s).phase = nextPhase s.phase` | `Core.lean` |
| `step_friction` | `(step s).friction = nextFriction s` | `Core.lean` |

### Cost

| Name | Statement | Location |
|---|---|---|
| `friction_nonneg` | `0 ≤ (if b then 1 else 0 : ℚ)` for all `b : Bool` | `Core.lean` |
| `cost_nonneg` | `0 ≤ cost s` for all valid states `s` | `Core.lean` |
| `cost_lower_bound` | `(if s.friction then 1 else 0) ≤ cost s` | `Core.lean` |
| `cost_well_defined` | `∃ c : ℚ, cost s = c` | `Core.lean` |
| `cost_ge_weight_mul_stepMag` | `s.weight * stepMag s.vel ≤ cost s` | `Core.lean` |

### Determinism

| Name | Statement | Location |
|---|---|---|
| `step_deterministic` | `step s = s₁ → step s = s₂ → s₁ = s₂` | `Core.lean` |
| `trans_deterministic` | `trans s = s₁ → trans s = s₂ → s₁ = s₂` | `Core.lean` |

### Algebraic Theorem

| Name | Statement | Location |
|---|---|---|
| `cost_reduction_calc` | If `s.weight = 2` and `s.friction = true` then `cost s = ‖v‖₁ + 1` | `Core.lean` |

---

## Sample Suite (`DeASI.Samples`)

| Name | Statement | Location |
|---|---|---|
| `sample_l1Norm` | `l1Norm sampleVel = 4` | `Samples.lean` |
| `sample_stepMag` | `stepMag sampleVel = 2` | `Samples.lean` |
| `sample_step_pos` | `(step sampleState).pos = (4, 4)` | `Samples.lean` |
| `sample_step_phase` | `(step sampleState).phase = true` | `Samples.lean` |
| `sample_step_friction` | `(step sampleState).friction = false` | `Samples.lean` |
| `sample_cost` | `cost sampleState = 3` | `Samples.lean` |
| `sample_cost_nonneg` | `0 ≤ cost sampleState` | `Samples.lean` |
| `sample_determinism` | Successor of sampleState is unique | `Samples.lean` |
| `canonical_example_correct` | `cost sampleState = 3 ∧ pos = (4, 4)` | `Samples.lean` |

---

## Proof Summary

```
Total definitions:  8
Total lemmas:      16
Total theorems:     2
Total sections:     6
Total namespaces:   2
Author:             Richard Arlie Charles Patterson
Year:               2026
License:            MIT
```

---

## Key Identity

```
C = W · (‖v‖₁ / 2) + F

where:
  W ∈ [0, 2]     weight
  v              velocity vector (integer components)
  ‖v‖₁           L1 norm of velocity
  F ∈ {0, 1}     friction term (1 if in friction zone)

At W = 2, F = 1:
  C = ‖v‖₁ + 1

Canonical example: v = (2, 2), W = 3/2, F = 0
  C = (3/2) · 2 + 0 = 3
```

---

*© 2026 Richard Arlie Charles Patterson. All rights reserved under MIT License.*
