Require Import Program.Equality.
From mathcomp Require Import ssreflect seq ssrnat.
From istari Require Import source subst_src rules_src help trans basic_types.
From istari Require Import Sigma Tactics
     Syntax Subst SimpSub Promote Hygiene
     ContextHygiene Equivalence Rules Defined.
Check context.

Ltac var_solv :=
  try (apply tr_hyp_tm; repeat constructor).

Ltac simpsub_backup := repeat (try rewrite subst_laters; try rewrite subst_subseq; try rewrite subst_store;
        try rewrite subst_pw;
        try rewrite subst_nzero; try rewrite subst_nat; try rewrite subst_pw; simpsub; simpl).

Ltac simpsub_big := repeat (simpsub; simpsub1).


Lemma tr_arrow_elim: forall G a b m n p q, 
    tr G (deqtype a a) ->
    tr G (deqtype b b) ->
      tr G (deq m n (arrow a b))
      -> tr G (deq p q a) 
      -> tr G (deq (app m p) (app n q) b).
intros. 
suffices: (subst1 p (subst sh1 b)) = b. move => Heq.
rewrite - Heq.
eapply (tr_pi_elim _ a); try assumption.
eapply tr_eqtype_convert; try apply tr_arrow_pi_equal; assumption.
simpsub. auto. Qed.

Lemma tr_arrow_intro: forall G a b m n,
    tr G (deqtype a a) ->
      tr G (deqtype b b)
      -> tr (cons (hyp_tm a) G) (deq m n (subst sh1 b))
      -> tr G (deq (lam m) (lam n) (arrow a b) ).
intros. eapply tr_eqtype_convert.
apply tr_eqtype_symmetry. apply tr_arrow_pi_equal; try assumption.
eapply tr_pi_intro; try assumption. Qed.

Lemma tr_karrow_elim: forall G a b m n p q,
    tr G (deqtype a a) ->
    tr G (deqtype b b) ->
      tr G (deq m n (karrow a b))
      -> tr G (deq p q a) 
      -> tr G (deq (app m p) (app n q) b).
  intros. apply (tr_arrow_elim _ a); try assumption.
  eapply tr_eqtype_convert. apply tr_eqtype_symmetry.
  apply tr_arrow_karrow_equal; assumption.
  assumption. Qed.

Lemma kind_type: forall {G K i},
    tr G (deq K K (kuniv i)) -> tr G (deqtype K K).
  intros. eapply tr_formation_weaken.
  eapply tr_kuniv_weaken. apply X. Qed.

Lemma nat_U0: forall G,
    tr G (oof nattp U0). Admitted.
Hint Resolve nat_U0. 

Lemma nat_type: forall G,
      tr G (deqtype nattp nattp). Admitted.
Hint Resolve nat_type. 




Lemma pw_kind: forall {G},
    tr G (deq preworld preworld (kuniv nzero)).
  intros. apply tr_rec_kind_formation.
  apply tr_arrow_kind_formation.
  auto. apply tr_karrow_kind_formation.
  apply tr_fut_kind_formation.
  simpl. rewrite - subst_kuniv.
  apply tr_hyp_tm. repeat constructor.
  auto.
  apply tr_arrow_kind_formation. apply tr_fut_formation_univ.
  rewrite subst_nzero. apply nat_U0. auto.
  apply tr_univ_kind_formation; auto. apply zero_typed. Qed.
Hint Resolve pw_kind. 

Lemma pw_type: forall {G},
    tr G (deqtype preworld preworld ).
  intros. apply (kind_type pw_kind). Qed.

Hint Resolve pw_type.

Lemma pw_type2: forall {G}, tr G (deqtype (arrow (fut nattp) (univ nzero))
                                   (arrow (fut nattp) (univ nzero))).
  intros. apply tr_arrow_formation.
  apply tr_fut_formation. auto.
  apply tr_univ_formation. auto. Qed.

Lemma pw_type1: forall {G}, tr G (deqtype
       (karrow (fut preworld) (arrow (fut nattp) (univ nzero)))
       (karrow (fut preworld) (arrow (fut nattp) (univ nzero)))
  ).
  intros. apply tr_karrow_formation.
  apply tr_fut_formation. auto. apply pw_type2. Qed.



Lemma unfold_pw: forall G,
    tr G (deqtype preworld (arrow nattp
          (karrow (fut preworld) (arrow (fut nattp) (univ nzero))))). Admitted.

Lemma split_world_elim2: forall W G,
    tr G (oof W world) -> tr G (oof (ppi2 W) nattp).
Admitted.

Lemma split_world_elim1: forall W G,
    tr G (oof W world) -> tr G (oof (ppi1 W) preworld).
Admitted.

Lemma world_type: forall G,
      tr G (deqtype world world). Admitted.
Hint Resolve world_type. 

    Lemma split_world1: forall w1 l1 G,
tr G (oof (ppair w1 l1) world) -> tr G (oof w1 preworld). (*ask karl can't put a
                                                          conjunction here*)
    Admitted.

    Lemma split_world2: forall w1 l1 G,
tr G (oof (ppair w1 l1) world) -> tr G (oof l1 nattp). (*ask karl can't put a
                                                          conjunction here*)
    Admitted.

    Lemma nth_works: forall G w n,
        tr G (oof w world) -> tr G (oof n nattp) -> tr G (oof (nth w n)
                           (karrow (fut preworld) (arrow (fut nattp) U0))).
      intros. unfold nth. apply (tr_arrow_elim _ nattp); auto.
      do 2? constructor. auto.
      constructor. auto.
      apply tr_univ_formation. auto.
      eapply tr_eqtype_convert. apply unfold_pw.
      apply split_world_elim1. assumption.
      Qed.


