# Image↔Clinical 비교 · Representation Learning 난점 — 데이터 사실

> **목적:** minyoungi 노트북 02(이미지↔임상 비교)·04(표현학습 난점)에서 출력된 세밀한 데이터 사실 정리  ·  **출처:** `/home/vlm/minyoungi/Clinical/notebooks/02_image_clinical_comparison.ipynb`, `04_repr_learning_challenges.ipynb` (master_df.parquet `(13022, 44)`, roi_volumes.parquet `(500, 41)`)  ·  **갱신:** 2026-06-02

⚠️ **ROI 경고**: 본 문서의 ROI/부피 기반 수치(해마·편도체 부피, signal dilution 비율, PCA feature 등)는 모두 **BLOCKED_PROVISIONAL(후보)** 산출물에 근거한다. 노트북 02의 ROI mask 경로는 `roi_transfer_option_b_candidate_v0`, signal dilution은 FastSurfer VINN에 eTIV 부재로 `MaskVol`을 **ICV 프록시**로 대체. 부피 절대값을 확정 사실로 인용하지 말 것.

---

## 1. 노트북 02 — 이미지 ↔ 임상 라벨 비교

노트북 02는 정량 통계가 아닌 **시각화 중심**(중앙 슬라이스, ROI overlay, QC 히스토그램)이다. voxel 통계의 수치 출력은 없으며, 관찰 노트(MD cell 13)는 빈칸으로 남아 있다.

| 항목 | 출력된 사실 | 상태 |
|---|---|---|
| master_df 규모 | `(13022, 44)`, 진단 컬럼 `diagnosis` | ✅ |
| 데이터 경로 | `/home/vlm/data/preprocessed_official/v2` | ✅ |
| CDR 그룹 시각화 | CDR=0 / CDR=0.5 / CDR≥1 각 3건 슬라이스 (정량 비교 없음) | 🟡 |
| ADNI CN vs AD | 70~80세 매칭, CN 2건·AD 2건 슬라이스 | 🟡 |
| Hippocampus overlay | CN 1건·AD 1건, ROI mask는 `roi_transfer_option_b_candidate_v0` 후보 경로 탐색 | ⚠️ ROI BLOCKED_PROVISIONAL |
| voxel/부피 정량 비교 | **노트북에 정량값 없음** (시각 관찰만, 관찰 노트 미작성) | ⚠️ |
| 핵심 가설(MD) | "AD 변화는 국소적(해마·내후각피질) — 전 복셀 동등 처리 모델은 신호를 noise로 희석" | 🟡 가설 |

02에는 hippocampus 부피 vs CDR, CN/AD 부피 대비, site effect의 **정량 수치가 출력되지 않았다**. 해당 정량 근거는 모두 노트북 04에 있다.

---

## 2. 노트북 04 — Representation Learning 5대 난점 (정량 근거)

`fig_04_c1`~`c5`에 대응. 모든 ROI 기반 수치는 ⚠️ BLOCKED_PROVISIONAL.

### Challenge 1 — Label Imbalance (`fig_04_c1`) ✅

전체 13,022 세션 진단 분포 (출력값):

| 진단 | 세션 수 | 비율 |
|---|---|---|
| CN | 5,439 | 41.8% |
| MCI | 3,470 | 26.6% |
| Unlabeled | 3,043 | 23.4% |
| AD | 1,070 | 8.2% |

- AD는 소수 클래스(8.2%, <10%). 🟡 노트북 주석은 "unlabeled 62%는 A4(예방 임상시험, CN 편향)+KDRC"라 적었으나, 출력된 Unlabeled 비율은 **23.4%**다. 62%는 [VERIFY] (출력값과 불일치).

### Challenge 2 — Site Effect / PCA (`fig_04_c2`) 🟡

- ROI 부피 17개 feature, PCA 샘플 388건(roi_df 500건 중 결측 제외). ⚠️ ROI BLOCKED_PROVISIONAL.
- PC1/PC2 **explained variance 수치는 출력 텍스트에 없음**(figure 내부에만 렌더). 컨소시엄 클러스터링 vs 진단 분리 여부는 그림으로만 제시 — 정량 결론 없음. `[VERIFY]` PC variance 비율.
- 제외 컬럼: `icv_proxy`, `BrainSegVol`, `_norm` suffix, id/메타.

### Challenge 3 — 3D Signal Dilution (`fig_04_c3`) ⚠️

CN subset 기준 출력값 (⚠️ ROI BLOCKED_PROVISIONAL, MaskVol=ICV 프록시):

| 항목 | 값 |
|---|---|
| 전체 복셀 (192×224×192) | 8,257,536 |
| 뇌 내 복셀 (약 35% 가정) | 2,890,137 |
| 해마+편도체 / MaskVol(ICV proxy) 비율 | 0.0081 (0.81%) |
| AD-sensitive 복셀 (추정) | 23,313 (0.28%) |

- 35% 뇌 마스크 비율과 categories 파이값(해마+편도체 0.3% 등)은 **하드코딩 추정치**이지 측정값 아님. ⚠️

### Challenge 4 — Label Noise: CDR vs Diagnosis (`fig_04_c4`) ✅

CDR×진단 교차표 (출력값):

| CDR \ 진단 | AD | CN | MCI |
|---|---|---|---|
| 0.0 | 7 | 5,317 | 49 |
| 0.5 | 286 | 122 | 3,419 |
| 1.0 | 639 | 0 | 2 |
| 2.0 | 120 | 0 | 0 |
| 3.0 | 18 | 0 | 0 |

불일치 케이스: **AD 진단 + CDR=0: 7건**, **CN 진단 + CDR≥1: 0건**. CDR=0.5에 CN 122·AD 286이 섞여 라벨 경계가 모호.

### Challenge 5 — MCI Heterogeneity (`fig_04_c5`) ✅

- MCI 총 세션 **3,470**. MCI 내 CDR 분포: CDR 0.0 **49건** / 0.5 **3,419건** / 1.0 **2건** (대부분 0.5에 집중).
- 종단 데이터에서 **MCI → AD 전환 subject 128건** (subject당 2세션 이상, session_id 정렬 후 MCI 인덱스 < AD 인덱스).

### 종합 severity (MD, 정성 평가) 🟡

severity는 노트북 작성자가 수기로 부여한 값(데이터 산출 아님): Site Effect=5, Signal Dilution=5, Label Imbalance=4, MCI Heterogeneity=4, Label Noise=3, Longitudinal Imbalance=2.

---

## 3. 주의 종합

- ⚠️ **ROI 전면 후보(BLOCKED_PROVISIONAL)**: C2 PCA, C3 signal dilution, 02 hippocampus overlay 모두 후보 ROI에 의존. 확정 부피 산출 전까지 절대값 인용 금지.
- `[VERIFY]` Unlabeled 비율: 출력 23.4% vs 주석 62% 불일치.
- `[VERIFY]` C2 PCA explained variance 비율 — figure 내부 렌더, 출력 텍스트에 미등장.
- 02의 voxel/부피 정량 비교, ADNI age 분포 등: **노트북에 정량값 없음**(시각화만).
