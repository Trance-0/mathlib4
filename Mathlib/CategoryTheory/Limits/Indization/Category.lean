/-
Copyright (c) 2024 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel
-/
import Mathlib.CategoryTheory.Functor.Flat
import Mathlib.CategoryTheory.Limits.Constructions.Filtered
import Mathlib.CategoryTheory.Limits.FullSubcategory
import Mathlib.CategoryTheory.Limits.Indization.LocallySmall
import Mathlib.CategoryTheory.Limits.Indization.FilteredColimits
import Mathlib.CategoryTheory.Limits.Indization.Products

/-!
# The category of Ind-objects

We define the `v`-category of Ind-objects of a category `C`, called `Ind C`, as well as the functors
`Ind.yoneda : C ⥤ Ind C` and `Ind.inclusion C : Ind C ⥤ Cᵒᵖ ⥤ Type v`.

For a small filtered category `I`, we also define `Ind.lim I : (I ⥤ C) ⥤ Ind C`.

This file will mainly collect results about ind-objects (stated in terms of `IsIndObject`) and
reinterpret them in terms of `Ind C`.

Adopting the theorem numbering of [Kashiwara2006], we show that
* `Ind C` has filtered colimits (6.1.8),
* `Ind C ⥤ Cᵒᵖ ⥤ Type v` creates filtered colimits (6.1.8),
* `C ⥤ Ind C` preserves finite colimits (6.1.6),
* if `C` has coproducts indexed by a finite type `α`, then `Ind C` has coproducts indexed by `α`
  (6.1.18(ii)),
* if `C` has finite coproducts, then `Ind C` has small coproducts (6.1.18(ii)),
* if `C` has products indexed by `α`, then `Ind C` has products indexed by `α`, and the functor
  `Ind C ⥤ Cᵒᵖ ⥤ Type v` creates such products (6.1.17)
* the functor `C ⥤ Ind C` preserves small limits.

More limit-colimit properties will follow.

Note that:
* the functor `Ind C ⥤ Cᵒᵖ ⥤ Type v` does not preserve any kind of colimit in general except for
  filtered colimits and
* the functor `C ⥤ Ind C` preserves finite colimits, but not infinite colimits in general.

## References
* [M. Kashiwara, P. Schapira, *Categories and Sheaves*][Kashiwara2006], Chapter 6
-/

universe v u

namespace CategoryTheory

open Limits

variable {C : Type u} [Category.{v} C]

variable (C) in
/-- The category of Ind-objects of `C`. -/
def Ind : Type (max u (v + 1)) :=
  ShrinkHoms (FullSubcategory (IsIndObject (C := C)))

noncomputable instance : Category.{v} (Ind C) :=
  inferInstanceAs <| Category.{v} (ShrinkHoms (FullSubcategory (IsIndObject (C := C))))

variable (C) in
/-- The defining properties of `Ind C` are that its morphisms live in `v` and that it is equivalent
to the full subcategory of `Cᵒᵖ ⥤ Type v` containing the ind-objects. -/
noncomputable def Ind.equivalence : Ind C ≌ FullSubcategory (IsIndObject (C := C)) :=
  (ShrinkHoms.equivalence _).symm

variable (C) in
/-- The canonical inclusion of ind-objects into presheaves. -/
protected noncomputable def Ind.inclusion : Ind C ⥤ Cᵒᵖ ⥤ Type v :=
  (Ind.equivalence C).functor ⋙ fullSubcategoryInclusion _

instance : (Ind.inclusion C).Full :=
  inferInstanceAs <| ((Ind.equivalence C).functor ⋙ fullSubcategoryInclusion _).Full

instance : (Ind.inclusion C).Faithful :=
  inferInstanceAs <| ((Ind.equivalence C).functor ⋙ fullSubcategoryInclusion _).Faithful

/-- The functor `Ind C ⥤ Cᵒᵖ ⥤ Type v` is fully faithful. -/
protected noncomputable def Ind.inclusion.fullyFaithful : (Ind.inclusion C).FullyFaithful :=
  .ofFullyFaithful _

/-- The inclusion of `C` into `Ind C` induced by the Yoneda embedding. -/
protected noncomputable def Ind.yoneda : C ⥤ Ind C :=
  FullSubcategory.lift _ CategoryTheory.yoneda isIndObject_yoneda ⋙ (Ind.equivalence C).inverse

instance : (Ind.yoneda (C := C)).Full :=
  inferInstanceAs <| Functor.Full <|
    FullSubcategory.lift _ CategoryTheory.yoneda isIndObject_yoneda ⋙ (Ind.equivalence C).inverse

instance : (Ind.yoneda (C := C)).Faithful :=
  inferInstanceAs <| Functor.Faithful <|
    FullSubcategory.lift _ CategoryTheory.yoneda isIndObject_yoneda ⋙ (Ind.equivalence C).inverse

