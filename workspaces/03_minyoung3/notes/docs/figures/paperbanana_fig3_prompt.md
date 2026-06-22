# Figure 3 — Claim Safety Controller (algorithm flow diagram)

Publication-quality academic methodology flow diagram for an AAAI-style paper. Vertical top-to-bottom flow.
Clean, minimal, professional, WHITE background, flat vector style, readable at single-column width. No photographs,
no medical imagery — this is an algorithm diagram.

TWO visually distinct block styles + a small legend:
- LLM blocks: light blue, rounded corners — label "LLM (propose / rewrite)"
- Deterministic code blocks: light grey, sharp rectangles — label "Deterministic code"

Vertical flow with downward arrows:
1. [grey] Structured artifact A   (input)
2. [BLUE] LLM propose -> candidate claim c0
3. [grey] Deterministic evidence extraction -> e
4. [grey] Verifier modules E1-E8 fire on e
5. [grey] Claim ceiling  L*(e) = strictest cap
6. [grey, decision diamond] Over-claim detect:  lambda(c0) > L*(e) ?
7. [grey] Ceiling-dependent routing  -> two main labeled branches:
       - "L0  ->  HARD BLOCK"
       - "L1+  ->  semantic-preserving rewrite"  (this rewrite box is BLUE = LLM)
   and two minor branches: "clean -> pass-through", "high-confidence forbidden -> reject -> rewrite -> fallback"
8. [grey] Strict enforcement  (explicit multi-word, negation-aware)
9. [grey] Final claim + claim level L* + verifier trace   (output)

RIGHT-side boxed inset titled "Trace example (e2_03)":
   delta-AUROC = +0.04 ; n = 300 ; features = 40 ; nested CV = no ; paired delta-CI = absent
   --> E2 module fires
   --> ceiling = L1.5
   --> "positive increment" wording rejected

Visual message: the LLM only proposes and rewrites; the safety decision (extraction, verifiers, ceiling, routing,
enforcement) is deterministic, auditable code.
