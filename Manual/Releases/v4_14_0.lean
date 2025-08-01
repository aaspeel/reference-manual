/-
Copyright (c) 2025 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Joachim Breitner
-/

import VersoManual

import Manual.Meta.Markdown

open Manual
open Verso.Genre


#doc (Manual) "Lean 4.14.0 (2024-12-02)" =>
%%%
tag := "release-v4.14.0"
file := "v4.14.0"
%%%

````markdown

**Full Changelog**: https://github.com/leanprover/lean4/compare/v4.13.0...v4.14.0

### Language features, tactics, and metaprograms

* `structure` and `inductive` commands
  * [#5517](https://github.com/leanprover/lean4/pull/5517) improves universe level inference for the resulting type of an `inductive` or `structure.` Recall that a `Prop`-valued inductive type is a syntactic subsingleton if it has at most one constructor and all the arguments to the constructor are in `Prop`. Such types have large elimination, so they could be defined in `Type` or `Prop` without any trouble. The way inference has changed is that if a type is a syntactic subsingleton with exactly one constructor, and the constructor has at least one parameter/field, then the `inductive`/`structure` command will prefer creating a `Prop` instead of a `Type`. The upshot is that the `: Prop` in `structure S : Prop` is often no longer needed. (With @arthur-adjedj).
  * [#5842](https://github.com/leanprover/lean4/pull/5842) and [#5783](https://github.com/leanprover/lean4/pull/5783) implement a feature where the `structure` command can now define recursive inductive types:
    ```lean
    structure Tree where
      n : Nat
      children : Fin n → Tree

    def Tree.size : Tree → Nat
      | {n, children} => Id.run do
        let mut s := 0
        for h : i in [0 : n] do
          s := s + (children ⟨i, h.2⟩).size
        pure s
    ```
  * [#5814](https://github.com/leanprover/lean4/pull/5814) fixes a bug where Mathlib's `Type*` elaborator could lead to incorrect universe parameters with the `inductive` command.
  * [#3152](https://github.com/leanprover/lean4/pull/3152) and [#5844](https://github.com/leanprover/lean4/pull/5844) fix bugs in default value processing for structure instance notation (with @arthur-adjedj).
  * [#5399](https://github.com/leanprover/lean4/pull/5399) promotes instance synthesis order calculation failure from a soft error to a hard error.
  * [#5542](https://github.com/leanprover/lean4/pull/5542) deprecates `:=` variants of `inductive` and `structure` (see breaking changes).

* **Application elaboration improvements**
  * [#5671](https://github.com/leanprover/lean4/pull/5671) makes `@[elab_as_elim]` require at least one discriminant, since otherwise there is no advantage to this alternative elaborator.
  * [#5528](https://github.com/leanprover/lean4/pull/5528) enables field notation in explicit mode. The syntax `@x.f` elaborates as `@S.f` with `x` supplied to the appropriate parameter.
  * [#5692](https://github.com/leanprover/lean4/pull/5692) modifies the dot notation resolution algorithm so that it can apply `CoeFun` instances. For example, Mathlib has `Multiset.card : Multiset α →+ Nat`, and now with `m : Multiset α`, the notation `m.card` resolves to `⇑Multiset.card m`.
  * [#5658](https://github.com/leanprover/lean4/pull/5658) fixes a bug where 'don't know how to synthesize implicit argument' errors might have the incorrect local context when the eta arguments feature is activated.
  * [#5933](https://github.com/leanprover/lean4/pull/5933) fixes a bug where `..` ellipses in patterns made use of optparams and autoparams.
  * [#5770](https://github.com/leanprover/lean4/pull/5770) makes dot notation for structures resolve using *all* ancestors. Adds a *resolution order* for generalized field notation. This is the order of namespaces visited during resolution when trying to resolve names. The algorithm to compute a resolution order is the commonly used C3 linearization (used for example by Python), which when successful ensures that immediate parents' namespaces are considered before more distant ancestors' namespaces. By default we use a relaxed version of the algorithm that tolerates inconsistencies, but using `set_option structure.strictResolutionOrder true` makes inconsistent parent orderings into warnings.

* **Recursion and induction principles**
  * [#5619](https://github.com/leanprover/lean4/pull/5619) fixes functional induction principle generation to avoid over-eta-expanding in the preprocessing step.
  * [#5766](https://github.com/leanprover/lean4/pull/5766) fixes structural nested recursion so that it is not confused when a nested type appears first.
  * [#5803](https://github.com/leanprover/lean4/pull/5803) fixes a bug in functional induction principle generation when there are `let` bindings.
  * [#5904](https://github.com/leanprover/lean4/pull/5904) improves functional induction principle generation to unfold aux definitions more carefully.
  * [#5850](https://github.com/leanprover/lean4/pull/5850) refactors code for `Predefinition.Structural`.

* **Error messages**
  * [#5276](https://github.com/leanprover/lean4/pull/5276) fixes a bug in "type mismatch" errors that would structurally assign metavariables during the algorithm to expose differences.
  * [#5919](https://github.com/leanprover/lean4/pull/5919) makes "type mismatch" errors add type ascriptions to expose differences for numeric literals.
  * [#5922](https://github.com/leanprover/lean4/pull/5922) makes "type mismatch" errors expose differences in the bodies of functions and pi types.
  * [#5888](https://github.com/leanprover/lean4/pull/5888) improves the error message for invalid induction alternative names in `match` expressions (@josojo).
  * [#5719](https://github.com/leanprover/lean4/pull/5719) improves `calc` error messages.

* [#5627](https://github.com/leanprover/lean4/pull/5627) and [#5663](https://github.com/leanprover/lean4/pull/5663) improve the **`#eval` command** and introduce some new features.
  * Now results can be pretty printed if there is a `ToExpr` instance, which means **hoverable output**. If `ToExpr` fails, it then tries looking for a `Repr` or `ToString` instance like before. Setting `set_option eval.pp false` disables making use of `ToExpr` instances.
  * There is now **auto-derivation** of `Repr` instances, enabled with the `pp.derive.repr` option (default to **true**). For example:
    ```lean
    inductive Baz
    | a | b

    #eval Baz.a
    -- Baz.a
    ```
    It simply does `deriving instance Repr for Baz` when there's no way to represent `Baz`.
  * The option `eval.type` controls whether or not to include the type in the output. For now the default is false.
  * Now expressions such as `#eval do return 2`, where monad is unknown, work. It tries unifying the monad with `CommandElabM`, `TermElabM`, or `IO`.
  * The classes `Lean.Eval` and `Lean.MetaEval` have been removed. These each used to be responsible for adapting monads and printing results. Now the `MonadEval` class is responsible for adapting monads for evaluation (it is similar to `MonadLift`, but instances are allowed to use default data when initializing state), and representing results is handled through a separate process.
  * Error messages about failed instance synthesis are now more precise. Once it detects that a `MonadEval` class applies, then the error message will be specific about missing `ToExpr`/`Repr`/`ToString` instances.
  * Fixes bugs where evaluating `MetaM` and `CoreM` wouldn't collect log messages.
  * Fixes a bug where `let rec` could not be used in `#eval`.

* `partial` definitions
  * [#5780](https://github.com/leanprover/lean4/pull/5780) improves the error message when `partial` fails to prove a type is inhabited. Add delta deriving.
  * [#5821](https://github.com/leanprover/lean4/pull/5821) gives `partial` inhabitation the ability to create local `Inhabited` instances from parameters.

* **New tactic configuration syntax.** The configuration syntax for all core tactics has been given an upgrade. Rather than `simp (config := { contextual := true, maxSteps := 22})`, one can now write `simp +contextual (maxSteps := 22)`. Tactic authors can migrate by switching from `(config)?` to `optConfig` in tactic syntaxes and potentially deleting `mkOptionalNode` in elaborators. [#5883](https://github.com/leanprover/lean4/pull/5883), [#5898](https://github.com/leanprover/lean4/pull/5898),  [#5928](https://github.com/leanprover/lean4/pull/5928), and [#5932](https://github.com/leanprover/lean4/pull/5932). (Tactic authors, see breaking changes.)

* `simp` tactic
  * [#5632](https://github.com/leanprover/lean4/pull/5632) fixes the simpproc for `Fin` literals to reduce more consistently.
  * [#5648](https://github.com/leanprover/lean4/pull/5648) fixes a bug in `simpa ... using t` where metavariables in `t` were not properly accounted for, and also improves the type mismatch error.
  * [#5838](https://github.com/leanprover/lean4/pull/5838) fixes the docstring of `simp!` to actually talk about `simp!`.
  * [#5870](https://github.com/leanprover/lean4/pull/5870) adds support for `attribute [simp ←]` (note the reverse direction). This adds the reverse of a theorem as a global simp theorem.

* `decide` tactic
  * [#5665](https://github.com/leanprover/lean4/pull/5665) adds `decide!` tactic for using kernel reduction (warning: this is renamed to `decide +kernel` in a future release).

* `bv_decide` tactic
  * [#5714](https://github.com/leanprover/lean4/pull/5714) adds inequality regression tests (@alexkeizer).
  * [#5608](https://github.com/leanprover/lean4/pull/5608) adds `bv_toNat` tag for `toNat_ofInt` (@bollu).
  * [#5618](https://github.com/leanprover/lean4/pull/5618) adds support for `at` in `ac_nf` and uses it in `bv_normalize` (@tobiasgrosser).
  * [#5628](https://github.com/leanprover/lean4/pull/5628) adds udiv support.
  * [#5635](https://github.com/leanprover/lean4/pull/5635) adds auxiliary bitblasters for negation and subtraction.
  * [#5637](https://github.com/leanprover/lean4/pull/5637) adds more `getLsbD` bitblaster theory.
  * [#5652](https://github.com/leanprover/lean4/pull/5652) adds umod support.
  * [#5653](https://github.com/leanprover/lean4/pull/5653) adds performance benchmark for modulo.
  * [#5655](https://github.com/leanprover/lean4/pull/5655) reduces error on `bv_check` to warning.
  * [#5670](https://github.com/leanprover/lean4/pull/5670) adds `~~~(-x)` support.
  * [#5673](https://github.com/leanprover/lean4/pull/5673) disables `ac_nf` by default.
  * [#5675](https://github.com/leanprover/lean4/pull/5675) fixes context tracking in `bv_decide` counter example.
  * [#5676](https://github.com/leanprover/lean4/pull/5676) adds an error when the LRAT proof is invalid.
  * [#5781](https://github.com/leanprover/lean4/pull/5781) introduces uninterpreted symbols everywhere.
  * [#5823](https://github.com/leanprover/lean4/pull/5823) adds `BitVec.sdiv` support.
  * [#5852](https://github.com/leanprover/lean4/pull/5852) adds `BitVec.ofBool` support.
  * [#5855](https://github.com/leanprover/lean4/pull/5855) adds `if` support.
  * [#5869](https://github.com/leanprover/lean4/pull/5869) adds support for all the SMTLIB BitVec divison/remainder operations.
  * [#5886](https://github.com/leanprover/lean4/pull/5886) adds embedded constraint substitution.
  * [#5918](https://github.com/leanprover/lean4/pull/5918) fixes loose mvars bug in `bv_normalize`.
  * Documentation:
    * [#5636](https://github.com/leanprover/lean4/pull/5636) adds remarks about multiplication.

* `conv` mode
  * [#5861](https://github.com/leanprover/lean4/pull/5861) improves the `congr` conv tactic to handle "over-applied" functions.
  * [#5894](https://github.com/leanprover/lean4/pull/5894) improves the `arg` conv tactic so that it can access more arguments and so that it can handle "over-applied" functions (it generates a specialized congruence lemma for the specific argument in question). Makes `arg 1` and `arg 2` apply to pi types in more situations. Adds negative indexing, for example `arg -2` is equivalent to the `lhs` tactic. Makes the `enter [...]` tactic show intermediate states like `rw`.

* **Other tactics**
  * [#4846](https://github.com/leanprover/lean4/pull/4846) fixes a bug where `generalize ... at *` would apply to implementation details (@ymherklotz).
  * [#5730](https://github.com/leanprover/lean4/pull/5730) upstreams the `classical` tactic combinator.
  * [#5815](https://github.com/leanprover/lean4/pull/5815) improves the error message when trying to unfold a local hypothesis that is not a local definition.
  * [#5862](https://github.com/leanprover/lean4/pull/5862) and [#5863](https://github.com/leanprover/lean4/pull/5863) change how `apply` and `simp` elaborate, making them not disable error recovery. This improves hovers and completions when the term has elaboration errors.

* `deriving` clauses
  * [#5899](https://github.com/leanprover/lean4/pull/5899) adds declaration ranges for delta-derived instances.
  * [#5265](https://github.com/leanprover/lean4/pull/5265) removes unused syntax in `deriving` clauses for providing arguments to deriving handlers (see breaking changes).

* [#5065](https://github.com/leanprover/lean4/pull/5065) upstreams and updates `#where`, a command that reports the current scope information.

* **Linters**
  * [#5338](https://github.com/leanprover/lean4/pull/5338) makes the unused variables linter ignore variables defined in tactics by default now, avoiding performance bottlenecks.
  * [#5644](https://github.com/leanprover/lean4/pull/5644) ensures that linters in general do not run on `#guard_msgs` itself.

* **Metaprogramming interface**
  * [#5720](https://github.com/leanprover/lean4/pull/5720) adds `pushGoal`/`pushGoals` and `popGoal` for manipulating the goal state. These are an alternative to `replaceMainGoal` and `getMainGoal`, and with them you don't need to worry about making sure nothing clears assigned metavariables from the goal list between assigning the main goal and using `replaceMainGoal`. Modifies `closeMainGoalUsing`, which is like a `TacticM` version of `liftMetaTactic`. Now the callback is run in a context where the main goal is removed from the goal list, and the callback is free to modify the goal list. Furthermore, the `checkUnassigned` argument has been replaced with `checkNewUnassigned`, which checks whether the value assigned to the goal has any *new* metavariables, relative to the start of execution of the callback. Modifies `withCollectingNewGoalsFrom` to take the `parentTag` argument explicitly rather than indirectly via `getMainTag`. Modifies `elabTermWithHoles` to optionally take `parentTag?`.
  * [#5563](https://github.com/leanprover/lean4/pull/5563) fixes `getFunInfo` and `inferType` to use `withAtLeastTransparency` rather than `withTransparency`.
  * [#5679](https://github.com/leanprover/lean4/pull/5679) fixes `RecursorVal.getInduct` to return the name of major argument’s type. This makes "structure eta" work for nested inductives.
  * [#5681](https://github.com/leanprover/lean4/pull/5681) removes unused `mkRecursorInfoForKernelRec`.
  * [#5686](https://github.com/leanprover/lean4/pull/5686) makes discrimination trees index the domains of foralls, for better performance of the simplify and type class search.
  * [#5760](https://github.com/leanprover/lean4/pull/5760) adds `Lean.Expr.name?` recognizer for `Name` expressions.
  * [#5800](https://github.com/leanprover/lean4/pull/5800) modifies `liftCommandElabM` to preserve more state, fixing an issue where using it would drop messages.
  * [#5857](https://github.com/leanprover/lean4/pull/5857) makes it possible to use dot notation in `m!` strings, for example `m!"{.ofConstName n}"`.
  * [#5841](https://github.com/leanprover/lean4/pull/5841) and [#5853](https://github.com/leanprover/lean4/pull/5853) record the complete list of `structure` parents in the `StructureInfo` environment extension.

* **Other fixes or improvements**
  * [#5566](https://github.com/leanprover/lean4/pull/5566) fixes a bug introduced in [#4781](https://github.com/leanprover/lean4/pull/4781) where heartbeat exceptions were no longer being handled properly. Now such exceptions are tagged with `runtime.maxHeartbeats` (@eric-wieser).
  * [#5708](https://github.com/leanprover/lean4/pull/5708) modifies the proof objects produced by the proof-by-reflection tactics `ac_nf0` and `simp_arith` so that the kernel is less prone to reducing expensive atoms.
  * [#5768](https://github.com/leanprover/lean4/pull/5768) adds a `#version` command that prints Lean's version information.
  * [#5822](https://github.com/leanprover/lean4/pull/5822) fixes elaborator algorithms to match kernel algorithms for primitive projections (`Expr.proj`).
  * [#5811](https://github.com/leanprover/lean4/pull/5811) improves the docstring for the `rwa` tactic.


### Language server, widgets, and IDE extensions

* [#5224](https://github.com/leanprover/lean4/pull/5224) fixes `WorkspaceClientCapabilities` to make `applyEdit` optional, in accordance with the LSP specification (@pzread).
* [#5340](https://github.com/leanprover/lean4/pull/5340) fixes a server deadlock when shutting down the language server and a desync between client and language server after a file worker crash.
* [#5560](https://github.com/leanprover/lean4/pull/5560) makes `initialize` and `builtin_initialize` participate in the call hierarchy and other requests.
* [#5650](https://github.com/leanprover/lean4/pull/5650) makes references in attributes participate in the call hierarchy and other requests.
* [#5666](https://github.com/leanprover/lean4/pull/5666) add auto-completion in tactic blocks without having to type the first character of the tactic, and adds tactic completion docs to tactic auto-completion items.
* [#5677](https://github.com/leanprover/lean4/pull/5677) fixes several cases where goal states were not displayed in certain text cursor positions.
* [#5707](https://github.com/leanprover/lean4/pull/5707) indicates deprecations in auto-completion items.
* [#5736](https://github.com/leanprover/lean4/pull/5736), [#5752](https://github.com/leanprover/lean4/pull/5752), [#5763](https://github.com/leanprover/lean4/pull/5763), [#5802](https://github.com/leanprover/lean4/pull/5802), and [#5805](https://github.com/leanprover/lean4/pull/5805) fix various performance issues in the language server.
* [#5801](https://github.com/leanprover/lean4/pull/5801) distinguishes theorem auto-completions from non-theorem auto-completions.

### Pretty printing

* [#5640](https://github.com/leanprover/lean4/pull/5640) fixes a bug where goal states in messages might print newlines as spaces.
* [#5643](https://github.com/leanprover/lean4/pull/5643) adds option `pp.mvars.delayed` (default false), which when false causes delayed assignment metavariables to pretty print with what they are assigned to. Now `fun x : Nat => ?a` pretty prints as `fun x : Nat => ?a` rather than `fun x ↦ ?m.7 x`.
* [#5711](https://github.com/leanprover/lean4/pull/5711) adds options `pp.mvars.anonymous` and `pp.mvars.levels`, which when false respectively cause expression metavariables and level metavariables to pretty print as `?_`.
* [#5710](https://github.com/leanprover/lean4/pull/5710) adjusts the `⋯` elaboration warning to mention `pp.maxSteps`.

* [#5759](https://github.com/leanprover/lean4/pull/5759) fixes the app unexpander for `sorryAx`.
* [#5827](https://github.com/leanprover/lean4/pull/5827) improves accuracy of binder names in the signature pretty printer (like in output of `#check`). Also fixes the issue where consecutive hygienic names pretty print without a space separating them, so we now have `(x✝ y✝ : Nat)` rather than `(x✝y✝ : Nat)`.
* [#5830](https://github.com/leanprover/lean4/pull/5830) makes sure all the core delaborators respond to `pp.explicit` when appropriate.
* [#5639](https://github.com/leanprover/lean4/pull/5639) makes sure name literals use escaping when pretty printing.
* [#5854](https://github.com/leanprover/lean4/pull/5854) adds delaborators for `<|>`, `<*>`, `>>`, `<*`, and `*>`.

### Library

* `Array`
  * [#5687](https://github.com/leanprover/lean4/pull/5687) deprecates `Array.data`.
  * [#5705](https://github.com/leanprover/lean4/pull/5705) uses a better default value for `Array.swapAt!`.
  * [#5748](https://github.com/leanprover/lean4/pull/5748) moves `Array.mapIdx` lemmas to a new file.
  * [#5749](https://github.com/leanprover/lean4/pull/5749) simplifies signature of `Array.mapIdx`.
  * [#5758](https://github.com/leanprover/lean4/pull/5758) upstreams `Array.reduceOption`.
  * [#5786](https://github.com/leanprover/lean4/pull/5786) adds simp lemmas for `Array.isEqv` and `BEq`.
  * [#5796](https://github.com/leanprover/lean4/pull/5796) renames `Array.shrink` to `Array.take`, and relates it to `List.take`.
  * [#5798](https://github.com/leanprover/lean4/pull/5798) upstreams `List.modify`, adds lemmas, relates to `Array.modify`.
  * [#5799](https://github.com/leanprover/lean4/pull/5799) relates `Array.forIn` and `List.forIn`.
  * [#5833](https://github.com/leanprover/lean4/pull/5833) adds `Array.forIn'`, and relates to `List`.
  * [#5848](https://github.com/leanprover/lean4/pull/5848) fixes deprecations in `Init.Data.Array.Basic` to not recommend the deprecated constant.
  * [#5895](https://github.com/leanprover/lean4/pull/5895) adds `LawfulBEq (Array α) ↔ LawfulBEq α`.
  * [#5896](https://github.com/leanprover/lean4/pull/5896) moves `@[simp]` from `back_eq_back?` to `back_push`.
  * [#5897](https://github.com/leanprover/lean4/pull/5897) renames `Array.back` to `back!`.

* `List`
  * [#5605](https://github.com/leanprover/lean4/pull/5605) removes `List.redLength`.
  * [#5696](https://github.com/leanprover/lean4/pull/5696) upstreams `List.mapIdx` and adds lemmas.
  * [#5697](https://github.com/leanprover/lean4/pull/5697) upstreams `List.foldxM_map`.
  * [#5701](https://github.com/leanprover/lean4/pull/5701) renames `List.join` to `List.flatten`.
  * [#5703](https://github.com/leanprover/lean4/pull/5703) upstreams `List.sum`.
  * [#5706](https://github.com/leanprover/lean4/pull/5706) marks `prefix_append_right_inj` as a simp lemma.
  * [#5716](https://github.com/leanprover/lean4/pull/5716) fixes `List.drop_drop` addition order.
  * [#5731](https://github.com/leanprover/lean4/pull/5731) renames `List.bind` and `Array.concatMap` to `flatMap`.
  * [#5732](https://github.com/leanprover/lean4/pull/5732) renames `List.pure` to `List.singleton`.
  * [#5742](https://github.com/leanprover/lean4/pull/5742) upstreams `ne_of_mem_of_not_mem`.
  * [#5743](https://github.com/leanprover/lean4/pull/5743) upstreams `ne_of_apply_ne`.
  * [#5816](https://github.com/leanprover/lean4/pull/5816) adds more `List.modify` lemmas.
  * [#5879](https://github.com/leanprover/lean4/pull/5879) renames `List.groupBy` to `splitBy`.
  * [#5913](https://github.com/leanprover/lean4/pull/5913) relates `for` loops over `List` with `foldlM`.

* `Nat`
  * [#5694](https://github.com/leanprover/lean4/pull/5694) removes `instBEqNat`, which is redundant with `instBEqOfDecidableEq` but not defeq.
  * [#5746](https://github.com/leanprover/lean4/pull/5746) deprecates `Nat.sum`.
  * [#5785](https://github.com/leanprover/lean4/pull/5785) adds `Nat.forall_lt_succ` and variants.

* Fixed width integers
  * [#5323](https://github.com/leanprover/lean4/pull/5323) redefine unsigned fixed width integers in terms of `BitVec`.
  * [#5735](https://github.com/leanprover/lean4/pull/5735) adds `UIntX.[val_ofNat, toBitVec_ofNat]`.
  * [#5790](https://github.com/leanprover/lean4/pull/5790) defines `Int8`.
  * [#5901](https://github.com/leanprover/lean4/pull/5901) removes native code for `UInt8.modn`.

* `BitVec`
  * [#5604](https://github.com/leanprover/lean4/pull/5604) completes `BitVec.[getMsbD|getLsbD|msb]` for shifts (@luisacicolini).
  * [#5609](https://github.com/leanprover/lean4/pull/5609) adds lemmas for division when denominator is zero (@bollu).
  * [#5620](https://github.com/leanprover/lean4/pull/5620) documents Bitblasting (@bollu)
  * [#5623](https://github.com/leanprover/lean4/pull/5623) moves `BitVec.udiv/umod/sdiv/smod` after `add/sub/mul/lt` (@tobiasgrosser).
  * [#5645](https://github.com/leanprover/lean4/pull/5645) defines `udiv` normal form to be `/`, resp. `umod` and `%` (@bollu).
  * [#5646](https://github.com/leanprover/lean4/pull/5646) adds lemmas about arithmetic inequalities (@bollu).
  * [#5680](https://github.com/leanprover/lean4/pull/5680) expands relationship with `toFin` (@tobiasgrosser).
  * [#5691](https://github.com/leanprover/lean4/pull/5691) adds `BitVec.(getMSbD, msb)_(add, sub)` and `BitVec.getLsbD_sub` (@luisacicolini).
  * [#5712](https://github.com/leanprover/lean4/pull/5712) adds `BitVec.[udiv|umod]_[zero|one|self]` (@tobiasgrosser).
  * [#5718](https://github.com/leanprover/lean4/pull/5718) adds `BitVec.sdiv_[zero|one|self]` (@tobiasgrosser).
  * [#5721](https://github.com/leanprover/lean4/pull/5721) adds `BitVec.(msb, getMsbD, getLsbD)_(neg, abs)` (@luisacicolini).
  * [#5772](https://github.com/leanprover/lean4/pull/5772) adds `BitVec.toInt_sub`, simplifies `BitVec.toInt_neg` (@tobiasgrosser).
  * [#5778](https://github.com/leanprover/lean4/pull/5778) prove that `intMin` the smallest signed bitvector (@alexkeizer).
  * [#5851](https://github.com/leanprover/lean4/pull/5851) adds `(msb, getMsbD)_twoPow` (@luisacicolini).
  * [#5858](https://github.com/leanprover/lean4/pull/5858) adds `BitVec.[zero_ushiftRight|zero_sshiftRight|zero_mul]` and cleans up BVDecide (@tobiasgrosser).
  * [#5865](https://github.com/leanprover/lean4/pull/5865) adds `BitVec.(msb, getMsbD)_concat` (@luisacicolini).
  * [#5881](https://github.com/leanprover/lean4/pull/5881) adds `Hashable (BitVec n)`

* `String`/`Char`
  * [#5728](https://github.com/leanprover/lean4/pull/5728) upstreams `String.dropPrefix?`.
  * [#5745](https://github.com/leanprover/lean4/pull/5745) changes `String.dropPrefix?` signature.
  * [#5747](https://github.com/leanprover/lean4/pull/5747) adds `Hashable Char` instance

* `HashMap`
  * [#5880](https://github.com/leanprover/lean4/pull/5880) adds interim implementation of `HashMap.modify`/`alter`

* **Other**
  * [#5704](https://github.com/leanprover/lean4/pull/5704) removes `@[simp]` from `Option.isSome_eq_isSome`.
  * [#5739](https://github.com/leanprover/lean4/pull/5739) upstreams material on `Prod`.
  * [#5740](https://github.com/leanprover/lean4/pull/5740) moves `Antisymm` to `Std.Antisymm`.
  * [#5741](https://github.com/leanprover/lean4/pull/5741) upstreams basic material on `Sum`.
  * [#5756](https://github.com/leanprover/lean4/pull/5756) adds `Nat.log2_two_pow` (@spinylobster).
  * [#5892](https://github.com/leanprover/lean4/pull/5892) removes duplicated `ForIn` instances.
  * [#5900](https://github.com/leanprover/lean4/pull/5900) removes `@[simp]` from `Sum.forall` and `Sum.exists`.
  * [#5812](https://github.com/leanprover/lean4/pull/5812) removes redundant `Decidable` assumptions (@FR-vdash-bot).

### Compiler, runtime, and FFI

* [#5685](https://github.com/leanprover/lean4/pull/5685) fixes help message flags, removes the `-f` flag and adds the `-g` flag (@James-Oswald).
* [#5930](https://github.com/leanprover/lean4/pull/5930) adds `--short-version` (`-V`) option to display short version (@juhp).
* [#5144](https://github.com/leanprover/lean4/pull/5144) switches all 64-bit platforms over to consistently using GMP for bignum arithmetic.
* [#5753](https://github.com/leanprover/lean4/pull/5753) raises the minimum supported Windows version to Windows 10 1903 (released May 2019).

### Lake

* [#5715](https://github.com/leanprover/lean4/pull/5715) changes `lake new math` to use `autoImplicit false` (@eric-wieser).
* [#5688](https://github.com/leanprover/lean4/pull/5688) makes `Lake` not create core aliases in the `Lake` namespace.
* [#5924](https://github.com/leanprover/lean4/pull/5924) adds a `text` option for `buildFile*` utilities.
* [#5789](https://github.com/leanprover/lean4/pull/5789) makes `lake init` not `git init` when inside git work tree (@haoxins).
* [#5684](https://github.com/leanprover/lean4/pull/5684) has Lake update a package's `lean-toolchain` file on `lake update` if it finds the package's direct dependencies use a newer compatible toolchain. To skip this step, use the `--keep-toolchain` CLI option. (See breaking changes.)
* [#6218](https://github.com/leanprover/lean4/pull/6218) makes Lake no longer automatically fetch GitHub cloud releases if the package build directory is already present (mirroring the behavior of the Reservoir cache). This prevents the cache from clobbering existing prebuilt artifacts. Users can still manually fetch the cache and clobber the build directory by running `lake build <pkg>:release`.
* [#6231](https://github.com/leanprover/lean4/pull/6231) improves the errors Lake produces when it fails to fetch a dependency from Reservoir. If the package is not indexed, it will produce a suggestion about how to require it from GitHub.

### Documentation

* [#5617](https://github.com/leanprover/lean4/pull/5617) fixes MSYS2 build instructions.
* [#5725](https://github.com/leanprover/lean4/pull/5725) points out that `OfScientific` is called with raw literals (@eric-wieser).
* [#5794](https://github.com/leanprover/lean4/pull/5794) adds a stub for application ellipsis notation (@eric-wieser).

### Breaking changes

* The syntax for providing arguments to deriving handlers has been removed, which was not used by any major Lean projects in the ecosystem. As a result, the  `applyDerivingHandlers` now takes one fewer argument, `registerDerivingHandlerWithArgs` is now simply `registerDerivingHandler`, `DerivingHandler` no longer includes the unused parameter, and `DerivingHandlerNoArgs` has been deprecated. To migrate code, delete the unused `none` argument and use `registerDerivingHandler` and `DerivingHandler`. ([#5265](https://github.com/leanprover/lean4/pull/5265))
* The minimum supported Windows version has been raised to Windows 10 1903, released May 2019. ([#5753](https://github.com/leanprover/lean4/pull/5753))
* The `--lean` CLI option for `lake` was removed. Use the `LEAN` environment variable instead. ([#5684](https://github.com/leanprover/lean4/pull/5684))
* The `inductive ... :=`, `structure ... :=`, and `class ... :=` syntaxes have been deprecated in favor of the `... where` variants. The old syntax produces a warning, controlled by the `linter.deprecated` option. ([#5542](https://github.com/leanprover/lean4/pull/5542))
* The generated tactic configuration elaborators now land in `TacticM` to make use of the current recovery state. Commands that wish to elaborate configurations should now use `declare_command_config_elab` instead of `declare_config_elab` to get an elaborator landing in `CommandElabM`. Syntaxes should migrate to `optConfig` instead of `(config)?`, but the elaborators are reverse compatible. ([#5883](https://github.com/leanprover/lean4/pull/5883))
````
