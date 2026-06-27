# DeASI

**Deterministic State-Transition Framework for Symbolic Reasoning**

> Author: Richard Arlie Charles Patterson  
> Copyright: © 2026 Richard Arlie Charles Patterson  
> Project Signature: `DeASI`  
> Primary Namespace: `DeASI`  
> Documentation Root: `DeASI:docs`  
> Repository: [De-ASI-INTERFACE/deasi-lean4](https://github.com/De-ASI-INTERFACE/deasi-lean4)

---

## Overview

DeASI is a Lean 4 formalization of a deterministic state-transition theory for symbolic
reasoning, calibrated cost functions, and reproducible execution semantics. The project
formalizes abstract reasoning as explicit, auditable state transitions over a discrete
coordinate space, paired with a weighted L1-norm cost function.

## Repository Structure

```text
DeASI/
  Core.lean          → Reusable theory: state, transition, cost, lemmas
  Samples.lean       → Concrete sample theorem suite
  Docs.lean          → Documentation entry point (doc-gen4)
docbuild/
  lakefile.toml      → Nested Lake project for doc generation
lakefile.lean        → Main project build file
LICENSE              → MIT License 2026
README.md            → This file
```

## Build

```bash
# Build main project
lake build

# Build documentation
cd docbuild
lake build DeASI:docs

# Serve docs locally
cd .lake/build/doc
python3 -m http.server
```

## Identity

| Field | Value |
|---|---|
| Project | DeASI |
| Author | Richard Arlie Charles Patterson |
| Namespace | `DeASI` |
| Repository | `deasi-lean4` |
| License | MIT 2026 |
| Doc target | `lake build DeASI:docs` |

## Core Theorems

- **Theorem 1:** Deterministic successor state
- **Theorem 2:** Cost well-definedness
- **Theorem 3:** Cost nonnegativity
- **Theorem 4:** Monotonicity in movement
- **Theorem 5:** Example consistency `(2,2) → (4,4)`, cost = 3
- **Theorem 6:** Cost reduction at max weight with friction

## License

MIT License © 2026 Richard Arlie Charles Patterson
