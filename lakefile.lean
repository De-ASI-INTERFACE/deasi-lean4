import Lake
open Lake DSL

package DeASI where
  name := "DeASI"
  version := Version.parse! "0.1.0"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.22.0"

lean_lib DeASI where
  roots := #[`DeASI]
