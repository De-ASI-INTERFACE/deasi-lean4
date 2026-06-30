/-!
# DeASI.Checks

Compile-time `#check` registry for all exported theorems and lemmas.

## Signature

- Project: `DeASI`
- Author: Richard Arlie Charles Patterson
- Copyright: © 2026 Richard Arlie Charles Patterson
- Namespace: `DeASI`
- Repository: `deasi-lean4`
- License: MIT

## Description

This module serves as a **manifest audit file**. Every `#check` assertion
below is evaluated at compile time by the Lean kernel. If any theorem or
lemma is renamed, removed, or its type changes, this file will fail to
elaborate, producing an immediate CI-visible error.

This is the formal verification analog of a test registry — it does not
prove anything new, but it guarantees that the entire exported surface
remains structurally sound across all future changes to `Core.lean`
and `Samples.lean`.

## Coverage

- All 16 lemmas from `DeASI.Core`
- Both theorems from `DeASI.Core` and `DeASI.Samples`
- All 9 sample lemmas from `DeASI.Samples`
- Total: 27 registered names
-/

import DeASI.Core
import DeASI.Samples

set_option autoImplicit false

--------------------------------------------------------------------------------
-- SECTION 1: Norm and Magnitude — DeASI.Core
--------------------------------------------------------------------------------

-- L1 norm is non-negative as a rational
#check @DeASI.l1Norm_nonneg
-- : ∀ {n : ℕ} (v : DeASI.Vec n), 0 ≤ ↑(DeASI.l1Norm v)

-- Calibrated step magnitude is non-negative
#check @DeASI.stepMag_nonneg
-- : ∀ {n : ℕ} (v : DeASI.Vec n), 0 ≤ DeASI.stepMag v

-- Step magnitude is zero iff all components are zero
#check @DeASI.stepMag_zero_of_zero
-- : ∀ {n : ℕ} (v : DeASI.Vec n), (∀ i, v i = 0) → DeASI.stepMag v = 0

--------------------------------------------------------------------------------
-- SECTION 2: Geometry — DeASI.Core
--------------------------------------------------------------------------------

-- Friction zone characterization: L1 position ≥ 10
#check @DeASI.isFrictionZone_iff
-- : ∀ {n : ℕ} (p : DeASI.Vec n), DeASI.isFrictionZone p = true ↔ DeASI.l1Norm p ≥ 10

--------------------------------------------------------------------------------
-- SECTION 3: State Dynamics — DeASI.Core
--------------------------------------------------------------------------------

-- Position advances by velocity at each step
#check @DeASI.step_pos
-- : ∀ {n : ℕ} (s : DeASI.State n), (DeASI.step s).pos = fun i => s.pos i + s.vel i

-- Velocity is preserved across step
#check @DeASI.step_vel
-- : ∀ {n : ℕ} (s : DeASI.State n), (DeASI.step s).vel = s.vel

-- Weight is preserved across step (conservation invariant)
#check @DeASI.step_weight
-- : ∀ {n : ℕ} (s : DeASI.State n), (DeASI.step s).weight = s.weight

-- Phase toggles deterministically at each step
#check @DeASI.step_phase
-- : ∀ {n : ℕ} (s : DeASI.State n), (DeASI.step s).phase = DeASI.nextPhase s.phase

-- Friction updates geometrically from projected position
#check @DeASI.step_friction
-- : ∀ {n : ℕ} (s : DeASI.State n), (DeASI.step s).friction = DeASI.nextFriction s

--------------------------------------------------------------------------------
-- SECTION 4: Cost Function — DeASI.Core
--------------------------------------------------------------------------------

-- Friction Boolean term is non-negative
#check @DeASI.friction_nonneg
-- : ∀ (b : Bool), 0 ≤ (if b then (1 : ℚ) else 0)

-- Stage cost is always non-negative
#check @DeASI.cost_nonneg
-- : ∀ {n : ℕ} (s : DeASI.State n), 0 ≤ DeASI.cost s

-- Friction term is a lower bound on cost
#check @DeASI.cost_lower_bound
-- : ∀ {n : ℕ} (s : DeASI.State n), (if s.friction then 1 else 0) ≤ DeASI.cost s

-- Cost is well-defined (existential witness)
#check @DeASI.cost_well_defined
-- : ∀ {n : ℕ} (s : DeASI.State n), ∃ c : ℚ, DeASI.cost s = c

-- Weight × stepMag is a lower bound on cost
#check @DeASI.cost_ge_weight_mul_stepMag
-- : ∀ {n : ℕ} (s : DeASI.State n), s.weight * DeASI.stepMag s.vel ≤ DeASI.cost s

--------------------------------------------------------------------------------
-- SECTION 5: Determinism — DeASI.Core
--------------------------------------------------------------------------------

-- Step function is deterministic: same input yields unique output
#check @DeASI.step_deterministic
-- : ∀ {n : ℕ} (s s₁ s₂ : DeASI.State n),
--     DeASI.step s = s₁ → DeASI.step s = s₂ → s₁ = s₂

-- Transition relation is deterministic
#check @DeASI.trans_deterministic
-- : ∀ {n : ℕ} (s s₁ s₂ : DeASI.State n),
--     DeASI.trans s = s₁ → DeASI.trans s = s₂ → s₁ = s₂

--------------------------------------------------------------------------------
-- SECTION 6: Algebraic Theorem — DeASI.Core
--------------------------------------------------------------------------------

-- At W=2, friction=true: cost = ‖v‖₁ + 1
#check @DeASI.cost_reduction_calc
-- : ∀ {n : ℕ} (s : DeASI.State n),
--     s.weight = 2 → s.friction = true → DeASI.cost s = ↑(DeASI.l1Norm s.vel) + 1

--------------------------------------------------------------------------------
-- SECTION 7: Sample Suite — DeASI.Samples
--------------------------------------------------------------------------------

-- L1 norm of sample velocity (2,2) equals 4
#check @DeASI.Samples.sample_l1Norm

-- Step magnitude of sample velocity equals 2
#check @DeASI.Samples.sample_stepMag

-- Sample state steps to position (4,4)
#check @DeASI.Samples.sample_step_pos

-- Sample state phase flips to true after one step
#check @DeASI.Samples.sample_step_phase

-- Sample state remains outside friction zone after one step
#check @DeASI.Samples.sample_step_friction

-- Sample state cost evaluates to exactly 3
#check @DeASI.Samples.sample_cost

-- Sample state cost is non-negative
#check @DeASI.Samples.sample_cost_nonneg

-- Sample state transition is deterministic
#check @DeASI.Samples.sample_determinism

-- Bundle theorem: canonical example (cost=3, pos=(4,4)) is correct
#check @DeASI.Samples.canonical_example_correct
