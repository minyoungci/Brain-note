# Review Pass 22: Protocol-Group Downstream Gate

Date: 2026-07-01 UTC

Scope:

```text
Flagship/v2_jepa/code/eval_jepa_downstream_probe.py
downstream/eval_global.py
Flagship/v2_jepa/results/downstream_probe/SUMMARY.md
```

## Reason

The previous JEPA downstream gate used random subject-disjoint folds. That is useful, but it is too weak for the active goal: a confound-robust 3D Brain-JEPA foundation model.

The downstream data tree does not expose true scanner/site IDs. Therefore this pass adds a stricter proxy split:

```text
protocol_group = actual modality variant + raw NIfTI shape + raw voxel spacing
```

This directly attacks sequence-protocol, FOV, and resolution shortcuts. It is not a full replacement for scanner/site-held-out validation.

## Implementation

Added to `eval_jepa_downstream_probe.py`:

```text
--split random|protocol_group
--group_by protocol|shape_spacing|modality_variant
--group_k
```

The same group-heldout probe is wired into `downstream/eval_global.py` so S3D+InfoNCE wg0.5 and A17 can be compared under the same split.

Important cache fix:

```text
cache validation now checks modality-file existence only
instead of calling core.load_modalities()
```

This prevents cached downstream probes from accidentally re-running slow yucca preprocessing.

## Validation

Static validation:

```text
python -m py_compile \
  Flagship/v2_jepa/code/eval_jepa_downstream_probe.py \
  downstream/eval_global.py
```

Unit tests remained green:

```text
python Flagship/v2_jepa/code/tests/test_brain_jepa.py
Ran 16 tests OK
```

## Result

Protocol-group heldout on Task1 and Task5:

| Branch | Task1 AUROC | Task5 AUROC | Decision |
|---|---:|---:|---|
| A17 adv `0.10` shared+morph | 0.8173 | 0.8976 | no protocol collapse, but no S3D win |
| S3D+InfoNCE wg0.5 | 0.8269 | 0.9010 | effectively tied |

Task3 cannot be evaluated with this local protocol split:

```text
all Task3 subjects have one group:
  t1w, 176x256x256, 1.0x1.0x1.0
```

## Verdict

A17 remains the best JEPA research candidate, but the stronger gate prevents overclaiming:

```text
source-probe: A17 much better than S3D
random downstream: A17 strong
protocol-group downstream: A17 roughly tied with S3D
```

So the next architecture must not be selected by source-probe alone. It must pass:

1. source-probe,
2. random downstream probe,
3. protocol/FOV heldout downstream probe,
4. later true site/scanner-held-out validation when metadata or external data is available.

## Next

Do not keep sweeping A17 adversarial weights. The next candidate needs a richer structural target:

```text
atlas/ROI/tissue context prediction
paired T1/FLAIR/DWI consistency
source/site-held-out selection when metadata exists
```
