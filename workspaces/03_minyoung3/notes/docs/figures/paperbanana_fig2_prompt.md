# Figure 2 — Dual-view benchmark & gold-leak correction  (modern infographic redesign)

STYLE: modern, clean **flat infographic** for an AAAI paper. Icon-driven, generous whitespace, rounded panels
with subtle (very light) shadow, a restrained 3-color palette (neutral grey/ink + one warm warning tone +
one calm teal/green). Flat vector only — NO 3D, NO neon, NO gradients-on-white, NO decorative clutter, NO brand
logos, NO emoji. Convert sentences into short labels + icons. Professional, not flashy.

ICONS (flat, monochrome, line-style):
- AGENT = a simple robot-head glyph.  - JUDGE = a balance-scale glyph.  - GOLD = a key + small document glyph.
- a brick-wall / shield glyph for the barrier.  - a checkmark-in-shield for the scan.
(No company logos. Agent and Judge are different glyphs to stress they are different models.)

TWO rounded panels side by side, divided by a thin vertical rule.

LEFT panel — small header chip "Before · confounded" (warm warning tone):
- A "verification prompt" card that visibly CONTAINS a GOLD key+document icon labeled "gold: claim level /
  forbidden / required checks".
- A bold arrow from that card INTO an AGENT (robot) glyph, with a small "reads the answer key" tag on the arrow.
- The agent turns into a warning-tone chip: "answer-aware".
- End chip: "confounded evaluation".
- One short caption under the panel: "case gold in the prompt -> agent becomes answer-aware".

RIGHT panel — small header chip "ClaimTrap30 · dual-view (leak-free)" (calm teal/green tone):
- TWO clean horizontal lanes:
  - Lane 1: a document icon "generation_view — neutral artifact, no gold"  --arrow-->  AGENT (robot) glyph
    labelled "Agent  ·  Sonnet 4.6".
  - Lane 2: a GOLD key+document icon "scoring_view — gold claim / forbidden / ceiling"  --arrow-->  JUDGE
    (balance-scale) glyph labelled "Judge  ·  GPT-5.5".
- A vertical WALL/BARRIER glyph between the gold (lane 2) and the agent (lane 1), making clear gold never reaches
  the agent (no crossing arrows).

BOTTOM ribbon spanning both panels: a checkmark-shield icon + "Zero-gold-token scan: PASS — 0 gold tokens in any
agent prompt".

Message in one read: a verification-aware agent becomes answer-aware ONLY if per-case gold enters its prompt; the
dual-view split makes that structurally impossible. Label the right side "leak-free", never "first".
