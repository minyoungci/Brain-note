# Korean Amyloid 멀티모달 예측 — 연구 문서 (통합본)

> KDRC+AJU(Korean) 코호트로 **PET 없이 MRI+임상으로 amyloid 양성을 예측**하는 연구의 설계 정리.
> 작성 2026-06-11 (Min 요청으로 4개 초안을 하나로 통합). 설계 lock 전. 실험 수행·최종 결정은 Min.
>
> **이 폴더의 기존 자산 위에서 읽을 것:** `korean_multimodal_manifest.(csv|parquet)`,
> `korean_clinical_subject_level.*`, `korean_clinical_text.*`, `korean_vlm_pairs.*`,
> `USAGE_ROADMAP.md`, `build_korean_*.py`. 본 문서는 그 자산을 **amyloid 예측 task 관점**으로 정리한 것.

---

## 0. MISSION

값싼 구조 MRI(T1, +FLAIR)와 임상/혈액 정형 데이터만으로 **비싸고 접근성 낮은 amyloid PET 없이
amyloid 양성을 예측**한다. 핵심 질문은 "멀티모달이 좋다"가 아니라
**"이미지(MRI)가 강한 정형 baseline(특히 APOE·임상·labs)을 *유의하게 incremental*하게 넘느냐"**.
넘지 못하면 그것이 결과다(정형만으로 충분하다는 정직한 음성).

> 가장 큰 함정: **PET = 라벨의 출처이지 입력이 아니다.** amyloid PET로 amyloid를 예측하면 circular.
> 입력에 `amyloid_suvr`/`pet_*`를 절대 넣지 않는다.

**임상 가치:** PET은 비싸고 한국 임상 접근이 제한적 → MRI+labs로 선별 예측하면 PET 의뢰 대상을 좁히는
실제 도구가 된다. null이어도 "MRI는 amyloid 선별에 부족하다"는 정직한 결론으로 의미.

---

## 1. 왜 이 라인이고, 어디서 깨지는가

깨질 지점(전부 정량 게이트로 통제):
1. **APOE가 다 해버린다.** APOE-e4는 amyloid의 강력한 예측자. 멀티모달 모델이 이미지 무시하고
   APOE/tabular만 학습할 수 있다. → image-only / tabular-only / APOE-only / fusion **ablation 의무**.
2. **PET 라벨 누수.** `amyloid_suvr`·`pet_suvr_*`는 라벨과 같은 측정 → 입력 금지(§5).
3. **Single-population(Korean only).** cross-population 일반화 주장 불가 → "Korean 코호트 멀티모달"로
   정직히 프레이밍. KDRC와 AJU는 성격이 다르니(아래) **코호트별 보고**.
4. **라벨 출처 미검증.** AJU dx는 raw 재현 불가([VERIFY]), KDRC 진단 권위 모순 기록.
   amyloid_visual의 코호트별 정의(AJU 1=정상/2=비정상, KDRC visual read 기준)를 먼저 검증 후 사용.
5. **N·불균형.** 사용 가능 라벨 ~1,820. 딥 멀티모달 fusion은 과적합 빠름. 정형은 sample-efficient
   → image+tabular fusion이 deep-image-only보다 안전.

선행 참고: minyoungi `notes/research_tracks/{01_adlip_multimodal_vlm, 04_vascular_vs_degenerative}`,
이 폴더 `USAGE_ROADMAP.md`·`korean_vlm_pairs.*`(이미 image-text/VLM 방향 자산 존재). 평가 프로토콜은
minyoung2 EXP01 "incremental value over baseline" 계승.

---

## 2. DATA (실측)

**Manifest:** `/home/vlm/data/preprocessed_official/korean_multimodal_manifest.parquet` (+ .csv)
= 이 폴더 사본과 동일. read-only(원본 `/home/vlm/data` 쓰기 금지).

- **2,196 세션 = KDRC 909(909 subj, 단일세션) + AJU 1,287(1,001 subj, 다세션)**.
- modality: has_t1w 100% · has_flair 98%(2,148) · has_pet 86%(1,882) · **multimodal_full(T1+FLAIR+PET) 1,836**.

**LABEL (출처 = PET; 입력 아님):**
- 1차: `amyloid_visual` ∈ {positive 797 / negative 1,023 / NA 376} → **사용 N≈1,820, 양성 44%(균형)**.
- 2차(연속): `amyloid_suvr`. 회귀/임계 분석용. **둘 다 입력 금지.**

**INPUT (멀티모달 = 구조 MRI + 정형):**
- 이미지: `t1w_final_path`(+mask) — 192×224×192 전처리 텐서. 선택 `flair_final_path`(98%). **PET 경로 입력 금지.**
- 정형: `apoe_genotype`/`apoe_e4_count` · `clin_mmse`/`mmse_baseline` · `education_years` · `gds_total` ·
  `age`/`sex` · labs(`hba1c` `ldl` `hdl` `tchol` `tg` `glucose` ~82%) · `dm`/`htn`/`dyslipidemia` ·
  `sbp`/`dbp`/`bmi` · `wmh_grade_visual`/`fazekas_pv`/`fazekas_deep`(저커버 13%).

