/-
Copyright (c) 2024 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: David Thrane Christiansen
-/

import VersoManual

import Verso.Code.Highlighted

import Manual.Meta.Basic
import Manual.Meta.PPrint

open Verso Doc Elab
open Verso.Genre Manual
open Verso.ArgParse
open Verso.Code (highlightingJs)
open Verso.Code.Highlighted.WebAssets


open Lean Elab Parser
open Lean.Widget (TaggedText)
open SubVerso.Highlighting
open Verso.Code

namespace Manual

def Inline.attr : Inline where
  name := `Manual.attr

@[role_expander attr]
def attr : RoleExpander
  | args, inlines => do
    let () ← ArgParse.done.run args
    let #[arg] := inlines
      | throwError "Expected exactly one argument"
    let `(inline|code( $a:str )) := arg
      | throwErrorAt arg "Expected code literal with the attribute"
    let altStr ← parserInputString a

    match Parser.runParserCategory (← getEnv) `attr altStr (← getFileName) with
    | .error e => throwErrorAt a e
    | .ok stx =>
      let attrName ←
        match stx.getKind with
        | `Lean.Parser.Attr.simple => pure stx[0].getId
        | .str (.str (.str (.str .anonymous "Lean") "Parser") "Attr") k => pure k.toName
        | .str (.str (.str .anonymous "Lean") "Attr") k => pure k.toName
        | other =>
          let allAttrs := attributeExtension.getState (← getEnv) |>.map |>.toArray |>.map (·.fst) |>.qsort (·.toString < ·.toString)
          throwErrorAt a "Failed to process attribute kind: {stx.getKind} {isAttribute (← getEnv) stx.getKind} {allAttrs |> repr}"
      match getAttributeImpl (← getEnv) attrName with
      | .error e => throwErrorAt a e
      | .ok {descr, name, ref, ..} =>
        let attrTok := a.getString
        let hl : Highlighted := attrToken ref descr attrTok
        try
          -- Attempt to add info to the document source for go-to-def and the like, but this doesn't
          -- work for all attributes (e.g. `csimp`)
          discard <| realizeGlobalConstNoOverloadWithInfo (mkIdentFrom a ref)
        catch _ =>
          pure ()
        pure #[← `(Verso.Doc.Inline.other {Inline.attr with data := ToJson.toJson $(quote hl)} #[Verso.Doc.Inline.code $(quote attrTok)])]

where
  -- TODO: This will eventually generate the right cross-reference, but VersoManual needs to have a
  -- domain for syntax categories/kinds upstreamed to it first (and then the appropriate link target
  -- code added)
  attrToken (ref : Name) (descr : String) (tok : String) : Highlighted :=
    .token ⟨.keyword ref none (some descr), tok⟩

@[inline_extension attr]
def attr.descr : InlineDescr where
  traverse _ _ _ := do
    pure none
  toTeX := none
  extraCss := [highlightingStyle, docstringStyle]
  extraJs := [highlightingJs]
  toHtml :=
    open Verso.Output.Html Verso.Doc.Html in
    some <| fun _ _ data _ => do
      match FromJson.fromJson? data with
      | .error err =>
        HtmlT.logError <| "Couldn't deserialize Lean attribute code while rendering HTML: " ++ err
        pure .empty
      | .ok (hl : Highlighted) =>
        hl.inlineHtml (g := Manual) "examples"
