/-!
# DeASI.Core

Deterministic state-transition theory for symbolic reasoning
and calibrated cost proofs.

## Signature

- Project: `DeASI`
- Author: Richard Arlie Charles Patterson
- Copyright: © 2026 Richard Arlie Charles Patterson
- Namespace: `DeASI`
- Repository: `deasi-lean4`
- License: MIT

## Description

This module defines the reusable core of the DeASI formalization:
state spaces, transition rules, cost functions, and generic proof
lemmas. It is designed to be the stable import root for all downstream
theorem files and documentation generation.
-/

import Mathlib
import Aesop

set_option autoImplicit false
set_option maxHeartbeats 400000

open scoped BigOperators

namespace DeASI

--------------------------------------------------------------------------------
-- 0. Notation
--------------------------------------------------------------------------------

abbrev Vec (n : ℕ) := Fin n → Int

--------------------------------------------------------------------------------
-- 1. L1 norm and step magnitude
--------------------------------------------------------------------------------

section NormDefinitions

/-- L1 norm over integer vectors.
    Defined as the sum of absolute values of components. -/
def l1Norm {n : ℕ} (v : Vec n) : ℕ :=
  ∑ i, Int.natAbs (v i)

/-- Calibrated step magnitude.
    Half the L1 norm, so that v=(2,2) gives magnitude 2,
    preserving the canonical cost example: W=1.5 → cost=3. -/
def stepMag {n : ℕ} (v : Vec n) : ℚ :=
  (l1Norm v : ℚ) / 2

lemma l1Norm_nonneg {n : ℕ} (v : Vec n) : 0 ≤ (l1Norm v : ℚ) := by
  unfold l1Norm
  positivity

lemma stepMag_nonneg {n : ℕ} (v : Vec n) : 0 ≤ stepMag v := by
  unfold stepMag
  have h := l1Norm_nonneg v
  positivity

lemma stepMag_zero_of_zero {n : ℕ} (v : Vec n) (h : ∀ i, v i = 0) : stepMag v = 0 := by
  unfold stepMag l1Norm
  have hs : ∑ i : Fin n, Int.natAbs (v i) = 0 := by
    apply Finset.sum_eq_zero
    intro i _
    rw [h i]
  rw [hs]
  norm_num

end NormDefinitions

--------------------------------------------------------------------------------
-- 2. Geometry and friction
--------------------------------------------------------------------------------

section Geometry

/-- An entity enters a high-friction zone when its projected
    L1 position exceeds a radius of 10 units. -/
def isFrictionZone {n : ℕ} (p : Vec n) : Bool :=
  l1Norm p ≥ 10

lemma isFrictionZone_iff {n : ℕ} (p : Vec n) :
    isFrictionZone p = true ↔ l1Norm p ≥ 10 := by
  rfl

end Geometry

--------------------------------------------------------------------------------
-- 3. State, dynamics, and transition
--------------------------------------------------------------------------------

section StateDynamics

/-- Core DeASI state record.
    All domain constraints are stored as proof fields. -/
structure State (n : ℕ) where
  pos : Vec n
  vel : Vec n
  weight : ℚ
  phase : Bool
  friction : Bool
  weight_nonneg : 0 ≤ weight
  weight_le_two : weight ≤ 2

/-- Deterministic phase toggle. -/
def nextPhase : Bool → Bool
  | true => false
  | false => true

/-- Deterministic friction update based on projected geometry. -/
def nextFriction {n : ℕ} (s : State n) : Bool :=
  isFrictionZone (fun i => s.pos i + s.vel i)

/-- Deterministic successor state.
    Position advances by velocity; friction updates geometrically. -/
def step {n : ℕ} (s : State n) : State n :=
{ pos := fun i => s.pos i + s.vel i
  vel := s.vel
  weight := s.weight
  phase := nextPhase s.phase
  friction := nextFriction s
  weight_nonneg := s.weight_nonneg
  weight_le_two := s.weight_le_two }

def trans {n : ℕ} (s : State n) : State n := step s

lemma step_pos {n : ℕ} (s : State n) :
    (step s).pos = fun i => s.pos i + s.vel i := rfl

