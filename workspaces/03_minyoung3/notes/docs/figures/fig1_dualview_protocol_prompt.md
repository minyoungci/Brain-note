# Figure 1 — Dual-view evaluation protocol (ClaimTrap-AD)

Clean FLAT academic vector schematic (NOT photorealistic, no 3D, no shadows). Horizontal
left-to-right flow. Colorblind-safe palette. Minimal text. Render every label EXACTLY as
written below (no paraphrasing, no extra words). Landscape aspect ~16:9.

## Nodes and flow (left to right)

1. LEFT — a single rounded box: "Structured analysis artifact" (subtitle: neuroimaging result).

2. The artifact splits into TWO stacked panels (top and bottom):
   - TOP panel, BLUE, header "Generation view (agent-visible)".
     Bullet list inside: "task text", "structured metrics", "provenance", "focus question".
   - BOTTOM panel, RED, with a small padlock/lock icon, header "Scoring view (judge-only, held-out)".
     Bullet list inside: "gold claim ceiling (L0-L2)", "allowed claim", "forbidden assertions",
     "out-of-cohort replication evidence".

3. MIDDLE — a SOLID arrow from the TOP (Generation view) panel ONLY into a box
   "Medical research agent (LLM)". From that box, a solid arrow to a box "Natural-language claim".
   (No arrow from the Scoring view to the agent.)

4. RIGHT — a box "Non-self LLM judge" receives TWO inputs: a solid arrow from "Natural-language
   claim" and a solid arrow from the BOTTOM (Scoring view) panel. From the judge, a solid arrow to
   a final box "Over-claim / calibration score vs ordinal ceiling".

5. A long horizontal DASHED barrier line running between the agent/claim path (above) and the
   Scoring view (below), labeled: "no leakage: agent never sees scoring view".

## Emphasis
The agent path uses ONLY the blue Generation view. The red Scoring view goes ONLY to the judge.
Visually separate the two views with the dashed barrier.
