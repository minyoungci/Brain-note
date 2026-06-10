# SCANNER / SITE-BIAS PLAYBOOK — 학습을 가장 잘 시키는 법 (우리 실험으로 증명됨)

> **이 파일이 무엇인가**: 다른 실험·에이전트가 *멀티사이트(7-컨소시엄) 뇌 T1 MRI로 AD 모델을 학습할 때 scanner/site bias를 어떻게 다뤄야 하는지*를 결정하기 위한 **단일 권위 문서**. 모든 규칙은 `01~09` 실험으로 검증됨(RF+LogReg 교차, 원본 무결).
> **읽는 법**: §1(규칙)만 보고 결정해도 됨. 근거가 필요하면 §2(증거표) → 해당 실험 `RESULTS.md`.
> **갱신 규칙**: 새 증거가 생기면 *이 파일을 업데이트*(새 문서 양산 금지). 마지막 갱신 2026-06-04(실험 09까지).

---

## 0. 한 줄 결론

**이미지 편향은 못 지운다. 지울 필요도 없다.** morphometry(ROI 부피) 공간으로 내려가면 site bias가 거의 안 새고(LOCO ~0.90, site-shift 비용 ~0, 한국 코호트 포함), 어떤 이미지 harmonization도 이 바닥을 못 이긴다. **그러니 "이미지를 고치는" 데 시간 쓰지 말고, site-robust한 feature 공간에서 학습하라.**

---

## 1. 규칙 (DO / DON'T) — 결정은 여기서

### ✅ DO
| # | 규칙 | 근거(실험) |
|---|---|---|
| D1 | **morphometry(fs_vol ROI 부피)를 1차 표현으로 써라.** CN/AD를 held-cohort로 ~0.90 일반화. | 04, 09 |
| D2 | **정규화는 simple하게: ICV(÷fs_MaskVol) 또는 train-z(train 통계).** feature-space 승자(LOCO 0.910). | 09 |
| D3 | **pooled로 학습하라(전 코호트 한 모델).** 코호트를 쪼개지 마라. | 09, §3 |
| D4 | **split은 반드시 leave-one-consortium-out(LOCO), subject 단위.** random split이면 site로 코호트를 외움(A4/KDRC/AJU/AIBL 거의 완전 식별). | 01, 04 |
| D5 | **scanner를 *지우지* 말고 *조건화*하라.** 모델에 acquisition 메타데이터(vendor·field·voxel)를 nuisance 입력으로 줘서 scanner만 정규화, population은 보존. | 01, §4 |
| D6 | **검증은 항상 3종 동시: site-probe↓ + biology-probe보존 + null control.** 단일 site-probe는 site==population에서 무효. | 02, 06 |

### ❌ DON'T
| # | 금지 | 왜 (근거) |
|---|---|---|
| X1 | **이미지 end-to-end로 바로 분류하지 마라(검증 없이).** 3D CNN held-AUC 0.88~0.90 < morphometry 0.93~0.95(전 seed). 게다가 표현이 site shortcut을 먹음. | 07 |
| X2 | **이미지 harmonization으로 site를 지우려 하지 마라.** N4가 최선이나 0.556→0.517(미미·probe의존); MixStyle은 site-probe를 오히려 +0.026. | 03, 07 |
| X3 | **per-cohort 학습 후 ensemble 하지 마라.** bias를 제거가 아니라 expert별 *분산 저장*; 데이터 쪼개 AD 희소 악화; 새 코호트에서 OOD. | §3(추론), 07 |
| X4 | **site를 chance까지 지우지 마라(adversarial/강한 harmonization).** site==population이라 population biology까지 삭제(over-correction). | 02, 06, 07 |
| X5 | **ComBat을 *cross-cohort 일반화 부스터*로 기대하지 마라.** 효과 작고 분류기 의존(RF −0.014 / LogReg +0.022, 부호 반전). in-distribution 정량분석엔 OK. | 09, 02 |
| X6 | **raw 코호트 정체성(consortium)을 분류기 head에 직접 주지 마라.** "AJU→MCI" 같은 라벨 지름길을 먹음(대신 acquisition 축만, D5). | 01, 08 |

---

## 2. 증거표 (proven findings — 무엇이 얼마나 견고한가)

| 발견 | 수치 | 견고성 | 실험 |
|---|---|---|---|
| site는 픽셀보다 metadata에 박힘 | metadata 0.761 > appearance 0.556 (chance 0.143) | RF+LogReg | 01 |
| 이미지 정규화는 site를 거의 못 지움 | N4 0.556→0.517 (RF만; LogReg 무이득) | probe-의존 | 03 |
| feature ComBat은 *in-distribution* site↓+biology보존 | site 0.238→0.175, within-ADNI AUC 0.885 불변 | RF+LogReg, null통과 | 02 |
| ComBat-GAM ≈ 선형 ComBat | 차이 노이즈 내(\|Δ\|0.0024<sd0.0029) | RF+LogReg | 05 |
| **morphometry는 cross-cohort robust(한국 포함)** | **LOCO ~0.90, site-shift 비용 ~0** | **RF+LogReg, within-cohort 기준선** | **04, 09** |
| simple norm이 feature-space 승자 | train-z/icv 0.910 | RF | 09 |
| ComBat은 일반화 향상 신뢰 불가 | RF −0.014 / LogReg +0.022 (부호 반전) | 교차검증으로 *반증* | 09 |
| **이미지 표현은 morphometry를 못 이김** | **CNN 0.88~0.90 < morph 0.93~0.95 (Δ−0.03~−0.08)** | **2 cohort×2 seed** | **07** |
| MixStyle은 site shortcut 못 줄임 | site-probe +0.026~0.027 (양 seed) | 재현 | 07 |
| 약 task(CN/MCI)도 harmonization이 unmask 못 함 | within-ADNI flat, pooled는 site-inflation 제거로↓ | RF+LogReg | 08 |

