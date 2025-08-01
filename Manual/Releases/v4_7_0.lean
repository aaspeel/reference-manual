/-
Copyright (c) 2025 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Joachim Breitner
-/

import VersoManual

import Manual.Meta.Markdown

open Manual
open Verso.Genre


#doc (Manual) "Lean 4.7.0 (2024-04-03)" =>
%%%
tag := "release-v4.7.0"
file := "v4.7.0"
%%%

````markdown
* `simp` and `rw` now use instance arguments found by unification,
  rather than always resynthesizing. For backwards compatibility, the original behaviour is
  available via `set_option tactic.skipAssignedInstances false`.
  [#3507](https://github.com/leanprover/lean4/pull/3507) and
  [#3509](https://github.com/leanprover/lean4/pull/3509).

* When the `pp.proofs` is false, now omitted proofs use `⋯` rather than `_`,
  which gives a more helpful error message when copied from the Infoview.
  The `pp.proofs.threshold` option lets small proofs always be pretty printed.
  [#3241](https://github.com/leanprover/lean4/pull/3241).

* `pp.proofs.withType` is now set to false by default to reduce noise in the info view.

* The pretty printer for applications now handles the case of over-application itself when applying app unexpanders.
  In particular, the ``| `($_ $a $b $xs*) => `(($a + $b) $xs*)`` case of an `app_unexpander` is no longer necessary.
  [#3495](https://github.com/leanprover/lean4/pull/3495).

* New `simp` (and `dsimp`) configuration option: `zetaDelta`. It is `false` by default.
  The `zeta` option is still `true` by default, but their meaning has changed.
  - When `zeta := true`, `simp` and `dsimp` reduce terms of the form
    `let x := val; e[x]` into `e[val]`.
  - When `zetaDelta := true`, `simp` and `dsimp` will expand let-variables in
    the context. For example, suppose the context contains `x := val`. Then,
    any occurrence of `x` is replaced with `val`.

  See [issue #2682](https://github.com/leanprover/lean4/pull/2682) for additional details. Here are some examples:
  ```
  example (h : z = 9) : let x := 5; let y := 4; x + y = z := by
    intro x
    simp
    /-
    New goal:
    h : z = 9; x := 5 |- x + 4 = z
    -/
    rw [h]

  example (h : z = 9) : let x := 5; let y := 4; x + y = z := by
    intro x
    -- Using both `zeta` and `zetaDelta`.
    simp (config := { zetaDelta := true })
    /-
    New goal:
    h : z = 9; x := 5 |- 9 = z
    -/
    rw [h]

  example (h : z = 9) : let x := 5; let y := 4; x + y = z := by
    intro x
    simp [x] -- asks `simp` to unfold `x`
    /-
    New goal:
    h : z = 9; x := 5 |- 9 = z
    -/
    rw [h]

  example (h : z = 9) : let x := 5; let y := 4; x + y = z := by
    intro x
    simp (config := { zetaDelta := true, zeta := false })
    /-
    New goal:
    h : z = 9; x := 5 |- let y := 4; 5 + y = z
    -/
    rw [h]
  ```

* When adding new local theorems to `simp`, the system assumes that the function application arguments
  have been annotated with `no_index`. This modification, which addresses [issue #2670](https://github.com/leanprover/lean4/issues/2670),
  restores the Lean 3 behavior that users expect. With this modification, the following examples are now operational:
  ```
  example {α β : Type} {f : α × β → β → β} (h : ∀ p : α × β, f p p.2 = p.2)
    (a : α) (b : β) : f (a, b) b = b := by
    simp [h]

  example {α β : Type} {f : α × β → β → β}
    (a : α) (b : β) (h : f (a,b) (a,b).2 = (a,b).2) : f (a, b) b = b := by
    simp [h]
  ```
  In both cases, `h` is applicable because `simp` does not index f-arguments anymore when adding `h` to the `simp`-set.
  It's important to note, however, that global theorems continue to be indexed in the usual manner.

* Improved the error messages produced by the `decide` tactic. [#3422](https://github.com/leanprover/lean4/pull/3422)

* Improved auto-completion performance. [#3460](https://github.com/leanprover/lean4/pull/3460)

* Improved initial language server startup performance. [#3552](https://github.com/leanprover/lean4/pull/3552)

* Changed call hierarchy to sort entries and strip private header from names displayed in the call hierarchy. [#3482](https://github.com/leanprover/lean4/pull/3482)

* There is now a low-level error recovery combinator in the parsing framework, primarily intended for DSLs. [#3413](https://github.com/leanprover/lean4/pull/3413)

* You can now write `termination_by?` after a declaration to see the automatically inferred
  termination argument, and turn it into a `termination_by …` clause using the “Try this” widget or a code action. [#3514](https://github.com/leanprover/lean4/pull/3514)

* A large fraction of `Std` has been moved into the Lean repository.
  This was motivated by:
  1. Making universally useful tactics such as `ext`, `by_cases`, `change at`,
    `norm_cast`, `rcases`, `simpa`, `simp?`, `omega`, and `exact?`
    available to all users of Lean, without imports.
  2. Minimizing the syntactic changes between plain Lean and Lean with `import Std`.
  3. Simplifying the development process for the basic data types
     `Nat`, `Int`, `Fin` (and variants such as `UInt64`), `List`, `Array`,
     and `BitVec` as we begin making the APIs and simp normal forms for these types
     more complete and consistent.
  4. Laying the groundwork for the Std roadmap, as a library focused on
     essential datatypes not provided by the core language (e.g. `RBMap`)
     and utilities such as basic IO.
  While we have achieved most of our initial aims in `v4.7.0-rc1`,
  some upstreaming will continue over the coming months.

* The `/` and `%` notations in `Int` now use `Int.ediv` and `Int.emod`
  (i.e. the rounding conventions have changed).
  Previously `Std` overrode these notations, so this is no change for users of `Std`.
  There is now kernel support for these functions.
  [#3376](https://github.com/leanprover/lean4/pull/3376).

* `omega`, our integer linear arithmetic tactic, is now available in the core language.
  * It is supplemented by a preprocessing tactic `bv_omega` which can solve goals about `BitVec`
    which naturally translate into linear arithmetic problems.
    [#3435](https://github.com/leanprover/lean4/pull/3435).
  * `omega` now has support for `Fin` [#3427](https://github.com/leanprover/lean4/pull/3427),
    the `<<<` operator [#3433](https://github.com/leanprover/lean4/pull/3433).
  * During the port `omega` was modified to no longer identify atoms up to definitional equality
    (so in particular it can no longer prove `id x ≤ x`). [#3525](https://github.com/leanprover/lean4/pull/3525).
    This may cause some regressions.
    We plan to provide a general purpose preprocessing tactic later, or an `omega!` mode.
  * `omega` is now invoked in Lean's automation for termination proofs
    [#3503](https://github.com/leanprover/lean4/pull/3503) as well as in
    array indexing proofs [#3515](https://github.com/leanprover/lean4/pull/3515).
    This automation will be substantially revised in the medium term,
    and while `omega` does help automate some proofs, we plan to make this much more robust.

* The library search tactics `exact?` and `apply?` that were originally in
  Mathlib are now available in Lean itself.  These use the implementation using
  lazy discrimination trees from `Std`, and thus do not require a disk cache but
  have a slightly longer startup time.  The order used for selection lemmas has
  changed as well to favor goals purely based on how many terms in the head
  pattern match the current goal.

* The `solve_by_elim` tactic has been ported from `Std` to Lean so that library
  search can use it.

* New `#check_tactic` and `#check_simp` commands have been added.  These are
  useful for checking tactics (particularly `simp`) behave as expected in test
  suites.

* Previously, app unexpanders would only be applied to entire applications. However, some notations produce
  functions, and these functions can be given additional arguments. The solution so far has been to write app unexpanders so that they can take an arbitrary number of additional arguments. However this leads to misleading hover information in the Infoview. For example, while `HAdd.hAdd f g 1` pretty prints as `(f + g) 1`, hovering over `f + g` shows `f`. There is no way to fix the situation from within an app unexpander; the expression position for `HAdd.hAdd f g` is absent, and app unexpanders cannot register TermInfo.

  This commit changes the app delaborator to try running app unexpanders on every prefix of an application, from longest to shortest prefix. For efficiency, it is careful to only try this when app delaborators do in fact exist for the head constant, and it also ensures arguments are only delaborated once. Then, in `(f + g) 1`, the `f + g` gets TermInfo registered for that subexpression, making it properly hoverable.

  [#3375](https://github.com/leanprover/lean4/pull/3375)

Breaking changes:
* `Lean.withTraceNode` and variants got a stronger `MonadAlwaysExcept` assumption to
  fix trace trees not being built on elaboration runtime exceptions. Instances for most elaboration
  monads built on `EIO Exception` should be synthesized automatically.
* The `match ... with.` and `fun.` notations previously in Std have been replaced by
  `nomatch ...` and `nofun`. [#3279](https://github.com/leanprover/lean4/pull/3279) and [#3286](https://github.com/leanprover/lean4/pull/3286)


Other improvements:
* several bug fixes for `simp`:
  * we should not crash when `simp` loops [#3269](https://github.com/leanprover/lean4/pull/3269)
  * `simp` gets stuck on `autoParam` [#3315](https://github.com/leanprover/lean4/pull/3315)
  * `simp` fails when custom discharger makes no progress [#3317](https://github.com/leanprover/lean4/pull/3317)
  * `simp` fails to discharge `autoParam` premises even when it can reduce them to `True` [#3314](https://github.com/leanprover/lean4/pull/3314)
  * `simp?` suggests generated equations lemma names, fixes [#3547](https://github.com/leanprover/lean4/pull/3547) [#3573](https://github.com/leanprover/lean4/pull/3573)
* fixes for `match` expressions:
  * fix regression with builtin literals [#3521](https://github.com/leanprover/lean4/pull/3521)
  * accept `match` when patterns cover all cases of a `BitVec` finite type [#3538](https://github.com/leanprover/lean4/pull/3538)
  * fix matching `Int` literals [#3504](https://github.com/leanprover/lean4/pull/3504)
  * patterns containing int values and constructors [#3496](https://github.com/leanprover/lean4/pull/3496)
* improve `termination_by` error messages [#3255](https://github.com/leanprover/lean4/pull/3255)
* fix `rename_i` in macros, fixes [#3553](https://github.com/leanprover/lean4/pull/3553) [#3581](https://github.com/leanprover/lean4/pull/3581)
* fix excessive resource usage in `generalize`, fixes [#3524](https://github.com/leanprover/lean4/pull/3524) [#3575](https://github.com/leanprover/lean4/pull/3575)
* an equation lemma with autoParam arguments fails to rewrite, fixing [#2243](https://github.com/leanprover/lean4/pull/2243) [#3316](https://github.com/leanprover/lean4/pull/3316)
* `add_decl_doc` should check that declarations are local [#3311](https://github.com/leanprover/lean4/pull/3311)
* instantiate the types of inductives with the right parameters, closing [#3242](https://github.com/leanprover/lean4/pull/3242) [#3246](https://github.com/leanprover/lean4/pull/3246)
* New simprocs for many basic types. [#3407](https://github.com/leanprover/lean4/pull/3407)

Lake fixes:
* Warn on fetch cloud release failure [#3401](https://github.com/leanprover/lean4/pull/3401)
* Cloud release trace & `lake build :release` errors [#3248](https://github.com/leanprover/lean4/pull/3248)
````
