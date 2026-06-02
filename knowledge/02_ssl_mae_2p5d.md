# 02 · 2.5D MAE self-supervised 표현학습 (F04)

_minyoung3의 핵심 축. 라벨 없이 표현을 배우려는 시도. 아직 백본 미학습._
_출처: minyoung3 README, reports/F04_*. (2026-06-02)_

## 1. 2.5D란 무엇인가 (3D도 2D도 아닌)

- **2D**: 슬라이스 1장. 3D 맥락 상실.
- **3D**: 볼륨 전체. 정확하지만 메모리·연산 폭발(EXP01에서 full-res 3D CNN이 >28분/epoch로 비실용).
- **2.5D**: **얇은 slab**(인접 슬라이스 몇 장)으로 3D 맥락 일부를 싸게 얻는 절충.
  - F04 정의: 5-slice axial slab `[z-2, z-1, z, z+1, z+2]` 입력.

## 2. MAE (Masked Autoencoder) SSL objective

- **자기지도학습(SSL)**: 라벨 없이 입력 자체에서 학습 신호를 만든다.
- **MAE**: 입력 패치 일부를 **마스킹**하고, 모델이 가린 부분을 **복원**하게 한다(ViT 기반).
- **F04 objective**: 5-slice slab을 받아 **center slice z의 masked brain patch를 복원**.
  → 인접 슬라이스 맥락으로 가운데 슬라이스의 가린 뇌 영역을 메우게 함.

## 3. ROI-informed 보조경로 (technical novelty 층)

- 단순 masked reconstruction은 novelty가 아니다. F04의 방어 가능한 novelty는:
  1. **엄격한 multi-consortium 2.5D SSL corpus** 구축
  2. **center-slice masked recon + subject-level split 규율**(누수 차단)
  3. **ROI-informed token/prompt/crop 보조경로** (단, ROI는 **fail-closed QC** 하에서만)
  4. official **CDR/CDR-SB/progression probe를 unlabeled SSL corpus와 분리**
  5. shortcut controls: cohort-only, ROI-volume-only, clinical-only, 2D-only, 2.5D-no-ROI

## 4. ⚠️ 경계선 (README가 못박은 것 — 넘으면 과장)

- **recon loss가 임상 표현 품질을 증명하지 않는다.** 복원 잘 한다 ≠ 치매 신호 담는다.
- **Visual-QC PASS만으로 ROI 해부학적 완벽을 주장 금지.** PASS는 trainability/policy 층일 뿐.
- **옛 full 3D voxel / PET-transfer 방향 부활 금지.**
- `/home/vlm/data`는 read-only — 쓰기 금지.

## 5. 현재 상태 (냉정하게)

- 🟡 MAE 백본은 **pilot/scaffold만, full-train 0회**. DDP trainer는 있으나 대규모 미검증.
- ✅ 검증된 신호는 **ROI evidence 회귀뿐**: ventricle(환실) R²≈0.64 강, hippo/MTL 약(R²≈0.19).
- ❌ downstream probe는 전부 삭제(스크립트는 생존). novelty 미확정.
- ⚠️ **git 없음** → 대규모 삭제가 비가역. 표현 품질 증거 부재.

## 6. EXP01 교훈의 적용

minyoung3가 SSL로 좋은 표현을 배웠다 해도, **반드시 5-ROI volumetry baseline·LOCO·multi-seed로
검증**해야 한다(→ `01_loco_transport.md`). recon loss나 within-cohort probe만으로는 부족하다.