**핵심 메커니즘**: site==population에선 site가 신호를 *가리는(mask)* 게 아니라 confounded 라벨을 *부풀린다(inflate)*. 그래서 harmonization을 걸면 일반화가 좋아지지 않고, disjoint 코호트(한국)에선 over-correction 위험만 생긴다.

---

## 3. 권장 학습 파이프라인 (ranked)

**① 1순위 (실증 승자, 지금 바로):**
```
입력: fs_vol_* (26 ROI) + fs_MaskVol
전처리: ICV(÷MaskVol) 또는 train-z (D2)
모델: 단일 분류기(RF/GBM/LogReg), pooled 학습 (D3)
split: LOCO subject-first (D4)
기대: held-cohort CN/AD AUC ~0.90, site-shift 비용 ~0
```
→ 이게 **이미지 방법이 넘어야 할 바 = 0.91**.

**② 이미지가 꼭 필요하면 (GPU, 사전 승인, 미실행):**
- shared backbone + **domain-specific normalization(DSBN)** — 조건화 키를 *consortium이 아니라 acquisition(vendor×field×voxel)*로 (D5, X6).
- **foundation/pretrained 3D 인코더 feature + linear probe** — 작은 from-scratch CNN(07)의 data-limited 한계를 우회할 유일한 미시도 레버.
- **test-time adaptation**(BN-adapt/TENT) — 새 코호트 bias를 추론 시 흡수.
- 단 **0.91 바를 LOCO로 넘어야** 채택. 04/07 기준 headroom 작음(낙관 금지).

**③ 정량 ROI 분석(일반화 아닌 in-distribution):** ComBat(age/sex/dx 보존) 후 분석 OK(02). 단 cross-cohort 예측엔 X5.

---

## 4. 핵심 원리 — "지우지 말고 분리하라(condition, not erase)"

site==population(한국 vs 서구, traveling subject 0)에선:
- **erase**(harmonization/adversarial로 코호트를 똑같이 보이게) → population biology까지 삭제(over-correction). 07/02/06이 입증.
- **condition**(코호트의 *acquisition 축*만 nuisance로 모델에 주고 population은 보존) → scanner만 factor out. DSBN/메타데이터 조건화가 그 구현.
- **factor out하는 축을 구분**: vendor·field·voxel = nuisance(제거/조건화 대상). 모집단(한국성) = 보존 대상(연구 변수). consortium 정체성 자체는 둘이 얽혀 있으니 head에 직접 주면 안 됨(X6).

---

## 5. 데이터 & 경로 (전부 read-only)
- manifest: `/home/vlm/data/preprocessed_official/official_manifest_full_n4.parquet` (13,022×101)
  - morphometry: `fs_vol_*`(26), `fs_MaskVol`; acquisition: `acq_scanner`,`acq_field_strength`,`vox_*`; 임상: `clin_*`(주의: dx는 **subject당 정적**, 종단/전환 불가 — `[[clinical-manifest-join]]`)
- 이미지 텐서(N4): `final_tensor_n4_path` (192×224×192 zscore); ROI 마스크: `roi_mask_path_*`(5 ROI)
- minyoung4 CN/AD 학습 계약: `/home/vlm/minyoung4/docs/context/full_n4_experiment_redesign_20260603/full_n4_supervised_cnad_adni_aibl_kdrc.csv` (1765 subj)
- 실험 증거: 이 폴더 `0{1..9}_*/RESULTS.md` + `out/*.json`. 인덱스 `README.md`.

## 6. 미해결 / 미검증 (정직성)
- 이미지 방법(DSBN/foundation) **미실행**(GPU 승인 대기) — 0.91 바 비교 필요.
- AJU(가장 site-특이, 한국)는 CN 22~23뿐이라 **CN/AD held-out 불가** → 가장 강한 반례 미검증.
- conversion(종단 MCI→AD) **불가**: manifest dx 정적(`[[clinical-manifest-join]]`). raw 테이블 재추출 별도 과제.
- ComBat은 transductive(배치 배포) 가정; 1건씩 inductive면 적용 불가.

---
_근거 논문(검증됨): Fortin 2017(overlap한정 ComBat), Bayer 2022(confound over-correction), Souza 2024(진단기=비밀 site분류기), Saponaro 2022(unmask는 mask일 때만). 상세: `06_feasibility_and_protocol.md`._
