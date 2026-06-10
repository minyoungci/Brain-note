# Track 01 — ADLIP식 Multimodal Contrastive VLM ⭐ 현재 진행

## 목표
3D 멀티모달 뇌영상(T1w + FLAIR + amyloid PET SUVR) ↔ 임상 프로파일 텍스트를
contrastive(InfoNCE)로 정렬하는 ADLIP식 VLM. zero-shot/linear-probe로 dx·amyloid 평가.

## 데이터 (준비 완료)
- 페어: `../../Clinical/consortiums/Korean/korean_vlm_pairs.parquet` — **train_ready 1,408**
  (AJU 962 / KDRC 446), 3영상경로 실존 100% + 텍스트 3변형 + 라벨.
- 텍스트: 영어 임상프로파일, 영상유래·dx·코호트ID·척도명 제외(누수 라벨레벨 차단 검증).
- 영상: 192³ 동일 grid, brain-extracted. PET=SUVR(whole-cereb).

## ⚠️ 이 track의 정직한 위험 (측정 확정 — 무시 금지)
1. **양 modality 코호트 누설** (텍스트 0.999 / 영상 0.747) → InfoNCE가 질병 아닌 코호트 정렬 위험.
2. **영상-텍스트 중복** (둘 다 치매로 수렴), **amyloid엔 영상 ~0**.
3. CN 소수(train_ready 142), AJU 편중(962:446).

→ 그래서 이 track은 **"정확도 자랑"이 아니라 "무엇이 정렬되나"를 정직하게 측정**하는 방식으로 진행.
   01의 결과(특히 정렬 후 코호트 probe)는 그대로 [Track 02 audit]의 증거가 된다.

## 필수 통제 (설계에 내장)
- **cohort-balanced batch sampling** (배치당 AJU:KDRC 1:1) — 코호트가 쉬운 negative 안 되게.
- **honest metric = ΔAUC over clinical-only baseline** (절대 AUC 금지; APOE/MMSE가 대리누수).
- **pre/post-alignment cohort probe** — 정렬이 코호트를 흡수하는지 정량.
- **LOCO**(held-KDRC) + within-cohort 양쪽 보고.
- amyloid 평가는 **PET held-out(구조만)** + 임상통제 ΔAUC.

## 설계 (TODO)
- [ ] 멀티모달 영상 인코더: 모달별 3D 인코더 → late fusion (PET는 SUVR 분포 별도 norm). T2는 미포함(anisotropic).
- [ ] 텍스트 인코더: Bio_ClinicalBERT (frozen→fine-tune).
- [ ] InfoNCE(temp 0.07) + (옵션) multi-teacher KD.
- [ ] 학습 스크립트 (GPU·bf16·사전승인 사안).
- [ ] 평가 프로토콜(위 통제) + cohort-probe 게이트.

## 선결 (GPU 전)
- 인코더 입력 호환성(192³) 확인 + **CPU cohort-probe baseline 재확인**(이미 0.999).
- 학습은 core_complete(MMSE+APOE+공존질환) 우선.

상태: 데이터·텍스트 완료. **다음 = 멀티모달 인코더 설계.**
