# roi_qc/notebooks/

roi_qc의 **ROI QC 검수용** 노트북. (Clinical/의 raw-data 이해 튜토리얼과는 계보가 다름 — 이쪽은 ROI usability 품질 점검.)

| 노트북 | 용도 | 의존 |
|---|---|---|
| `roi_inspection.ipynb` | 임의 세션의 **MRI ↔ ROI overlay ↔ QC label/FastSurfer L/R 부피/임상**을 한 화면에서 cross-check. `roi_usability`(USABLE_AUTO/USABLE_W_CAVEAT/REVIEW_REQUIRED/ROI_UNUSABLE/NOT_CANDIDATE)별 샘플 검수. | `../scripts/roi_verify_viz.py` (전용 helper, 절대경로 import) |
| `embedding_diagnostics.ipynb` | **학습된(SSL/foundation) 표현 4-panel 진단**: collapse / site-probe(chance 0.143) / utility(age·sex) / morphometry baseline-gap. 자동 verdict("생물학 대신 하드웨어를 배움" 등). 목표 (C) FOMO300K 사전학습 모델을 우리 T1w 임베딩으로 평가. stand-in 데모로 하네스 검증됨. | `../scripts/embedding_diagnostics.py` (절대경로 import); manifest fs_vol + img_features |

- 데이터: `official_manifest_full.parquet` (13,022×75, `roi_usability` 포함)
- 실행: `base`(`/opt/conda`). import 경로는 절대경로라 어느 CWD에서도 동작.
- **데이터 이해 튜토리얼을 인사이트 축으로 찾으려면 → `../../Clinical/INSIGHTS.md`**
