# Archive — De-confounding / cross-site dementia exploration (2026-06-11)

> 자체완결 기록. 이 디렉토리(minyoung4)에서 진행한 탐색의 목적·여정·측정값·종료 사유.
> 실험 코드/캐시/체크포인트는 reset으로 삭제됨 — **모든 수치는 이 문서에 보존**.

## 0. 한 줄 결론 (왜 reset)
4개 독립 방향을 측정으로 빠르게 배제. **이 데이터의 임상 라벨(dx/amyloid/cdr)엔 deep-method 헤드룸이 없음**
— dementia는 morphometry로 ceiling, amyloid는 구조로 unlearnable, 교란은 irreducible-but-benign.
→ publishable한 강한 기여 불성립. 산만한 탐색 산출물을 삭제하고 clean slate로 리셋.

## 1. 여정 (시간순)
1. **데이터 준비**: ADNI/OASIS amyloid PET을 Korean(AJU/KDRC) 파이프라인과 동일 코어로 전처리 → **2,896 subj, hard-defect 0** (음성 anchor 등 검증). *Direction A용.*
2. **Direction A — PET-privileged de-confounding**: PET(생물학적 teacher)을 T1w에 distill해 site-invariant 표현. → **P0.1c에서 폐기**.
3. **Direction B — representation de-siting (GRL/adversarial)**: 강한 신호(dementia)에 대한 site-invariant 표현. → **EXP-2 + P1-A에서 폐기**.
4. **Manifest pivot**: `official_manifest_full_n4_real_final.csv` (7 코호트·실제 dx)로 토대 교체.
5. **P1 — cross-site dementia method**: → **P1-A에서 폐기**(morphometry ceiling).

## 2. 측정 결과 (전부 보존)

### 2.1 Direction A kill (PET teacher가 자체로 site-confound)
- PET SUVR 분포 → cohort macro-AUC **0.829** (구조 fs_vol 0.747보다 높음). pairwise: ADNI-OASIS 0.90, OASIS-AJU 0.93, same-tracer {AJU,KDRC} 0.78.
- scale-정규화해도 0.829→**0.776** (shape에도 cohort 신호).
- **amyloid 통제 후**: 음성 stratum **0.855** / 양성 0.734 → 분리가 amyloid biology 아니라 **tracer/scanner 교란**. (kill gate 발화)
- 부수: amyloid clinical-only AUC ~0.78; 구조→amyloid ΔAUC≈0; PET→amyloid 0.97(trivial).

### 2.2 Direction B — de-siting no-op (7코호트, 실제 dx)
EXP-2 λ-sweep (morpho-distill + GRL cohort-adversarial; frozen-probe eval):
| λ | cohort macro-AUC | LOCO dementia 평균(6코호트) |
|--:|--:|--:|
| 0 (baseline) | 0.842 | 0.882 |
| 0.1 | 0.808 | 0.880 |
| 0.3 | 0.835 | 0.886 |
| 1.0 | 0.843 | 0.872 |
→ de-siting Δcohort −0.03~0(비단조=노이즈), **ΔLOCO≈0**. (선형 INLP: cohort 0.92→0.78 lin/0.89→0.75 MLP, dementia 0.95→0.89.)

### 2.3 P1-A — baseline ladder (CN vs AD/Dementia, LOCO)
| baseline | LOCO 평균 |
|---|--:|
| clinical (비인지: age/sex/apoe) | 0.625 |
| **ROI-morphometry (fs_vol logistic)** | **0.881** |
| morpho-distill 3D encoder | 0.882 |
→ **3D pixel encoder = ROI logistic. value-add ≈ 0.** (encoder를 fs_vol로 distill했으니 fs_vol 재현.)

### 2.4 핵심 findings
- **F1** privileged amyloid-PET도 site-confound (음성 0.855).
- **F2** 표현 de-siting이 cohort 못 줄임(~0.84 floor).
- **F3** 그래도 disease 강건 전이 (LOCO 0.88).
- **F4** site-decodability ⟂ disease-transfer **분리**; de-confounding 달성·이득 모두 없음.
- **F5** site=population·traveling-subject-0 regime서 de-confounding 3회 실패(A·B·minyoung2 §9).
- **F6** cross-site dementia = morphometry로 완전 포착; pixel/distill/DG method ΔAUC≈0 → **deep-method 헤드룸 없음**.

## 3. 데이터 현실 (확정)
- manifest: 13,022 QC-PASS T1w 세션 / 7 코호트(ADNI/NACC/A4/OASIS/AJU/AIBL/KDRC) / 실제 dx(CN 7580 vs AD+Dem 969) / fs_vol·clinical 내장.
- 라벨 성질: dementia=morphometry ceiling, amyloid=구조 unlearnable. → method가 이길 자리 없음.

## 4. reset에서 **보존**된 것 (삭제 안 함)
- **공유 데이터**: ADNI/OASIS amyloid PET `@/home/vlm/data/preprocessed_official/v2`(2,896 subj, defect-free, 재사용 가능).
- **minyoungi 파이프라인 패치**: `preprocessing/{paths,executor,pet_suvr}.py` + `run_pet_adni_oasis.py` (ADNI/OASIS PET 배선; additive infra, 다른 프로젝트).
- **minyoungi Track-01 `EXPERIMENTS.md` EXP-003**(harmonization-distill eval 결과; 그 로그에 정당 기여).
- minyoung4 `data/`(label tables; legacy `preprocessed_mm` 스냅샷은 그대로 둠 — 별도 정리 대상).

## 5. reset에서 **삭제**된 것 (이번 세션 minyoung4 산출물)
- `experiments/` (p0_probes, desiting_v1[22GB 캐시·ckpt], p1_benchmark, _cache).
- `audits/` (modality_amyloid_pet_inventory).
- `SPEC.md`, `CONTRIBUTION.md` (내용은 본 아카이브로 흡수).

## 6. 다음 진입자에게 (lessons)
- 이 데이터의 임상 라벨로는 "de-confounding"도 "pixels>morphometry"도 안 됨 — 측정으로 확정.
- 강한 기여를 원하면 **morphometry로 못 푸는 task**가 필요(예: 이미지 추론형 — minyoung3 Q-ROUTE가 그 영역 선점) 또는 longitudinal conversion(MCI→AD, 미검증·고위험).
- 인프라(manifest 토대·LOCO 평가·distill·code-auditor 통과 패턴)는 재사용 가능했음.
