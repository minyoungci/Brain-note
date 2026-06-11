# data · ROI / 부피 분석 — option_b grid 마스크 · FastSurfer 부피 vs CDR

> **목적:** minyoungi의 ROI/부피 분석(그리드 사실, BLOCKED_PROVISIONAL QC 현실, FastSurfer 부피 vs CDR/진단 실측치, per-ROI QC 게이트)을 세밀히 정리한다.  ·  **출처:** `minyoungi/Clinical/VOXEL_ANALYSIS_PLAN.md`(권위 문서), `Clinical/notebooks/03_roi_volume_analysis.ipynb`, `roi_qc/{ROI_USABILITY_REPORT.md,VISUAL_QC_CRITERIA.md,SCRATCHPAD.md}`, `roi_qc/scripts/{auto_anatomical_qc.py,roi_verify_viz.py}`, `Clinical/common/roi_tools.py`  ·  **갱신:** 2026-06-02

⚠️ **이 문서의 모든 ROI/부피 수치는 BLOCKED_PROVISIONAL(후보)이다.** option_b ROI는 manifest 전수 13,022행에서 `roi_final_ready=False`(fail-closed). 정량 주장 전 per-ROI QC 게이트 통과가 선행되어야 한다(§2·§4).

---

## 1. 그리드 사실 (리샘플 불필요의 근거)

세 종류의 격자가 공존하며, 무엇을 인덱싱하느냐에 따라 신뢰도가 갈린다. 출처: `VOXEL_ANALYSIS_PLAN.md §0`, `Clinical/common/roi_tools.py`.

| 자산 | 격자 | affine | 강도 | 용도 |
|---|---|---|---|---|
| `final_tensor` (ft_zscore) | 192×224×192 | identity (RAS, x축 L/R, 정중선 x=96) | z-score | 모델 입력 채널 |
| `roi_masks/*.nii.gz` (legacy) | 256³ conformed | conformed | label | ⚠️ final_tensor에 **직접 오버레이 불가** |
| **option_b** final_tensor-grid 버전 | 192×224×192 | identity | aseg label + per-ROI 이진 마스크 | ROI 인덱싱·오버레이 |

✅ **동일 그리드 사실**: `final_tensor`와 option_b aseg/ROI grid는 동일 격자 → 리샘플·affine 변환 없이 `tensor[c]`와 `mask[c]`를 직접 인덱싱 가능. (`roi_tools.check_alignment()`가 `shape_match`/`affine_match`/`aseg_identity_affine`/`n_labels`로 전수 검증.)

✅ **option_b 전수 존재**: manifest 전수 13,022행 100%에 grid aseg + 16 ROI 마스크 + summary JSON 존재(`VOXEL_ANALYSIS_PLAN.md §0` 검증된 사실 2).

option_b 디렉토리 구성(`roi_transfer_option_b_candidate_v0/`):
- `aparc_DKTatlas_aseg_final_tensor_grid_option_b_candidate.nii.gz` — 192×224×192 aseg labelmap
- `roi_masks_final_tensor_grid_option_b_candidate/<roi>.nii.gz` — per-ROI 이진 마스크 (bilateral 통합)
- `option_b_one_subject_summary.json` — per-ROI `voxel_count` / `physical_volume_mm3` / `centroid_voxel` / `status`

### ⚠️ centroid_voxel ~31 voxel 어긋남 (함정)

summary JSON의 `centroid_voxel`는 **256-conformed 좌표**라서 final_tensor 격자와 **~31 voxel 어긋난다**(`VOXEL_ANALYSIS_PLAN.md §0` 함정 2). 큐브 크롭 중심으로 쓰면 안 됨.

| 양 | 격자 정합 | 사용 가능 여부 |
|---|---|---|
| `centroid_voxel` | 256-conformed (≈31vox 오프셋) | ❌ 크롭 중심에 직접 사용 금지 |
| 크롭 중심 대안 | `expected_centroid_final_voxel` 또는 **마스크에서 재계산한 centroid** | ✅ |
| `voxel_count`, `physical_volume_mm3` | 그리드와 일치 | ✅ **부피는 신뢰 가능** |

