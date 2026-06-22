# Figure 1 — Problem setup: artifact -> unsupported claim  (modern infographic redesign)

STYLE: modern, clean **flat infographic** for an AAAI paper. Icon-driven, generous whitespace, rounded cards with
very light shadow, restrained 3-color palette (neutral ink/grey + warm red for "wrong" + calm green for
"calibrated"). Flat vector only — NO 3D, NO neon, NO gradients, NO decorative clutter, NO brand logos, NO emoji,
NO brain/medical imagery. Replace sentences with short labels + small icons. Professional, not flashy.

ICONS (flat, monochrome, line-style): AGENT = simple robot-head glyph; up-tick mini-chart; clock; price-tag;
lab-flask/control; red ✗ badge; green ✓ badge.

LAYOUT — left-to-right pipeline across the top two-thirds:

1. A rounded card "Analysis artifact". INSIDE it, render the four risk factors as four small ICON CHIPS (not a
   bullet list), each = icon + 2-3 word label:
     [up-tick chart] "small AUROC gain +0.04"
     [clock] "temporal ambiguity"
     [price-tag] "label provenance"
     [flask] "negative control"
   --arrow-->
2. An AGENT (robot-head) glyph card labelled "Generic agent".
   --arrow-->
3. A warm-red alert card "Unsupported biomarker claim" (clearly marked as the error: red, with a small ✗ badge).

RIGHT third — a vertically stacked CONTRAST, two cards:
- Red card, header "✗ Wrong":  "improves discrimination"  /  "rules out scanner confounding"
- Green card, header "✓ Calibrated":  "gain not credible without nested validation"  /  "bounds only the measured
  site-label axis"

BOTTOM — a slim worked-example strip: a chip "site-only AUROC = 0.497 (chance)" with two short branches:
   ✗ "scanner confounding ruled out"   vs   ✓ "measured shortcut unsupported; feature-level effects still possible"

Message in one read: weak/confounded artifacts get inflated into strong biomarker claims; the correct output is a
LOWER claim. This is claim calibration, NOT biomarker discovery. Keep all "wrong" items visibly marked as errors
(red / ✗), never as results.
