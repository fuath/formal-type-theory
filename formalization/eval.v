(* Translating CTT to (E)ITT *)
Require config.
Require Import config_tactics.

Require Import syntax.
Require Import tt.

Require ctt.
Require Import coerce.

Require eitt.

Fixpoint eval_substitution' (sbs : ctt.substitution') : substitution :=
  match sbs with
  | ctt.sbzero A u => sbzero (eval_type A) (eval_term u)
  | ctt.sbweak A => sbweak (eval_type A)
  | ctt.sbshift A sbs =>
    sbshift (eval_type A) (eval_substitution sbs)
  | ctt.sbid => sbid
  | ctt.sbcomp sbs sbt =>
    sbcomp (eval_substitution sbs) (eval_substitution sbt)
  end

with eval_substitution (sbs : ctt.substitution) : substitution :=
  match sbs with
   | ctt.sbcoerce crc1 crc2 sbs => coerce.act_subst crc1 crc2 (eval_substitution' sbs)
  end

with eval_type' (A : ctt.type') : type :=
  match A with
  | ctt.Prod A B => Prod (eval_type A) (eval_type B)
  | ctt.Id A u v => Id (eval_type A) (eval_term u) (eval_term v)
  | ctt.Subst A sbs => Subst (eval_type A) (eval_substitution sbs)
  | ctt.Empty => Empty
  | ctt.Unit => Unit
  | ctt.Bool => Bool
  end

with eval_type (A : ctt.type) : type :=
  match A with
  | ctt.Coerce crc A => coerce.act_type crc (eval_type' A)
  end

with eval_term' (t : ctt.term') : term :=
  match t with
  | ctt.var k => var k
  | ctt.lam A B u => lam (eval_type A) (eval_type B) (eval_term u)
  | ctt.app u A B v =>
    app (eval_term u) (eval_type A) (eval_type B) (eval_term v)
  | ctt.refl A u => refl (eval_type A) (eval_term u)
  | ctt.j A u C w v p => j (eval_type A)
                          (eval_term u)
                          (eval_type C)
                          (eval_term w)
                          (eval_term v)
                          (eval_term p)
  | ctt.subst u sbs => subst (eval_term u) (eval_substitution sbs)
  | ctt.exfalso A u => exfalso (eval_type A) (eval_term u)
  | ctt.unit => unit
  | ctt.true => true
  | ctt.false => false
  | ctt.cond A u v w => cond (eval_type A)
                            (eval_term u)
                            (eval_term v)
                            (eval_term w)
  end

with eval_term (t : ctt.term) : term :=
  match t with
  | ctt.coerce crc crt t => coerce.act_term crc crt (eval_term' t)
  end.

Fixpoint eval_ctx (G : ctt.context) : context :=
  match G with
  | ctt.ctxempty => ctxempty
  | ctt.ctxextend G A => ctxextend (eval_ctx G) (eval_type A)
  end.


(* Some lemmata to push coercions inside *)

(* Lemma coerceProd : *)
(*   forall G' G'' A B crc, *)
(*     eitt.eqtype G'' (coerce.act_type crc (Prod A B)) *)
(*                 (Prod (coerce.act_type crc A) *)
(*                       (coerce.act_type )) *)

Lemma coerceEmpty :
  forall G' G'' crc,
    coerce.isctxcoe crc G' G'' ->
    eitt.eqtype G'' (coerce.act_type crc Empty) Empty.
Proof.
  intros G' G'' crc h.
  induction crc.
  simpl. capply EqTyRefl. capply TyEmpty. now destruct h.
Defined.

Lemma coerceUnit :
  forall G' G'' crc,
    coerce.isctxcoe crc G' G'' ->
    eitt.eqtype G'' (coerce.act_type crc Unit) Unit.
Proof.
  intros G' G'' crc h.
  induction crc.
  simpl. capply EqTyRefl. capply TyUnit. now destruct h.
Defined.

Lemma coerceBool :
  forall G' G'' crc,
    coerce.isctxcoe crc G' G'' ->
    eitt.eqtype G'' (coerce.act_type crc Bool) Bool.
Proof.
  intros G' G'' crc h.
  induction crc.
  simpl. capply EqTyRefl. capply TyBool. now destruct h.
Defined.