즉 **부피·복셀수는 격자와 일치해 신뢰 가능**하지만, centroid는 별도 격자라 크롭 정렬에 그대로 쓰면 ~31vox 어긋난다.

---

## 2. ROI = BLOCKED_PROVISIONAL (전수)

⚠️ option_b ROI는 **공식적으로 BLOCKED_PROVISIONAL**이다. manifest 전수 13,022행에서 동일 플래그(`VOXEL_ANALYSIS_PLAN.md §0` 함정 1; 컬럼은 `Clinical/notebooks/00_manifest_alignment.ipynb` 스키마로 확인):

| 플래그 | 값 (전수 13,022) |
|---|---|
| `do_not_use_for_atlaswide_roi_features` | True |
| `roi_final_ready` | False |
| `roi_final_grid_qc_status` | BLOCKED_PROVISIONAL |
| `roi_block_reason` | `"FastSurfer-to-native transfer requires ROI-specific visual approval; legacy ROI dirs and repair candidates are provisional."` |

→ **ROI 기반 수치는 "검증됨"이 아니라 "후보(candidate)"**. 정량 주장 전 per-ROI QC 게이트가 필요하다(§4).

`roi_final_ready=True` 조건(fail-closed, `VISUAL_QC_CRITERIA.md`): numeric pass ∧ all-ROI visual PASS ∧ **명시적 사람 승인**. 자동 게이트 통과는 anatomical sign-off가 아니므로 전수가 여전히 False다(`ROI_USABILITY_REPORT.md`).

---

## 3. FastSurfer 부피 분석 (노트북 03 실측)

입력: `master_df.parquet (13022, 44)`. FastSurfer `aseg+DKT.VINN.stats`를 파싱해 ROI 부피를 CDR/진단과 대조.

### 3.1 ICV 프록시로 MaskVol을 쓰는 이유

⚠️ **FastSurfer VINN은 eTIV(EstimatedTotalIntraCranialVol)를 산출하지 않는다.** 예시 세션 파싱 출력(`002_S_0413`):

| 측정 | 값 |
|---|---|
| MaskVol | 1,373,127.0 |
| BrainSegVol | 1,046,498.12 |
| BrainSegVolNotVent | 1,006,302.15 |
| SupraTentorialVol | 934,256.67 |
| **eTIV** | **None** |

→ 전역 두개강 부피 대용으로 `MaskVol`(두개강 마스크 부피)을 ICV 프록시로 사용(`ICV_KEY='MaskVol'`). ⚠️ **MaskVol은 진짜 eTIV가 아니다** → cross-site 정규화의 한계는 노트북 04에서 다룸.

경로 함정: stats 경로는 `session_id`로 재구성하지 않고 manifest의 `final_tensor_path`(권위 절대경로)에서 유도한다. ADNI 세션 디렉토리는 `<date>.0`처럼 `.0` 접미사가 붙는데 `master_df.session_id`는 join 위해 `.0`를 strip한 상태라, 재구성하면 경로가 깨진다(과거 ADNI 전건 `exists()=False` 버그 원인).

### 3.2 해마 부피 vs CDR / 진단 (500건 샘플, seed=42)

파싱 500건 전부 성공(실패 0), hippocampus·ICV 프록시 가용 100%.

**Bilateral hippocampus, CN vs AD (Mann-Whitney U, CN > AD):**

| 그룹 | 평균 부피 (mm³) | SD |
|---|---|---|
| CN | 7,680 | ±762 |
| AD | 6,455 | ±1,288 |
| | **p = 3.27e-08** | (AD < CN 방향 확인) |

⚠️ 부피 절대값은 후보(§2). 방향성은 정상적 위축 패턴과 일치하나, AD의 큰 SD(±1,288, CN의 약 1.7배)는 세그먼트 불안정·후보 ROI 노이즈 가능성을 시사한다.

### 3.3 ROI boxplot — 진단 그룹별 (CN/MCI/AD)

`03` §3: bilateral hippocampus / left amygdala / left entorhinal / left lateral-ventricle 4종을 CN<MCI<AD 순서로 boxplot, CN vs AD Mann-Whitney 유의성 별표 주석. (figure만 출력, 셀별 p값은 노트북 figure 내부에 기록 — 본 텍스트 덤프에는 수치 미노출 → `[VERIFY]` 개별 p값.)