Lemma subseq_U0: forall G w1 w2,
    tr G (oof w1 world) -> tr G (oof w2 world) ->
    tr G (oof (subseq w1 w2) (univ nzero)).
  intros.
  assert (forall V,
tr [:: hyp_tm
          (leq_t (var 0)
             (subst (sh 3) (ppi2 (var 0)))),
        hyp_tm nattp, hyp_tm (fut nattp),
        hyp_tm (fut preworld), hyp_tm world,
        hyp_tm world
        & G] (oof V world) ->

  tr
    [:: hyp_tm
          (leq_t (var 0)
             (subst (sh 3) (ppi2 (var 0)))),
        hyp_tm nattp, hyp_tm (fut nattp),
        hyp_tm (fut preworld), hyp_tm world,
        hyp_tm world
      & G]
    (oof
       (app3 (ppi1 V) 
          (var 1) (var 3) (var 2)) 
     (univ nzero))
         ) as Hworldapp.
  intros V Hvw.

  rewrite - (subst_nzero (dot (var 2) id)). (*start of the application proof,
                                              make this general for any
                                              (var 0) which gamma says is world*)
  rewrite - subst_univ.
  eapply (tr_pi_elim _ (fut nattp) ).
   simpsub. simpl.
  assert (forall s, pi (fut nattp) (univ nzero)
                     =  @subst False s (pi (fut nattp) (univ nzero))
         ) as sub1.
  auto.
  assert (forall s, @subst False s (karrow (fut preworld) (arrow (fut nattp) (univ nzero)))
                     = (karrow (fut preworld) (arrow (fut nattp) (univ nzero)))
         ) as sub2.
  auto.
  assert (forall s, arrow (fut nattp) (univ nzero)
                     =  @subst False s (arrow (fut nattp) (univ nzero))
         ) as sub3.
  auto.
  eapply tr_eqtype_convert.
  rewrite - (subst_U0 (sh 1)).
  eapply tr_arrow_pi_equal.
  eapply tr_fut_formation. eapply nat_type.
  eapply tr_univ_formation.
  apply zero_typed.
  rewrite (sub3 (dot (var 3) id)).
  eapply (tr_pi_elim _ (fut preworld)).
  eapply tr_eqtype_convert.
  rewrite (sub3 sh1).
  eapply tr_arrow_pi_equal.
  eapply tr_fut_formation. eapply pw_type.
  eapply pw_type2.
  assert (forall s, (arrow (fut preworld)
          (arrow (fut nattp) (univ nzero)))
               =  @subst False s (arrow (fut preworld)
          (arrow (fut nattp) (univ nzero)))
)
    as sub4.
  auto.
  eapply tr_eqtype_convert.
  eapply tr_eqtype_symmetry.
  eapply tr_arrow_karrow_equal.
  eapply tr_fut_formation. eapply pw_type.
  eapply pw_type2.
  rewrite - (sub2 (dot (var 1) id)).
  eapply (tr_pi_elim _ nattp).
  eapply tr_eqtype_convert.
  rewrite - (sub2 (sh1)).
  eapply tr_arrow_pi_equal.
  apply nat_type.
  eapply pw_type1.
  eapply tr_eqtype_convert.
  apply unfold_pw.
  eapply (tr_sigma_elim1 _ _ nattp).
  (*assert (forall s, (arrow nattp
             (karrow (fut preworld) (arrow (fut nattp) (univ nzero))))
               =  @subst False s (arrow nattp
             (karrow (fut preworld) (arrow (fut nattp) (univ nzero))))
)
    as sub5.
  intros. auto.*)
  apply Hvw.
  (*assert (sigma preworld nattp = world) by auto. rewrite H.
  rewrite - {3}(subst_world (sh 5)).
  apply tr_hyp_tm. repeat constructor.*)
  rewrite - {3}(subst_nat (sh 2)).
  apply tr_hyp_tm. repeat constructor.
  rewrite - {2}(subst_pw (sh 4)).
  rewrite - subst_fut.
  apply tr_hyp_tm. repeat constructor.
  rewrite - {2}(subst_nat (sh 3)).
  rewrite - subst_fut.
  apply tr_hyp_tm. repeat constructor.
  simpsub. simpl.


unfold subseq.
  rewrite - (subst_nzero (dot w2 id)).
  rewrite - subst_univ.
  eapply (tr_pi_elim _ world).
  rewrite - (subst_nzero (under 1 (dot w1 id)) ).
  rewrite - subst_univ.
  rewrite - (subst_world (dot w1 id)).
  rewrite - subst_pi.
  eapply (tr_pi_elim _ world).
  apply tr_pi_intro. apply world_type.
  apply tr_pi_intro. apply world_type.
  eapply tr_prod_formation_univ.
  eapply leq_type.
  eapply split_world_elim2.
  rewrite - (subst_world (sh 1)).
  eapply tr_hyp_tm. constructor.
  eapply split_world_elim2.
  rewrite - (subst_world (sh 2)).
  eapply tr_hyp_tm. repeat constructor.
  eapply tr_all_formation_univ.
  eapply tr_fut_kind_formation.
  apply pw_kind.
  apply zero_typed.
  eapply tr_pi_formation_univ.
  eapply tr_fut_formation_univ.
  apply nat_U0.
  repeat rewrite subst_nzero. apply zero_typed.
  repeat rewrite subst_nzero.
  eapply tr_pi_formation_univ. apply nat_U0.
  repeat rewrite subst_nzero. eapply tr_pi_formation_univ.
  apply leq_type.
  rewrite - (subst_nat (sh 1)).
  eapply tr_hyp_tm. repeat constructor.
  rewrite subst_ppi2. simpsub. simpl.
  eapply split_world_elim2.
  rewrite - (subst_world (sh 4)).
  eapply tr_hyp_tm. repeat constructor.
  repeat rewrite subst_nzero.
  eapply tr_eqtype_formation_univ.
apply Hworldapp. 
  rewrite - {3}(subst_world (sh 5)).
  apply tr_hyp_tm. repeat constructor.
simpsub. simpl. apply Hworldapp. 
  rewrite - {3}(subst_world (sh 6)).
  apply tr_hyp_tm. repeat constructor.
  auto.
  repeat rewrite subst_nzero. apply leq_refl. auto.
assumption. assumption.
Qed.


