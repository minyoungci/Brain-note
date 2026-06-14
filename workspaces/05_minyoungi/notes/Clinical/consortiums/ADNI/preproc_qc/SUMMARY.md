# ADNI — preprocessed-tensor QC

Sessions QC'd: **4742**  |  PASS **4742**  WARN **0**  FAIL **0**

Re-opened on-disk files: `final_tensor[_n4]` + `final_mask[_n4]` (192x224x192, RAS, 1mm). Checks: geometry / finite / binary-mask / in-mask z-score(mean~0,std~1) / out-of-mask~0 / brain-vol / tensor<->mask coincidence / N4-vs-raw mask Dice / cross-session duplicate hash.

_Verifies the files are physically sound & internally consistent. Does NOT verify anatomical correctness — a consistent L/R flip of both tensor+mask (affine intact) or plausibly-normalised non-anatomy is out of scope here._

- raw in-mask mean: min=0.000 median=0.000 max=0.000
- raw in-mask std: min=1.000 median=1.000 max=1.000
- N4 in-mask mean: min=-0.000 median=0.000 max=-0.000
- N4 in-mask std: min=1.000 median=1.000 max=1.000
- raw brain vol (ml): min=913.200 median=1323.350 max=1843.900
- raw tensor<->mask Dice: min=1.000 median=1.000 max=1.000
- N4 tensor<->mask Dice: min=1.000 median=1.000 max=1.000
- mask Dice raw vs N4: min=0.972 median=0.984 max=1.000
