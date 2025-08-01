/-
Copyright (c) 2025 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Joachim Breitner
-/

import VersoManual

import Manual.Meta.Markdown

open Manual
open Verso.Genre


#doc (Manual) "Lean 4.15.0 (2025-01-04)" =>
%%%
tag := "release-v4.15.0"
file := "v4.15.0"
%%%

````markdown

## Language

- [#4595](https://github.com/leanprover/lean4/pull/4595) implements `Simp.Config.implicitDefEqsProofs`. When `true`
(default: `true`), `simp` will **not** create a proof term for a
rewriting rule associated with an `rfl`-theorem. Rewriting rules are
provided by users by annotating theorems with the attribute `@[simp]`.
If the proof of the theorem is just `rfl` (reflexivity), and
`implicitDefEqProofs := true`, `simp` will **not** create a proof term
which is an application of the annotated theorem.

- [#5429](https://github.com/leanprover/lean4/pull/5429) avoid negative environment lookup

- [#5501](https://github.com/leanprover/lean4/pull/5501) ensure `instantiateMVarsProfiling` adds a trace node

- [#5856](https://github.com/leanprover/lean4/pull/5856) adds a feature to the the mutual def elaborator where the
`instance` command yields theorems instead of definitions when the class
is a `Prop`.

- [#5907](https://github.com/leanprover/lean4/pull/5907) unset trailing for `simpa?` "try this" suggestion

- [#5920](https://github.com/leanprover/lean4/pull/5920) changes the rule for which projections become instances. Before,
all parents along with all indirect ancestors that were represented as
subobject fields would have their projections become instances. Now only
projections for direct parents become instances.

- [#5934](https://github.com/leanprover/lean4/pull/5934) make `all_goals` admit goals on failure

- [#5942](https://github.com/leanprover/lean4/pull/5942) introduce synthetic atoms in bv_decide

- [#5945](https://github.com/leanprover/lean4/pull/5945) adds a new definition `Message.kind` which returns the top-level
tag of a message. This is serialized as the new field `kind` in
`SerialMessaege` so that i can be used by external consumers (e.g.,
Lake) to identify messages via `lean --json`.

- [#5968](https://github.com/leanprover/lean4/pull/5968) `arg` conv tactic misreported number of arguments on error

- [#5979](https://github.com/leanprover/lean4/pull/5979) BitVec.twoPow in bv_decide

- [#5991](https://github.com/leanprover/lean4/pull/5991) simplifies the implementation of `omega`.

- [#5992](https://github.com/leanprover/lean4/pull/5992) fix style in bv_decide normalizer

- [#5999](https://github.com/leanprover/lean4/pull/5999) adds configuration options for
`decide`/`decide!`/`native_decide` and refactors the tactics to be
frontends to the same backend. Adds a `+revert` option that cleans up
the local context and reverts all local variables the goal depends on,
along with indirect propositional hypotheses. Makes `native_decide` fail
at elaboration time on failure without sacrificing performance (the
decision procedure is still evaluated just once). Now `native_decide`
supports universe polymorphism.

- [#6010](https://github.com/leanprover/lean4/pull/6010) changes `bv_decide`'s configuration from lots of `set_option` to
an elaborated config like `simp` or `omega`. The notable exception is
`sat.solver` which is still a `set_option` such that users can configure
a custom SAT solver globally for an entire project or file. Additionally
it introduces the ability to set `maxSteps` for the simp preprocessing
run through the new config.

- [#6012](https://github.com/leanprover/lean4/pull/6012) improves the validation of new syntactic tokens. Previously, the
validation code had inconsistencies: some atoms would be accepted only
if they had a leading space as a pretty printer hint. Additionally,
atoms with internal whitespace are no longer allowed.

- [#6016](https://github.com/leanprover/lean4/pull/6016) removes the `decide!` tactic in favor of `decide +kernel`
(breaking change).

- [#6019](https://github.com/leanprover/lean4/pull/6019) removes @[specilize] from `MkBinding.mkBinding`, which is a
function that cannot be specialized (as none of its arguments are
functions). As a result, the specializable function `Nat.foldRevM.loop`
doesn't get specialized, which leads to worse performing code.

- [#6022](https://github.com/leanprover/lean4/pull/6022) makes the `change` tactic and conv tactic use the same
elaboration strategy. It works uniformly for both the target and local
hypotheses. Now `change` can assign metavariables, for example:
```lean
example (x y z : Nat) : x + y = z := by
  change ?a = _
  let w := ?a
  -- now `w : Nat := x + y`
```

- [#6024](https://github.com/leanprover/lean4/pull/6024) fixes a bug where the monad lift coercion elaborator would
partially unify expressions even if they were not monads. This could be
taken advantage of to propagate information that could help elaboration
make progress, for example the first `change` worked because the monad
lift coercion elaborator was unifying `@Eq _ _` with `@Eq (Nat × Nat)
p`:
```lean
example (p : Nat × Nat) : p = p := by
  change _ = ⟨_, _⟩ -- used to work (yielding `p = (p.fst, p.snd)`), now it doesn't
  change ⟨_, _⟩ = _ -- never worked
```
As such, this is a breaking change; you may need to adjust expressions
to include additional implicit arguments.

- [#6029](https://github.com/leanprover/lean4/pull/6029) adds a normalization rule to `bv_normalize` (which is used by
`bv_decide`) that converts `x / 2^k` into `x >>> k` under suitable
conditions. This allows us to simplify the expensive division circuits
that are used for bitblasting into much cheaper shifting circuits.
Concretely, it allows for the following canonicalization:

- [#6030](https://github.com/leanprover/lean4/pull/6030) fixes `simp only [· ∈ ·]` after #5020.

- [#6035](https://github.com/leanprover/lean4/pull/6035) introduces the and flattening pre processing pass from Bitwuzla
to `bv_decide`. It splits hypotheses of the form `(a && b) = true` into
`a = true` and `b = true` which has synergy potential with the already
existing embedded constraint substitution pass.

- [#6037](https://github.com/leanprover/lean4/pull/6037) fixes `bv_decide`'s embedded constraint substitution to generate
correct counter examples in the corner case where duplicate theorems are
in the local context.

- [#6045](https://github.com/leanprover/lean4/pull/6045) add `LEAN_ALWAYS_INLINE` to some functions

- [#6048](https://github.com/leanprover/lean4/pull/6048) fixes `simp?` suggesting output with invalid indentation

- [#6051](https://github.com/leanprover/lean4/pull/6051) mark `Meta.Context.config` as private

- [#6053](https://github.com/leanprover/lean4/pull/6053) fixes the caching infrastructure for `whnf` and `isDefEq`,
ensuring the cache accounts for all relevant configuration flags. It
also cleans up the `WHNF.lean` module and improves the configuration of
`whnf`.

- [#6061](https://github.com/leanprover/lean4/pull/6061) adds a simp_arith benchmark.

- [#6062](https://github.com/leanprover/lean4/pull/6062) optimize Nat.Linear.Expr.toPoly

- [#6064](https://github.com/leanprover/lean4/pull/6064) optimize Nat.Linear.Poly.norm

- [#6068](https://github.com/leanprover/lean4/pull/6068) improves the asymptotic performance of `simp_arith` when there are many variables to consider.

- [#6077](https://github.com/leanprover/lean4/pull/6077) adds options to `bv_decide`'s configuration structure such that
all non mandatory preprocessing passes can be disabled.

- [#6082](https://github.com/leanprover/lean4/pull/6082) changes how the canonicalizer handles `forall` and `lambda`,
replacing bvars with temporary fvars. Fixes a bug reported by @hrmacbeth
on
[zulip](https://leanprover.zulipchat.com/#narrow/channel/270676-lean4/topic/Quantifiers.20in.20CanonM/near/482483448).

- [#6093](https://github.com/leanprover/lean4/pull/6093) use mkFreshUserName in ArgsPacker

- [#6096](https://github.com/leanprover/lean4/pull/6096) improves the `#print` command for structures to show all fields
and which parents the fields were inherited from, hiding internal
details such as which parents are represented as subobjects. This
information is still present in the constructor if needed. The pretty
printer for private constants is also improved, and it now handles
private names from the current module like any other name; private names
from other modules are made hygienic.

- [#6098](https://github.com/leanprover/lean4/pull/6098) modifies `Lean.MVarId.replaceTargetDefEq` and
`Lean.MVarId.replaceLocalDeclDefEq` to use `Expr.equal` instead of
`Expr.eqv` when determining whether the expression has changed. This is
justified on the grounds that binder names and binder infos are
user-visible and affect elaboration.

- [#6105](https://github.com/leanprover/lean4/pull/6105) fixes a stack overflow caused by a cyclic assignment in the
metavariable context. The cycle is unintentionally introduced by the
structure instance elaborator.

- [#6108](https://github.com/leanprover/lean4/pull/6108) turn off pp.mvars in apply? results

- [#6109](https://github.com/leanprover/lean4/pull/6109) fixes an issue in the `injection` tactic. This tactic may
execute multiple sub-tactics. If any of them fail, we must backtrack the
partial assignment. This issue was causing the error: "`mvarId` is
already assigned" in issue #6066. The issue is not yet resolved, as the
equation generator for the match expressions is failing in the example
provided in this issue.

- [#6112](https://github.com/leanprover/lean4/pull/6112) makes stricter requirements for the `@[deprecated]` attribute,
requiring either a replacement identifier as `@[deprecated bar]` or
suggestion text `@[deprecated "Past its use by date"]`, and also
requires a `since := "..."` field.

- [#6114](https://github.com/leanprover/lean4/pull/6114) liberalizes atom rules by allowing `''` to be a prefix of an
atom, after #6012 only added an exception for `''` alone, and also adds
some unit tests for atom validation.

- [#6116](https://github.com/leanprover/lean4/pull/6116) fixes a bug where structural recursion did not work when indices
of the recursive argument appeared as function parameters in a different
order than in the argument's type's definition.

- [#6125](https://github.com/leanprover/lean4/pull/6125) adds support for `structure` in `mutual` blocks, allowing
inductive types defined by `inductive` and `structure` to be mutually
recursive. The limitations are (1) that the parents in the `extends`
clause must be defined before the `mutual` block and (2) mutually
recursive classes are not allowed (a limitation shared by `class
inductive`). There are also improvements to universe level inference for
inductive types and structures. Breaking change: structure parents now
elaborate with the structure in scope (fix: use qualified names or
rename the structure to avoid shadowing), and structure parents no
longer elaborate with autoimplicits enabled.

- [#6128](https://github.com/leanprover/lean4/pull/6128) does the same fix as #6104, but such that it doesn't break the
test/the file in `Plausible`. This is done by not creating unused let
binders in metavariable types that are made by `elimMVar`. (This is also
a positive thing for users looking at metavariable types, for example in
error messages)

- [#6129](https://github.com/leanprover/lean4/pull/6129) fixes a bug at `isDefEq` when `zetaDelta := false`. See new test
for a small example that exposes the issue.

- [#6131](https://github.com/leanprover/lean4/pull/6131) fixes a bug at the definitional equality test (`isDefEq`). At
unification constraints of the form `c.{u} =?= c.{v}`, it was not trying
to unfold `c`. This bug did not affect the kernel.

- [#6141](https://github.com/leanprover/lean4/pull/6141) make use of recursive structures in snapshot types

- [#6145](https://github.com/leanprover/lean4/pull/6145) fixes the `revert` tactic so that it creates a `syntheticOpaque`
metavariable as the new goal, instead of a `natural` metavariable

- [#6146](https://github.com/leanprover/lean4/pull/6146) fixes a non-termination bug that occurred when generating the
match-expression splitter theorem. The bug was triggered when the proof
automation for the splitter theorem repeatedly applied `injection` to
the same local declaration, as it could not be removed due to forward
dependencies. See issue #6065 for an example that reproduces this issue.

- [#6165](https://github.com/leanprover/lean4/pull/6165) modifies structure instance notation and `where` notation to use
the same notation for fields. Structure instance notation now admits
binders, type ascriptions, and equations, and `where` notation admits
full structure lvals. Examples of these for structure instance notation:
```lean
structure PosFun where
  f : Nat → Nat
  pos : ∀ n, 0 < f n
```

- [#6168](https://github.com/leanprover/lean4/pull/6168) extends the "motive is not type correct" error message for the
rewrite tactic to explain what it means. It also pretty prints the
type-incorrect motive and reports the type error.

- [#6170](https://github.com/leanprover/lean4/pull/6170) adds core metaprogramming functions for forking off background
tasks from elaboration such that their results are visible to reporting
and the language server

- [#6175](https://github.com/leanprover/lean4/pull/6175) fixes a bug with the `structure`/`class` command where if there
are parents that are not represented as subobjects but which used other
parents as instances, then there would be a kernel error. Closes #2611.

- [#6180](https://github.com/leanprover/lean4/pull/6180) fixes a non-termination bug that occurred when generating the
match-expression equation theorems. The bug was triggered when the proof
automation for the equation theorem repeatedly applied `injection(` to
the same local declaration, as it could not be removed due to forward
dependencies. See issue #6067 for an example that reproduces this issue.

- [#6189](https://github.com/leanprover/lean4/pull/6189) changes how generalized field notation ("dot notation") resolves
the function. The new resolution rule is that if `x : S`, then `x.f`
resolves the name `S.f` relative to the root namespace (hence it now
affected by `export` and `open`). Breaking change: aliases now resolve
differently. Before, if `x : S`, and if `S.f` is an alias for `S'.f`,
then `x.f` would use `S'.f` and look for an argument of type `S'`. Now,
it looks for an argument of type `S`, which is more generally useful
behavior. Code making use of the old behavior should consider defining
`S` or `S'` in terms of the other, since dot notation can unfold
definitions during resolution.

- [#6206](https://github.com/leanprover/lean4/pull/6206) makes it possible to write `rw (occs := [1,2]) ...` instead of
`rw (occs := .pos [1,2]) ...` by adding a coercion from `List.Nat` to
`Lean.Meta.Occurrences`.

- [#6220](https://github.com/leanprover/lean4/pull/6220) adds proper support for `let_fun` in `simp`.

- [#6236](https://github.com/leanprover/lean4/pull/6236) fixes an issue where edits to a command containing a nested
docstring fail to reparse the entire command.

## Library

- [#4904](https://github.com/leanprover/lean4/pull/4904) introduces date and time functionality to the Lean 4 Std.

- [#5616](https://github.com/leanprover/lean4/pull/5616) is a follow-up to https://github.com/leanprover/lean4/pull/5609,
where we add lemmas characterizing `smtUDiv` and `smtSDiv`'s behavior
when the denominator is zero.

- [#5866](https://github.com/leanprover/lean4/pull/5866) verifies the `keys` function on `Std.HashMap`.

- [#5885](https://github.com/leanprover/lean4/pull/5885) add Int16/Int32/Int64

- [#5926](https://github.com/leanprover/lean4/pull/5926) add `Option.or_some'`

- [#5927](https://github.com/leanprover/lean4/pull/5927) `List.pmap_eq_self`

- [#5937](https://github.com/leanprover/lean4/pull/5937) upstream lemmas about Fin.foldX

- [#5938](https://github.com/leanprover/lean4/pull/5938) upstream List.ofFn and relate to Array.ofFn

- [#5941](https://github.com/leanprover/lean4/pull/5941) List.mapFinIdx, lemmas, relate to Array version

- [#5949](https://github.com/leanprover/lean4/pull/5949) consolidate `decide_True` and `decide_true_eq_true`

- [#5950](https://github.com/leanprover/lean4/pull/5950) relate Array.takeWhile with List.takeWhile

- [#5951](https://github.com/leanprover/lean4/pull/5951) remove @[simp] from BitVec.ofFin_sub and sub_ofFin

- [#5952](https://github.com/leanprover/lean4/pull/5952) relate Array.eraseIdx with List.eraseIdx

- [#5961](https://github.com/leanprover/lean4/pull/5961) define ISize and basic operations on it

- [#5969](https://github.com/leanprover/lean4/pull/5969) upstream List.insertIdx from Batteries, lemmas from Mathlib, and revise lemmas

- [#5970](https://github.com/leanprover/lean4/pull/5970) deprecate Array.split in favour of identical Array.partition

- [#5971](https://github.com/leanprover/lean4/pull/5971) relate Array.isPrefixOf with List.isPrefixOf

- [#5972](https://github.com/leanprover/lean4/pull/5972) relate Array.zipWith/zip/unzip with List versions

- [#5974](https://github.com/leanprover/lean4/pull/5974) add another List.find?_eq_some lemma

- [#5981](https://github.com/leanprover/lean4/pull/5981) names the default SizeOf instance `instSizeOfDefault`

- [#5982](https://github.com/leanprover/lean4/pull/5982) minor lemmas about List.ofFn

- [#5984](https://github.com/leanprover/lean4/pull/5984) adds lemmas for `List` for the interactions between {`foldl`,
`foldr`, `foldlM`, `foldlrM`} and {`filter`, `filterMap`}.

- [#5985](https://github.com/leanprover/lean4/pull/5985) relates the operations `findSomeM?`, `findM?`, `findSome?`, and
`find?` on `Array` with the corresponding operations on `List`, and also
provides simp lemmas for the `Array` operations `findSomeRevM?`,
`findRevM?`, `findSomeRev?`, `findRev?` (in terms of `reverse` and the
usual forward find operations).

- [#5987](https://github.com/leanprover/lean4/pull/5987) BitVec.getMsbD in bv_decide

- [#5988](https://github.com/leanprover/lean4/pull/5988) changes the signature of `Array.set` to take a `Nat`, and a
tactic-provided bound, rather than a `Fin`.

- [#5995](https://github.com/leanprover/lean4/pull/5995) BitVec.sshiftRight' in bv_decide

- [#6007](https://github.com/leanprover/lean4/pull/6007) List.modifyTailIdx naming fix

- [#6008](https://github.com/leanprover/lean4/pull/6008) missing @[ext] attribute on monad transformer ext lemmas

- [#6023](https://github.com/leanprover/lean4/pull/6023) variants of List.forIn_eq_foldlM

- [#6025](https://github.com/leanprover/lean4/pull/6025) deprecate duplicated Fin.size_pos

- [#6032](https://github.com/leanprover/lean4/pull/6032) changes the signature of `Array.get` to take a Nat and a proof,
rather than a `Fin`, for consistency with the rest of the (planned)
Array API. Note that because of bootstrapping issues we can't provide
`get_elem_tactic` as an autoparameter for the proof. As users will
mostly use the `xs[i]` notation provided by `GetElem`, this hopefully
isn't a problem.

- [#6041](https://github.com/leanprover/lean4/pull/6041) modifies the order of arguments for higher-order `Array`
functions, preferring to put the `Array` last (besides positional
arguments with defaults). This is more consistent with the `List` API,
and is more flexible, as dot notation allows two different partially
applied versions.

- [#6049](https://github.com/leanprover/lean4/pull/6049) adds a primitive for accessing the current thread ID

- [#6052](https://github.com/leanprover/lean4/pull/6052) adds `Array.pmap`, as well as a `@[csimp]` lemma in terms of the
no-copy `Array.attachWith`.

- [#6055](https://github.com/leanprover/lean4/pull/6055) adds lemmas about for loops over `Array`, following the existing
lemmas for `List`.

- [#6056](https://github.com/leanprover/lean4/pull/6056) upstream some NameMap functions

- [#6060](https://github.com/leanprover/lean4/pull/6060) implements conversion functions from `Bool` to all `UIntX` and
`IntX` types.

- [#6070](https://github.com/leanprover/lean4/pull/6070) adds the Lean.RArray data structure.

- [#6074](https://github.com/leanprover/lean4/pull/6074) allow `Sort u` in `Squash`

- [#6094](https://github.com/leanprover/lean4/pull/6094) adds raw transmutation of floating-point numbers to and from
`UInt64`. Floats and UInts share the same endianness across all
supported platforms. The IEEE 754 standard precisely specifies the bit
layout of floats. Note that `Float.toBits` is distinct from
`Float.toUInt64`, which attempts to preserve the numeric value rather
than the bitwise value.

- [#6095](https://github.com/leanprover/lean4/pull/6095) generalize `List.get_mem`

- [#6097](https://github.com/leanprover/lean4/pull/6097) naming convention and `NaN` normalization

- [#6102](https://github.com/leanprover/lean4/pull/6102) moves `IO.rand` and `IO.setRandSeed` to be in the `BaseIO`
monad.

- [#6106](https://github.com/leanprover/lean4/pull/6106) fix naming of left/right injectivity lemmas

- [#6111](https://github.com/leanprover/lean4/pull/6111) fills in the API for `Array.findSome?` and `Array.find?`,
transferring proofs from the corresponding List statements.

- [#6120](https://github.com/leanprover/lean4/pull/6120) adds theorems `BitVec.(getMsbD, msb)_(rotateLeft, rotateRight)`.

- [#6126](https://github.com/leanprover/lean4/pull/6126) adds lemmas for extracting a given bit of a `BitVec` obtained
via `sub`/`neg`/`sshiftRight'`/`abs`.

- [#6130](https://github.com/leanprover/lean4/pull/6130) adds `Lean.loadPlugin` which exposes functionality similar to
the `lean` executable's `--plugin` option to Lean code.

- [#6132](https://github.com/leanprover/lean4/pull/6132) duplicates the verification API for
`List.attach`/`attachWith`/`pmap` over to `Array`.

- [#6133](https://github.com/leanprover/lean4/pull/6133) replaces `Array.feraseIdx` and `Array.insertAt` with
`Array.eraseIdx` and `Array.insertIdx`, both of which take a `Nat`
argument and a tactic-provided proof that it is in bounds. We also have
`eraseIdxIfInBounds` and `insertIdxIfInBounds` which are noops if the
index is out of bounds. We also provide a `Fin` valued version of
`Array.findIdx?`. Together, these quite ergonomically improve the array
indexing safety at a number of places in the compiler/elaborator.

- [#6136](https://github.com/leanprover/lean4/pull/6136) fixes the run-time evaluation of `(default : Float)`.

- [#6139](https://github.com/leanprover/lean4/pull/6139) modifies the signature of the functions `Nat.fold`,
`Nat.foldRev`, `Nat.any`, `Nat.all`, so that the function is passed the
upper bound. This allows us to change runtime array bounds checks to
compile time checks in many places.

- [#6148](https://github.com/leanprover/lean4/pull/6148) adds a primitive for creating temporary directories, akin to the
existing functionality for creating temporary files.

- [#6149](https://github.com/leanprover/lean4/pull/6149) completes the elementwise accessors for `ofNatLt`, `allOnes`,
and `not` by adding their implementations of `getMsbD`.

- [#6151](https://github.com/leanprover/lean4/pull/6151) completes the `toInt` interface for `BitVec` bitwise operations.

- [#6154](https://github.com/leanprover/lean4/pull/6154) implements `BitVec.toInt_abs`.

- [#6155](https://github.com/leanprover/lean4/pull/6155) adds `toNat` theorems for `BitVec.signExtend.`

- [#6157](https://github.com/leanprover/lean4/pull/6157) adds toInt theorems for BitVec.signExtend.

- [#6160](https://github.com/leanprover/lean4/pull/6160) adds theorem `mod_eq_sub`, makes theorem
`sub_mul_eq_mod_of_lt_of_le` not private anymore and moves its location
within the `rotate*` section to use it in other proofs.

- [#6184](https://github.com/leanprover/lean4/pull/6184) uses `Array.findFinIdx?` in preference to `Array.findIdx?` where
it allows converting a runtime bounds check to a compile time bounds
check.

- [#6188](https://github.com/leanprover/lean4/pull/6188) completes the `toNat` theorems for the bitwise operations
(`and`, `or`, `xor`, `shiftLeft`, `shiftRight`) of the UInt types and
adds `toBitVec` theorems as well. It also renames `and_toNat` to
`toNat_and` to fit with the current naming convention.

- [#6190](https://github.com/leanprover/lean4/pull/6190) adds the builtin simproc `USize.reduceToNat` which reduces the
`USize.toNat` operation on literals less than `UInt32.size` (i.e.,
`4294967296`).

- [#6191](https://github.com/leanprover/lean4/pull/6191) adds `Array.zipWithAll`, and the basic lemmas relating it to
`List.zipWithAll`.

- [#6192](https://github.com/leanprover/lean4/pull/6192) adds deprecations for `Lean.HashMap` functions which did not
receive deprecation attributes initially.

- [#6193](https://github.com/leanprover/lean4/pull/6193) completes the TODO in `Init.Data.Array.BinSearch`, removing the
`partial` keyword and converting runtime bounds checks to compile time
bounds checks.

- [#6194](https://github.com/leanprover/lean4/pull/6194) changes the signature of `Array.swap`, so it takes `Nat`
arguments with tactic provided bounds checking. It also renames
`Array.swap!` to `Array.swapIfInBounds`.

- [#6195](https://github.com/leanprover/lean4/pull/6195) renames `Array.setD` to `Array.setIfInBounds`.

- [#6197](https://github.com/leanprover/lean4/pull/6197) upstreams the definition of `Vector` from Batteries, along with
the basic functions.

- [#6200](https://github.com/leanprover/lean4/pull/6200) upstreams `Nat.lt_pow_self` and `Nat.lt_two_pow` from Mathlib
and uses them to prove the simp theorem `Nat.mod_two_pow`.

- [#6202](https://github.com/leanprover/lean4/pull/6202) makes `USize.toUInt64` a regular non-opaque definition.

- [#6203](https://github.com/leanprover/lean4/pull/6203) adds the theorems `le_usize_size` and `usize_size_le`, which
make proving inequalities about `USize.size` easier.

- [#6205](https://github.com/leanprover/lean4/pull/6205) upstreams some UInt theorems from Batteries and adds more
`toNat`-related theorems. It also adds the missing `UInt8` and `UInt16`
to/from `USize` conversions so that the the interface is uniform across
the UInt types.

- [#6207](https://github.com/leanprover/lean4/pull/6207) ensures the `Fin.foldl` and `Fin.foldr` are semireducible.
Without this the defeq `example (f : Fin 3 → ℕ) : List.ofFn f = [f 0, f
1, f 2] := rfl` was failing.

- [#6208](https://github.com/leanprover/lean4/pull/6208) fix Vector.indexOf?

- [#6217](https://github.com/leanprover/lean4/pull/6217) adds `simp` lemmas about `List`'s `==` operation.

- [#6221](https://github.com/leanprover/lean4/pull/6221) fixes:
- Problems in other linux distributions that the default `tzdata`
directory is not the same as previously defined by ensuring it with a
fallback behavior when directory is missing.
- Trim unnecessary characters from local time identifier.

- [#6222](https://github.com/leanprover/lean4/pull/6222) changes the definition of `HashSet.insertMany` and
`HashSet.Raw.insertMany` so that it is equivalent to repeatedly calling
`HashSet.insert`/`HashSet.Raw.insert`. It also clarifies the docstrings
of all the `insert` and `insertMany` functions.

- [#6230](https://github.com/leanprover/lean4/pull/6230) copies some lemmas about `List.foldX` to `Array`.

- [#6233](https://github.com/leanprover/lean4/pull/6233) upstreams lemmas about `Vector` from Batteries.

- [#6234](https://github.com/leanprover/lean4/pull/6234) upstreams the definition and basic lemmas about `List.finRange`
from Batteries.

- [#6235](https://github.com/leanprover/lean4/pull/6235) relates that operations `Nat.fold`/`foldRev`/`any`/`all` to the
corresponding List operations over `List.finRange`.

- [#6241](https://github.com/leanprover/lean4/pull/6241) refactors `Array.qsort` to remove runtime array bounds checks,
and avoids the use of `partial`. We use the `Vector` API, along with
auto_params, to avoid having to write any proofs. The new code
benchmarks indistinguishably from the old.

- [#6242](https://github.com/leanprover/lean4/pull/6242) deprecates `Fin.ofNat` in favour of `Fin.ofNat'` (which takes an
`[NeZero]` instance, rather than returning an element of `Fin (n+1)`).

- [#6247](https://github.com/leanprover/lean4/pull/6247) adds the theorems `numBits_pos`, `le_numBits`, `numBits_le` ,
which make proving inequalities about `System.Platform.numBits` easier.

## Compiler

- [#5840](https://github.com/leanprover/lean4/pull/5840) changes `lean_sharecommon_{eq,hash}` to only consider the
salient bytes of an object, and not any bytes of any
unspecified/uninitialized unused capacity.

- [#6087](https://github.com/leanprover/lean4/pull/6087) fixes a bug in the constant folding for the `Nat.ble` and
`Nat.blt` function in the old code generator, leading to a
miscompilation.

- [#6143](https://github.com/leanprover/lean4/pull/6143) should make lean better-behaved around sanitizers, per
https://github.com/google/sanitizers/issues/1688.
As far as I can tell,
https://github.com/google/sanitizers/wiki/AddressSanitizerUseAfterReturn#algorithm
replaces local variables with heap allocations, and so taking the
address of a local is not effective at producing a monotonic measure of
stack usage.

- [#6209](https://github.com/leanprover/lean4/pull/6209) documents under which conditions `Runtime.markPersistent` is
unsafe and adjusts the elaborator accordingly

- [#6257](https://github.com/leanprover/lean4/pull/6257) harden `markPersistent` uses

## Pretty Printing

- [#2934](https://github.com/leanprover/lean4/pull/2934) adds the option `pp.parens` (default: false) that causes the
pretty printer to eagerly insert parentheses, which can be useful for
teaching and for understanding the structure of expressions. For
example, it causes `p → q → r` to pretty print as `p → (q → r)`.

- [#6014](https://github.com/leanprover/lean4/pull/6014) prevents `Nat.succ ?_` from pretty printing as `?_.succ`, which
should make `apply?` be more usable.

- [#6085](https://github.com/leanprover/lean4/pull/6085) improves the term info for coercions marked with
`CoeFnType.coeFun` (such as `DFunLike.coe` in Mathlib), making "go to
definition" on the function name work. Hovering over such a coerced
function will show the coercee rather than the coercion expression. The
coercion expression can still be seen by hovering over the whitespace in
the function application.

- [#6096](https://github.com/leanprover/lean4/pull/6096) improves the `#print` command for structures to show all fields
and which parents the fields were inherited from, hiding internal
details such as which parents are represented as subobjects. This
information is still present in the constructor if needed. The pretty
printer for private constants is also improved, and it now handles
private names from the current module like any other name; private names
from other modules are made hygienic.

- [#6119](https://github.com/leanprover/lean4/pull/6119) adds a new delab option `pp.coercions.types` which, when
enabled, will display all coercions with an explicit type ascription.

- [#6161](https://github.com/leanprover/lean4/pull/6161) ensures whitespace is printed before `+opt` and `-opt`
configuration options when pretty printing, improving the experience of
tactics such as `simp?`.

- [#6181](https://github.com/leanprover/lean4/pull/6181) fixes a bug where the signature pretty printer would ignore the
current setting of `pp.raw`. This fixes an issue where `#check ident`
would not heed `pp.raw`. Closes #6090.

- [#6213](https://github.com/leanprover/lean4/pull/6213) exposes the difference in "synthesized type class instance is
not definitionally equal" errors.

## Documentation

- [#6009](https://github.com/leanprover/lean4/pull/6009) fixes a typo in the docstring for prec and makes the text
slightly more precise.

- [#6040](https://github.com/leanprover/lean4/pull/6040) join → flatten in docstring

- [#6110](https://github.com/leanprover/lean4/pull/6110) does some mild refactoring of the `Lean.Elab.StructInst` module
while adding documentation.

- [#6144](https://github.com/leanprover/lean4/pull/6144) converts 3 doc-string to module docs since it seems that this is
what they were intended to be!

- [#6150](https://github.com/leanprover/lean4/pull/6150) refine kernel code comments

- [#6158](https://github.com/leanprover/lean4/pull/6158) adjust file reference in Data.Sum

- [#6239](https://github.com/leanprover/lean4/pull/6239) explains the order in which `Expr.abstract` introduces de Bruijn
indices.

## Server

- [#5835](https://github.com/leanprover/lean4/pull/5835) adds auto-completion for the fields of structure instance notation. Specifically, querying the completions via `Ctrl+Space` in the whitespace of a structure instance notation will now bring up the full list of fields. Whitespace structure completion can be enabled for custom syntax by wrapping the parser for the list of fields in a `structInstFields` parser.

- [#5837](https://github.com/leanprover/lean4/pull/5837) fixes an old auto-completion bug where `x.` would issue
nonsensical completions when `x.` could not be elaborated as a dot
completion.

- [#5996](https://github.com/leanprover/lean4/pull/5996) avoid max heartbeat error in completion

- [#6031](https://github.com/leanprover/lean4/pull/6031) fixes a regression with go-to-definition and document highlight
misbehaving on tactic blocks.

- [#6246](https://github.com/leanprover/lean4/pull/6246) fixes a performance issue where the Lean language server would
walk the full project file tree every time a file was saved, blocking
the processing of all other requests and notifications and significantly
increasing overall language server latency after saving.

## Lake

- [#5684](https://github.com/leanprover/lean4/pull/5684) update toolchain on `lake update`

- [#6026](https://github.com/leanprover/lean4/pull/6026) adds a newline at end of each Lean file generated by `lake new`
templates.

- [#6218](https://github.com/leanprover/lean4/pull/6218) makes Lake no longer automatically fetch GitHub cloud releases
if the package build directory is already present (mirroring the
behavior of the Reservoir cache). This prevents the cache from
clobbering existing prebuilt artifacts. Users can still manually fetch
the cache and clobber the build directory by running `lake build
<pkg>:release`.

- [#6225](https://github.com/leanprover/lean4/pull/6225) makes `lake build` also eagerly print package materialization
log lines. Previously, only a `lake update` performed eager logging.

- [#6231](https://github.com/leanprover/lean4/pull/6231) improves the errors Lake produces when it fails to fetch a
dependency from Reservoir. If the package is not indexed, it will
produce a suggestion about how to require it from GitHub.

## Other

- [#6137](https://github.com/leanprover/lean4/pull/6137) adds support for displaying multiple threads in the trace
profiler output.

- [#6138](https://github.com/leanprover/lean4/pull/6138) fixes `trace.profiler.pp` not using the term pretty printer.

- [#6259](https://github.com/leanprover/lean4/pull/6259) ensures that nesting trace nodes are annotated with timing
information iff `trace.profiler` is active.
````
