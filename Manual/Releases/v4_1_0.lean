/-
Copyright (c) 2025 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Joachim Breitner
-/

import VersoManual

import Manual.Meta.Markdown

open Manual
open Verso.Genre


#doc (Manual) "Lean 4.1.0 (2023-09-26)" =>
%%%
tag := "release-v4.1.0"
file := "v4.1.0"
%%%

```markdown
* The error positioning on missing tokens has been [improved](https://github.com/leanprover/lean4/pull/2393). In particular, this should make it easier to spot errors in incomplete tactic proofs.

* After elaborating a configuration file, Lake will now cache the configuration to a `lakefile.olean`. Subsequent runs of Lake will import this OLean instead of elaborating the configuration file. This provides a significant performance improvement (benchmarks indicate that using the OLean cuts Lake's startup time in half), but there are some important details to keep in mind:
  + Lake will regenerate this OLean after each modification to the `lakefile.lean` or `lean-toolchain`. You can also force a reconfigure by passing the new `--reconfigure` / `-R` option to `lake`.
  + Lake configuration options (i.e., `-K`) will be fixed at the moment of elaboration. Setting these options when `lake` is using the cached configuration will have no effect. To change options, run `lake` with `-R` / `--reconfigure`.
  + **The `lakefile.olean` is a local configuration and should not be committed to Git. Therefore, existing Lake packages need to add it to their `.gitignore`.**

* The signature of `Lake.buildO` has changed, `args` has been split into `weakArgs` and `traceArgs`. `traceArgs` are included in the input trace and `weakArgs` are not. See Lake's [FFI example](https://github.com/leanprover/lean4/blob/releases/v4.1.0/src/lake/examples/ffi/lib/lakefile.lean) for a demonstration of how to adapt to this change.

* The signatures of `Lean.importModules`, `Lean.Elab.headerToImports`, and `Lean.Elab.parseImports`

* There is now [an `occs` field](https://github.com/leanprover/lean4/pull/2470)
  in the configuration object for the `rewrite` tactic,
  allowing control of which occurrences of a pattern should be rewritten.
  This was previously a separate argument for `Lean.MVarId.rewrite`,
  and this has been removed in favour of an additional field of `Rewrite.Config`.
  It was not previously accessible from user tactics.

```
