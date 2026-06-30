/-!
# DeASI.Samples

Worked examples and concrete theorem suites for the DeASI formalization.

## Signature

- Project: `DeASI`
- Author: Richard Arlie Charles Patterson
- Copyright: © 2026 Richard Arlie Charles Patterson
- Namespace: `DeASI.Samples`
- Repository: `deasi-lean4`
- License: MIT

## Description

This module imports `DeASI.Core` and contains sample states, explicit
evaluations, and theorem demonstrations intended for regression testing
and documentation output.
-/

import DeASI.Core

set_option autoImplicit false
set_option maxHeartbeats 400000

open scoped BigOperators

namespace DeASI
namespace Samples

--------------------------------------------------------------------------------
-- Sample state: (2,2) → (4,4), cost = 3
--------------------------------------------------------------------------------

section SampleDefinitions

def samplePos : Vec 2
  | ⟨0, _⟩ => 2
  | ⟨1, _⟩ => 2

def sampleVel : Vec 2
  | ⟨0, _⟩ => 2
  | ⟨1, _⟩ => 2

/-- Canonical sample state: W=3/2, no friction, position (2,2), velocity (2,2).
    Author: Richard Arlie Charles Patterson -/
def sampleState : State 2 :=
{ pos := samplePos
  vel := sampleVel
  weight := (3 : ℚ) / 2
  phase := false
  friction := false
  weight_nonneg := by norm_num
  weight_le_two := by norm_num }

end SampleDefinitions

--------------------------------------------------------------------------------
-- Sample lemmas
--------------------------------------------------------------------------------

section SampleLemmas

lemma sample_l1Norm : l1Norm sampleVel = 4 := by
  unfold l1Norm sampleVel
  fin_cases <;> norm_num

lemma sample_stepMag : stepMag sampleVel = 2 := by
  unfold stepMag
  rw [sample_l1Norm]
  norm_num

lemma sample_step_pos :
    (step sampleState).pos = fun
      | ⟨0, _⟩ => 4
      | ⟨1, _⟩ => 4 := by
  unfold step sampleState samplePos sampleVel
  funext i <;> fin_cases i <;> norm_num

lemma sample_step_phase : (step sampleState).phase = true := by
  unfold step sampleState nextPhase
  simp

lemma sample_step_friction : (step sampleState).friction = false := by
  unfold step sampleState nextFriction isFrictionZone l1Norm samplePos sampleVel
  native_decide

lemma sample_cost : cost sampleState = 3 := by
  unfold cost sampleState
  rw [sample_stepMag]
  norm_num

lemma sample_cost_nonneg : 0 ≤ cost sampleState := by
  simpa using cost_nonneg (s := sampleState)

lemma sample_determinism :
    ∀ s₁ s₂, step sampleState = s₁ → step sampleState = s₂ → s₁ = s₂ := by
  intro s₁ s₂ h₁ h₂
  exact step_deterministic (s := sampleState) (s₁ := s₁) (s₂ := s₂) h₁ h₂

/-- Bundle theorem: sample state transitions to (4,4) with cost 3.
    Author: Richard Arlie Charles Patterson -/
theorem canonical_example_correct :
    cost sampleState = 3 ∧
    (step sampleState).pos = fun
      | ⟨0, _⟩ => 4
      | ⟨1, _⟩ => 4 :=
  ⟨sample_cost, sample_step_pos⟩

end SampleLemmas

end Samples
end DeASI
