# Preprocessed-tensor QC — duplicate-session findings

_From `preproc_qc.py` content-hashing over all 13,022 QC-passed sessions
(2026-06-14). 4 pairs of sessions have **byte-identical** preprocessed tensors.
Root cause traced to source; verdict below._

## What was found

Cross-session blake2b hashing of every `final_tensor` and `final_tensor_n4`
returned **4 collisions** (8 sessions). All four reproduce in BOTH the raw and
the N4 tensor, and were confirmed byte-identical with `md5sum`.

| pair | type | preprocessed md5 (N4) |
|---|---|---|
| AJU `ABD-BS-0013/V1` ≡ `ABD-BS-0014/V1` | **cross-subject** | `d97f26ec…` |
| AJU `ABD-AJ-0029/V2` ≡ `ABD-AJ-0030/V1` | **cross-subject** | (identical) |
| OASIS `OAS30527/d0000` ≡ `OAS30527/d0006` | same-subject | `9f098555…` |
| OASIS `OAS30422/d0099` ≡ `OAS30422/d0104` | same-subject | (identical) |

## Root cause — NOT a preprocessing bug

The pipeline is deterministic, so identical input → identical output is the
*correct* behaviour. Traced each pair back to its source:

- **AJU (cross-subject).** The native inputs `native_t1w_hdbet.nii.gz` are
  byte-identical md5 across the two subject IDs (`893eeadf…` for BS-0013≡BS-0014;
  `22e3bd8c…` for AJ-0029≡AJ-0030). → **The same raw T1 scan is enrolled under
  two different subject IDs** (upstream AJU data-entry duplication).
- **OASIS (same-subject).** The two raw files differ in bytes (different
  header/compression) but the **image arrays are identical** (`np.array_equal ==
  True`, max abs diff 0.0; both 176×240×256). → **The same acquisition exported
  under two session/day labels** within one subject.

So all 8 files are physically sound (they PASS every geometry/finite/normalisation
check); the issue is **dataset integrity / redundancy**, not corruption.

## Impact

- **AJU cross-subject pairs = train/test LEAKAGE risk.** Subject-level
  splitting does *not* catch these — the two members have different
  `subject_id`s but the identical image. If one lands in train and its twin in
  test, the model "sees" the test image during training → optimistic bias.
- **OASIS same-subject pairs = inflated session count + spurious zero-change.**
  Subject-level splitting already keeps them together, so no leakage; but a
  longitudinal "d0000→d0006" (or "d0099→d0104") delta is spuriously zero, and
  per-session counts double-count one scan.

## Recommendation (no data altered — needs owner decision)

1. **Before any split**, collapse each pair to one canonical session. For the
   AJU cross-subject pairs this is mandatory to avoid leakage; for OASIS it is
   cosmetic but advisable.
2. Add a `dup_group` / `is_duplicate` column to the manifest (do **not** delete
   raw data) so downstream code can drop or co-locate duplicates deterministically.
3. Re-confirm with the AJU source whether BS-0013/BS-0014 and AJ-0029/AJ-0030 are
   genuine re-enrollments or a labeling error.

Reproduce: `python Clinical/common/preproc_qc_rollup.py` (lists collisions with
CROSS-SUBJECT vs same-subject tags); md5/array evidence in this session's log.
