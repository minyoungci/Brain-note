# Insights — 실패·실패지점·재사용 가능한 교훈 아카이브

목적: 실패한 실험과 그 실패 지점, 그리고 거기서 얻은 인사이트를 구조화 저장해, 추후 연구
방향 설정·함정 회피·novelty 발굴에 재사용한다. (사용자 지시, 2026-06-14부터 상시 적용)

작성 규칙: 각 파일은 **(1) 무엇을 시도했나 (2) 어디서/왜 실패·정체했나 (3) 재사용 가능한
인사이트 (4) 증거/스크립트 포인터** 순으로. 결과 수치는 재현 가능한 산출물을 가리킨다.

## 색인
- [I01](I01_freesurfer_vqa_circularity.md) — FreeSurfer-percentile VQA: 2단계 circularity (vision novelty 구조적 불가)
- [I02](I02_amyloid_null_and_morphometry_oracle.md) — Amyloid-from-MRI: representation-robust null + morphometry-oracle taxonomy
- [I03](I03_data_reality_checks.md) — 데이터 현실 점검: manifest headline의 함정, 날짜 복원, base-rate/교란
- [I04](I04_engineering_pitfalls.md) — 엔지니어링 함정: cache 정렬 오류, tag 충돌, 소표본 AUC 인플레이션
- [I05](I05_methodology_and_design.md) — 방법론·설계 인사이트: leakage-safe fusion, gating 검증, 정직한 바
- [I06](I06_longitudinal_contrastive_harmful.md) — longitudinal same-subject contrastive는 진행 task에 해롭다 (invariance-to-progression) + fusion 이득 대부분 noise
- [I07](I07_whattofuse_amyloid_clinical_dominant.md) — 무엇을 fuse(amyloid): 임상/유전 지배·T1 image marginal (CN에서 image 증분 0)
- [I08](I08_mci_conversion_feasibility.md) — MCI→AD 전환: 최선의 non-circular task이나 N=134·PET3%·engineered바0.831 제약
- [I09](I09_multimodal_alignment_transfer.md) — 첫 POSITIVE: multimodal alignment이 cross-cohort 전이 개선 (LOCO→한국 AD/CN +0.14)