Lemma tr_weakening_appends: forall G1 G2 G3 J1 J2 t J1' J2' t',
    tr G1 (deq J1 J2 t) ->
    J1' = (shift (size G2) J1) ->
    J2' = (shift (size G2) J2) ->
    t' = (shift (size G2) t) ->
    G3 = G2 ++ G1 ->
      tr G3 (deq J1' J2' t').
 intros. move: G3 t t' J1' J2' J1 J2 H H0 H1 H2 X. induction G2; intros.
 -  simpl. subst. repeat rewrite - subst_sh_shift. simpsub. assumption.
 -
  suffices: (tr (substctx sh1 [::] ++ cons a (G2 ++ G1))
                (substj (under (length [::]) sh1)
                        (substj (sh (size G2)) (deq J1 J2 t)))).
  move => Hdone.
  simpl in Hdone. subst.
  rewrite (size_ncons 1).
  rewrite - plusE. 
  repeat rewrite subst_sh_shift.
  repeat rewrite - shift_sum.
  repeat rewrite subst_sh_shift in Hdone.
  rewrite cat_cons.
 apply (Hdone False). 
 intros.
 eapply tr_weakening.
 simpl. repeat rewrite subst_sh_shift. eapply IHG2; try reflexivity. assumption.
Qed.

 Lemma tr_weakening_append: forall (G1: context) G2 J1 J2 t,
      tr G1 (deq J1 J2 t) ->
      tr (G2 ++ G1) (
                       (deq (shift (size G2) J1)
                            (shift (size G2) J2)
                            (shift (size G2) t))).
   intros. eapply tr_weakening_appends; try apply X; try reflexivity.
   Qed.

Lemma store_type: forall W G,
    (tr G (oof W world)) -> tr G (oof (store W) U0).
Admitted.
Hint Resolve store_type.

Lemma laters_type: forall A G i,
    (tr G (oof A (univ i))) -> tr G (oof (laters A) (univ i)).
  Admitted.
Hint Resolve laters_type.

Lemma bind_type: forall G A B M0 M1,
    tr G (oof M0 (laters A)) ->
    tr G (oof M1 (arrow A (laters B))) ->
    tr G (oof (make_bind M0 M1) (laters B)). Admitted.

Lemma sh_sum :
  forall m n t,
    @subst False (sh n) (subst (sh m) t) = @subst False (sh (n+m)) t.
  intros. repeat rewrite subst_sh_shift.
  rewrite shift_sum. auto. Qed.

Lemma world_pair: forall w l G, tr G (oof w preworld) ->
                           tr G (oof l nattp) ->
    tr G (oof (ppair w l) world).
intros.
   (* eapply tr_eqtype_convert.
    eapply tr_eqtype_symmetry.
      eapply tr_prod_sigma_equal.*)
    (*eapply tr_formation_weaken; eapply tr_kuniv_weaken.
    eapply pw_kind. eapply nat_type.*)
    eapply tr_sigma_intro; try assumption.     apply nat_type. Qed.

Lemma hseq2: forall (T: Type) (x y: T)
                  (L: seq T), [:: x; y] ++ L=
                 [:: x, y & L].
intros. auto. Qed.

  Lemma hseq3: forall (T: Type) (x y z: T)
                  (L: seq T), [:: x; y; z] ++ L=
                 [:: x, y, z & L].
intros. auto. Qed.

Lemma hseq4: forall (T: Type) (x y z a: T)
                  (L: seq T), [:: x; y; z; a] ++ L=
                 [:: x, y, z, a & L].
intros. auto. Qed.

  Lemma uworld10: forall G,
      (tr [:: hyp_tm nattp, hyp_tm preworld & G]
    (oof (ppair (var 1) (var 0)) world)). intros.
     apply world_pair. 
        rewrite - (subst_pw (sh 2)).
      apply tr_hyp_tm; repeat constructor.
        rewrite - (subst_nat (sh 1)).
        apply tr_hyp_tm; repeat constructor. Admitted.

  Hint Resolve uworld10.

Lemma uworld32: forall G x y,
      (tr [:: x, y, hyp_tm nattp, hyp_tm preworld & G]
    (oof (ppair (var 3) (var 2)) world)). intros.
   apply world_pair.
  rewrite - (subst_pw (sh 4)). var_solv.
  rewrite - (subst_nat (sh 3)). var_solv. Qed. 

Hint Resolve uworld32.

Lemma uworld21: forall G x,
      (tr [:: x, hyp_tm nattp, hyp_tm preworld & G]
    (oof (ppair (var 2) (var 1)) world)). intros.
   apply world_pair.
  rewrite - (subst_pw (sh 3)). var_solv.
  rewrite - (subst_nat (sh 2)). var_solv. Qed. 

Lemma subst_trans_type : forall w l A s,
    (subst s (ppair w l)) = (ppair w l) ->
    (subst s (trans_type w l A)) = (trans_type w l A).
  move => w l A s H. move: w l s H. induction A; intros;simpl; auto; simpsub; simpl; repeat rewrite subst_lt; repeat rewrite subst_nth; repeat rewrite subst_nat; repeat rewrite subst_pw;
  repeat rewrite subst_subseq; repeat rewrite subst_nzero; repeat rewrite subst_store; repeat rewrite - subst_sh_shift; simpsub; try rewrite - subst_ppair;
 try rewrite subst_compose; try rewrite H. 
  - (*arrow*)
    suffices:  (subst
                (dot (var 0) (dot (var 1) (compose s (sh 2))))
                (trans_type (var 1) (var 0) A1)) = (trans_type (var 1) (var 0) A1). move => Heq1.
  suffices:  (subst
                (dot (var 0) (dot (var 1) (compose s (sh 2))))
                (trans_type (var 1) (var 0) A2)) = (trans_type (var 1) (var 0) A2). move => Heq2.
  rewrite Heq1 Heq2. auto. 
eapply IHA2. simpsub. auto. 
eapply IHA1. simpsub. auto.
  - (*comp*)
 rewrite subst_ppair in H. inversion H. rewrite H1.
repeat rewrite subst_ppair.
repeat rewrite subst_compose.
repeat rewrite H2. 
simpsub_big. simpl. suffices: (
            (subst
                            (dot (var 0)
                               (dot (var 1)
                                  (dot (var 2)
                                     (dot (var 3)
                                        (dot 
                                           (subst (sh 4) l)
                                           (compose s (sh 4)))))))
                            (trans_type (var 1) (var 0) A)
            ) = subst
                            (dot (var 0)
                               (dot 
                                 (var 1)
                                 (dot 
                                 (var 2)
                                 (dot 
                                 (var 3)
                                 (dot
                                 (subst (sh 4) l)
                                 (sh 4))))))
                            (trans_type 
                               (var 1) 
                               (var 0) A)

          ).
move => Heq. rewrite Heq. unfold subst1. auto. repeat rewrite IHA; simpsub; auto.
  - (*ref*)
    rewrite - subst_ppair. rewrite subst_compose. rewrite H.
    suffices: (subst
                      (dot (var 0)
                         (dot (var 1)
                            (dot (var 2) (compose s (sh 3)))))
                      (trans_type (var 1) (var 0) A)) =
              (trans_type (var 1) (var 0) A).
    move => Heq. rewrite Heq. auto.
eapply IHA. simpsub. auto.
Qed.



Lemma sh_trans_type : forall w l A s,
    (subst (sh s) (trans_type w l A)) = (trans_type
                                           (subst (sh s) w)
                                           (subst (sh s) l) A).
  induction A; intros; simpl; auto; simpsub_big; repeat rewrite plusE;
repeat rewrite - addnA;
    simpl; replace (1 + 1) with 2;
      replace (1 + 0) with 1; auto.
  - (*arrow*)
     repeat rewrite - subst_sh_shift.
     simpsub. rewrite plusE.
    repeat rewrite subst_trans_type; auto.
  - (*comp*)
    repeat rewrite subst_trans_type; simpsub; auto.
    unfold subst1. simpsub1.
    repeat rewrite - subst_sh_shift. simpsub. auto.
  - (*ref*)
    repeat rewrite subst_trans_type; simpsub; auto.
    unfold subst1. simpsub1.
    repeat rewrite - subst_sh_shift. simpsub. auto.
    rewrite subst_lt. simpsub. auto.
Qed.

(*pick up here*)
Lemma compm4_Type: forall U A G,
    (tr [:: hyp_tm preworld & G] (oof U world)) ->
    (tr [:: hyp_tm nattp, hyp_tm preworld & G] (oof A U0)) ->
    sigma nattp ( let v := Syntax.var 1 in
                  let lv := Syntax.var 0 in
                  let V := ppair v lv in
                  prod (prod (subseq (subst (sh 1) U) V) (store V))
                                                   A
                                                    ))
                               ) U0).
