# I10 — actigraphy(circadian RAR)는 morphometry+clinical 위에 증분 없음 (천장이 behavior에도 성립)

## 무엇을 시도했나
9개 실패(전부 이미지가 engineered morphometry+clinical 천장을 못 넘음)의 탈출구로, **이미지에서 유도되지 않는** modality = actigraphy(손목 활동량, 10초 간격, circadian rest-activity rhythm)를 시도. 가설(I09 묶음 방향의 positive 절반): "구조 MRI는 saturated여도 비-이미지 행동신호는 천장 밖 증분을 줄 것."
- 데이터: AJU 라이프로그 ∩ MRI라벨 = T1+DTI+actigraphy 삼중모달 260명. CPU gating(GPU 0, 전처리 0).
- RAR 비모수지표 추출: IS/IV/RA/M10/L5/mean (raw activity가 아니라 circadian 지표 — Li-2025가 무가치라 한 raw level과 구분).
- 타깃: **MCI-vs-AD**(CN=11이라 제외), 바 = morphometry(32 vol) + clinical(age/sex/APOE). **CDR/MMSE는 바에서 제외**(circularity 회피, F1).
- `scripts/actigraphy_gating.py`, 247명(AD102/MCI145).

## 어디서/왜 (결과 = 깨끗한 null)
- AUC: clinical 0.517 / morph 0.642 / RAR_only 0.591 / morph+clin 0.638 / **morph+clin+RAR 0.663**.
- **증분 ΔAUC(RAR over morph+clin): 10-seed 평균 +0.0082 ± 0.0097, range[−0.011,+0.024], >0 in 9/10 → negligible/noise.** subject-bootstrap CI도 0 포함.
- **단일 seed(random_state=0)는 +0.024로 보였다 = 10-seed range의 운 좋은 최대값.** 하마터면 이걸 positive로 보고할 뻔 → I06/I03 소표본 단일분할 인플레이션 실증 재발(생성자=평가자 분리·multi-seed가 막음).
- RAR_only 0.591 > clinical 0.517: actigraphy가 *단독으로는* MCI-vs-AD 신호 일부 보유(문헌 Q1 포화 = severity 상관). 그러나 morphometry(0.642) 아래 + morphometry에 **redundant**(증분 0). I07의 "T1 image는 morphometry 못 미치고 clinical에 redundant"와 동형 — 이번엔 behavior가 morphometry에 redundant.

## 재사용 가능한 인사이트
1. **morphometry+clinical 천장은 이미지에만 성립하는 게 아니다 — 이미지와 구조적으로 직교한 behavior(circadian)도 못 넘는다.** 천장은 modality가 아니라 *target에 대한 engineered+clinical의 충분성*의 문제. (5축 → behavior축까지 6축 일관)
2. **대규모 선행(Li 2025 PLOS Dig Health, N=19,793: MRI 지배, wearable 무가치)이 우리 N=247 memory-clinic·circadian-RAR판에서 재확인됨.** "그들은 raw activity·건강인구라 우리는 다를 것"이라는 sliver 희망은 데이터로 기각.
3. **단일-seed CV 점추정 보고 절대 금지(소표본).** +0.024(seed0) vs +0.008(10-seed)의 3배 차. 헤드라인은 항상 multi-seed 평균±std + bootstrap CI.
4. **CN=11의 구조적 한계**: 문헌상 actigraphy가 빛나는 regime은 CN→impaired(조기), 우리가 가진 건 MCI-vs-AD(severity, actigraphy 최약 regime). 우리 데이터는 actigraphy의 best-case regime을 *테스트할 수 없다*. 데이터 CN-빈곤이 또 결론을 제약.
5. **이 데이터(한국 memory-clinic)는 actigraphy를 포함해도 깨끗한 positive를 못 만든다** → 묶음 방향의 positive 절반 empirically dead. negative/ceiling capstone 또는 powered 외부데이터(UK Biobank) 외 정직한 길 없음.

## 증거/포인터
- `scripts/actigraphy_gating.py`, `results/actigraphy_gating/RESULTS.md`, `results/actigraphy_gating/rar_features.csv`.
- 선행/반증: Li 2025 PLOS Digital Health(MRI 지배), Wang 2019 NeuroImage:Clinical(한국코호트 WM 증분 멀티사이트서 소멸), KBASE 2023(한국 WM=백인 동일).
- 연결: [[I07_whattofuse_amyloid_clinical_dominant]](redundant-with-clinical), [[I02_amyloid_null_and_morphometry_oracle]](천장 taxonomy), [[I06_longitudinal_contrastive_harmful]](bootstrap/multi-seed 규율).
