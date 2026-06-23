# Mask Taxonomy Audit Plan

## Purpose

G-SURE depends on segmentation masks as supervision. Before modeling, we must
verify what each mask file means across all sources.

## Questions

For every dataset and segmentation file type:

1. What anatomical/biological region does this mask represent?
2. Is it whole tumor, tumor core, enhancing tumor, edema, total cellular tumor,
   or another derived region?
3. Is the mask binary or multi-label?
4. What label integers appear in the mask?
5. Does the mask shape match the selected structural MRI?
6. Does the mask affine match the selected structural MRI?
7. Are any masks cropped, empty, all-zero, or zero-byte?

## Required Outputs

Create a table with one row per segmentation file key:

```text
dataset
package
file_key
candidate_semantic_region
binary_or_multilabel
observed_label_values
expected_shape_policy
requires_resampling
known_blockers
recommended_use
```

## Candidate Unified Targets

Possible official segmentation targets:

1. Whole tumor.
2. Edema-inclusive lesion.
3. Tumor core.
4. Enhancing tumor.
5. Binary union of all available tumor labels.

For the first G-SURE protocol, prefer the target with:

- highest all-consortium coverage,
- clearest semantic consistency,
- lowest geometry/mask ambiguity,
- clinically interpretable failure regions.

## Hard Blockers

- Any source-specific mask that cannot be mapped to the official target.
- Incompatible cropped mask without a reliable affine or reconstruction rule.
- Ambiguous label values.
- Silent exclusion of masks without audit row.

