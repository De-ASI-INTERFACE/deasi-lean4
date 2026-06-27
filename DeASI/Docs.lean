/-!
# DeASI.Docs

Public documentation entry point for doc-gen4.

## Signature

- Project: `DeASI`
- Author: Richard Arlie Charles Patterson
- Copyright: © 2026 Richard Arlie Charles Patterson
- Namespace: `DeASI`
- Repository: `deasi-lean4`
- License: MIT
- Doc build target: `lake build DeASI:docs`

## What to read first

1. `DeASI.Core` — reusable theory
2. `DeASI.Samples` — concrete theorem evaluations
3. `DeASI.Docs` — this file, documentation entry point

## Purpose

This repository separates formal theory from sample computations and keeps the
documentation build isolated through a nested `docbuild` Lake project.
The result is a stable, reproducible formalization with a consistent author
signature across source code, docs, and repository metadata.
© 2026 Richard Arlie Charles Patterson
-/

import DeASI.Core
import DeASI.Samples

namespace DeASI

end DeASI
