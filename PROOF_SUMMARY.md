# DeASI Formal Proof Summary

**Author: Richard Arlie Charles Patterson**  
**Copyright: © 2026 Richard Arlie Charles Patterson**  
**Project: DeASI**  
**License: MIT**

---

## What is DeASI?

DeASI formalizes a **deterministic state-transition system** over a discrete
coordinate space, equipped with a calibrated weighted L1-norm cost function.
The formalization is mechanized in Lean 4 with full proof coverage across
norm properties, transition determinism, cost nonnegativity, and algebraic
reduction theorems.

---

## Cost Identity

The central formal result is the cost identity:

```
C = W · (‖v‖₁ / 2) + F
```

where `W` is entity weight, `v` is velocity, `‖v‖₁` is the L1 norm of velocity,
and `F ∈ {0, 1}` is the active friction term.

At maximum weight `W = 2` inside a friction zone `F = 1`:

```
C = ‖v‖₁ + 1
```

This reduction is the core theorem `cost_reduction_calc`, proved
algebraically by a five-step `calc` chain in Lean 4.

---

## Proof Architecture

```
DeASI/
  Core.lean
    ├─ Section: NormDefinitions
    ├─ Section: Geometry
    ├─ Section: StateDynamics
    ├─ Section: CostFunction
    ├─ Section: Determinism
    └─ Section: AlgebraicTheory

  Samples.lean
    ├─ Section: SampleDefinitions
    └─ Section: SampleLemmas

  Docs.lean
    └─ doc-gen4 entry point
```

---

## Tactic Inventory

| Tactic | Usage |
|---|---|
| `positivity` | Nonnegativity of norms, products, rationals |
| `nlinarith` | Combining nonnegativity inequalities |
| `norm_num` | Numeric computation and arithmetic |
| `ring_nf` | Rational algebraic normalization |
| `simp` | Definitional reduction and Boolean cases |
| `fin_cases` | Case analysis over `Fin n` vectors |
| `funext` | Pointwise function equality |
| `calc` | Explicit equational proof chains |
| `by_cases` | Boolean friction case splits |
| `aesop` | General proof search fallback |

---

## Canonical Example

```
State:     pos = (2, 2), vel = (2, 2), W = 3/2, friction = false
L1 norm:   ‖v‖₁ = 4
Step mag:  4 / 2 = 2
Cost:      (3/2) · 2 + 0 = 3
Successor: pos = (4, 4), phase = true, friction = false
```

Proved by `canonical_example_correct` in `DeASI.Samples`.

---

## Guarantees

- **Determinism** — every state has exactly one successor
- **Cost nonnegativity** — `0 ≤ cost s` for all valid states in any dimension
- **Domain safety** — weight bounds `[0, 2]` enforced by proof fields
- **Geometric friction** — friction zone determined by L1 ball radius 10
- **Algebraic reduction** — cost reduces to `‖v‖₁ + 1` at max weight in friction zone

---

*© 2026 Richard Arlie Charles Patterson. All rights reserved under MIT License.*
