# minyoung2 — risks & open weaknesses

> **목적:** EXP01 thesis·방법론·운영 약점과 검증 경로 정리  ·  **출처:** docs/EXP01_REVIEWER2_CRITIQUE.md, reports/EXP01_OVERVIEW.md, experiment_ledgers  ·  **갱신:** 2026-06-02 (커밋 bb9b29f)

## thesis-level blocker

### B1. deep ≈ 5-ROI regional volume (핵심 가치 명제 붕괴) ⚠️

- **지적될 지점**: 핵심 framing "학습된 T1 표현이 nuisance/geometry 너머 가치를 가진다"가, baseline을 전뇌용적 → 5-ROI 위축으로 강화하자 소멸. 5/5 evaluable fold 무승부, pooled에서만 +0.018 AUROC. deep 복잡도가 정당화되지 않는다.
- **확인 방법**: `...regional-volume-baseline-critical.md` Δ(img−reg) CI 표. 모두 0 포함. 3D CNN(IMG-020/021/022)이 regional을 유의하게 이기는 fold가 하나라도 나오는지가 분기점.

### B2. +0.018 (유일 양성)의 통계가 취약 (exchangeability 위반) ⚠️

- **지적될 지점**: pooled bootstrap이 fold별로 다른 held-out cohort·다른 combiner의 test를 단순 concat → between-cohort 이질성을 within-resample로 흡수, CI 과소추정. Reviewer-2 [F3] fatal.
- **확인 방법**: cohort를 random effect로 둔 random-effects 메타분석(DL/REML, τ² 보고) + cohort-cluster bootstrap 병행. 둘 다 하한>0이어야 +0.018 주장 유지. `[VERIFY]` 현재 미수행.

### B3. 음성 주장이 검정력 부족과 구별 불가 ⚠️

- **지적될 지점**: per-fold n=600~1440은 ΔAUROC<~0.03을 detect 못 함. "deep≈regional 무승부"가 효과 부재인지 검정력 결핍인지 미분리(Reviewer-2 [F1]).
- **확인 방법**: equivalence test(TOST) + 사전 비열등 마진 δ로 "90% CI가 [−δ,+δ] 안"을 입증. `[VERIFY]` 미구현.

## 실패모드 / 열린 약점

### W1. LOCO seed 불안정 (단일-run 주장 위험)

- **지적될 지점**: NACC/AIBL 일부 seed가 붕괴(예 0.486/0.444), in-dist val은 높으나 held-out transport 실패. grad-accum·warmup·brain-pretrain·OOD-select 모두 교정 실패. group-DRO도 NACC만 안정화, AIBL은 새 붕괴(IMG-019).
- **확인 방법**: ≥10 seed + 붕괴seed(val<0.55) 사전 정의 처리정책(Reviewer-2 [M3]). 현재 5-seed도 부족. 3-seed→5-seed에서 F8이 뒤집힌 전례가 경고.

### W2. val 체크포인트가 in-dist → OOD test gap

- **지적될 지점**: best-checkpoint를 in-dist val AUPRC로 선택 → held-out cohort와 분포 gap. F5 불안정의 직접 원인.
- **확인 방법**: cohort-out val(IMG-015)은 이미 음성. last-k 평균 / EMA / 외부 검증 set 비교가 future work.

### W3. regional baseline 측정 타당성 (LOCO 치명 가능)

- **지적될 지점**: regional ROI가 raw voxel_count(ICV 미정규화, FreeSurfer 아닌 자체 mask). cohort 간 voxel spacing 차이 → voxel_count가 site effect를 학습할 위험 → LOCO에서 baseline이 부풀거나 무너짐(Reviewer-2 [M1]).
- **확인 방법**: ICV 정규화 + mm³ 물리부피 + cohort별 segmentation QC + age/sex 공변량을 baseline·deep combiner 동일 적용 후 F9 재실행. `[VERIFY]` 미수행.

### W4. RAM 압박 (서버 다중 프로세스 종료 이력)

- **지적될 지점**: 총 RAM 2435GB, full-volume 3D 캐싱이 OOM 위험. jobs가 SIGHUP으로 반복 종료(setsid 미분리). SSH/세션 종료 시 학습 전멸 → 결과 미생성(IMG-020/022 산출 디렉토리 비어 있음).
- **확인 방법**: setsid 분리(SID=PID, PPID=1) + `--mem-cap-pct 90`(>90%면 캐싱 중단) 적용됨. 로그 폴링으로 생존·진행 확인. `[VERIFY]` systemd cgroup 하드캡은 user-bus 부재로 불가 → 앱레벨 가드만.

### W5. 단일 약백본 (deep 상한 미입증)

- **지적될 지점**: resnet18 단일·2.5D·1세션. ConvNeXt-ImageNet은 val 0.50으로 학습 실패 → "강한 deep을 제대로 안 했다"는 반론에 무방비. 결론이 "deep 2.5D 표현"이 아니라 "이 특정 파이프라인"으로 축소(Reviewer-2 [F2]).
- **확인 방법**: 3D 백본(IMG-020) + 도메인 사전학습 백본 ≥1 + ConvNeXt 0.50 근인 규명, 전부 동일 LOCO/controls/combiner. 하나라도 regional을 이기면 thesis가 "작지만 실재 이득"으로 강화. `[VERIFY]` 3D 결과 미생성.

## framing / 절차 약점

- **deep≈volumetry의 thesis 함의**: 정직한 결론이 parsimony/cautionary(음성+방법론)로 강등 → MedIA/TMI는 novelty 부족 reject 위험. NeuroImage:Clinical/HBM은 F1/F2/F3 닫으면 가능권(Reviewer-2 venue 판정).
- **다중비교 보정 부재**: fold×cohort×subgroup 15~20 검정에 Holm/BH 미적용 → "NACC만 안정화" cherry-pick 위험([M2]).
- **LOCO 라벨 무결성 `[VERIFY]`**: baseline_broadcast 라벨 timestamp audit(미래정보 누수?), IMPAIRED≥0.5가 7 cohort 동일 척도인지, A4 제외 sensitivity 미검증([M4]).
- **F3b vs F9 표면상 모순**: deep>전뇌용적(F3b)과 deep≈5-ROI regional(F9)은 baseline 차이로 분리 설명 필요. 진짜 발견은 "regional이 전뇌용적보다 강한 baseline"([m3]).

출처: `docs/EXP01_REVIEWER2_CRITIQUE.md`, `reports/EXP01_OVERVIEW.md` F5/F8, ledger 3건(regional/deep-probes/img-019), 커밋 bb9b29f.