### 3.4 ROI 부피만으로 AD 분류 (선형 분리 가능성)

CN/AD 라벨, hippocampus·amygdala·entorhinal feature 9개, 5-fold ROC-AUC:

| 항목 | 값 |
|---|---|
| 학습 데이터 | (262, 9) — AD=37, CN=225 |
| Logistic Regression ROC-AUC | **0.807 ± 0.066** |

노트북 자체 해석 기준: AUC 0.70~0.85 = "제한적 신호 — 이미지 표현 학습의 부가가치 있음" 구간. ⚠️ AD=37로 클래스 불균형이 크고(class_weight='balanced' 사용), ROI 부피는 후보 산출물이므로 이 AUC는 상한 추정으로 보는 게 안전하다.

### 3.5 site effect · MCI 이질성

- **Site effect**(CN만, 진단효과 제거): 컨소시엄별 bilateral hippocampus boxplot + Kruskal-Wallis, MaskVol 정규화 전후 비교. (p값은 figure 내부 — `[VERIFY]`.)
- **MCI 내부**: MCI 126건 전부 `cdr_global=0.5`(분포 `{0.5: 126}`) → 노트북 결론 "MCI는 단일 그룹이 아님"은 이 샘플에서 CDR 분산이 0이라 **데이터로 뒷받침되지 않는다**(Spearman은 상수 CDR에 대해 무의미). 단일 CDR 값에 대한 해마 산점도일 뿐이다.

---

## 4. per-ROI QC 게이트 (roi_qc — 정량 주장 전 필수)

`VOXEL_ANALYSIS_PLAN.md §2`가 요구한 게이트를 `roi_qc/`가 구현. 13,022 전수 대상, validation-only(원본 불변).

### 4.1 세 게이트 (weakest-link, `ROI_USABILITY_REPORT.md`)

| 게이트 | 증명하는 것 | 결과 |
|---|---|---|
| 1. Numeric transfer QC | 마스크가 FastSurfer seg를 192³ final grid에 충실히 복사 | 12,978/13,022 pass (99.7% 커버) |
| 2. Auto-anatomical QC | 격자 병리 없음(containment·leak·symmetry·topology) | **12,932 PASS / 46 FLAG** |
| 3. Vision QC | FastSurfer **자체 분할**이 해부학적으로 옳은가 | ❌ 대규모 미수행 (gap) |

⚠️ **Gate 2 PASS ⇏ Gate 3 PASS.** numeric `overlap≈1.0`/`volerr≈0`은 "FastSurfer seg를 final grid에 충실히 재현"(transfer fidelity)만 증명할 뿐, FastSurfer 자체 분할 오류는 못 본다. 그래서 vision QC가 고유 가치(`VISUAL_QC_CRITERIA.md`).

### 4.2 auto-anatomical QC 메트릭 (`auto_anatomical_qc.py`)

required ROI 5종(hippocampus, amygdala, thalamus, lateral_ventricle, parahippocampal_cortex), 192×224×192 RAS, 정중선 x=96.

per-ROI: `vox`, `asym`=|Vl−Vr|/(Vl+Vr), `n_cc`/`frag`=1−largest_cc/total(반구별 dominant component), `inside_brain_frac`. 세션: `max_pairwise_leak`.

FLAG 임계(fail-closed): `inside_brain_frac<0.98` ∨ `asym>0.40` ∨ `frag>0.10` ∨ `leak>0.02` → 아니면 `PROVISIONAL_PASS_AUTO`. 전수 결과(`autoqc_full.out`): **PROVISIONAL_PASS_AUTO 12,932 / FLAG 46 / ERROR 0.**

### 4.3 usability 판정 (FLAG 46 vision 검토 후)

| 클래스 | n | 의미 |
|---|---|---|
| USABLE_AUTO | 12,932 | numeric + auto-geometry pass (vision pending) |
| USABLE_W_CAVEAT | 30 | benign FLAG: ventricle 비대칭(22) / thin-structure frag(8) |
| REVIEW_REQUIRED | 11 | borderline: asym 0.40–0.60(10) + PHC frag 0.22(1) → 사람 판독 |
| ROI_UNUSABLE | 5 | real: 한쪽 반구 MTL ROI under-seg |
| NOT_CANDIDATE | 44 | numeric fail/uncovered (39 A4 + 5 others) |

