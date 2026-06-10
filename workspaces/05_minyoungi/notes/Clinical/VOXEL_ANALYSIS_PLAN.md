# Voxel-level 분석 조직 설계 (제안)

> 멀티에이전트 워크플로(3개 설계안 + 심사 + 적대적 비평)로 도출. 핵심은 두 가지 **검증된 사실**과
> 두 가지 **함정**을 전제로 데이터를 정리하는 것.

## 0. 전제: 반드시 인지할 사실 / 함정

**검증된 사실**
1. `final_tensor`(192×224×192, identity affine, z-score)와 `option_b` aseg/ROI grid는 **동일 그리드** →
   리샘플·affine 변환 없이 `tensor[c]`와 `mask[c]`를 직접 인덱싱 가능.
2. `option_b`는 manifest **전수 13,022행 100% 존재**(grid aseg + 16 ROI 마스크 + summary JSON).

**함정 (워크플로가 적발)**
1. ⚠️ **ROI는 공식적으로 BLOCKED_PROVISIONAL**: manifest 전수에서
   `do_not_use_for_atlaswide_roi_features=True`, `roi_final_ready=False`,
   `roi_final_grid_qc_status=BLOCKED_PROVISIONAL`,
   `roi_block_reason="FastSurfer-to-native transfer requires ROI-specific visual approval;
   legacy ROI dirs and repair candidates are provisional."`
   → **ROI 기반 수치는 "검증됨"이 아니라 "후보(candidate)"**. 정량 주장 전 per-ROI QC 게이트 필요.
2. ⚠️ summary JSON의 `centroid_voxel`는 **256-conformed 좌표**(final_tensor 그리드와 ~31 voxel 어긋남).
   큐브 크롭 중심은 **`expected_centroid_final_voxel`** 또는 **마스크에서 재계산한 centroid**를 써야 함.
   (`voxel_count`/`physical_volume_mm3`는 그리드와 일치 — 부피는 신뢰 가능.)

**원본 보호**: raw 데이터/마스크는 복사·이동·수정 금지. 산출물은 신규 디렉토리에 두고 경로 참조/symlink만.

## 1. 권위 인덱스 (단일 진실원)

`Clinical/voxel_dataset/voxel_manifest.parquet` — 1 row = 1 session (13,022).
official_manifest.csv에서 파생, 모든 경로는 `final_tensor_path`에서 유도(`mri_io.t1w_dir`; session_id '.0' 재구성 금지).

| 컬럼 | 내용 |
|---|---|
| consortium, subject_id, session_id, qc_t1w_key | 키 |
| ft_zscore_path, brain_mask_path, aseg_grid_path, roi_mask_dir | 경로(참조) |
| cdr_global, cdr_bin (0/0.5/≥1), cdrsb, diagnosis | 라벨 |
| icv_proxy(MaskVol) | 정규화 분모 |
| has_option_b, aseg_shape_match, aseg_identity, n_labels | 그리드 정합 QC |
| **roi_provisional=True**, roi_block_reason | ⚠️ QC 상태(전수 BLOCKED_PROVISIONAL) |
| split (train/val/test), fold | site-stratified subject split 결과 |

## 2. per-ROI voxel QC 게이트 (정량 주장 전 필수)

`Clinical/voxel_dataset/roi_voxel_qc.parquet` — 1 row = (session, ROI).
`_reports/roi_transfer_option_b_*`의 batch_results(per-ROI `overlap`, `volerr`, `cshiftvox`, `status`)를
UNION(A4 별도 report 포함). `roi_pass = (status==PASS) & (overlap≥τ) & (volerr≤τ)`.
→ **이 게이트를 통과한 (session,ROI)만 정량 분석에 사용**. 통과율 자체가 핵심 EDA 산출물.

## 3. 학습용 데이터셋 (두 형태, 목적별)

**(A) ROI-cube 데이터셋** — signal-dilution 회피, 소형 구조 집중
`Clinical/voxel_dataset/cubes/` : 각 ROI의 **expected_centroid_final_voxel(또는 마스크 재계산 centroid)** 중심 48³ 큐브.
- `cube_manifest.parquet`: (session,roi) + cube_center/origin + inside_brain_frac + roi_voxel_count + roi_pass + cdr_bin + split
- 텐서: `tensors/<consortium>/<subj>__<sess>/<roi>.npy` (float32 z-score; 재정규화 안 함) + `<roi>_mask.npy`(uint8)
- 큐브는 bilateral 통합(정중선 구조는 48³로 양반구 포함).

**(B) whole-brain + label-volume 페어** — segmentation/ROI-attention
`final_tensor`(채널1) + `aseg_grid`(label) 쌍. 리샘플 불필요(동일 그리드). MONAI PersistentDataset 캐시는 `cache/`에만.

## 4. 분할 / 라벨 / 정규화 (누수·편향 방지)

- **split**: `splits/site_stratified_subject_split.json` — subject_id 단위(세션/ROI 누수 0),
  consortium × cdr_bin 층화, seed 고정. `split_summary.csv`로 누수 0 검증.
- **label**: 1차 = CDR 3-bin(0/0.5/≥1) ordinal. **A4는 분리**(preclinical, CDR≥1=36뿐 → CDR0/0.5만 또는 보조 코호트).
  2차 = CDR0 vs CDR≥0.5 binary. 보조 = CDR-SB 연속(AIBL 결측 → 제외).
- **정규화**: 부피는 MaskVol(ICV proxy)로 — 단 MaskVol은 진짜 eTIV 아님. intensity는 이미 z-score.
- **harmonization** _(2026-06-02 갱신: 실측 근거)_:
  - **이미지 강도: N4 채택** (post-FastSurfer, 이미지에만). 실측상 순수 스캐너 bias를 줄이고(within-ADNI 0.75→0.59~0.62) **모집단 생물학은 보존**. WhiteStripe(WM-ref)·Nyúl은 N4 대비 추가이득 없어 제외. v2엔 N4가 원래 없었음(z-score만). 상세: `research_notes/daily/2026-06-02.md`, memory `v2-no-n4-bias-correction`.
  - **⚠️ ComBat-on-site / site-adversarial 주의**: 이 데이터는 site==모집단 교란(AJU/KDRC 한국인 vs 서구). site 라벨을 제거대상으로 삼으면 **보존해야 할 모집단 생물학까지 지움**. ComBat 쓸 거면 age/dx 등 보호변수 필수 + train에만 fit→apply(누수 금지), 순서 고정.
  - **해상도/voxel은 독립 site 축**(N4 무관): voxel만으로 코호트 0.53·AJU 0.92. native 헤더로 voxel 100% 복구(`roi_qc/scripts/extract_acq_voxel.py`). 필요시 resolution aug(RandSimulateLowResolution, 비파괴) 별도 검토. memory `manifest-acq-voxel-site`.

## 5. 산출 순서 (첫 deliverable부터)

1. `voxel_manifest.parquet` (§1) + 그리드 정합 전수 QC.
2. `roi_voxel_qc.parquet` (§2) — batch_results UNION, ROI 통과율 리포트. **여기서 BLOCKED_PROVISIONAL의 실제 영향 정량화**.
3. site-stratified subject split (§4).
4. ROI-cube 데이터셋 (§3A) — 통과 ROI만.
5. 검증 노트북: 큐브 무결성(centroid·brain_frac), CDR-bin 분포×split, site 누수 0.

> 요약: **"option_b는 후보"**라는 QC 현실을 1급 시민으로 다루고(§2 게이트), 그리드 동일성(리샘플 불필요)과
> 올바른 centroid(expected_final)를 활용해 누수 없는 site-stratified 데이터셋을 만든다.
