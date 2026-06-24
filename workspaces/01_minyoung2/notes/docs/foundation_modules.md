# FOMO26 Foundation Model — module-by-module data flow

각 모듈에서 3D brain MRI 데이터가 어떻게 처리되는지 단계별 figure. (paperbanana 생성, 코드 정합.)
전체 개요는 `figures/foundation_model_detailed.png`(정밀 단일도), 흐름 요약은 `figures/pipeline_resenc_s3d.png`.

## ① 입력 & 두 뷰 — Input & views
원본 MRI → offline 전처리(skull-strip·1mm resample·z-norm·float16 .npy) → online(load→random 96³ crop→z-norm) → v1, v2.
![입력](figures/modules/mod_01_input_views.png)

## ② 블록 마스킹 — Block masking
v1을 16³ voxel 블록으로 나눠 ~60% 숨김 → masked v1 (1×96³) + visibility mask m. 숨긴 영역이 MAE 복원 타깃.
![마스킹](figures/modules/mod_02_block_masking.png)

## ③ ResEnc-L 인코더 (submanifold) — Encoder
stem(1→32) → Stage1~5 [32×96³ → 64×48³ → 128×24³ → 256×12³ → 320×6³]. 각 stage 후 hidden voxel re-zero(submanifold) + mask 다운샘플 → 누수 없이 skip 사용 가능.
![인코더](figures/modules/mod_03_encoder_submanifold.png)

## ④ S3D-style dense decoder (MAE) — Reconstruction
bottleneck 320×6³ → ConvTranspose3d+ResBlock ×4 (skip Stage1~4: 256×12³/128×24³/64×48³/32×96³) → recon head(32→1) → 복원 1×96³. L_dense = masked-voxel MSE.
![디코더](figures/modules/mod_04_s3d_decoder.png)

## ⑤ SimPool + projection head — Global vector
bottleneck(216 tokens×320) → SimPool(MHA+LayerNorm) → global vec 320 → projection head(DINO-style MLP 320→2048→2048→256 → L2-norm → prototype 1024).
![SimPool](figures/modules/mod_05_simpool_head.png)

## ⑥ InfoNCE + EMA teacher — Global objective
student(v1) proj ↔ EMA-teacher(v2, m=0.996, decoder 제외) proj → InfoNCE(in-batch, temp 0.1; negative로 붕괴 차단) → L_global.
![InfoNCE](figures/modules/mod_06_infonce_ema.png)

---
**Total**: L = w_dense·L_dense + w_global·L_global + 0.1·KoLeo → 단일 SSL ckpt → 7 downstream (Task1–5 finetune[seg×2 50%·cls×2·reg], Task6 linear probe, Task7 fairness).
재현: `figures/draw_foundation_arch.py`(정밀 단일도), 모듈 프롬프트 `/tmp/pbmod/*.md`.
