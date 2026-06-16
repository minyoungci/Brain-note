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
- [I10](I10_actigraphy_no_increment_over_morphometry.md) — actigraphy(circadian RAR)도 morphometry+clinical 천장 못 넘음(ΔAUC +0.008±0.010 noise). 천장이 behavior축에도 성립; 단일-seed +0.024는 운나쁜 인플레이션
- [I11](I11_snsb_domain_dissociation_and_decline.md) — 새 자산(다site 한국 cerebrovascular+SNSB 도메인z+종단292). morphometry=1차원 전반-중증도 센서: 기억-특이만 잡고(+0.030) 집행/언어/시공간-특이 0%·종단저하 예측불가(R²<0). 유일 균열=morphometry가 0인 reliable executive-specific 변량(DTI 후보, EV중간). 추가: radiomics shape 196개도 음수(−0.23)→volume·shape·WMH 전부 null, DTI EV 하락
- [I12](I12_ceiling_meta_topic_preempted_by_literature.md) — "예측-법칙" 메타토픽은 Schulz/Bzdok(Nat Commun'20·Cell Rep'24)·Bron'21에 경험적 칸 전부 선점. 생존 각도=딥모델 학습 전 S·M 싸게 계산하는 a priori 스크리닝 *규칙*(method, MIDL tier). 진짜 미점유 자산=심층표현형 한국 VCI 코호트(ML 아닌 임상 finding 쪽)
