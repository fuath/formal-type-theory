(* In order to test our formalisation, we propose our own formalisation of a
   model that negates function extensionality, following Simon Boulier,
   Pierre-Marie Pédrot et Nicolas Tabareau.
*)

Require config.
Require Import config_tactics.

Require Import syntax.
Require Import tt.

(* Source type theory *)
Module Stt.

  Section Stt.

  Local Instance hasPrecond : config.Precond
    := {| config.precondFlag := config.Yes |}.
  Context `{configReflection : config.Reflection}.
  Context `{ConfigSimpleProducts : config.SimpleProducts}.

  Definition isctx   := isctx.
  Definition issubst := issubst.
  Definition istype  := istype.
  Definition isterm  := isterm.
  Definition eqctx   := eqctx.
  Definition eqsubst := eqsubst.
  Definition eqtype  := eqtype.
  Definition eqterm  := eqterm.

  End Stt.

End Stt.

(* Target type theory *)
Module Ttt.

  Section Ttt.

  Local Instance hasPrecond : config.Precond
    := {| config.precondFlag := config.No |}.
  Context `{configReflection : config.Reflection}.
  Local Instance hasSimpleProducts : config.SimpleProducts
    := {| config.simpleproductsFlag := config.Yes |}.

  Definition isctx   := isctx.
  Definition issubst := issubst.
  Definition istype  := istype.
  Definition isterm  := isterm.
  Definition eqctx   := eqctx.
  Definition eqsubst := eqsubst.
  Definition eqtype  := eqtype.
  Definition eqterm  := eqterm.

  End Ttt.

End Ttt.

Section Translation.

Context `{configReflection : config.Reflection}.
Context `{configSimpleProducts : config.SimpleProducts}.

Axiom cheating : forall A : Type, A.
Ltac todo := apply cheating.

Fixpoint trans_ctx (G : context) : context :=
  match G with
  | ctxempty => ctxempty
  | ctxextend G A => ctxextend (trans_ctx G) (trans_type A)
  end

with trans_type (A : type) : type :=
  match A with
  | Prod A B => SimProd (Prod (trans_type A) (trans_type B)) Bool
  | Id A u v => Id (trans_type A) (trans_term u) (trans_term v)
  | Subst A sbs => Subst (trans_type A) (trans_subst sbs)
  | Empty => Empty
  | Unit => Unit
  | Bool => Bool
  | SimProd A B => SimProd (trans_type A) (trans_type B)
  end

with trans_term (t : term) : term :=
  match t with
  | var k => var k
  | lam A B u =>
    pair (Prod (trans_type A) (trans_type B))
         Bool
         (lam (trans_type A) (trans_type B) (trans_term u))
         true
  | app u A B v =>
    app (proj1 (Prod (trans_type A) (trans_type B)) Bool (trans_term u))
        (trans_type A)
        (trans_type B)
        (trans_term v)
  | refl A u => refl (trans_type A) (trans_term u)
  | j A u C w v p =>
    j (trans_type A)
      (trans_term u)
      (trans_type C)
      (trans_term w)
      (trans_term v)
      (trans_term p)
  | subst u sbs => subst (trans_term u) (trans_subst sbs)
  | exfalso A u => exfalso (trans_type A) (trans_term u)
  | unit => unit
  | true => true
  | false => false
  | cond C u v w =>
    cond (trans_type C) (trans_term u) (trans_term v) (trans_term w)
  | pair A B u v =>
    pair (trans_type A) (trans_type B) (trans_term u) (trans_term v)
  | proj1 A B p =>
    proj1 (trans_type A) (trans_type B) (trans_term p)
  | proj2 A B p =>
    proj2 (trans_type A) (trans_type B) (trans_term p)
  end

with trans_subst (sbs : substitution) : substitution :=
  match sbs with
  | sbzero A u => sbzero (trans_type A) (trans_term u)
  | sbweak A => sbweak (trans_type A)
  | sbshift A sbs => sbshift (trans_type A) (trans_subst sbs)
  | sbid => sbid
  | sbcomp sbs sbt => sbcomp (trans_subst sbs) (trans_subst sbt)
  end.

Ltac ih :=
  match goal with
  | trans_isctx :
      forall G,
        Stt.isctx G ->
        Ttt.isctx (trans_ctx G)
    |- isctx (trans_ctx ?G) =>
    now apply (trans_isctx G)
  | trans_istype :
      forall G A,
        Stt.istype G A ->
        Ttt.istype (trans_ctx G) (trans_type A)
    |- istype (trans_ctx ?G) (trans_type ?A) =>
    now apply (trans_istype G A)
  | trans_isterm :
      forall G u A,
        Stt.isterm G u A ->
        Ttt.isterm (trans_ctx G) (trans_term u) (trans_type A)
    |- isterm (trans_ctx ?G) (trans_term ?u) (trans_type ?A) =>
    now apply (trans_isterm G u A)
  | trans_issubst :
      forall sbs G D,
        Stt.issubst sbs G D ->
        Ttt.issubst (trans_subst sbs) (trans_ctx G) (trans_ctx D)
    |- issubst (trans_subst ?sbs) (trans_ctx ?G) (trans_ctx ?D) =>
    now apply (trans_issubst sbs G D)
  | trans_eqctx :
      forall G D,
        Stt.eqctx G D ->
        Ttt.eqctx (trans_ctx G) (trans_ctx D)
    |- eqctx (trans_ctx ?G) (trans_ctx ?D) =>
    now apply (trans_eqctx G D)
  | trans_eqtype :
      forall G A B,
        Stt.eqtype G A B ->
        Ttt.eqtype (trans_ctx G) (trans_type A) (trans_type B)
    |- eqtype (trans_ctx ?G) (trans_type ?A) (trans_type ?B) =>
    now apply (trans_eqtype G A B)
  | trans_eqterm :
      forall G u v A,
        Stt.eqterm G u v A ->
        Ttt.eqterm (trans_ctx G) (trans_term u) (trans_term v) (trans_type A)
    |- eqterm (trans_ctx ?G) (trans_term ?u) (trans_term ?v) (trans_type ?A) =>
    now apply (trans_eqterm G u v A)
  | trans_eqsubst :
      forall sbs sbt G D,
        Stt.eqsubst sbs sbt G D ->
        Ttt.eqsubst (trans_subst sbs)
                    (trans_subst sbt)
                    (trans_ctx G)
                    (trans_ctx D)
    |- eqsubst (trans_subst ?sbs)
              (trans_subst ?sbt)
              (trans_ctx ?G)
              (trans_ctx ?D) =>
    now apply (trans_eqsubst sbs sbt G D)
  end.

Fixpoint trans_isctx {G} (H : Stt.isctx G) {struct H} :
  Ttt.isctx (trans_ctx G)

with trans_istype {G A} (H : Stt.istype G A) {struct H} :
  Ttt.istype (trans_ctx G) (trans_type A)

with trans_isterm {G u A} (H : Stt.isterm G u A) {struct H} :
  Ttt.isterm (trans_ctx G) (trans_term u) (trans_type A)

with trans_issubst {sbs G D} (H : Stt.issubst sbs G D) {struct H} :
  Ttt.issubst (trans_subst sbs) (trans_ctx G) (trans_ctx D)

with trans_eqctx {G D} (H : Stt.eqctx G D) {struct H} :
  Ttt.eqctx (trans_ctx G) (trans_ctx D)

with trans_eqtype {G A B} (H : Stt.eqtype G A B) {struct H} :
  Ttt.eqtype (trans_ctx G) (trans_type A) (trans_type B)

with trans_eqterm {G u v A} (H : Stt.eqterm G u v A) {struct H} :
  Ttt.eqterm (trans_ctx G) (trans_term u) (trans_term v) (trans_type A)

with trans_eqsubst {sbs sbt G D} (H : Stt.eqsubst sbs sbt G D) {struct H} :
  Ttt.eqsubst (trans_subst sbs) (trans_subst sbt) (trans_ctx G) (trans_ctx D).

Proof.

  (* trans_isctx *)
  - { destruct H ; doConfig.

      (* CtxEmpty *)
      - constructor.

      (* CtxExtend *)
      - simpl. config constructor.
        ih.
    }

  (* trans_istype *)
  - { destruct H ; doConfig.

      (* TyCtxConv *)
      - { (config apply @TyCtxConv with (G := trans_ctx G)) ; ih. }

      (* TySubst *)
      - { simpl.
          config apply @TySubst with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* TyProd *)
      - { simpl.
          capply TySimProd.
          - todo. (* Where is the hypothesis that Ttt has simple products? *)
          - capply TyProd.
            now apply (trans_istype (ctxextend G A) B).
          (* Too bad ih doesn't deal with this*)
          - capply TyBool. ih.
        }

      (* TyId *)
      - { simpl. capply TyId.
          - ih.
          - ih.
        }

      (* TyEmpty *)
      - capply TyEmpty ; ih.

      (* TyUnit *)
      - capply TyUnit ; ih.

      (* TyBool *)
      - capply TyBool ; ih.

      (* TySimProd *)
      - { simpl. capply TySimProd.
          - todo. (* I'm not good with type classes yet *)
          - ih.
          - ih.
        }
    }

  (* trans_isterm *)
  - { destruct H ; doConfig.

      (* TermTyConv *)
      - { config apply @TermTyConv with (A := trans_type A).
          - ih.
          - ih.
        }

      (* TermCtxConv *)
      - { config apply @TermCtxConv with (G := trans_ctx G).
          - ih.
          - ih.
        }

      (* TermSubst *)
      - { simpl.
          config apply @TermSubst with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* TermVarZero *)
      - { simpl. capply TermVarZero. ih. }

      (* TermVarSucc *)
      - { simpl. capply TermVarSucc.
          - now apply (trans_isterm G (var k) A).
          - ih.
        }

      (* TermAbs *)
      - { simpl.
          capply TermPair.
          - todo. (* type classes problem *)
          - capply TermAbs.
            now apply (trans_isterm (ctxextend G A) u B).
          - capply TermTrue. ih.
        }

      (* TermApp *)
      - { simpl.
          capply TermApp.
          - capply TermProj1.
            + todo. (* type classes *)
            + now apply (trans_isterm G u (Prod A B)).
          - ih.
        }

      (* TermRefl *)
      - { simpl. capply TermRefl. ih. }

      (* TermJ *)
      - { simpl. capply TermJ.
          - ih.
          - now apply (trans_istype (ctxextend (ctxextend G A)
            (Id (Subst A (sbweak A)) (subst u (sbweak A)) (var 0))) C).
          - now apply (trans_isterm G w
         (Subst
            (Subst C
               (sbshift (Id (Subst A (sbweak A)) (subst u (sbweak A)) (var 0))
                  (sbzero A u))) (sbzero (Id A u u) (refl A u)))).
          - ih.
          - now apply (trans_isterm G p (Id A u v)).
        }

      (* TermExfalso *)
      - { simpl. capply TermExfalso.
          - ih.
          - now apply (trans_isterm G u Empty).
        }

      (* TermUnit *)
      - { simpl. capply TermUnit. ih. }

      (* TermTrue *)
      - { simpl. capply TermTrue. ih. }

      (* TermFalse *)
      - { simpl. capply TermFalse. ih. }

      (* TermCond *)
      - { simpl. capply TermCond.
          - now apply (trans_isterm G u Bool).
          - now apply (trans_istype (ctxextend G Bool) C).
          - now apply (trans_isterm G v (Subst C (sbzero Bool true))).
          - now apply (trans_isterm G w (Subst C (sbzero Bool false))).
        }

      (* TermPair *)
      - { simpl. capply TermPair.
          - todo. (* type classes *)
          - ih.
          - ih.
        }

      (* TermProj1 *)
      - { simpl. capply TermProj1.
          - todo. (* type classes *)
          - now apply (trans_isterm G p (SimProd A B)).
        }

      (* TermProj2 *)
      - { simpl. capply TermProj2.
          - todo. (* type classes *)
          - now apply (trans_isterm G p (SimProd A B)).
        }
    }

  (* trans_issubst *)
  - { destruct H ; doConfig.

      (* SubstZerp *)
      - { simpl. capply SubstZero. ih. }

      (* SubstWeak *)
      - { simpl. capply SubstWeak. ih. }

      (* SubstShift *)
      - { simpl. capply SubstShift ; ih. }

      (* SubstId *)
      - { simpl. capply SubstId. ih. }

      (* SubstComp *)
      - { simpl. config apply @SubstComp with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* SubstCtxConv *)
      - { config apply @SubstCtxConv with (G1 := trans_ctx G1) (D1 := trans_ctx D1).
          - ih.
          - ih.
          - ih.
        }
    }

  (* trans_eqctx *)
  - { destruct H ; doConfig.

      (* CtxRefl *)
      - { capply CtxRefl. ih. }

      (* CtxSym *)
      - { capply CtxSym. ih. }

      (* CtxTrans *)
      - { config apply @CtxTrans with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* EqCtxEmpty *)
      - { capply EqCtxEmpty. }

      (* EqCtxExtend *)
      - { simpl. capply EqCtxExtend.
          - ih.
          - ih.
        }
    }

  (* trans_eqtype *)
  - { destruct H ; doConfig.

      (* EqTyCtxConv *)
      - { config apply @EqTyCtxConv with (G := trans_ctx G).
          - ih.
          - ih.
        }

      (* EqTyRefl *)
      - { capply EqTyRefl. ih. }

      (* EqTySym *)
      - { capply EqTySym. ih. }

      (* EqTyTrans *)
      - { config apply @EqTyTrans with (B := trans_type B).
          - ih.
          - ih.
        }

      (* EqTyIdSubst *)
      - { simpl. capply EqTyIdSubst. ih. }

      (* EqTySubstComp *)
      - { simpl. config apply @EqTySubstComp with (D := trans_ctx D) (E := trans_ctx E).
          - ih.
          - ih.
          - ih.
        }

      (* EqTySubstProd *)
      - { simpl. ceapply EqTyTrans.
          - ceapply EqTySubstSimProd.
            + todo. (* type classes *)
            + now apply (trans_issubst sbs G D).
            + capply TyProd.
              now apply (trans_istype (ctxextend D A) B).
            + capply TyBool. ih.
          - capply CongSimProd.
            + todo. (* type classes *)
            + config apply @EqTySubstProd with (D := trans_ctx D).
              * ih.
              * now apply (trans_istype (ctxextend D A) B).
            + config apply @EqTySubstBool with (D := trans_ctx D). ih.
        }

      (* EqTySubstId *)
      - { simpl. config apply @EqTySubstId with (D := trans_ctx D).
          - ih.
          - ih.
          - ih.
        }

      (* EqTySubstEmpty *)
      - { simpl. config apply @EqTySubstEmpty with (D := trans_ctx D). ih. }

      (* EqTySubstUnit *)
      - { simpl. config apply @EqTySubstUnit with (D := trans_ctx D). ih. }

      (* EqTySubstBool *)
      - { simpl. config apply @EqTySubstBool with (D := trans_ctx D). ih. }

      (* EqTyExfalso *)
      - { config apply @EqTyExfalso with (u := trans_term u).
          - ih.
          - ih.
          - now apply (trans_isterm G u Empty).
        }

      (* CongProd *)
      - { simpl. capply CongSimProd.
          - todo. (* type classes *)
          - capply CongProd.
            + ih.
            + now apply (trans_eqtype (ctxextend G A1) A2 B2).
          - capply EqTyRefl. capply TyBool. ih.
        }

      (* CongId *)
      - { simpl. capply CongId ; ih. }

      (* CongTySubst *)
      - { simpl. config apply @CongTySubst with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* CongSimProd *)
      - { simpl. capply CongSimProd.
          - todo. (* type classes *)
          - ih.
          - ih.
        }

      (* EqTySubstSimProd *)
      - { simpl. config apply @EqTySubstSimProd with (D := trans_ctx D).
          - todo. (* types classes *)
          - ih.
          - ih.
          - ih.
        }
    }

  (* trans_eqterm *)
  - { destruct H ; doConfig.

      (* EqTyConv *)
      - { config apply @EqTyConv with (A := trans_type A).
          - ih.
          - ih.
        }

      (* EqCtxConv *)
      - { config apply @EqCtxConv with (G := trans_ctx G).
          - ih.
          - ih.
        }

      (* EqRefl *)
      - { capply EqRefl. ih. }

      (* EqSym *)
      - { capply EqSym. ih. }

      (* EqTrans *)
      - { config apply @EqTrans with (v := trans_term v).
          - ih.
          - ih.
        }

      (* EqIdSubst *)
      - { simpl. capply EqIdSubst. ih. }

      (* EqSubstComp *)
      - { simpl. config apply @EqSubstComp with (D := trans_ctx D) (E := trans_ctx E).
          - ih.
          - ih.
          - ih.
        }

      (* EqSubstWeak *)
      - { simpl. capply EqSubstWeak.
          - now apply (trans_isterm G (var k) A).
          - ih.
        }

      (* EqSubstZeroZero *)
      - { simpl. capply EqSubstZeroZero. ih. }

      (* EqSubstZeroSucc *)
      - { simpl. capply EqSubstZeroSucc.
          - now apply (trans_isterm G (var k) A).
          - ih.
        }

      (* EqSubstShiftZero *)
      - { simpl. config apply @EqSubstShiftZero with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* EqSubstShiftSucc *)
      - { simpl. config apply @EqSubstShiftSucc with (D := trans_ctx D).
          - ih.
          - now apply (trans_isterm D (var k) B).
          - ih.
        }

      (* EqSubstAbs *)
      - { simpl. ceapply EqTrans.
          - ceapply EqTyConv.
            + ceapply EqSubstPair.
              * todo. (* type classes *)
              * now apply (trans_issubst sbs G D).
              * capply TermAbs.
                now apply (trans_isterm (ctxextend D A) u B).
              * capply TermTrue. ih.
            + capply CongSimProd.
              * todo. (* type classes *)
              * config apply @EqTySubstProd with (D := trans_ctx D).
                -- ih.
                -- now apply (trans_istype (ctxextend D A) B).
              * config apply @EqTySubstBool with (D := trans_ctx D). ih.
          - ceapply EqTyConv.
            + capply CongPair.
              * todo. (* type classes *)
              * ceapply EqTyConv.
                -- config apply @EqSubstAbs with (D := trans_ctx D).
                   ++ now apply (trans_isterm (ctxextend D A) u B).
                   ++ ih.
                -- capply EqTySym.
                   config apply @EqTySubstProd with (D := trans_ctx D).
                   ++ ih.
                   ++ now apply (trans_istype (ctxextend D A) B).
              * ceapply EqTyConv.
                -- config apply @EqSubstTrue with (D := trans_ctx D).
                   ih.
                -- capply EqTySym.
                   config apply @EqTySubstBool with (D := trans_ctx D).
                   ih.
              * config apply @EqTySubstProd with (D := trans_ctx D).
                -- ih.
                -- now apply (trans_istype (ctxextend D A) B).
              * config apply @EqTySubstBool with (D := trans_ctx D). ih.
            + capply CongSimProd.
              * todo. (* type classes *)
              * config apply @EqTySubstProd with (D := trans_ctx D).
                -- ih.
                -- now apply (trans_istype (ctxextend D A) B).
              * config apply @EqTySubstBool with (D := trans_ctx D). ih.
        }

      (* EqSubstApp *)
      - { simpl. ceapply EqTrans.
          - config apply @EqSubstApp with (D := trans_ctx D).
            + capply TermProj1.
              * todo. (* type classes *)
              * now apply (trans_isterm D u (Prod A B)).
            + ih.
            + ih.
          - ceapply EqTyConv.
            + capply CongApp.
              * capply EqTyRefl.
                config apply @TySubst with (D := trans_ctx D).
                -- ih.
                -- ih.
              * capply EqTyRefl.
                config apply @TySubst with (D := trans_ctx (ctxextend D A)).
                -- simpl. capply SubstShift.
                   ++ ih.
                   ++ ih.
                -- ih.
              * ceapply EqTrans.
                -- ceapply EqTyConv.
                   ++ config apply @EqSubstProj1 with (D := trans_ctx D).
                      ** todo. (* type classes *)
                      ** ih.
                      ** now apply (trans_isterm D u (Prod A B)).
                   ++ config apply @EqTySubstProd with (D := trans_ctx D).
                      ** ih.
                      ** now apply (trans_istype (ctxextend D A) B).
                -- ceapply EqTyConv.
                   ++ capply CongProj1.
                      ** todo. (* type classes *)
                      ** capply EqRefl.
                         ceapply TermTyConv.
                         --- config apply @TermSubst with (D := trans_ctx D).
                             +++ ih.
                             +++ now apply (trans_isterm D u (Prod A B)).
                         --- simpl.
                             config apply @EqTySubstSimProd with (D := trans_ctx D).
                             +++ todo. (* type classes *)
                             +++ ih.
                             +++ capply TyProd.
                                 now apply (trans_istype (ctxextend D A) B).
                             +++ capply TyBool. ih.
                      ** config apply @EqTySubstProd with (D := trans_ctx D).
                         --- ih.
                         --- now apply (trans_istype (ctxextend D A) B).
                      ** config apply @EqTySubstBool with (D := trans_ctx D).
                         ih.
                   ++ config apply @EqTySubstProd with (D := trans_ctx D).
                      ** ih.
                      ** now apply (trans_istype (ctxextend D A) B).
              * capply EqRefl.
                config apply @TermSubst with (D := trans_ctx D).
                -- ih.
                -- ih.
            + ceapply EqTyTrans.
              * ceapply EqTySubstComp.
                -- now apply (trans_istype (ctxextend D A) B).
                -- capply SubstZero.
                   config apply @TermSubst with (D := trans_ctx D).
                   ++ ih.
                   ++ ih.
                -- simpl. capply SubstShift.
                   ++ ih.
                   ++ ih.
              * capply EqTySym.
                ceapply EqTyTrans.
                -- ceapply EqTySubstComp.
                   ++ now apply (trans_istype (ctxextend D A) B).
                   ++ now apply (trans_issubst sbs G D).
                   ++ capply SubstZero. ih.
                -- config apply @CongTySubst with (D := trans_ctx (ctxextend D A)).
                   ++ capply SubstSym.
                      simpl. ceapply ShiftZero.
                      ** ih.
                      ** ih.
                   ++ capply EqTyRefl. ih.
        }

      (* EqSubstRefl *)
      - { simpl. config apply @EqSubstRefl with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* EqSubstJ *)
      - { simpl. config apply @EqSubstJ with (D := trans_ctx D).
          - ih.
          - ih.
          - now apply (trans_istype _ C i4).
          - now apply (trans_isterm _ _ _ i5).
          - ih.
          - now apply (trans_isterm _ _ _ i7).
        }

      (* EqSubstExfalso *)
      - { simpl. config apply @EqSubstExfalso with (D := trans_ctx D).
          - ih.
          - now apply (trans_isterm D u Empty).
          - ih.
        }

      (* EqSubstUnit *)
      - { simpl. config apply @EqSubstUnit with (D := trans_ctx D). ih. }

      (* EqSubstTrue *)
      - { simpl. config apply @EqSubstTrue with (D := trans_ctx D). ih. }

      (* EqSubstFalse *)
      - { simpl. config apply @EqSubstFalse with (D := trans_ctx D). ih. }

      (* EqSubstCond *)
      - { simpl. config apply @EqSubstCond with (D := trans_ctx D).
          - ih.
          - now apply (trans_isterm D u Bool).
          - now apply (trans_istype (ctxextend D Bool) C).
          - now apply (trans_isterm D v _ i4).
          - now apply (trans_isterm D w _ i5).
        }

      (* EqTermExfalso *)
      - { config apply @EqTermExfalso with (w := trans_term w).
          - ih.
          - ih.
          - now apply (trans_isterm G w Empty).
        }

      (* UnitEta *)
      - { simpl. capply UnitEta.
          - now apply (trans_isterm G u Unit).
          - now apply (trans_isterm G v Unit).
        }

      (* EqReflection *)
      - { config apply @EqReflection with (w1 := trans_term w1) (w2 := trans_term w2).
          - now apply (trans_isterm G w1 (Id A u v)).
          - (* now apply (trans_isterm G w2 (reflective A)). *)
            (* Problem: trans_type and reflective should commute *)
            todo.
        }

      (* ProdBeta *)
      - { simpl. ceapply EqTrans.
          - ceapply CongApp.
            + capply EqTyRefl. ih.
            + capply EqTyRefl.
              now apply (trans_istype (ctxextend G A) B).
            + capply Proj1Pair.
              * todo. (* type classes *)
              * capply TermAbs.
                now apply (trans_isterm (ctxextend G A) u B).
              * capply TermTrue. ih.
            + capply EqRefl. ih.
          - capply ProdBeta.
            + now apply (trans_isterm (ctxextend G A) u B).
            + ih.
        }

      (* CondTrue *)
      - { simpl. capply CondTrue.
          - now apply (trans_istype (ctxextend G Bool) C).
          - now apply (trans_isterm G v (Subst C (sbzero Bool true))).
          - now apply (trans_isterm G w (Subst C (sbzero Bool false))).
        }

      (* CondFalse *)
      - { simpl. capply CondFalse.
          - now apply (trans_istype (ctxextend G Bool) C).
          - now apply (trans_isterm G v (Subst C (sbzero Bool true))).
          - now apply (trans_isterm G w (Subst C (sbzero Bool false))).
        }

      (* ProdEta *)
      - { simpl. todo. (* We need PairEta as well *) }

      (* JRefl *)
      - { simpl. capply JRefl.
          - ih.
          - now apply (trans_istype _ _ i2).
          - now apply (trans_isterm _ _ _ i3).
        }

      (* CongAbs *)
      - { simpl. capply CongPair.
          - todo. (* type classes *)
          - capply CongAbs.
            + ih.
            + now apply (trans_eqtype _ _ _ e0).
            + now apply (trans_eqterm _ _ _ _ H).
          - capply EqRefl. capply TermTrue. ih.
          - capply CongProd.
            + ih.
            + now apply (trans_eqtype _ _ _ e0).
          - capply EqTyRefl. capply TyBool. ih.
        }

      (* CongApp *)
      - { simpl. capply CongApp.
          - ih.
          - now apply (trans_eqtype _ _ _ e0).
          - capply CongProj1.
            + todo. (* type classes *)
            + now apply (trans_eqterm _ _ _ _ H).
            + capply CongProd.
              * ih.
              * now apply (trans_eqtype _ _ _ e0).
            + capply EqTyRefl. capply TyBool. ih.
          - ih.
        }

      (* CongRefl *)
      - { simpl. capply CongRefl.
          - ih.
          - ih.
        }

      (* CongJ *)
      - { simpl. capply CongJ.
          - ih.
          - ih.
          - now apply (trans_eqtype _ _ _ e0).
          - now apply (trans_eqterm _ _ _ _ H0).
          - ih.
          - now apply (trans_eqterm _ _ _ _ H2).
        }

      (* CongCond *)
      - { simpl. capply CongCond.
          - now apply (trans_eqterm G u1 u2 Bool).
          - now apply (trans_eqtype (ctxextend G Bool) C1 C2).
          - now apply (trans_eqterm G v1 v2 _ H0).
          - now apply (trans_eqterm _ _ _ _ H1).
        }

      (* CongTermSubst *)
      - { simpl. config apply @CongTermSubst with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* CongPair *)
      - { simpl. capply CongPair.
          - todo. (* type classes *)
          - ih.
          - ih.
          - ih.
          - ih.
        }

      (* CongProj1 *)
      - { simpl. capply CongProj1.
          - todo. (* type classes *)
          - now apply (trans_eqterm G p1 p2 (SimProd A1 B1)).
          - ih.
          - ih.
        }

      (* CongProj2 *)
      - { simpl. capply CongProj2.
          - todo. (* type classes *)
          - now apply (trans_eqterm G p1 p2 (SimProd A1 B1)).
          - ih.
          - ih.
        }

      (* EqSubstPair *)
      - { simpl. config apply @EqSubstPair with (D := trans_ctx D).
          - todo. (* type classes *)
          - ih.
          - ih.
          - ih.
        }

      (* EqSubstProj1 *)
      - { simpl. config apply @EqSubstProj1 with (D := trans_ctx D).
          - todo. (* type classes *)
          - ih.
          - now apply (trans_isterm D p (SimProd A B)).
        }

      (* EqSubstProj2 *)
      - { simpl. config apply @EqSubstProj2 with (D := trans_ctx D).
          - todo. (* type classes *)
          - ih.
          - now apply (trans_isterm D p (SimProd A B)).
        }

      (* Proj1Pair *)
      - { simpl. capply Proj1Pair.
          - todo. (* type classes *)
          - ih.
          - ih.
        }

      (* Proj2Pair *)
      - { simpl. capply Proj2Pair.
          - todo. (* type classes *)
          - ih.
          - ih.
        }
    }

  (* trans_eqsubst *)
  - { destruct H ; doConfig.

      (* SubstRefl *)
      - { capply SubstRefl. ih. }

      (* SubstSym *)
      - { capply SubstSym. ih. }

      (* SubstTrans *)
      - { config apply @SubstTrans with (sb2 := trans_subst sb2).
          - ih.
          - ih.
        }

      (* CongSusbtZero *)
      - { simpl. capply CongSubstZero.
          - ih.
          - ih.
        }

      (* CongSubstWeak *)
      - { simpl. capply CongSubstWeak. ih. }

      (* CongSubstShift *)
      - { simpl. capply CongSubstShift ; ih. }

      (* CongSubstComp *)
      - { simpl. config apply @CongSubstComp with (D := trans_ctx D).
          - ih.
          - ih.
        }

      (* EqSubstCtxConv *)
      - { config apply @EqSubstCtxConv with (G1 := trans_ctx G1) (D1 := trans_ctx D1).
          - ih.
          - ih.
          - ih.
        }

      (* CompAssoc *)
      - { simpl. config apply @CompAssoc with (D := trans_ctx D) (E := trans_ctx E).
          - ih.
          - ih.
          - ih.
        }

      (* WeakNat *)
      - { simpl. capply WeakNat ; ih. }

      (* WeakZero *)
      - { simpl. capply WeakZero ; ih. }

      (* ShiftZero *)
      - { simpl. capply ShiftZero ; ih. }

      (* CompShift *)
      - { simpl. config apply @CompShift with (D := trans_ctx D).
          - ih.
          - ih.
          - ih.
        }

      (* CompIdRight *)
      - { simpl. capply CompIdRight. ih. }

      (* CompIdLeft *)
      - { simpl. capply CompIdLeft. ih. }
    }
Qed.

(* Stt is consistent if Ttt is. *)
Theorem relative_consistency :
  forall bot,
    Stt.isterm ctxempty bot Empty ->
    Ttt.isterm ctxempty (trans_term bot) Empty.
Proof.
  intros bot h.
  now apply (trans_isterm h).
Qed.

(* In Stt, we have the negation of funext *)
(* Do we need universe to say so? I'm afraid so. *)
(* Let's have a "meta-version". *)
(* Definition funext A B := *)
(*   let w1 := sbweak (Arrow A B) in *)
(*   let w2' := sbweak (Subst (Arrow A B) w1) in *)
(*   let w3' := sbweak (Subst A w2') in *)

(*   let w2 := sbcomp w1 w2' in *)
(*   let w3 := sbcomp w2 w3' in *)
(*   Prod (Arrow A B) (* f : A → B *) *)
(*        (Prod (Subst (Arrow A B) w1) (* g : A → B *) *)
(*              (Arrow (Prod (Subst A w2) (Id B )))) *)

End Translation.