/-- The functor `C ⥤ Ind C` is fully faithful. -/
protected noncomputable def Ind.yoneda.fullyFaithful : (Ind.yoneda (C := C)).FullyFaithful :=
  .ofFullyFaithful _

/-- The composition `C ⥤ Ind C ⥤ (Cᵒᵖ ⥤ Type v)` is just the Yoneda embedding. -/
noncomputable def Ind.yonedaCompInclusion : Ind.yoneda ⋙ Ind.inclusion C ≅ CategoryTheory.yoneda :=
  isoWhiskerLeft (FullSubcategory.lift _ _ _)
    (isoWhiskerRight (Ind.equivalence C).counitIso (fullSubcategoryInclusion _))

noncomputable instance {J : Type v} [SmallCategory J] [IsFiltered J] :
    CreatesColimitsOfShape J (Ind.inclusion C) :=
  letI _ : CreatesColimitsOfShape J (fullSubcategoryInclusion (IsIndObject (C := C))) :=
    createsColimitsOfShapeFullSubcategoryInclusion (closedUnderColimitsOfShape_of_colimit
      (isIndObject_colimit _ _))
  inferInstanceAs <|
    CreatesColimitsOfShape J ((Ind.equivalence C).functor ⋙ fullSubcategoryInclusion _)

instance : HasFilteredColimits (Ind C) where
  HasColimitsOfShape _ _ _ :=
    hasColimitsOfShape_of_hasColimitsOfShape_createsColimitsOfShape (Ind.inclusion C)

noncomputable instance {J : Type v} [HasLimitsOfShape (Discrete J) C] :
    CreatesLimitsOfShape (Discrete J) (Ind.inclusion C) :=
  letI _ : CreatesLimitsOfShape (Discrete J) (fullSubcategoryInclusion (IsIndObject (C := C))) :=
    createsLimitsOfShapeFullSubcategoryInclusion (closedUnderLimitsOfShape_of_limit
      (isIndObject_limit_of_discrete_of_hasLimitsOfShape _))
  inferInstanceAs <|
    CreatesLimitsOfShape (Discrete J) ((Ind.equivalence C).functor ⋙ fullSubcategoryInclusion _)

instance {J : Type v} [HasLimitsOfShape (Discrete J) C] :
    HasLimitsOfShape (Discrete J) (Ind C) :=
  hasLimitsOfShape_of_hasLimitsOfShape_createsLimitsOfShape (Ind.inclusion C)

instance : PreservesLimits (Ind.yoneda (C := C)) :=
  letI _ : PreservesLimitsOfSize.{v, v} (Ind.yoneda ⋙ Ind.inclusion C) :=
    preservesLimits_of_natIso Ind.yonedaCompInclusion.symm
  preservesLimits_of_reflects_of_preserves Ind.yoneda (Ind.inclusion C)

theorem Ind.isIndObject_inclusion_obj (X : Ind C) : IsIndObject ((Ind.inclusion C).obj X) :=
  X.2

/-- Pick a presentation of an ind-object `X` using choice. -/
noncomputable def Ind.presentation (X : Ind C) : IndObjectPresentation ((Ind.inclusion C).obj X) :=
  X.isIndObject_inclusion_obj.presentation

/-- An ind-object `X` is the colimit (in `Ind C`!) of the filtered diagram presenting it. -/
noncomputable def Ind.colimitPresentationCompYoneda (X : Ind C) :
    colimit (X.presentation.F ⋙ Ind.yoneda) ≅ X :=
  Ind.inclusion.fullyFaithful.isoEquiv.symm <| calc
    (Ind.inclusion C).obj (colimit (X.presentation.F ⋙ Ind.yoneda))
      ≅ colimit (X.presentation.F ⋙ Ind.yoneda ⋙ Ind.inclusion C) := preservesColimitIso _ _
    _ ≅ colimit (X.presentation.F ⋙ yoneda) :=
          HasColimit.isoOfNatIso (isoWhiskerLeft X.presentation.F Ind.yonedaCompInclusion)
    _ ≅ (Ind.inclusion C).obj X :=
          IsColimit.coconePointUniqueUpToIso (colimit.isColimit _) X.presentation.isColimit

instance : RepresentablyCoflat (Ind.yoneda (C := C)) := by
  refine ⟨fun X => ?_⟩
  suffices IsFiltered (CostructuredArrow yoneda ((Ind.inclusion C).obj X)) from
    IsFiltered.of_equivalence
      ((CostructuredArrow.post Ind.yoneda (Ind.inclusion C) X).asEquivalence.trans
      (CostructuredArrow.mapNatIso Ind.yonedaCompInclusion)).symm
  exact ((isIndObject_iff _).1 (Ind.isIndObject_inclusion_obj X)).1

