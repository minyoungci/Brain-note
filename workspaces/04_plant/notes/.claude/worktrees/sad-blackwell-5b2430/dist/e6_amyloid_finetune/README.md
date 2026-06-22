# T1 → biomarker: pretrained 3D-encoder fine-tune comparison

Fine-tunes two released pretrained 3D brain-MRI encoders on a T1w → **binary label**
(e.g. amyloid +/−) and compares them to a hand-crafted FreeSurfer-volume (fs_vol) baseline,
fully leakage-controlled. Runs on any machine with a CUDA GPU.

- **BrainIAC** (HuggingFace `eugenehp/brainiac`, ViT-B 96³ SimCLR)
- **AMAES** (Zenodo, U-Net 128³ 1mm; encoder vendored in `amaes_encoder.py`)

## Honest expectation
On amyloid-like targets, a learned encoder typically **TIES** regional volumetry (~AUC 0.70).
A large clean win over fs_vol at N~1000 is a **leakage signal**, not a discovery — the script
prints a `LEAKAGE-AUDIT` flag if ΔAUC CI excludes 0 in the encoder's favor.

## Setup
```bash
pip install -r requirements.txt
python download_weights.py          # BrainIAC (HF, ~353MB) + AMAES (Zenodo, ~70MB) -> weights/
```

## Data
A parquet/csv manifest, ONE row per subject, with at least:
- a column of absolute paths to T1w NIfTI files (`--tensor-col`)
- a binary label column (`--label-col`; accepts 0/1 or positive/negative)
- optional: FreeSurfer volume columns sharing a prefix (`--fsvol-prefix`, default `fs_vol`) +
  an ICV column (`--icv-col`) for the hand-crafted baseline.

## Run
```bash
python finetune.py --manifest table.parquet --tensor-col t1_path --label-col amyloid \
    --fsvol-prefix fs_vol --icv-col fs_BrainSegVol --model both --folds 5 --epochs 30 --out out/
# or: MANIFEST=table.parquet LABEL_COL=amyloid ./run.sh
```
Smoke test: add `--smoke 1` (60/class, fast).

## Method (leakage controls)
- subject-level StratifiedKFold; inside each train fold a held-out val split for early stopping
  (never the test fold); per-volume z-score (no cross-subject leakage).
- partial fine-tune (last encoder block + linear head), AdamW (backbone 1e-5 / head 1e-3), bf16.
- fs_vol baseline = L2-logistic, same subjects/folds; paired ΔAUC bootstrap (B=2000).

Output: `out/results.json` with per-model AUC and ΔAUC-vs-fs_vol [95% CI].
