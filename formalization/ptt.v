(* Paranoid type theory. *)

Require Import syntax.

Inductive isctx : context -> Type :=

     | CtxEmpty :
         isctx ctxempty

     | CtxExtend :
         forall {G A},
           isctx G ->
           istype G A ->
           isctx (ctxextend G A)



with issubst : substitution -> context -> context -> Type :=

     | SubstZero :
         forall {G u A},
           isctx G ->
           istype G A ->
           isterm G u A ->
           issubst (sbzero G A u) G (ctxextend G A)

     | SubstWeak :
         forall {G A},
           isctx G ->
           istype G A ->
           issubst (sbweak G A) (ctxextend G A) G

     | SubstShift :
         forall {G D A sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           istype D A ->
           issubst (sbshift G A sbs)
                   (ctxextend G (Subst A sbs))
                   (ctxextend D A)

     | SubstId :
         forall {G},
           isctx G ->
           issubst (sbid G) G G

     | SubstComp :
         forall {G D E sbs sbt},
           isctx G ->
           isctx D ->
           isctx E ->
           issubst sbs G D ->
           issubst sbt D E ->
           issubst (sbcomp sbt sbs) G E

     | SubstCtxConv :
         forall {G1 G2 D1 D2 sbs},
           isctx G1 ->
           isctx G2 ->
           isctx D1 ->
           isctx D2 ->
           issubst sbs G1 D1 ->
           eqctx G1 G2 ->
           eqctx D1 D2 ->
           issubst sbs G2 D2


with istype : context -> type -> Type :=

     | TyCtxConv :
         forall {G D A},
           isctx G ->
           isctx D ->
           istype G A ->
           eqctx G D ->
           istype D A

     | TySubst :
         forall {G D A sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           istype D A ->
           istype G (Subst A sbs)

     | TyProd :
         forall {G A B},
           isctx G ->
           istype G A ->
           istype (ctxextend G A) B ->
           istype G (Prod A B)

     | TyId :
         forall {G A u v},
           isctx G ->
           istype G A ->
           isterm G u A ->
           isterm G v A ->
           istype G (Id A u v)

     | TyEmpty :
         forall {G},
           isctx G ->
           istype G Empty

     | TyUnit :
         forall {G},
           isctx G ->
           istype G Unit

     | TyBool :
         forall {G},
           isctx G ->
           istype G Bool



with isterm : context -> term -> type -> Type :=

     | TermTyConv :
         forall {G A B u},
           isctx G ->
           istype G A ->
           istype G B ->
           isterm G u A ->
           eqtype G A B ->
           isterm G u B

     | TermCtxConv :
         forall {G D A u},
           isctx G ->
           isctx D ->
           istype G A ->
           isterm G u A ->
           eqctx G D ->
           isterm D u A

     | TermSubst :
         forall {G D A u sbs},
           isctx G ->
           isctx D ->
           istype D A ->
           issubst sbs G D ->
           isterm D u A ->
           isterm G (subst u sbs) (Subst A sbs)

     | TermVarZero :
         forall {G A},
           isctx G ->
           istype G A ->
           isterm (ctxextend G A) (var 0) (Subst A (sbweak G A))

     | TermVarSucc :
         forall {G A B k},
           isctx G ->
           istype G A ->
           isterm G (var k) A ->
           istype G B ->
           isterm (ctxextend G B) (var (S k)) (Subst A (sbweak G B))

     | TermAbs :
         forall {G A u B},
           isctx G ->
           istype G A ->
           istype (ctxextend G A) B ->
           isterm (ctxextend G A) u B ->
           isterm G (lam A B u) (Prod A B)

     | TermApp :
         forall {G A B u v},
           isctx G ->
           istype G A ->
           istype (ctxextend G A) B ->
           isterm G u (Prod A B) ->
           isterm G v A ->
           isterm G (app u A B v) (Subst B (sbzero G A v))

     | TermRefl :
         forall {G A u},
           isctx G ->
           istype G A ->
           isterm G u A ->
           isterm G (refl A u) (Id A u u)

     | TermJ :
         forall {G A C u v w p},
           isctx G ->
           istype G A ->
           isterm G u A ->
           istype
             (ctxextend
                (ctxextend G A)
                (Id
                   (Subst A (sbweak G A))
                   (subst u (sbweak G A))
                   (var 0)
                )
             )
             C ->
           isterm G
                  w
                  (Subst
                     (Subst
                        C
                        (sbshift
                           G
                           (Id
                              (Subst A (sbweak G A))
                              (subst u (sbweak G A))
                              (var 0)
                           )
                           (sbzero G A u)
                        )
                     )
                     (sbzero G (Id A u u) (refl A u))
                  ) ->
           isterm G v A ->
           isterm G p (Id A u v) ->
           isterm G
                  (j A u C w v p)
                  (Subst
                     (Subst
                        C
                        (sbshift
                           G
                           (Id
                              (Subst A (sbweak G A))
                              (subst u (sbweak G A))
                              (var 0)
                           )
                           (sbzero G A v)
                        )
                     )
                     (sbzero G (Id A u v) p)
                  )

     | TermExfalso :
         forall {G A u},
           isctx G ->
           istype G A ->
           isterm G u Empty ->
           isterm G (exfalso A u) A

     | TermUnit :
         forall {G},
           isctx G ->
           isterm G unit Unit

     | TermTrue :
         forall {G},
           isctx G ->
           isterm G true Bool

     | TermFalse :
         forall {G},
           isctx G ->
           isterm G false Bool

     | TermCond :
         forall {G C u v w},
           isctx G ->
           isterm G u Bool ->
           istype (ctxextend G Bool) C ->
           isterm G v (Subst C (sbzero G Bool true)) ->
           isterm G w (Subst C (sbzero G Bool false)) ->
           isterm G
                  (cond C u v w)
                  (Subst C (sbzero G Bool u))



with eqctx : context -> context -> Type :=


     | CtxRefl :
         forall {G},
           isctx G ->
           eqctx G G

     | CtxSym :
         forall {G D},
           isctx G ->
           isctx D ->
           eqctx G D ->
           eqctx D G

     | CtxTrans :
         forall {G D E},
           isctx G ->
           isctx D ->
           isctx E ->
           eqctx G D ->
           eqctx D E ->
           eqctx G E

     | EqCtxEmpty :
         eqctx ctxempty ctxempty

     | EqCtxExtend :
         forall {G A B},
           isctx G ->
           istype G A ->
           istype G B ->
           eqtype G A B ->
           eqctx (ctxextend G A) (ctxextend G B)


with eqsubst : substitution -> substitution -> context -> context -> Type :=

     | SubstRefl :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqsubst sbs sbs G D

     | SubstSym :
         forall {G D sbs sbt},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           issubst sbt G D ->
           eqsubst sbs sbt G D ->
           eqsubst sbt sbs G D

     | SubstTrans :
         forall {G D sb1 sb2 sb3},
           isctx G ->
           isctx D ->
           issubst sb1 G D ->
           issubst sb2 G D ->
           issubst sb3 G D ->
           eqsubst sb1 sb2 G D ->
           eqsubst sb2 sb3 G D ->
           eqsubst sb1 sb3 G D

     | CongSubstZero :
         forall {G1 G2 A1 A2 u1 u2},
           isctx G1 ->
           isctx G2 ->
           istype G1 A1 ->
           istype G1 A2 ->
           isterm G1 u1 A1 ->
           isterm G1 u2 A1 ->
           eqctx G1 G2 ->
           eqtype G1 A1 A2 ->
           eqterm G1 u1 u2 A1 ->
           eqsubst (sbzero G1 A1 u1)
                   (sbzero G1 A2 u2)
                   G1
                   (ctxextend G1 A1)

     | CongSubstWeak :
         forall {G1 G2 A1 A2},
           isctx G1 ->
           isctx G2 ->
           istype G1 A1 ->
           istype G1 A2 ->
           eqctx G1 G2 ->
           eqtype G1 A1 A2 ->
           eqsubst (sbweak G1 A1)
                   (sbweak G2 A2)
                   (ctxextend G1 A1)
                   G1

     | CongSubstShift :
         forall {G1 G2 D A1 A2 sbs1 sbs2},
           isctx G1 ->
           isctx G2 ->
           isctx D ->
           istype G1 A1 ->
           istype G1 A2 ->
           issubst sbs1 G1 D ->
           issubst sbs2 G1 D ->
           eqctx G1 G2 ->
           eqsubst sbs1 sbs2 G1 D ->
           eqtype D A1 A2 ->
           eqsubst (sbshift G1 A1 sbs1)
                   (sbshift G2 A2 sbs2)
                   (ctxextend G1 (Subst A1 sbs1))
                   (ctxextend D A1)

     | CongSubstComp :
         forall {G D E sbs1 sbs2 sbt1 sbt2},
           isctx G ->
           isctx D ->
           isctx E ->
           issubst sbs1 G D ->
           issubst sbs2 G D ->
           issubst sbt1 D E ->
           issubst sbt2 D E ->
           eqsubst sbs1 sbs2 G D ->
           eqsubst sbt1 sbt2 D E ->
           eqsubst (sbcomp sbt1 sbs1)
                   (sbcomp sbt2 sbs2)
                   G
                   E

     | EqSubstCtxConv :
         forall {G1 G2 D1 D2 sbs sbt},
           isctx G1 ->
           isctx G2 ->
           isctx D1 ->
           isctx D2 ->
           issubst sbs G1 D1 ->
           issubst sbt G1 D1 ->
           eqsubst sbs sbt G1 D1 ->
           eqctx G1 G2 ->
           eqctx D1 D2 ->
           eqsubst sbs sbt G2 D2

     | CompAssoc :
         forall {G D E F sbs sbt sbr},
           isctx G ->
           isctx D ->
           isctx E ->
           isctx F ->
           issubst sbs G D ->
           issubst sbt D E ->
           issubst sbr E F ->
           eqsubst (sbcomp (sbcomp sbr sbt) sbs)
                   (sbcomp sbr (sbcomp sbt sbs))
                   G
                   F

     | WeakNat :
         forall {G D A sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           istype D A ->
           eqsubst (sbcomp (sbweak D A)
                           (sbshift G A sbs))
                   (sbcomp sbs
                           (sbweak G (Subst A sbs)))
                   (ctxextend G (Subst A sbs))
                   D

     | WeakZero :
         forall {G A u},
           isctx G ->
           istype G A ->
           isterm G u A ->
           eqsubst (sbcomp (sbweak G A) (sbzero G A u))
                   (sbid G)
                   G
                   G

     | ShiftZero :
         forall {G D A u sbs},
           isctx G ->
           isctx D ->
           istype D A ->
           issubst sbs G D ->
           isterm D u A ->
           eqsubst (sbcomp (sbshift G A sbs)
                           (sbzero G (Subst A sbs) (subst u sbs)))
                   (sbcomp (sbzero D A u)
                           sbs)
                   G
                   (ctxextend D A)

     | CompShift :
         forall {G D E A sbs sbt},
           isctx G ->
           isctx D ->
           isctx E ->
           issubst sbs G D ->
           issubst sbt D E ->
           istype E A ->
           eqsubst (sbcomp (sbshift D A sbt)
                           (sbshift G (Subst A sbt) sbs))
                   (sbshift G A (sbcomp sbt sbs))
                   (ctxextend G (Subst A (sbcomp sbt sbs)))
                   (ctxextend E A)

     | CompIdRight :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqsubst (sbcomp (sbid D) sbs) sbs G D

     | CompIdLeft :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqsubst (sbcomp sbs (sbid G)) sbs G D


with eqtype : context -> type -> type -> Type :=

     | EqTyCtxConv :
         forall {G D A B},
           isctx G ->
           isctx D ->
           istype G A ->
           istype G B ->
           eqtype G A B ->
           eqctx G D ->
           eqtype D A B

     | EqTyRefl:
         forall {G A},
           isctx G ->
           istype G A ->
           eqtype G A A

     | EqTySym :
         forall {G A B},
           isctx G ->
           istype G A ->
           istype G B ->
           eqtype G A B ->
           eqtype G B A

     | EqTyTrans :
         forall {G A B C},
           isctx G ->
           istype G A ->
           istype G B ->
           istype G C ->
           eqtype G A B ->
           eqtype G B C ->
           eqtype G A C

     | EqTyIdSubst :
         forall {G A},
           isctx G ->
           istype G A ->
           eqtype G
                  (Subst A (sbid G))
                  A

     | EqTySubstComp :
         forall {G D E A sbs sbt},
           isctx G ->
           isctx D ->
           isctx E ->
           istype E A ->
           issubst sbs G D ->
           issubst sbt D E ->
           eqtype G
                  (Subst (Subst A sbt) sbs)
                  (Subst A (sbcomp sbt sbs))


     | EqTySubstProd :
         forall {G D A B sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           istype D A ->
           istype (ctxextend D A) B ->
           eqtype G
                  (Subst (Prod A B) sbs)
                  (Prod (Subst A sbs) (Subst B (sbshift G A sbs)))

     | EqTySubstId :
         forall {G D A u v sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           istype D A ->
           isterm D u A ->
           isterm D v A ->
           eqtype G
                  (Subst (Id A u v) sbs)
                  (Id (Subst A sbs) (subst u sbs) (subst v sbs))

     | EqTySubstEmpty :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqtype G
                  (Subst Empty sbs)
                  Empty

     | EqTySubstUnit :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqtype G
                  (Subst Unit sbs)
                  Unit

     | EqTySubstBool :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqtype G
                  (Subst Bool sbs)
                  Bool

     | EqTyExfalso :
         forall {G A B u},
           isctx G ->
           istype G A ->
           istype G B ->
           isterm G u Empty ->
           eqtype G A B

     | CongProd :
         forall {G A1 A2 B1 B2},
           isctx G ->
           istype G A1 ->
           istype (ctxextend G A1) A2 ->
           istype G B1 ->
           istype (ctxextend G A1) B2 ->
           eqtype G A1 B1 ->
           eqtype (ctxextend G A1) A2 B2 ->
           eqtype G (Prod A1 A2) (Prod B1 B2)

     | CongId :
         forall {G A B u1 u2 v1 v2},
           isctx G ->
           istype G A ->
           istype G B ->
           isterm G u1 A ->
           isterm G u2 A ->
           isterm G v1 A ->
           isterm G v2 A ->
           eqtype G A B ->
           eqterm G u1 v1 A ->
           eqterm G u2 v2 A ->
           eqtype G (Id A u1 u2) (Id B v1 v2)

     | CongTySubst :
         forall {G D A B sbs sbt},
           isctx G ->
           isctx D ->
           istype D A ->
           istype D B ->
           issubst sbs G D ->
           issubst sbt G D ->
           eqtype D A B ->
           eqtype G (Subst A sbs) (Subst B sbt)


with eqterm : context -> term -> term -> type -> Type :=

     | EqTyConv :
         forall {G A B u v},
           isctx G ->
           istype G A ->
           istype G B ->
           isterm G u A ->
           isterm G v A ->
           eqterm G u v A ->
           eqtype G A B ->
           eqterm G u v B

     | EqCtxConv :
         forall {G D u v A},
           isctx G ->
           isctx D ->
           istype G A ->
           isterm G u A ->
           isterm G v A ->
           eqterm G u v A ->
           eqctx G D ->
           eqterm D u v A

     | EqRefl :
         forall {G A u},
           isctx G ->
           istype G A ->
           isterm G u A ->
           eqterm G u u A

     | EqSym :
         forall {G A u v},
           isctx G ->
           istype G A ->
           isterm G u A ->
           isterm G v A ->
           eqterm G v u A ->
           eqterm G u v A

     | EqTrans :
         forall {G A u v w},
           isctx G ->
           istype G A ->
           isterm G u A ->
           isterm G v A ->
           isterm G w A ->
           eqterm G u v A ->
           eqterm G v w A ->
           eqterm G u w A


     | EqIdSubst :
         forall {G A u},
           isctx G ->
           istype G A ->
           isterm G u A ->
           eqterm G
                  (subst u (sbid G))
                  u
                  A

     | EqSubstComp :
         forall {G D E A u sbs sbt},
           isctx G ->
           isctx D ->
           isctx E ->
           istype E A ->
           isterm E u A ->
           issubst sbs G D ->
           issubst sbt D E ->
           eqterm G
                  (subst (subst u sbt) sbs)
                  (subst u (sbcomp sbt sbs))
                  (Subst A (sbcomp sbt sbs))

     | EqSubstWeak :
         forall {G A B k},
           isctx G ->
           istype G A ->
           isterm G (var k) A ->
           istype G B ->
           eqterm (ctxextend G B)
                  (subst (var k) (sbweak G B))
                  (var (S k))
                  (Subst A (sbweak G B))


     | EqSubstZeroZero :
         forall {G u A},
           isctx G ->
           istype G A ->
           isterm G u A ->
           eqterm G
                  (subst (var 0) (sbzero G A u))
                  u
                  A

     | EqSubstZeroSucc :
         forall {G A B u k},
           isctx G ->
           istype G A ->
           istype G B ->
           isterm G (var k) A ->
           isterm G u B ->
           eqterm G
                  (subst (var (S k)) (sbzero G B u))
                  (var k)
                  A

     | EqSubstShiftZero :
         forall {G D A sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           istype D A ->
           eqterm (ctxextend G (Subst A sbs))
                  (subst (var 0) (sbshift G A sbs))
                  (var 0)
                  (Subst (Subst A sbs) (sbweak G (Subst A sbs)))

     | EqSubstShiftSucc :
         forall { G D A B sbs k },
           isctx G ->
           isctx D ->
           istype D B ->
           issubst sbs G D ->
           isterm D (var k) B ->
           istype D A ->
           eqterm (ctxextend G (Subst A sbs))
                  (subst (var (S k)) (sbshift G A sbs))
                  (subst (subst (var k) sbs) (sbweak G (Subst A sbs)))
                  (Subst (Subst B sbs) (sbweak G (Subst A sbs)))

     | EqSubstAbs :
         forall {G D A B u sbs},
           isctx G ->
           isctx D ->
           istype D A ->
           istype (ctxextend D A) B ->
           isterm (ctxextend D A) u B ->
           issubst sbs G D ->
           eqterm G
                  (subst (lam A B u) sbs)
                  (lam
                     (Subst A sbs)
                     (Subst B (sbshift G A sbs))
                     (subst u (sbshift G A sbs)))
                  (Prod
                     (Subst A sbs)
                     (Subst B (sbshift G A sbs)))

     | EqSubstApp :
         forall {G D A B u v sbs},
           isctx G ->
           isctx D ->
           istype D A ->
           istype (ctxextend D A) B ->
           isterm D u (Prod A B) ->
           isterm D v A ->
           issubst sbs G D ->
           eqterm G
                  (subst (app u A B v) sbs)
                  (app
                     (subst u sbs)
                     (Subst A sbs)
                     (Subst B (sbshift G A sbs))
                     (subst v sbs))
                  (Subst (Subst B (sbzero D A v)) sbs)

     | EqSubstRefl :
         forall {G D A u sbs},
           isctx G ->
           isctx D ->
           istype D A ->
           isterm D u A ->
           issubst sbs G D ->
           eqterm G
                  (subst (refl A u) sbs)
                  (refl (Subst A sbs) (subst u sbs))
                  (Id (Subst A sbs) (subst u sbs) (subst u sbs))

     | EqSubstJ :
         forall {G D A C u v w p sbs},
           isctx G ->
           isctx D ->
           istype D A ->
           issubst sbs G D ->
           isterm D u A ->
           istype
             (ctxextend
                (ctxextend D A)
                (Id
                   (Subst A (sbweak D A))
                   (subst u (sbweak D A))
                   (var 0)
                )
             )
             C ->
           isterm D
                  w
                  (Subst
                     (Subst
                        C
                        (sbshift
                           D
                           (Id
                              (Subst A (sbweak D A))
                              (subst u (sbweak D A))
                              (var 0)
                           )
                           (sbzero D A u)
                        )
                     )
                     (sbzero D (Id A u u) (refl A u))
                  ) ->
           isterm D v A ->
           isterm D p (Id A u v) ->
           eqterm G
                  (subst
                     (j A u C w v p)
                     sbs
                  )
                  (j (Subst A sbs)
                     (subst u sbs)
                     (Subst C
                            (sbshift
                               (ctxextend G
                                          (Subst A sbs))
                               (Id
                                  (Subst A (sbweak D A))
                                  (subst u (sbweak D A))
                                  (var 0)
                               )
                               (sbshift G A sbs)
                            )
                     )
                     (subst w sbs)
                     (subst v sbs)
                     (subst p sbs)
                  )
                  (Subst
                     (Subst
                        (Subst
                           C
                           (sbshift
                              D
                              (Id
                                 (Subst A (sbweak D A))
                                 (subst u (sbweak D A))
                                 (var 0)
                              )
                              (sbzero D A v)
                           )
                        )
                        (sbzero G (Id A u v) p)
                     )
                     sbs
                  )

     (* This rule is subsumed by EqTermExfalso *)
     | EqSubstExfalso :
         forall {G D A u sbs},
           isctx G ->
           isctx D ->
           istype D A ->
           isterm D u Empty ->
           issubst sbs G D ->
           eqterm G
                  (subst (exfalso A u) sbs)
                  (exfalso (Subst A sbs) (subst u sbs))
                  (Subst A sbs)

     | EqSubstUnit :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqterm G
                  (subst unit sbs)
                  unit
                  Unit

     | EqSubstTrue :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqterm G
                  (subst true sbs)
                  true
                  Bool

     | EqSubstFalse :
         forall {G D sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           eqterm G
                  (subst false sbs)
                  false
                  Bool

     | EqSubstCond :
         forall {G D C u v w sbs},
           isctx G ->
           isctx D ->
           issubst sbs G D ->
           isterm D u Bool ->
           istype (ctxextend D Bool) C ->
           isterm D v (Subst C (sbzero D Bool true)) ->
           isterm D w (Subst C (sbzero D Bool false)) ->
           eqterm G
                  (subst (cond C u v w) sbs)
                  (cond (Subst C (sbshift G Bool sbs))
                        (subst u sbs)
                        (subst v sbs)
                        (subst w sbs))
                  (Subst (Subst C (sbzero D Bool u)) sbs)

     | EqTermExfalso :
         forall {G A u v w},
           isctx G ->
           istype G A ->
           isterm G u A ->
           isterm G v A ->
           isterm G w Empty ->
           eqterm G u v A

     | UnitEta :
         forall {G u v},
           isctx G ->
           isterm G u Unit ->
           isterm G v Unit ->
           eqterm G u v Unit

     | EqReflection :
         forall {G A u v w1 w2},
           isctx G ->
           istype G A ->
           isterm G u A ->
           isterm G v A ->
           isterm G w1 (Id A u v) ->
           isterm G w2 (reflective A) ->
           eqterm G u v A

     | ProdBeta :
         forall {G A B u v},
           isctx G ->
           istype G A ->
           istype (ctxextend G A) B ->
           isterm (ctxextend G A) u B ->
           isterm G v A ->
           eqterm G
                  (app (lam A B u) A B v)
                  (subst u (sbzero G A v))
                  (Subst B (sbzero G A v))

     | CondTrue :
         forall {G C v w},
           isctx G ->
           istype (ctxextend G Bool) C ->
           isterm G v (Subst C (sbzero G Bool true)) ->
           isterm G w (Subst C (sbzero G Bool false)) ->
           eqterm G
                  (cond C true v w)
                  v
                  (Subst C (sbzero G Bool true))

     | CondFalse :
         forall {G C v w},
           isctx G ->
           istype (ctxextend G Bool) C ->
           isterm G v (Subst C (sbzero G Bool true)) ->
           isterm G w (Subst C (sbzero G Bool false)) ->
           eqterm G
                  (cond C false v w)
                  w
                  (Subst C (sbzero G Bool false))

     | ProdEta :
         forall {G A B u v},
           isctx G ->
           istype G A ->
           istype (ctxextend G A) B ->
           isterm G u (Prod A B) ->
           isterm G v (Prod A B) ->
           eqterm (ctxextend G A)
                  (app (subst u (sbweak G A))
                       (Subst A (sbweak G A))
                       (Subst B (sbshift (ctxextend G A) A (sbweak G A)))
                       (var 0))
                  (app (subst v (sbweak G A))
                       (Subst A (sbweak G A))
                       (Subst B (sbshift (ctxextend G A) A (sbweak G A)))
                       (var 0))
                  B ->
           eqterm G u v (Prod A B)

     | JRefl :
         forall {G A C u w},
           isctx G ->
           istype G A ->
           isterm G u A ->
           istype
             (ctxextend
                (ctxextend G A)
                (Id
                   (Subst A (sbweak G A))
                   (subst u (sbweak G A))
                   (var 0)
                )
             )
             C ->
           isterm G
                  w
                  (Subst
                     (Subst
                        C
                        (sbshift
                           G
                           (Id
                              (Subst A (sbweak G A))
                              (subst u (sbweak G A))
                              (var 0)
                           )
                           (sbzero G A u)
                        )
                     )
                     (sbzero G (Id A u u) (refl A u))
                  ) ->
           eqterm G
                  (j A u C w u (refl A u))
                  w
                  (Subst
                     (Subst
                        C
                        (sbshift
                           G
                           (Id
                              (Subst A (sbweak G A))
                              (subst u (sbweak G A))
                              (var 0)
                           )
                           (sbzero G A u)
                        )
                     )
                     (sbzero G (Id A u u) (refl A u))
                  )

     | CongAbs :
         forall {G A1 A2 B1 B2 u1 u2},
           isctx G ->
           istype G A1 ->
           istype G B1 ->
           istype (ctxextend G A1) A2 ->
           istype (ctxextend G A1) B2 ->
           isterm (ctxextend G A1) u1 A2 ->
           isterm (ctxextend G A1) u2 A2 ->
           eqtype G A1 B1 ->
           eqtype (ctxextend G A1) A2 B2 ->
           eqterm (ctxextend G A1) u1 u2 A2 ->
           eqterm G
                  (lam A1 A2 u1)
                  (lam B1 B2 u2)
                  (Prod A1 A2)

     | CongApp :
         forall {G A1 A2 B1 B2 u1 u2 v1 v2},
           isctx G ->
           istype G A1 ->
           istype G A2 ->
           istype (ctxextend G A1) A2 ->
           istype (ctxextend G A1) B2 ->
           isterm G u1 (Prod A1 A2) ->
           isterm G v1 (Prod A1 A2) ->
           isterm G u2 A1 ->
           isterm G v2 A1 ->
           eqtype G A1 B1 ->
           eqtype (ctxextend G A1) A2 B2 ->
           eqterm G u1 v1 (Prod A1 A2) ->
           eqterm G u2 v2 A1 ->
           eqterm G
                  (app u1 A1 A2 u2)
                  (app v1 B1 B2 v2)
                  (Subst A2 (sbzero G A1 u2))

     | CongRefl :
         forall {G u1 u2 A1 A2},
           isctx G ->
           istype G A1 ->
           istype G A2 ->
           isterm G u1 A1 ->
           isterm G u2 A1 ->
           eqterm G u1 u2 A1 ->
           eqtype G A1 A2 ->
           eqterm G
                  (refl A1 u1)
                  (refl A2 u2)
                  (Id A1 u1 u1)

     | CongJ :
         forall {G A1 A2 C1 C2 u1 u2 v1 v2 w1 w2 p1 p2},
           isctx G ->
           istype G A1 ->
           istype G A2 ->
           istype
             (ctxextend
                (ctxextend G A1)
                (Id
                   (Subst A1 (sbweak G A1))
                   (subst u1 (sbweak G A1))
                   (var 0)
                )
             )
             C1 ->
           istype
             (ctxextend
                (ctxextend G A1)
                (Id
                   (Subst A1 (sbweak G A1))
                   (subst u1 (sbweak G A1))
                   (var 0)
                )
             )
             C2 ->
           isterm G u1 A1 ->
           isterm G u2 A1 ->
           isterm G v1 A1 ->
           isterm G v2 A1 ->
           isterm G p1 (Id A1 u1 v1) ->
           isterm G p2 (Id A1 u1 v1) ->
           eqtype G A1 A2 ->
           eqterm G u1 u2 A1 ->
           eqtype
             (ctxextend
                (ctxextend G A1)
                (Id
                   (Subst A1 (sbweak G A1))
                   (subst u1 (sbweak G A1))
                   (var 0)
                )
             )
             C1
             C2 ->
           eqterm G
                  w1
                  w2
                  (Subst
                     (Subst
                        C1
                        (sbshift
                           G
                           (Id
                              (Subst A1 (sbweak G A1))
                              (subst u1 (sbweak G A1))
                              (var 0)
                           )
                           (sbzero G A1 u1)
                        )
                     )
                     (sbzero G (Id A1 u1 u1) (refl A1 u1))
                  ) ->
           eqterm G v1 v2 A1 ->
           eqterm G p1 p2 (Id A1 u1 v1) ->
           eqterm G
                  (j A1 u1 C1 w1 v1 p1)
                  (j A2 u2 C2 w2 v2 p2)
                  (Subst
                     (Subst
                        C1
                        (sbshift
                           G
                           (Id
                              (Subst A1 (sbweak G A1))
                              (subst u1 (sbweak G A1))
                              (var 0)
                           )
                           (sbzero G A1 v1)
                        )
                     )
                     (sbzero G (Id A1 u1 u1) p1)
                  )

     (* This rule doesn't seem necessary as subsumed by EqTermexfalso! *)
     (* | CongExfalso : *)
     (*     forall {G A B u v}, *)
     (*       eqtype G A B -> *)
     (*       eqterm G u v Empty -> *)
     (*       eqterm G *)
     (*              (exfalso A u) *)
     (*              (exfalso B v) *)
     (*              A *)

     | CongCond :
         forall {G C1 C2 u1 u2 v1 v2 w1 w2},
           isctx G ->
           istype (ctxextend G Bool) C1 ->
           istype (ctxextend G Bool) C2 ->
           isterm G u1 Bool ->
           isterm G u2 Bool ->
           isterm G v1 (Subst C1 (sbzero G Bool true)) ->
           isterm G v2 (Subst C1 (sbzero G Bool true)) ->
           isterm G w1 (Subst C1 (sbzero G Bool false)) ->
           isterm G w2 (Subst C1 (sbzero G Bool false)) ->
           eqterm G u1 u2 Bool ->
           eqtype (ctxextend G Bool) C1 C2 ->
           eqterm G v1 v2 (Subst C1 (sbzero G Bool true)) ->
           eqterm G w1 w2 (Subst C1 (sbzero G Bool false)) ->
           eqterm G
                  (cond C1 u1 v1 w1)
                  (cond C2 u2 v2 w2)
                  (Subst C1 (sbzero G Bool u1))

     | CongTermSubst :
         forall {G D A u1 u2 sbs},
           isctx G ->
           isctx D ->
           istype D A ->
           isterm D u1 A ->
           isterm D u2 A ->
           issubst sbs G D ->
           eqterm D u1 u2 A ->
           eqterm G
                  (subst u1 sbs)
                  (subst u2 sbs)
                  (Subst A sbs).

Definition sane_issubst sbs G D :
  issubst sbs G D -> isctx G * isctx D.
Proof.
  intro H ; destruct H.

  (* SubstZero *)
  { split.

    - assumption.
    - now apply CtxExtend.
  }

  (* SubstWeak *)
  { split.

    - now apply CtxExtend.
    - assumption.
  }

  (* SubstShift *)
  { split.

    - apply CtxExtend.
      + assumption.
      + now apply (@TySubst G D).
    - now apply CtxExtend.
  }

  (* SubstId *)
  { split.
    - assumption.
    - assumption.
  }

  (* SubstComp *)
  { split.
    - assumption.
    - assumption.
  }

  (* SubstCtxConv *)
  { split.
    - assumption.
    - assumption.
  }
Defined.

Definition sane_istype G A :
  istype G A -> isctx G.
Proof.
  intro H; destruct H ; assumption.
Defined.

Definition sane_isterm' G u A :
  isterm G u A -> istype G A.
Proof.
  intro H ; destruct H.

  (* TermTyConv *)
  { assumption. }

  (* TermCtxConv *)
  { now apply (@TyCtxConv G D). }

  (* TermSubst *)
  { now apply (@TySubst G D A sbs). }

  (* TermVarZero *)
  { eapply TySubst.
    - now apply (@CtxExtend G A).
    - eassumption.
    - now eapply SubstWeak.
    - assumption.
  }

  (* TermVarSucc *)
  { apply (@TySubst (ctxextend G B) G).
    - now apply CtxExtend.
    - assumption.
    - now apply SubstWeak.
    - assumption.
  }

  (* TermAbs *)
  { now apply (@TyProd). }

  (* TermApp *)
  { apply (@TySubst G (ctxextend G A)).
    - assumption.
    - now apply CtxExtend.
    - now apply SubstZero.
    - assumption.
  }

  (* TermRefl *)
  { now apply TyId. }

  (* TermJ *)
  { admit. }

  (* TermExfalso *)
  { assumption. }

  (* TermUnit *)
  { now apply TyUnit. }

  (* TermTrue *)
  { now apply TyBool. }

  (* TermFalse *)
  { now apply TyBool. }

  (* TermCond *)
  { eapply (@TySubst G (ctxextend G Bool)).
    + assumption.
    + apply CtxExtend.
      * assumption.
      * now apply TyBool.
    + apply SubstZero.
      * assumption.
      * now apply TyBool.
      * assumption.
    + assumption.
  }
Admitted.


Definition sane_isterm G u A :
  isterm G u A -> isctx G * istype G A.
Proof.
  intro H.
  pose (K := sane_isterm' G u A H).
  split ; [now apply (@sane_istype G A) | assumption].
Defined.

Definition sane_eqtype' G A B :
  eqtype G A B -> istype G A * istype G B.
Proof.
  intro H ; destruct H.

  (* EqTyCtxConv *)
  { split.
    - { now apply (@TyCtxConv G D). }
    - { now apply (@TyCtxConv G D). }
  }

  (* EqTyRefl*)
  { split ; assumption. }

  (* EqTySym *)
  { split ; assumption. }

  (* EqTyTrans *)
  { split ; assumption. }

  (* EqTyIdSubst *)
  { split.
    - eapply TySubst.
      + assumption.
      + eassumption.
      + now apply SubstId.
      + assumption.
    - assumption.
  }

  (* EqTySubstComp *)
  { split.
    - apply (@TySubst G D) ; auto.
      apply (@TySubst D E) ; auto.
    - apply (@TySubst G E) ; auto.
      apply (@SubstComp G D E) ; auto.
  }

  (* EqTySubstProd *)
  { split.
    - { apply (@TySubst G D) ; auto using TyProd. }
    - { apply TyProd ; auto.
        + now apply (@TySubst G D).
        + apply (@TySubst _ (ctxextend D A)) ; auto.
          * apply CtxExtend ; auto.
            now apply (@TySubst G D).
          * now apply CtxExtend.
          * now apply SubstShift.
      }
  }

  (* EqTySubstId *)
  { split.
    - { apply (@TySubst G D) ; auto using TyId. }
    - { apply TyId ; auto using (@TySubst G D), (@TermSubst G D). }
  }

  (* EqTySubstEmpty *)
  { split.
    - { apply (@TySubst G D) ; auto using TyEmpty. }
    - { now apply TyEmpty. }
  }

  (* EqTySubstUnit *)
  { split.
    - { apply (@TySubst G D) ; auto using TyUnit. }
    - { now apply TyUnit. }
  }

  (* EqTySubstBool *)
  { split.
    - { apply (@TySubst G D) ; auto using TyBool. }
    - { now apply TyBool. }
  }

  (* EqTyExfalso *)
  { split ; assumption. }

  (* CongProd *)
  { split.
    - { now apply TyProd. }
    - { apply TyProd ; auto.
        apply (@TyCtxConv (ctxextend G A1)) ; auto using CtxExtend.
        now apply EqCtxExtend. }
      }

  (* CongId *)
  { split.
    - { now apply TyId. }
    - { apply TyId.
        - assumption.
        - assumption.
        - now apply (@TermTyConv G A B v1).
        - now apply (@TermTyConv G A B v2).
      }
  }

  (* CongTySubst *)
  { split.
    - { now apply (@TySubst G D). }
    - { now apply (@TySubst G D). }
  }

Defined.

Theorem sane_eqctx G D :
  eqctx G D -> isctx G * isctx D.
Proof.
  intro H ; destruct H.

  (* CtxRefl *)
  { split.
    - assumption.
    - assumption.
  }

  (* CtxSym *)
  { split.
    - assumption.
    - assumption.
  }

  (* CtxTrans *)
  { split.
    - assumption.
    - assumption.
  }

  (* EqCtxEmpty *)
  { split.
    - now apply CtxEmpty.
    - now apply CtxEmpty.
  }

  (* EqCtxExtend *)
  { split.
    - now apply CtxExtend.
    - now apply CtxExtend.
  }

Defined.

Theorem sane_eqtype G A B :
  eqtype G A B -> isctx G * istype G A * istype G B.
Proof.
  intro H.
  destruct (sane_eqtype' G A B H).
  auto using (sane_istype G A).
Defined.

Theorem sane_eqterm' G u v A :
  eqterm G u v A -> isterm G u A * isterm G v A.
Proof.
  intro H ; destruct H.

  (* EqTyConv *)
  - { split.
      - { now apply (@TermTyConv G A B u). }
      - { now apply (@TermTyConv G A B v). }
    }

  (* EqCtxConv *)
  - { split.
      - { now apply (@TermCtxConv G D A). }
      - { now apply (@TermCtxConv G D A). }
    }

  (* EqRefl *)
  - { split.
      - { assumption. }
      - { assumption. }
    }

  (* EqSym *)
  - { split.
      - { assumption. }
      - { assumption. }
    }

  (* EqTrans *)
  - { split.
      - { assumption. }
      - { assumption. }
    }

  (* EqIdSubst *)
  - { split.
      - { apply (@TermTyConv G (Subst A (sbid G)) A).
          - assumption.
          - apply (@TySubst G G) ; auto using SubstId.
          - assumption.
          - apply (@TermSubst G G) ; auto using SubstId.
          - now apply EqTyIdSubst.
        }
      - { assumption. }
    }

  (* EqSubstComp *)
  - { split.
      - { apply (@TermTyConv G (Subst (Subst A sbt) sbs) (Subst A (sbcomp sbt sbs))).
          - assumption.
          - apply (@TySubst G D) ; auto.
            now apply (@TySubst D E).
          - apply (@TySubst G E) ; auto.
            now apply (@SubstComp G D E).
          - apply (@TermSubst G D) ; auto.
            + now apply (@TySubst D E).
            + now apply (@TermSubst D E).
          - now apply (@EqTySubstComp G D E).
        }
      - { apply (@TermSubst G E) ; auto.
          now apply (@SubstComp G D E).
        }
    }

  (* EqSubstWeak *)
  - { split.
      - { apply (@TermSubst _ G) ; auto using CtxExtend.
          now apply SubstWeak.
        }
      - { now apply TermVarSucc. }
    }


  (* EqSubstZeroZero *)
  - { split.
      - { apply (@TermTyConv G (Subst (Subst A (sbweak G A)) (sbzero G A u))).
          - assumption.
          - apply (@TySubst _ (ctxextend G A)) ; auto using CtxExtend.
            + now apply SubstZero.
            + apply (@TySubst _ G) ; auto using CtxExtend.
              now apply SubstWeak.
          - assumption.
          - apply (@TermSubst _ (ctxextend G A)) ; auto using CtxExtend.
            + apply (@TySubst _ G) ; auto using CtxExtend, SubstWeak.
            + now apply SubstZero.
            + now apply TermVarZero.
          - apply (@EqTyTrans G _ (Subst A (sbid G))) ; auto.
            + apply (@TySubst _ (ctxextend G A)) ; auto using CtxExtend.
              * now apply SubstZero.
              * apply (@TySubst _ G) ; auto using CtxExtend, SubstWeak.
            + apply (@TySubst _ G) ; auto using SubstId.
            + { apply (@EqTyTrans _ _ (Subst A (sbcomp (sbweak G A) (sbzero G A u)))) ; auto.
                - apply (@TySubst _ (ctxextend G A)) ; auto using CtxExtend, SubstZero.
                  apply (@TySubst _ G) ; auto using CtxExtend, SubstWeak.
                - apply (@TySubst _ G) ; auto.
                  + apply (@SubstComp _ (ctxextend G A)) ; auto using CtxExtend, SubstWeak, SubstZero.
                - apply (@TySubst _ G) ; auto using SubstId.
                - apply (@EqTySubstComp G (ctxextend G A) G) ;
                  auto using CtxExtend, (@SubstComp G (ctxextend G A)) , SubstWeak, SubstZero.
                - apply (@CongTySubst G G) ;
                  auto using CtxExtend, (@SubstComp G (ctxextend G A)) , SubstWeak, SubstZero, SubstId, EqTyRefl.
              }
            + now apply EqTyIdSubst.
        }
      - { assumption. }
    }

  (* EqSubstZeroSucc *)
  - { split.
      - { apply (@TermTyConv G (Subst (Subst A (sbweak G B)) (sbzero G B u))).
          - assumption.
          - apply (@TySubst _ (ctxextend G B)) ; auto using CtxExtend, SubstZero.
            apply (@TySubst _ G) ; auto using CtxExtend, SubstWeak.
          - assumption.
          - apply (@TermSubst G (ctxextend G B)) ; auto using CtxExtend.
            + apply (@TySubst _ G) ; auto using CtxExtend, SubstWeak.
            + now apply SubstZero.
            + now apply TermVarSucc.
          - admit.
        }
      - { assumption. }
    }

  (* EqSubstShiftZero *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstShiftSucc *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstAbs *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstApp *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstRefl *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstJ *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstExfalso *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstUnit *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstTrue *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstFalse *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqSubstCond *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqTermExfalso *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* UnitEta *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* EqReflection *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* ProdBeta *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* CondTrue *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* CondFalse *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* ProdEta *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* JRefl *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* CongAbs *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* CongApp *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* CongRefl *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* CongJ *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* CongCond *)
  - { split.
      - { admit. }
      - { admit. }
    }

  (* CongTermSubst *)
  - { split.
      - { admit. }
      - { admit. }
    }

Admitted.