lemma step_vel {n : ℕ} (s : State n) : (step s).vel = s.vel := rfl

lemma step_weight {n : ℕ} (s : State n) : (step s).weight = s.weight := rfl

lemma step_phase {n : ℕ} (s : State n) : (step s).phase = nextPhase s.phase := rfl

lemma step_friction {n : ℕ} (s : State n) : (step s).friction = nextFriction s := rfl

end StateDynamics

--------------------------------------------------------------------------------
-- 4. Cost function
--------------------------------------------------------------------------------

section CostFunction

/-- Stage cost.
    C = W * (||v||_1 / 2) + F, where F in {0,1} is the friction term. -/
def cost {n : ℕ} (s : State n) : ℚ :=
  s.weight * stepMag s.vel + (if s.friction then 1 else 0)

lemma friction_nonneg (b : Bool) : 0 ≤ (if b then (1 : ℚ) else 0) := by
  cases b <;> norm_num

lemma cost_nonneg {n : ℕ} (s : State n) : 0 ≤ cost s := by
  unfold cost
  have hmul : 0 ≤ s.weight * stepMag s.vel := by
    apply mul_nonneg s.weight_nonneg (stepMag_nonneg s.vel)
  have hfr : 0 ≤ (if s.friction then (1 : ℚ) else 0) := friction_nonneg s.friction
  linarith

lemma cost_lower_bound {n : ℕ} (s : State n) :
    (if s.friction then (1 : ℚ) else 0) ≤ cost s := by
  unfold cost
  have hmul : 0 ≤ s.weight * stepMag s.vel :=
    mul_nonneg s.weight_nonneg (stepMag_nonneg s.vel)
  by_cases hfr : s.friction
  · simp [hfr, hmul]
  · simp [hfr, hmul]

lemma cost_well_defined {n : ℕ} (s : State n) : ∃ c : ℚ, cost s = c :=
  ⟨cost s, rfl⟩

lemma cost_ge_weight_mul_stepMag {n : ℕ} (s : State n) :
    s.weight * stepMag s.vel ≤ cost s := by
  unfold cost
  have hfr : 0 ≤ (if s.friction then (1 : ℚ) else 0) := friction_nonneg s.friction
  linarith

end CostFunction

--------------------------------------------------------------------------------
-- 5. Determinism
--------------------------------------------------------------------------------

section Determinism

lemma step_deterministic {n : ℕ} (s s₁ s₂ : State n)
    (h₁ : step s = s₁) (h₂ : step s = s₂) : s₁ = s₂ := by
  rw [← h₁, ← h₂]

lemma trans_deterministic {n : ℕ} (s s₁ s₂ : State n)
    (h₁ : trans s = s₁) (h₂ : trans s = s₂) : s₁ = s₂ := by
  simpa [trans] using step_deterministic (s := s) (s₁ := s₁) (s₂ := s₂) h₁ h₂

end Determinism

--------------------------------------------------------------------------------
-- 6. Algebraic theorem
--------------------------------------------------------------------------------

section AlgebraicTheory

/-- Cost reduction theorem.
    When weight is maximized (w=2) inside a friction zone,
    the cost reduces exactly to the L1 norm plus 1.
    Author: Richard Arlie Charles Patterson -/
theorem cost_reduction_calc {n : ℕ} (s : State n)
    (h_weight : s.weight = 2)
    (h_friction : s.friction = true) :
    cost s = (l1Norm s.vel : ℚ) + 1 := by
  calc
    cost s = s.weight * stepMag s.vel + (if s.friction then (1 : ℚ) else 0) := by rfl
    _ = 2 * stepMag s.vel + (if s.friction then (1 : ℚ) else 0)            := by rw [h_weight]
    _ = 2 * stepMag s.vel + 1                                               := by rw [h_friction]; rfl
    _ = 2 * ((l1Norm s.vel : ℚ) / 2) + 1                                   := by unfold stepMag; rfl
    _ = (l1Norm s.vel : ℚ) + 1                                             := by ring_nf

end AlgebraicTheory

end DeASI
