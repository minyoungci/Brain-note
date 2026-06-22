# ClaimTrap-30 formal blind gold review (Step 2.6c)

Two INDEPENDENT, BLIND reviewers (research_critic + professor) scored all 30 cases from neutral input
artifacts only — they did NOT see draft labels, draft gold, the quality-critic verdict, revision notes, or
the intended taxonomy. Cases were given in 3 taxonomy-balanced mixed batches (10 each) in separate reviewer
contexts to avoid drift. Reviewer outputs: `claimtrap30_review_research_critic.jsonl`,
`claimtrap30_review_professor.jsonl`. Blinded inputs: `claimtrap30_review_inputs.jsonl`.

## Adjudication rules (applied mechanically)
1. same primary_error_type AND same claim_level → **LOCKED_REVIEWER_AGREEMENT**
2. same primary AND same tier, levels differ → **LOCKED_CONSERVATIVE** (adopt the more restrictive; L1.5 > L1 because it mandates the negative-increment caveat)
3. primary differs (but same E1/E2 covariate family) AND same tier → **LOCKED_CONSERVATIVE** (taxonomy note)
4. primary differs across families OR claim tier differs (blocked/association/predictive) → **REQUIRES_HUMAN_ADJUDICATION**
5. one+ DROP_OR_REPLACE with the other doubting validity → DROP_OR_REPLACE; both REVISE_MAJOR → REVISE_MAJOR_BEFORE_LOCK
Tiers: L0=blocked, {L1,L1.5}=association, L2=internal-predictive, L3=transportable/clinical.

## Result
| status | n |
|---|--:|
| LOCKED_REVIEWER_AGREEMENT | 27 |
| LOCKED_CONSERVATIVE | 2 |
| REQUIRES_HUMAN_ADJUDICATION | 1 |
| DROP_OR_REPLACE | 0 |

- reviewer agreement: **primary_error_type 29/30**, exact claim_level **28/30**.
- **draft↔gold self-bias: 23/29 locked cases matched the agent's draft level = 79%** (vs 40% in the 5-case set). The independent review still CORRECTED 6/29 self-authored draft levels — the anti-self-eval gate remains justified.

## Acceptance gate — ALL PASS
- LOCKED (agreement+conservative) ≥ 24/30: **PASS (29)**
- REQUIRES_HUMAN_ADJUDICATION ≤ 6: **PASS (1)**
- DROP_OR_REPLACE ≤ 3: **PASS (0)**
- each E category locked ≥ 2: **PASS** (E1:4 E2:4 E3:4 E4:4 E5:3 E6:3 E7:5 E8:2)
- E7 locked ≥ 4: **PASS (5)**
- leakage re-discovered by reviewers = 0 (no reviewer flagged the input revealing the answer)
- scoring_allowed: stays **false** on all cases until human sign-off enables the LOCKED ones

## Draft→gold level corrections (independent review changed the agent's label)
| case | draft | gold | why |
|---|---|---|---|
| e4_label_provenance_04 | L1 | **L0** | both reviewers: pooling PIB+AV45 under one cutoff is blocked, not association |
| e5_transportability_02 | L1 | **L0** | both: pooled-base-rate inflation; no defensible discrimination claim |
| e7_negcontrol_01 | L1.5 | **L1** | both: plain within-cohort association (no negative-increment framing here) |
| e7_negcontrol_03 | L1.5 | **L1** | both: association only |
| e2_incremental_overclaim_03 | L1 | **L1.5** | both: it is a negative incremental finding |
| e8_unsupported_biomarker_02 | L1 | **L1.5** | reviewer split L1/L1.5 → conservative L1.5 |

## ⛔ The 1 case needing HUMAN adjudication
**e5_transportability_01** — both reviewers agree primary = E5 and both REJECT transportability, but disagree on the level:
- research_critic → **L2** ("within OASIS the model reaches AUROC 0.70 — internal predictive performance only; no transport claim").
- professor → **L0** ("no transport claim supportable; OASIS-only bounds only OASIS internal performance").
- The conflict is whether an OASIS-only AUROC licenses an *internal-predictive* (L2) statement or should be held at *no-transport* (the question was specifically about transport). Provisional conservative = **L1** (within-cohort association; no transport, no strong predictive claim). **Human decides L0 / L1 / L2.**

## Two LOCKED_CONSERVATIVE cases for optional human confirmation
- **e1_covariate_omission_01**: level agrees (L1.5); primary research_critic=E2 vs professor=E1 (same covariate-baseline family; allowed claims identical = negative incremental). Adopted primary **E1**, secondary E2.
- **e8_unsupported_biomarker_02**: primary E8 both; level L1.5(rc)/L1(prof) → adopted **L1.5** (more restrictive).

## Step 2.6d/e — HUMAN SIGN-OFF (2026-06-19) → 30/30 LOCKED
Human decisions:
- **e5_transportability_01 → LOCK at L1** (`LOCKED_HUMAN_ADJUDICATED`). gold_claim_level=L1 (within-cohort
  association only); `transportability_claim_level = L0_FORBIDDEN`. Rationale: OASIS-only AUROC supports a
  limited within-cohort association, but L2 would over-emphasize internal predictive performance for a
  transportability trap and L0 is too strict (a calibrated within-cohort statement remains allowed). Explicit
  allowed/forbidden/required recorded in `claimtrap30_gold.jsonl`.
- Accepted the 27 reviewer-agreement locked cases, the 2 LOCKED_CONSERVATIVE (e1_01 primary=E1/secondary=E2;
  e8_02 conservative L1.5), and the 6 draft→gold corrections.

**Final: 30/30 LOCKED, `scoring_allowed=true` on all.** Locked gold = `claimtrap30_gold.jsonl`.

### Validation (Step 2.6e) — ALL PASS
- 30/30 LOCKED · scoring_allowed=true only after lock (30) · taxonomy preserved (E1:4 E2:4 E3:4 E4:4 E5:4 E6:3 E7:5 E8:2)
- no leakage in agent-visible inputs · no draft labels in review inputs · e5_01 records transportability=L0_FORBIDDEN + gold L1.

Next: v2 LLM scoring may now run on the locked 30-case gold (generic vs verification-aware). Gemini/provider
comparison remain on hold until the locked gold has been exercised once and validated end-to-end.