noncomputable instance : PreservesFiniteColimits (Ind.yoneda (C := C)) :=
  preservesFiniteColimits_of_coflat _

/-- This is the functor `(I ⥤ C) ⥤ Ind C` that sends a functor `F` to `colim (Y ∘ F)`, where `Y`
is the Yoneda embedding. It is known as "ind-lim" and denoted `“colim”` in [Kashiwara2006]. -/
protected noncomputable def Ind.lim (I : Type v) [SmallCategory I] [IsFiltered I] :
    (I ⥤ C) ⥤ Ind C :=
  (whiskeringRight _ _ _).obj Ind.yoneda ⋙ colim

/-- Computing ind-lims in `Ind C` is the same as computing them in `Cᵒᵖ ⥤ Type v`. -/
noncomputable def Ind.limCompInclusion {I : Type v} [SmallCategory I] [IsFiltered I] :
    Ind.lim I ⋙ Ind.inclusion C ≅ (whiskeringRight _ _ _).obj yoneda ⋙ colim := calc
  Ind.lim I ⋙ Ind.inclusion C
    ≅ (whiskeringRight _ _ _).obj Ind.yoneda ⋙ colim ⋙ Ind.inclusion C := Functor.associator _ _ _
  _ ≅ (whiskeringRight _ _ _).obj Ind.yoneda ⋙
      (whiskeringRight _ _ _).obj (Ind.inclusion C) ⋙ colim :=
    isoWhiskerLeft _ (preservesColimitNatIso _)
  _ ≅ ((whiskeringRight _ _ _).obj Ind.yoneda ⋙
      (whiskeringRight _ _ _).obj (Ind.inclusion C)) ⋙ colim := (Functor.associator _ _ _).symm
  _ ≅ (whiskeringRight _ _ _).obj (Ind.yoneda ⋙ Ind.inclusion C) ⋙ colim :=
    isoWhiskerRight (whiskeringRightObjCompIso _ _) colim
  _ ≅ (whiskeringRight _ _ _).obj yoneda ⋙ colim :=
    isoWhiskerRight ((whiskeringRight _ _ _).mapIso (Ind.yonedaCompInclusion)) colim

instance {α : Type v} [SmallCategory α] [FinCategory α] [HasLimitsOfShape α C] {I : Type v}
    [SmallCategory I] [IsFiltered I] :
    PreservesLimitsOfShape α (Ind.lim I : (I ⥤ C) ⥤ _) :=
  haveI : PreservesLimitsOfShape α (Ind.lim I ⋙ Ind.inclusion C) :=
    preservesLimitsOfShape_of_natIso Ind.limCompInclusion.symm
  preservesLimitsOfShape_of_reflects_of_preserves _ (Ind.inclusion C)

instance {α : Type v} [SmallCategory α] [FinCategory α] [HasColimitsOfShape α C] {I : Type v}
    [SmallCategory I] [IsFiltered I] :
    PreservesColimitsOfShape α (Ind.lim I : (I ⥤ C) ⥤ _) :=
  inferInstanceAs (PreservesColimitsOfShape α (_ ⋙ colim))

instance {α : Type v} [Finite α] [HasColimitsOfShape (Discrete α) C] :
    HasColimitsOfShape (Discrete α) (Ind C) := by
  refine ⟨fun F => ?_⟩
  let I : α → Type v := fun s => (F.obj ⟨s⟩).presentation.I
  let G : ∀ s, I s ⥤ C := fun s => (F.obj ⟨s⟩).presentation.F
  let iso : Discrete.functor (fun s => Pi.eval I s ⋙ G s) ⋙
      (whiskeringRight _ _ _).obj Ind.yoneda ⋙ colim ≅ F := by
    refine Discrete.natIso (fun s => ?_)
    refine (Functor.Final.colimitIso (Pi.eval I s.as) (G s.as ⋙ Ind.yoneda)) ≪≫ ?_
    exact Ind.colimitPresentationCompYoneda _
  -- The actual proof happens during typeclass resolution in the following line, which deduces
  -- ```
  -- HasColimit Discrete.functor (fun s => Pi.eval I s ⋙ G s) ⋙
  --    (whiskeringRight _ _ _).obj Ind.yoneda ⋙ colim
  -- ```
  -- from the fact that finite limits commute with filtered colimits and from the fact that
  -- `Ind.yoneda` preserves finite colimits.
  apply hasColimitOfIso iso.symm

instance [HasFiniteCoproducts C] : HasCoproducts.{v} (Ind C) :=
  have : HasFiniteCoproducts (Ind C) :=
    ⟨fun _ => hasColimitsOfShape_of_equivalence (Discrete.equivalence Equiv.ulift)⟩
  hasCoproducts_of_finite_and_filtered

end CategoryTheory