자동 게이트 통과율 **99.54% (12,962/13,022)**. ⚠️ `roi_final_ready`는 전부 False(fail-closed).

### 4.4 5개 ROI_UNUSABLE (vision 확인, 4/5 개별 검토)

| tag | 결함 |
|---|---|
| `OASIS_OAS30805_d7028` | parahippocampal R=0 (우 MTL 결손); hippo L:R = 3261:555 |
| `OASIS_OAS30805_d5456` | (동일 subject) parahippocampal asym 0.97 (우 MTL) |
| `ADNI_127_S_4197_20150921` | 좌 MTL under-seg: PHC L:R = 20:263, hippo 993:2683 |
| `NACC_NACC124125_I11044252` | 좌 amygdala under-seg L:R = 174:1035 |
| `NACC_NACC188891_I10964571` | 좌 amygdala under-seg L:R = 152:1037 |

한쪽 반구·한 ROI의 분할 실패이며, 다른 ROI/반대 반구는 정상일 수 있음.

### 4.5 PASS 신뢰도 spot-check (Gate-3 표본)

stratified PASS 표본 n=21(코호트당 3), 고해상 5-ROI montage 육안 검토:
- **0/21 gross 분할 오류.** 모든 ROI 정위치·양측 존재·타당한 경계. 위축 뇌도 올바르게 분할(위축 ≠ 오류).
- gross 오류율 95% 상한 ≈ 14% (rule-of-three, n=21).
- ⚠️ **한계**: montage 해상도는 gross만 잡음. sub-voxel/수 mm 경계 오류는 미정량 → 더 큰 표본 사람 κ-rating 필요.

### 4.6 ROI 검증 시각화 (`roi_verify_viz.py`)

`make_verify_figure(row)`: MRI + ROI 오버레이(low-alpha fill + boundary contour, z-score 윈도우 −1.5..2.5)를 usability/auto_verdict/FastSurfer L/R 부피·|asym|/임상 사실과 한 장 결합. 인터랙티브: `notebooks/roi_inspection.ipynb`(TAG 변경). FS 컬럼명(`parahippocampal`)과 ROI 마스크명(`parahippocampal_cortex`) 차이는 `FS_KEY` 매핑으로 흡수.

---

## 5. 종합 판단

| 용도 | 가용성 |
|---|---|
| representation-learning / pretraining (occasional ROI 노이즈 허용) | 🟡 12,932 USABLE_AUTO(+30 caveat)는 **오늘** 방어 가능한 학습 풀; 5 UNUSABLE 제외, 11 review 보류 |
| ROI-wise biomarker 등 **해부학적 정확성 요구** 주장 | ❌ 아직 불가 — Gate 3(체계적 사람 vision QC) 선행 필요. `roi_final_ready` False 유지 |

> 요약: 그리드는 동일(리샘플 불필요)하고 **부피·복셀수는 신뢰 가능**하나, **centroid는 256-conformed라 ~31vox 어긋나며 ROI 전체가 BLOCKED_PROVISIONAL**이다. 노트북 03의 부피 vs CDR 신호(해마 CN>AD p=3.3e-08, ROI-only AUC 0.807)는 방향성은 일관되나 후보 ROI에 근거하므로 확정 사실로 인용하지 말 것.

---

## [VERIFY] 목록

- 노트북 03 §3 boxplot(hippocampus/amygdala/entorhinal/lateral-ventricle)의 개별 CN-vs-AD p값 — figure 내부에만 기록, 텍스트 덤프 미노출.
- 노트북 03 §4 site effect Kruskal-Wallis p값(원본/MaskVol 정규화) — figure 내부.
- `expected_centroid_final_voxel`의 정확한 산출 위치/컬럼(summary JSON vs manifest) — `roi_tools.py`에는 미구현, `VOXEL_ANALYSIS_PLAN.md`가 권장 대안으로만 명시.
- centroid 오프셋 "~31 voxel"의 정확한 측정 근거 — PLAN 본문 수치, 재현 코드 미확인.
