# data · 데이터 지식 (minyoungi ipynb tutorial 기반)

> **목적:** minyoungi `Clinical/` 교육용 노트북에서 추출한 데이터의 세밀한 사실을 집약  ·  **출처:** minyoungi `Clinical/notebooks/00~06`, `Clinical/consortiums/<C>/01~03`, `Clinical/VOXEL_ANALYSIS_PLAN.md`, `roi_qc/`  ·  **갱신:** 2026-06-02

본 영역은 `../00_data_manifest.md`(요약)를 코호트·노트북 단위로 **세밀하게 확장**한 것이다.
모든 수치는 노트북 헤드리스 실행 출력 또는 manifest 실측이며, 재현 도구는 `OBSERVATORY/tools/nb_text.py`.

## 문서 목록

| 문서 | 출처 노트북 | 내용 |
|---|---|---|
| `manifest_and_overview.md` | 00, 01 | 3-way join 구조, 스키마, 코호트별 진단/CDR/종단 개요 |
| `roi_volumes.md` | 03 + roi_qc + VOXEL_ANALYSIS_PLAN | 그리드 정합, ROI BLOCKED_PROVISIONAL, 부피 분석 |
| `cdr_target_and_harmonization.md` | 05, 06 | CDR 공통 타깃 설계, ComBat site harmonization |
| `challenges.md` | 02, 04 | 표현학습 난점(불균형/site effect/signal dilution/label noise/MCI 이질성) |
| `cohorts/<C>.md` (7) | consortiums/\<C\>/01~03 | 코호트별 raw clinical·ID 매핑·커버리지·변수·함정 |

## 핵심 검증 사실 (재현됨)

- ✅ master_df = **13,022 × 44, 행 손실 0%, 중복 0**, 라벨 커버리지 96.86%.
- ✅ CDR global 분포(세션): 0→7,080 / 0.5→4,931 / 1→831 / 2→161 / 3→19. **CDR은 7코호트 100% 보유**.
- ✅ 그리드: `final_tensor`(192×224×192, identity, z-score)와 option_b aseg/ROI는 동일 격자 → 리샘플 불필요.
- ✅ 해마 부피 CN vs AD: 7,680±762 vs 6,455±1,288 mm³, Mann-Whitney p=3.27e-08 (단, ROI는 후보).
- ✅ ROI→CDR 분류: CDR≥1 vs CDR0 AUC 0.895±0.019 (n=8,091) — 단 LOCO 미적용(site 누수 가능).
- ✅ ComBat: site 분류 정확도 0.407→0.362(chance 0.364 수준)로 site 신호 제거, 질병 신호(ROI→CDR AUC)는 보존.

## ⚠️ 반드시 인지할 함정·미해결 (`[VERIFY]`)

1. **ROI 전수 BLOCKED_PROVISIONAL.** 13,022행 `roi_final_ready=False`, `do_not_use_for_atlaswide_roi_features=True`.
   → 03·05·06·코호트 02/03의 모든 ROI/부피 수치는 "검증"이 아닌 **후보(provisional)**. 부피는 native mm³가
   아니라 final-grid voxel_count(+MaskVol을 ICV 프록시; VINN eTIV 부재).
2. **centroid 함정.** summary JSON `centroid_voxel`은 256-conformed 좌표(그리드와 ~31vox 어긋남) →
   크롭 중심은 `expected_centroid_final_voxel`/마스크 재계산. 단 `voxel_count`/`physical_volume_mm3`는 신뢰 가능.
3. **APOE는 NACC-only가 아니다.** A4에도 `APOEGN` 존재(`clinical_io.py` 로더 대조). NACC-only는 **MoCA**.
4. **NACC 결측코드 함정.** `88/99/-4`가 정수로 저장 → `isna()`가 결측을 0%로 오판. 디코딩 전 통계 금지.
5. **raw diagnosis ≠ master diagnosis.** raw_input_manifest(중복 포함) 카운트와 master_df(dedup·join 후)
   카운트가 다름. 집계 시 master 기준 사용.
6. **코호트 진단 출처 불일치(미해결):**
   - **KDRC**: 노트북 01은 diagnosis 보유(결측 0%, 3범주)·CDR 36.9% 결측으로 보고 → master_df의
     "KDRC diagnosis 전무·CDR 전수"와 **반대**. 어느 소스가 학습 권위인지 확정 필요.
   - **OASIS**: master_df의 CN1126/MCI42/AD252가 `cdr_global`·raw_input 어느 쪽으로도 직접 재현 안 됨.
   - **AJU**: 진단 split(CN23/MCI998/AD220)이 raw clinical/manifest에 진단 컬럼이 없어 재현 불가
     (CDR 분포는 직접 집계 가능: subject-level 0/27·0.5/776·1/159·2/34·3/5).
   - 상세는 각 `cohorts/<C>.md`의 `[VERIFY]` 섹션 참조.

## 재현 방법

```bash
# 노트북 텍스트(마크다운+텍스트출력, 이미지 제외) 추출 — stdlib만, uv 불필요
python3 /home/vlm/minyoung/OBSERVATORY/tools/nb_text.py <notebook.ipynb> [max_out_lines]
```