**보조/계층화:** `cdr_global`/`cdr_sb_baseline` · `dx_3class`(MCI 1010·Dementia 293·AD 221·CN 195·OtherDementia 102; **라벨 아님**).

**코호트 성격(다름 → 코호트별 보고):**
- KDRC: 이미징 멀티모달 강함(T1·FLAIR·PET·T2·DWI), 임상 중간(MMSE/APOE/amyloid ~52-58%).
- AJU: 정형/임상 강함(MMSE·APOE·education·GDS·labs 99-100%), 이미징은 T1(+FLAIR) 중심.

---

## 3. SUCCESS — 정량 게이트

- **G1 (멀티모달 증분):** fusion(이미지+정형) AUROC가 **best 단일모달(APOE-only·tabular-only·image-only)
  대비 paired bootstrap CI가 0을 배제**하는 incremental 향상. subject-level CV, multi-seed.
- **G2 (이미지가 진짜 기여):** image-only AUROC > chance **그리고** fusion > (tabular+APOE).
  G1만 통과·G2 실패면 "정형이 다 한 것".
- 코호트별(KDRC/AJU)+pooled 보고. **null도 1차 결과.**

판정: G1∧G2 → MRI가 amyloid 선별에 멀티모달로 기여. G1∧¬G2 → 정형(APOE/labs)이 본질, MRI 불필요.
¬G1 → 어느 모달도 amyloid를 충분히 못 잡음(MRI+임상 한계 보고).

---

## 4. PHASED PLAN (kill-criteria 포함)

**P0 — 라벨·누수 audit (학습 없음, 대부분 CPU).**
amyloid_visual의 코호트별 정의·출처 검증(AJU 1/2 매핑, KDRC visual 기준), suvr↔visual 일관성, NA 376 구조.
누수 지도(amyloid_suvr/pet_* 격리, dx/cdr와 amyloid 얽힘). 단일모달 예측력 즉시 측정(APOE-only/tabular-only/image-only).
NO-GO: amyloid_visual이 코호트 간 비교 불가로 판명되면 라벨 재정의 먼저.

**P1 — 강한 단일모달 baseline lock.** APOE-only 로지스틱 · full-tabular GBM · image-only(T1; +FLAIR) CNN.
subject-level split, multi-seed. G1/G2 임계 숫자 고정. NO-GO: split 누수 단위테스트 통과 전 P2 금지.

**P2 — 멀티모달 fusion arms (동일 게이트로 경쟁).** A: image(T1)+tabular late fusion · B: +FLAIR ·
C: intermediate/attention fusion · D(대조): tabular-only. subject-level CV, multi-seed, 코호트별.
NO-GO: Arm이 D 대비 G1 유의 개선 못 하면 폐기·ledger 기록.

**P3 — 증분 판정 + ablation(leave-one-modality-out).** fusion vs 각 단일모달 paired CI, 이미지 기여를
leave-image-out로 격리. §3 판정 규칙. NO-GO: 단일 seed·단일 fold 성공을 결과로 쓰지 않는다.

**P4 — (전방) 해석·calibration.** region/모달 기여, calibration, PET 의뢰 선별 임계.

---

## 5. HARD CONSTRAINTS / ANTI-GOALS

- **라벨 누수 금지:** 입력에 `amyloid_suvr`·`pet_*`·라벨 파생 컬럼 절대 금지. APOE는 합법 입력이나 **ablation으로 격리**.
- **subject-level split**(AJU 다세션 — 같은 subject train/test 양쪽 금지), **multi-seed**, **validation-lock**(in-dist val 성공 주장 금지), 코호트별 보고.
- bf16 필수(fp16 금지, B200), RAM 1TB 상한. 산출물은 작업 디렉토리 내, `/home/vlm/data` 쓰기 금지.
- single-population 정직 프레이밍. PET 입력 금지(circular). ablation 없이 "멀티모달이 좋다" 주장 금지.
- 근거 약하면 `[VERIFY]`/`[불확실]`. 생성과 검증은 분리된 단계. null도 결과.

**연구 태도(권고):** 긍정 결과일수록 더 의심(누수·APOE·single-seed). NO-GO 충족 시 sunk-cost로 끌지 말고
즉시 중단·기록. 진단 없는 반복 금지. 의미있는 단계 전 체크포인트 + 결정 로그로 되돌릴 수 있게.

---

## 6. FIRST MOVE
1. `korean_multimodal_manifest` 컬럼·라벨(amyloid_visual)·코호트별 커버리지 파악(+ datadict, 이 폴더 `USAGE_ROADMAP.md`).
2. §1 함정 + minyoungi 멀티모달/vascular track 확인.
3. P0 라벨·누수 audit 계획부터(설계만) → 승인 후 코드. GPU·대형 배치는 사전 승인.