Lemma compm3_type: forall U A G,
    (tr G (oof U world)) -> (tr [:: hyp_tm nattp, hyp_tm preworld & G] (oof A U0)) ->
                    tr G  (oof (exist nzero preworld (
                                          sigma nattp 
                                          ( let v := Syntax.var 1 in
                                              let lv := Syntax.var 0 in
                                              let V := ppair v lv in
                                              prod (prod (subseq (subst (sh 2) U) V) (store V))
                                                   A
                                                    ))
                               ) U0).
  intros. apply tr_exist_formation_univ.
  apply pw_kind. eapply tr_sigma_formation_univ.
  unfold nzero. simpsub. apply nat_U0.
  simpl.
    eapply tr_prod_formation_univ.
    eapply tr_prod_formation_univ. unfold nzero. simpl.
    apply subseq_U0.
    rewrite - (subst_world (sh 2)).
assert (size [:: hyp_tm nattp; hyp_tm preworld] = 2) as Hsize. by auto. 
    rewrite - Hsize. rewrite - hseq2. repeat rewrite subst_sh_shift.
eapply tr_weakening_append; try apply X; try reflexivity. apply uworld10. 
    auto. unfold nzero. simpsub. apply store_type. auto.
    rewrite subst_nzero. apply X0. 
    auto. apply leq_refl. auto. Qed.


Lemma compm2_type: forall U A G,
    (tr G (oof U world)) -> (tr [:: hyp_tm nattp, hyp_tm preworld & G] (oof A U0)) ->
                    tr G  (oof (laters (exist nzero preworld (
                                          sigma nattp 
                                          ( let v := Syntax.var 1 in
                                              let lv := Syntax.var 0 in
                                              let V := ppair v lv in
                                              prod (prod (subseq (subst (sh 2) U) V) (store V))
                                                   A
                                                    ))
                               )) U0).
  intros. apply laters_type. apply compm3_type; try assumption. Qed.



  Lemma compm1_type : forall U A G,
    (tr G (oof U world)) -> (tr [:: hyp_tm nattp, hyp_tm preworld & G] (oof A U0)) ->
    tr G (oof (arrow (store U)
                     (*split the theorem up so that this
                      laters part stands alone*)
                         (laters (exist nzero preworld (
                                          sigma nattp 
                                          ( let v := Syntax.var 1 in
                                              let lv := Syntax.var 0 in
                                              let V := ppair v lv in
                                              prod (prod (subseq (subst (sh 2) U) V) (store V))
                                                   A
                                                    ))
                                    )
         )) U0). (*A should be substed by 2 here start here fix this in trans also*)
  move => U A G U_t A_t.
  eapply tr_arrow_formation_univ.
  apply store_type. assumption. apply compm2_type; assumption.
  Qed.


  Lemma compm0_type : forall A G w1 l1,
      (tr G (oof (ppair w1 l1) world)) ->
      (tr [:: hyp_tm nattp, hyp_tm preworld, hyp_tm nattp, hyp_tm preworld & G] (oof A U0)) ->
    tr [:: hyp_tm preworld & G] (oof
       (pi nattp
          (arrow
             (subseq
                (ppair (subst (sh 2) w1)
                   (subst (sh 2) l1))
                (ppair (var 1) (var 0)))
             (arrow (store (ppair (var 1) (var 0)))
                (laters
                   (exist nzero preworld
                      (sigma nattp
                         (prod
                            (prod
                               (subseq
                                  (ppair 
                                   (var 3) 
                                   (var 2))
                                  (ppair 
                                   (var 1) 
                                   (var 0)))
                               (store
                                  (ppair 
                                   (var 1) 
                                   (var 0))))
                            A))))))) U0
          ).
         intros. 
        apply tr_pi_formation_univ. auto.
        apply tr_arrow_formation_univ.
        apply subseq_U0.
        eapply (tr_weakening_appends _ [:: hyp_tm nattp; hyp_tm preworld]); try apply X; try reflexivity;
        try (rewrite - subst_ppair; rewrite subst_sh_shift; auto); auto.
        apply uworld10.
        apply compm1_type; auto. Qed. 

  Lemma trans_type_works : forall w l A G,
      (tr G (oof (ppair w l) world)) ->
      tr G (oof (trans_type w l A) U0).
    move => w l A G Du.
  move : w l G Du.
    induction A; intros; simpl; try apply nat_U0.
    + (*arrow*)
        apply tr_all_formation_univ.
      apply pw_kind.
      apply tr_pi_formation_univ.
      rewrite subst_nzero. apply nat_U0.
      apply tr_arrow_formation_univ.
      repeat rewrite subst_nzero.
      apply subseq_U0.
    - (*showing w, l world*)
      rewrite - (subst_world (sh 2)).
      rewrite subst_sh_shift. rewrite - hseq2.
      eapply tr_weakening_appends; try apply Du; try reflexivity; auto. 
      apply uworld10.
        apply tr_arrow_formation_univ; try auto.
        repeat rewrite subst_nzero.
        eapply IHA1; try assumption; try auto. 
        eapply IHA2; try assumption; try auto.
        auto. apply leq_refl. auto.
        (*comp type*)
      + simpsub_big. simpl. unfold subst1. simpsub1.
       (* unfold U0. rewrite - (subst_U0 (dot l id)).
        eapply tr_pi_elim.
        eapply tr_pi_intro. apply nat_type.*)
        apply tr_all_formation_univ. auto.
        rewrite - subst_sh_shift. simpsub.
        apply compm0_type; try assumption.
        rewrite subst_trans_type.
        eapply IHA; auto.  auto. auto.
        apply leq_refl. auto. 
    - (*ref type*)
      eapply tr_sigma_formation_univ; auto.
      eapply tr_prod_formation_univ. apply lt_type.
      rewrite - (subst_nat sh1). var_solv.
      rewrite subst_ppi2. apply split_world_elim2.
      rewrite - (subst_world sh1).
      rewrite - cat1s. repeat rewrite subst_sh_shift.
      eapply tr_weakening_append; try apply Du; try reflexivity; auto. 
      apply tr_all_formation_univ. apply pw_kind.
      apply tr_pi_formation_univ; auto.
      repeat rewrite subst_nzero. apply nat_U0.
      apply tr_eqtype_formation_univ.
      eapply (tr_arrow_elim _ (fut nattp) ). constructor; auto.
      apply tr_univ_formation.  auto.
      apply (tr_karrow_elim _ (fut preworld)).
      eapply kind_type. apply tr_fut_kind_formation. apply pw_kind. auto.
      apply tr_arrow_formation. constructor; auto.
      apply tr_univ_formation. auto. 
      eapply nth_works.
      rewrite - hseq3. rewrite - (subst_world (sh 3) ). rewrite subst_sh_shift.
      eapply tr_weakening_append; try apply Du; try reflexivity; auto. 
      rewrite - (subst_nat (sh 3) ).
      var_solv. apply tr_fut_intro.
      rewrite - (subst_pw (sh 2)). var_solv.
      apply tr_fut_intro.
      rewrite - (subst_nat (sh 1)). var_solv.
      apply tr_fut_formation_univ; auto. apply IHA; auto. apply uworld10.
      auto. apply leq_refl. auto. apply tr_unittp_formation.
