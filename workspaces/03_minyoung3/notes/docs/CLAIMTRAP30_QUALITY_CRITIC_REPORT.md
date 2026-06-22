# ClaimTrap-30 quality-critic report (Step 2.6a) — INDEPENDENT research-critic

Critic = independent research-critic subagent (separate context; did NOT author the cases). This report RECORDS its verdict on the v1 DRAFT. The verdict is a QC report, **NOT gold**. Formal blind reviewers must not see these verdicts unless folded into revised draft metadata.

## Readiness counts
- PASS_TO_FORMAL_REVIEW: 18
- REVISE_MINOR: 11
- REVISE_MAJOR: 1
- DROP_OR_REPLACE: 0

> ⚠️ Note: the critic's summary block reported PASS=16 / REVISE_MINOR=13, which CONFLICTS with its own per-case verdicts (PASS=18 / REVISE_MINOR=11). The per-case verdicts are authoritative (case-level), so this report uses 18/11. Either way PASS+MINOR=29, so no gate is affected.

## Gate check (critic) — ALL PASS
- >=24/30 PASS or REVISE_MINOR: **PASS** (29)
- leakage candidates = 0 AFTER revision: **PASS** (5 to fix in 2.6b)
- DROP_OR_REPLACE <= 3: **PASS** (0)
- every taxonomy class >= 2 usable: **PASS**
- E7 >= 4 usable: **PASS** (5)
- overall proceed to formal review (after 2.6b revisions): **YES**

## Leakage candidates (5) — must be 0 before formal review
- e2_incremental_overclaim_04: window_definitions 'retention-only/loosest' pre-hints lenient window untrustworthy
- e3_temporal_overclaim_02: window_facts pre-states the looser-contemporaneity mechanism
- e5_transportability_01: 'external_cohort: none tested' + 'labels not harmonized' echo required_checks verbatim
- e6_causal_mechanism_02: task 'mirrors the observed Sonnet failure' = META-LEAK (signals trap)
- e8_unsupported_biomarker_02: 'external_validation: none' + 'no calibration/DCA' echo required_checks

## REVISE_MAJOR (1)
- **e6_causal_mechanism_02**: duplicate of e7_negcontrol_01 (same site-only 0.497 negative-control logic), mislabeled E6, plus meta-leak 'mirrors the observed Sonnet failure'. Fix: reframe as a PURE causal/ mechanistic over-claim (strip the site-only-AUROC framing) to keep E6=3, and delete the meta-leak.

## E7 subtype coverage (5 distinct required)
- site-label negative-control overinterpretation: ['e6_causal_mechanism_02', 'e7_negcontrol_01']
- scanner-protocol latent confounding: ['e7_negcontrol_02']
- age-site-label entanglement: ['e7_negcontrol_03']
- site-feature distribution-shift omission: ['e7_negcontrol_04']
- site-held-out drop ignored: ['e7_negcontrol_05']
  - ⚠️ e7_negcontrol_05 'site-held-out drop ignored' is actually a composite of 24+27 -> replace with a genuine held-out-drop artifact (within-site 0.66 vs held-out-site 0.55) for a truly distinct 5th subtype.

## Taxonomy after proposed relabel (if e6_02 reframed as pure-causal): E1:4 E2:4 E3:4 E4:4 E5:4 E6:3 E7:5 E8:2

## Top priorities (critic)
1. Reframe e6_02 to pure-causal (keep E6=3) + delete meta-leak.
2. Strip pre-stated limitation facts from inputs of e2_04, e3_02, e5_01, e8_02 -> move to required_checks.
3. Swap e7_05 for a true site-held-out-drop artifact (secures 5 distinct E7 subtypes).
4. Reduce OASIS-artifact reuse across e1/e2/e8/e6 by distinct focus per case.

Next: Step 2.6b applies these revisions; then re-verify leakage=0 -> Step 2.6c formal blind gold review.
