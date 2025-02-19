/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel
-/
import Mathlib.Algebra.Category.Grp.Basic
import Mathlib.CategoryTheory.Preadditive.Basic

/-!
# The category of additive commutative groups is preadditive.
-/

open CategoryTheory

universe u

namespace AddCommGrp

instance (P Q : AddCommGrp) : AddCommGroup (P ⟶ Q) :=
  (inferInstance : AddCommGroup (AddMonoidHom P Q))

-- Porting note (https://github.com/leanprover-community/mathlib4/pull/10688): this lemma was not necessary in mathlib
@[simp]
lemma hom_add_apply {P Q : AddCommGrp} (f g : P ⟶ Q) (x : P) : (f + g) x = f x + g x := rfl

instance : Preadditive AddCommGrp where

end AddCommGrp