Qed.

Lemma size_cons: forall(T: Type) (a: T) (L: seq T),
    size (a:: L) = 1 + (size L). Admitted.
 
Lemma size_gamma_at: forall G w l,
    size (gamma_at G w l) = size G. Admitted.

Theorem typed_hygiene: forall G M M' A,
    (tr G (deq M M' A)) -> (hygiene (ctxpred G) M).
  intros. dependent induction X; auto; try repeat constructor.
  - rewrite ctxpred_length. eapply Sequence.index_length. apply i0.
  - suffices:  (fun j : nat =>
     (j < 0)%coq_nat \/
     (j >= 0)%coq_nat /\ ctxpred G (j - 0)%coq_nat) = (ctxpred G).
    intros Heq. rewrite Heq. eapply IHX1; try reflexivity.
    (*apply extensionality.*)
    Admitted.


(*Opaque laters.
Opaque preworld.
Opaque U0.
Opaque subseq.
Opaque leqtp.
Opaque nzero.
Opaque nattp.
Opaque world.
Opaque nth.*)

Theorem test: forall s, (@subst False s nattp) = nattp.
  intros. simpsub1. Admitted.

(*Theorem one_five: forall G D e T ebar w1 l1, 
    of_m G e T ->
    trans e ebar -> 
         tr (gamma_at G ___? (oof ebar (all nzero preworld (pi nattp (trans_type
                                                      (var 1) (var 0)
                                                    T )))).*)


Theorem one: forall G D e T ebar w1 l1,
    of_m G e T -> tr D (oof (ppair w1 l1) world) ->
    trans e ebar -> 
         tr ((gamma_at G w1 l1) ++ D) (oof (app ebar (shift (size G) l1))
                                                   (trans_type
                                                      (shift (size G)
                                                             w1) (shift (size G)
                                                             l1)
                                                    T )).
  move => G D e T ebar w1 l1 De Dw Dtrans.
  move : D w1 l1 ebar Dw Dtrans. induction De; intros.
  10 : {
    (*Useful facts that will help us later*)
assert (size
         [:: hyp_tm (store (ppair (var 2) (var 1))),
      hyp_tm
        (subseq
           (ppair (subst (sh (size G + 2)) w1)
              (subst (sh (size G + 2)) l1))
           (ppair (var 1) (var 0))),
     hyp_tm nattp, hyp_tm preworld & gamma_at G w1 l1]
= (4 + size G)
       ) as Hsize. intros. repeat rewrite size_cons. rewrite size_gamma_at. auto.

assert (tr 
    [:: hyp_tm (store (ppair (var 2) (var 1))),
        hyp_tm
          (subseq
             (ppair (subst (sh (size G).+2) w1)
                (subst (sh (size G + 2)) l1))
             (ppair (var 1) (var 0))), hyp_tm nattp,
        hyp_tm (subst1 (subst (sh (size G)) l1) preworld)
      & gamma_at G w1 l1 ++ D]
    (oof
       (ppair (subst (sh (4 + size G)) w1)
          (subst (sh (4 + size G)) l1)) world)) as wworld4.
apply world_pair;
  auto; try rewrite - {2}(subst_pw  (sh (4 + size G)));
  try rewrite - {2}(subst_nat (sh (4 + size G)));
repeat rewrite (subst_sh_shift _ (4 + size G));
rewrite - hseq4; rewrite - (addn2 (size G));
rewrite - Hsize; rewrite catA;
  apply tr_weakening_append; [eapply split_world1 | eapply split_world2]; apply Dw.

     remember (size ([:: hyp_tm nattp,
        hyp_tm preworld
        & gamma_at G w1 l1])) as sizel.
    assert (sizel = (2 + size G )) as Hsizel. subst.
    repeat rewrite size_cons. repeat rewrite addnA.
    rewrite size_gamma_at. auto.
   (*assert (tr
    [:: hyp_tm nattp, hyp_tm preworld, hyp_tm nattp
      & gamma_at G w1 l1 ++ D]
    (oof (ppair (var 1) (var 0)) world) ) as Hu.
   apply world_pair.
        rewrite - (subst_pw (sh 2)).
      apply tr_hyp_tm; repeat constructor.
        rewrite - (subst_nat (sh 1)).
        apply tr_hyp_tm; repeat constructor.*)
(*assert (tr
    [:: hyp_tm nattp, hyp_tm preworld, hyp_tm nattp
      & gamma_at G w1 l1 ++ D]
    (oof (ppair (subst (sh (3 + (size G))) w1) (var 2)) world)) as Hwv2.
    apply world_pair. 
    (*rewrite subst_sh_shift. subst.
    repeat rewrite - Hseq.*)
    rewrite - {2}(subst_pw (sh (3 + size G))).
    repeat rewrite subst_sh_shift. repeat rewrite plusE.
    repeat rewrite - Hsizel.
    repeat rewrite - cat_cons. subst.
    apply tr_weakening_append; auto.
eapply split_world1. apply Dw.
      rewrite - (subst_nat (sh 3)).
      apply tr_hyp_tm; repeat constructor.*)
    (*actual proof*)
    suffices: hygiene (ctxpred (gamma_at G w1 l1 ++ D)) (trans_type (shift (size G) w1)
                                                          (shift (size G) l1) (comp_m B)) /\
              hygiene (ctxpred (gamma_at G w1 l1 ++ D)) (app ebar (shift (size G) l1)).
    move => [Hh1 Hh2].
    suffices: equiv 
       (trans_type (shift (size G) w1) 
          (shift (size G) l1) (comp_m B))
       (trans_type (shift (size G) w1) 
          (shift (size G) l1) (comp_m B)). move => Hequivt. simpl in Hequivt.
    inversion Dtrans; subst. simpl.
    suffices: equiv (
       (app
          (lam
             (lam
                (lam
                   (lam
                      (make_bind
                         (app
                            (app
                               (app
                                  (app 
                                     (shift 4 Et1) 
                                     (var 3)) 
                                  (var 2)) 
                               (var 1)) 
                            (var 0))
                         (lam
                            (make_bind
                               (app
                                  (app
                                     (app
                                     (app
                                     (app
                                     (shift 5
                                     (lam
                                     (move_gamma G0
                                     make_subseq 1 Et2)))
                                     (picomp4 (var 0)))
                                     (picomp1 (var 0)))
                                     (picomp1 (var 0)))
                                     make_subseq)
                                  (picomp3 (var 0)))
                               (lam
                                  (app ret
                                     (ppair
                                     (picomp1 (var 0))
                                     (ppair make_subseq
                                     (ppair
                                     (picomp3 (var 0))
                                     (picomp4 (var 0))))))))))))))
          (shift (size G) l1))
)
          (subst1 (subst (sh (size G)) l1)
             (lam
                (lam
                   (lam
                      (make_bind
                         (app
                            (app
                               (app (app (subst (sh 4) Et1) (var 3))
                                  (var 2)) (var 1)) 
                            (var 0))
                         (lam
                            (make_bind
                               (app
                                  (app
                                     (app
                                        (app
                                           (app
                                              (subst 
                                                (sh 5)
                                                (lam
                                                (move_gamma G0 make_subseq
                                                1 Et2))) 
                                              (picomp4 (var 0)))
                                           (picomp1 (var 0)))
                                        (picomp1 (var 0))) make_subseq)
                                  (picomp3 (var 0)))
                               (lam
                                  (app ret
                                     (ppair (picomp1 (var 0))
                                        (ppair make_subseq
                                           (ppair 
                                              (picomp3 (var 0))
                                              (picomp4 (var 0)))))))))))))).
    move => Hequiv.
apply (tr_compute _ _ _ _ _ _ _ Hh1 Hh2 Hh2 Hequivt Hequiv Hequiv); try assumption.
(*get the substitutions nice before i split
 things up*)
simpsub. simpl.
repeat rewrite - subst_sh_shift. simpsub_big.
rewrite subst_trans_type. simpl.
    repeat rewrite plusE. rewrite - trunc_sum. simpsub. simpl.
    rewrite trunc_sh.
(*put the arith assert in here if you need it*) 
     apply tr_all_intro.
    apply pw_kind.
    simpsub_big. simpl.
    apply tr_pi_intro.  apply nat_type. 
    apply tr_arrow_intro.
    eapply tr_formation_weaken. 
    apply subseq_U0. (*to show subseqs
                        are the same type,
 need to show that the variables are both of type world*)
   + repeat rewrite plusE.
     rewrite - hseq2. rewrite catA.
     rewrite - addn2.
      rewrite - subst_ppair.
      rewrite - (subst_world (sh (2 + size G))).
  repeat rewrite subst_sh_shift.
      repeat rewrite addnC - Hsizel.
      eapply tr_weakening_append; try apply Du; try reflexivity; auto. 
  + apply uworld10.
  +
    eapply tr_formation_weaken.
    eapply compm1_type. apply uworld10.
    apply trans_type_works. apply uworld10. 
  (*back to main proof*)
-  simpsub_big. simpl.
  apply tr_arrow_intro.
  + 
    eapply tr_formation_weaken. 
    apply store_type.  apply uworld21.
    assert (@ppair False (var 4) (var 3) = subst (sh 2) (ppair (var 2) (var 1))) as Hppair. simpsub. auto. rewrite Hppair. eapply tr_formation_weaken.
  apply compm2_type. apply uworld21. rewrite subst_trans_type. apply trans_type_works. auto.
simpsub. auto.
    rewrite subst_bind. simpsub_big. simpl. rewrite subst_trans_type.
    repeat rewrite plusE. rewrite - trunc_sum. simpsub. simpl.
    rewrite trunc_sh.
    eapply (bind_type _
                      (exist nzero preworld (
                                          sigma nattp (*l1 = 6 u := 5, l := 4, v= 1, lv := 0*)
                                          (let u := Syntax.var 5 in
                                              let l := Syntax.var 4 in
                                              let v := Syntax.var 1 in
                                              let lv := Syntax.var 0 in
                                              let U := ppair u l in
                                              let V := ppair v lv in
                                              (*u = 4, l = 3, subseq = 2, v = 1, lv = 0*)
                                                    prod (prod (subseq U V) (store V))
                                                     (trans_type v lv A))))
                                 ).
    simpsub.
(*at make_bind*)
    eapply (tr_arrow_elim _  (store (ppair (var 3)
                                                   (var 2)
           ))).
- 
 eapply tr_formation_weaken. apply store_type.
  apply world_pair. rewrite - (subst_pw (sh 4)). var_solv.
  rewrite - (subst_nat (sh 3)). var_solv.
  eapply tr_formation_weaken.
  assert (@ppair False (var 5) (var 4) = subst (sh 2) (ppair (var 3) (var 2))) as Hppair. simpsub. auto. rewrite Hppair.
  apply compm2_type. apply uworld32. apply trans_type_works.
  apply uworld10.
  (*Et1 nonsense
just make below more shifts maybe?
   *)
apply (tr_arrow_elim _
          (subseq
             (ppair
                (subst (sh (4 + size G)) w1)
                (subst (sh (4 + size G)) l1))
 (ppair (var 3) (var 2)))).
eapply tr_formation_weaken. apply subseq_U0.
apply wworld4.
apply uworld32.
eapply tr_formation_weaken; apply compm1_type. apply uworld32.
apply trans_type_works. auto.
assert (
       (arrow
          (subseq (ppair (subst (sh (4 + size G)) w1)
                         (subst (sh (4 + size G)) l1))
             (ppair (var 3) (var 2)))
          (arrow (store (ppair (var 3) (var 2)))
             (laters
                (exist nzero preworld
                   (sigma nattp
                      (prod
                         (prod
                            (subseq (ppair (var 5) (var 4))
                               (ppair (var 1) (var 0)))
                            (store (ppair (var 1) (var 0))))
                         (trans_type (var 1) (var 0) A))))))) =
subst1 (var 2) 
       (arrow
          (subseq (ppair (subst (sh (5 + size G)) w1)
                         (subst (sh (5 + size G)) l1))
             (ppair (var 4) (var 0)))
          (arrow (store (ppair (var 4) (var 0)))
             (laters
                (exist nzero preworld
                   (sigma nattp
                      (prod
                         (prod
                            (subseq (ppair (var 6) (var 2))
                               (ppair (var 1) (var 0)))
                            (store (ppair (var 1) (var 0))))
                         (trans_type (var 1) (var 0) A)))))))) as Hsub.
simpsub. unfold subst1; simpsub1. simpsub_big.
(*ask karl arrow subseq*) simpl. unfold subst1. simpsub1.
rewrite subst_trans_type.
rewrite addnC. auto. simpsub. rewrite - (addn4 (size G)).
auto. simpsub. auto.
rewrite Hsub.
eapply (tr_pi_elim _ nattp).
    assert(   (pi nattp
          (arrow
             (subseq
                (ppair (subst (sh (5 + size G)) w1)
                       (subst (sh (5 + size G)) l1))
                (ppair (var 4) (var 0)))
             (arrow (store (ppair (var 4) (var 0)))
                (laters
                   (exist nzero preworld
                      (sigma nattp
                         (prod
                            (prod
                               (subseq (ppair (var 6) (var 2))
                                  (ppair (var 1) (var 0)))
                               (store (ppair (var 1) (var 0))))
                            (trans_type (var 1) (var 0) A)))))))) =
subst1 (var 3) (pi nattp
          (arrow
             (subseq
                (ppair (subst (sh (6 + size G)) w1)
                       (subst (sh (6 + size G)) l1))
                (ppair (var 1) (var 0)))
             (arrow (store (ppair (var 1) (var 0)))
                (laters
                   (exist nzero preworld
                      (sigma nattp
                         (prod
                            (prod
                               (subseq (ppair (var 3) (var 2))
                                  (ppair (var 1) (var 0)))
                               (store (ppair (var 1) (var 0))))
                            (trans_type (var 1) (var 0) A))))))))
       )
           as Hsub2.
    simpsub_big. simpl. rewrite - (addn4 (size G)) - (addn1 (size G + 4)).
    auto. unfold subst1. simpsub1. rewrite - addnA.
    rewrite subst_trans_type. rewrite addnC. auto. simpsub. auto.
    rewrite Hsub2.
    eapply (tr_all_elim _ nzero preworld).
    (*strange goal comes from here
     get this out of comp type
     get w to have the shift in front from the start*)
    clear Hsub Hsub2.
assert 
       (all nzero preworld
          (pi nattp
             (arrow
                (subseq
                   (ppair
                      (subst (sh (6 + size G))
                         w1)
                      (subst (sh (6 + size G))
                         l1))
                   (ppair (var 1) (var 0)))
                (arrow
                   (store
                      (ppair (var 1) (var 0)))
                   (laters
                      (exist nzero preworld
                         (sigma nattp
                            (prod
                              (prod
                              (subseq
                              (ppair 
                              (var 3) 
                              (var 2))
                              (ppair 
                              (var 1) 
                              (var 0)))
                              (store
                              (ppair 
                              (var 1) 
                              (var 0))))
                              (trans_type
                              (var 1) 
                              (var 0) A))))))))
= subst1 (subst (sh (4 + size G)) l1)
       (all nzero preworld
          (pi nattp
             (arrow
                (subseq
                   (ppair (shift 3(subst (sh (4 + size G)) w1))
                          (var 2))
                   (ppair (var 1) (var 0)))
                (arrow (store (ppair (var 1) (var 0)))
                   (laters
                      (exist nzero preworld
                         (sigma nattp
                            (prod
                               (prod
                                  (subseq
                                     (ppair (var 3) (var 2))
                                     (ppair (var 1) (var 0)))
                                  (store
                                     (ppair (var 1) (var 0))))
                               (trans_type (var 1) (var 0) A))))))))))
      as Hsub3.
rewrite - subst_sh_shift.
simpsub. simpl. unfold subst1. simpsub1. simpsub_big. simpl.
repeat rewrite plusE.
rewrite subst_trans_type. repeat rewrite - addnA.
replace (3 + 2) with 5; auto.
replace (1 + 1) with 2; auto.
repeat rewrite - (addn1 (size G + 5)).
repeat rewrite - (addn4 (size G + 2)).
rewrite addnC. auto. repeat rewrite - addnA.
replace (5 + 1) with 6; auto.
replace (2 + 4) with 6; auto.
(*ask karl: a mess!!*)
rewrite Hsub3.
clear Hsub3.
assert( 
       (subst1 (subst (sh (4 + size G)) l1)
          (all nzero preworld
             (pi nattp
                (arrow
                   (subseq
                      (ppair (shift 3 (subst (sh (4 + size G)) w1))
                         (var 2)) (ppair (var 1) (var 0)))
                   (arrow (store (ppair (var 1) (var 0)))
                      (laters
                         (exist nzero preworld
                            (sigma nattp
                               (prod
                                  (prod
                                     (subseq (ppair (var 3) (var 2))
                                        (ppair (var 1) (var 0)))
                                     (store (ppair (var 1) (var 0))))
                                  (trans_type (var 1) (var 0) A)))))))))) =
trans_type (subst (sh (4 + size G)) w1) (subst (sh (4 + size G)) l1) (comp_m A) ) as Hsub4.
simpl. auto.
rewrite Hsub4.
clear Hsub4.
rewrite - (addn2 (size G)).
repeat rewrite plusE.
repeat rewrite - (sh_sum (size G) 4).
rewrite - sh_trans_type. rewrite - subst_app.
unfold subst1. rewrite subst_pw. rewrite - hseq4.
repeat rewrite subst_sh_shift. apply tr_weakening_append.
eapply IHDe1; try assumption.
rewrite - (subst_pw (sh 4)). var_solv.
replace 6 with (2 + 4). rewrite - addnA.
repeat rewrite - (sh_sum (4 + size G) 2). eapply tr_formation_weaken; apply compm0_type.
apply wworld4. apply trans_type_works. apply uworld10. auto.
rewrite - (subst_nat (sh 3)). var_solv.
rewrite - (addn2 (size G)).
replace ( subseq
          (ppair (subst (sh (4 + size G)) w1)
             (subst (sh (4 + size G)) l1))
          (ppair (var 3) (var 2)))
  with (subst (sh 2)
          (subseq
             (ppair (subst (sh (size G + 2)) w1)
                (subst (sh (size G + 2)) l1)) (ppair (var 1) (var 0))
       )). var_solv. simpsub_big. auto. rewrite plusE.
replace (size G + 2 + 2) with (4 + size G); auto.
rewrite addnC. rewrite - addnA. auto.
replace (store (ppair (var 3) (var 2)))
with (subst (sh 1) (store (ppair (var 2) (var 1)))). var_solv.
simpsub_big. auto. simpsub.
(*e2bar*)
 rewrite subst_bind.
 simpsub_big. simpl. simpsub.
 apply tr_arrow_intro.
 - 
   replace (ppair (var 5) (var 4)) with
       (@subst False (sh 2)
              (ppair (var 3) (var 2))
       ).
   eapply tr_formation_weaken; eapply compm3_type; auto.
   apply trans_type_works; auto.
   simpsub. auto.
 -
   replace (ppair (var 5) (var 4)) with
       (@subst False (sh 2)
              (ppair (var 3) (var 2))
       ).
   eapply tr_formation_weaken; eapply compm2_type; auto.
   apply trans_type_works; auto.
   simpsub. auto.
 - simpsub_big. simpl.
   replace (make_bind
          (app
             (app
                (app
                   (app
                      (app
                         (lam
                            (subst (dot (var 0) (sh 6))
                               (move_gamma G0 make_subseq 1 Et2)))
                         (picomp4 (var 0))) 
                      (ppi1 (var 0))) (ppi1 (var 0)))
                make_subseq) (picomp3 (var 0)))
          (lam
             (app ret
                (ppair (ppi1 (var 0))
                   (ppair make_subseq
                          (ppair (picomp3 (var 0)) (picomp4 (var 0)))))))) with
       (subst1 (var 0) (make_bind
          (app
             (app
                (app
                   (app
                      (app
                         (lam
                            (subst (dot (var 0) (sh 6))
                               (move_gamma G0 make_subseq 1 Et2)))
                         (picomp4 (var 0))) 
                      (ppi1 (var 0))) (ppi1 (var 0)))
                make_subseq) (picomp3 (var 0)))
          (lam
             (app ret
                (ppair (ppi1 (var 0))
                   (ppair make_subseq
                          (ppair (picomp3 (var 0)) (picomp4 (var 0)))))))) ).
   eapply (tr_exist_elim _ (subst (sh 1) nzero)
                         (subst (sh 1) preworld) 
             (subst (under 1 (sh 1)) (sigma nattp
                (prod
                   (prod
                      (subseq (ppair (var 5) (var 4))
                         (ppair (var 1) (var 0)))
                      (store (ppair (var 1) (var 0))))
                   (trans_type (var 1) (var 0) A)))) ).
 -  rewrite - subst_exist. var_solv.
    apply pw_type. simpsub_big. simpl.

(*get this out of comp type*)


   (*first apply rule 72 before
    you touch the bind type*)
    eapply (bind_type _
                      (exist nzero preworld (
                                          sigma nattp (*l1 = 6 u := 5, l := 4, v= 1, lv := 0*)
                                          (let u := Syntax.var 1 in
                                              let l := Syntax.var 0 in
                                              let v := Syntax.var 1 in
                                              let lv := Syntax.var 0 in
                                              let U := ppair u l in
                                              let V := ppair v lv in
                                              (*u = 4, l = 3, subseq = 2, v = 1, lv = 0*)
                                                    prod (prod (subseq U V) (store V))
                                                     (trans_type v lv A))))
                                 ).
    simpsub.
 (*start here*)

rewrite - subst_ppair. rewrite (subst_sh_shift _ (4 + (size G))).
rewrite - (addn2 (size G)).
unfold subst1. rewrite subst_pw. rewrite - Hsize.
rewrite - hseq4. rewrite catA.
rewrite hseq4. rewrite - (subst_world 4)
apply tr_weakening_append.
















(*start here with the bring shift out lemma*)
eapply tr_all_elim. clear Hsub3.
(*IH features l1 specifically*)
assert(
       (all nzero preworld
          (pi nattp
             (pi nattp
                (arrow
                   (subseq
                      (ppair (subst (sh (8 + size G)) w1)
                         (var 1)) (ppair (var 2) (var 0)))
                   (arrow (store (ppair (var 2) (var 0)))
                      (laters
                         (exist nzero preworld
                            (sigma nattp
                               (prod
                                  (prod
                                     (subseq
                                        (ppair (var 8) (var 7))
                                        (ppair (var 1) (var 0)))
                                     (store
                                        (ppair (var 1) (var 0))))
                                  (trans_type (var 1) (var 0) A)))))))))) =
       subst (sh 5)
(all nzero preworld
          (pi nattp
             (pi nattp
                (arrow
                   (subseq
                      (ppair (subst (sh (8 + size G)) w1)
                         (var 1)) (ppair (var 2) (var 0)))
                   (arrow (store (ppair (var 2) (var 0)))
                      (laters
                         (exist nzero preworld
                            (sigma nattp
                               (prod
                                  (prod
                                     (subseq
                                        (ppair (var 8) (var 7))
                                        (ppair (var 1) (var 0)))
                                     (store
                                        (ppair (var 1) (var 0))))
                                  (trans_type (var 1) (var 0) A))))))))))

  )



    rewrite sh_sum.
    rewrite - compose_sh.
unfold subst1
repeat rewrite subst_store. simpsub.

eapply tr_pi_elim.

apply world_pair.
  rewrite - (subst_pw (sh 4)). var_solv.
  rewrite - (subst_nat (sh 3)). var_solv. apply trans_type_works.





    rewrite - (subst_world (sh 2)).
    rewrite - Hsize. rewrite - Hseq. repeat rewrite subst_sh_shift.
apply tr_weakening_append. assumption. assumption.
    auto. unfold nzero. simpsub. apply store_type. auto.
    rewrite subst_nzero. apply A_t.
    auto. apply leq_refl. auto.

        (*do a suffices somehow*)
suffices:
          tr [:: hyp_tm nattp, hyp_tm preworld, hyp_tm nattp & gamma_at G w1 l1 ++ D]
    (oof
       (arrow (store (ppair (var 1) (var 0)))
          (laters
             (exist nzero preworld
                (sigma nattp
                   (let v := var 1 in
                    let lv := var 0 in
                    let V := ppair v lv in
                    prod (prod (subseq (subst (sh 2) (ppair (var 1) (var 0))) V) (store V))
                          (trans_type (var 1) (var 0) B)))))) U0).
simpsub. move => Hdone. 
eapply tr_formation_weaken. apply Hdone.
        apply compm1_type.
        assumption.
        (*when forming the type A -> B, the x: A doesnt bind
         when you're writing B
         but when forming an element of A -> B, the x: A does bind

         when forming the type A \times B, the x: A doesnt bind
         when forming a value of type A \times B, the x: A does bind*)
        simpsub.
      eapply tr_hyp_tm. constructor.
      repeat rewrite subst_nat. apply nat_type.
      (*start here*)
      apply arrow_kind_formation.
      rewrite subseq_subst.
    simpsub.
    induction G. simpsub.
    repeat rewrite compose_sh_dot.
    auto.
    apply (tr_weakening D).
    apply tr_hyp_tm.
    try prove_subst.
    repeat simpl.
    Opaque subst. Opaque sh1.
    auto.
    simpsub.
    simpl.
    eapply tr_pi_intro.
    (*eapply tr_compute; try (
      apply Relation.star_one; left;
      eapply reduce_app_beta; try apply reduce_id).
    4 : {
      unfold equiv.
      eapply Relation.star_refl.
    }
    4 : { unfold subst1. simpl.
      unfold equiv.
    }*)

  }
