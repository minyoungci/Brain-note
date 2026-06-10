# ROI QC — 작업 상태 / 핸드오프

_최종 업데이트: 2026-06-01_

## 현재 실행 중인 백그라운드 작업
- **전수 auto-anatomical-QC** (`scripts/run_autoqc_full.py`, 12 workers)
  - 대상: `manifest_roi_qc.parquet`의 `voxelwise_qc_candidate == True` 12,978개
  - 실행: `./run_bg.sh autoqc_full /opt/conda/bin/python scripts/run_autoqc_full.py 12`
  - detach 방식: `setsid + nohup`, PPID=1 → SSH/세션 끊겨도 생존
  - 체크포인트: `reports/autoqc_full_checkpoint.jsonl` (세션당 1줄 append)
  - **재개 가능**: 재실행하면 checkpoint에 있는 tag는 건너뜀 (중단돼도 in-flight만 손실)
  - 진행 로그: `reports/autoqc_full.log`, stdout: `reports/autoqc_full.out`
  - PID: `reports/autoqc_full.pid` / 중지: `kill $(cat reports/autoqc_full.pid)`
  - 완료 시 산출물: `reports/autoqc_full.parquet`
  - ETA ≈ 60~90분

## 완료된 것
- JPG 시각화 → `samples/` (대시보드 2 + flagged 7 + pass_examples 14)
- 455개 stratified 샘플 auto-QC → `reports/visual_qc_worksheet.csv` (448 PASS / 7 FLAG)
- montage PNG: `montages/{pilot,tier1,tier2}/` (464개)
- 수치 QC 결합 manifest: `manifest_roi_qc.parquet` (13,022, 커버리지 99.7%)
- 시각 QC 기준 문서: `VISUAL_QC_CRITERIA.md`

## 전체 검토 완료 (2026-06-01)
- 전수 auto-QC: 12,932 PASS / 46 FLAG / 0 ERROR (`reports/autoqc_full.parquet`)
- FLAG 46개 vision 검토 완료 → 30 benign / 11 review / 5 real-underseg
- PASS 표본 21개(코호트당 3) vision 검토 → gross 오류 0개
- merge + 사용가능성 판정: `manifest_roi_qc_final.parquet` (`roi_usability` 컬럼)
  - USABLE_AUTO 12932 / USABLE_W_CAVEAT 30 / REVIEW_REQUIRED 11 / ROI_UNUSABLE 5 / NOT_CANDIDATE 44
  - **자동 게이트 통과 99.54%**, `roi_final_ready`는 전부 False (fail-closed)
- 최종 리포트: `ROI_USABILITY_REPORT.md`

## 통합 manifest + 시각화 (2026-06-01)
- 최종 통합 manifest: `/home/vlm/data/preprocessed_official/official_manifest_full.{parquet,csv}` (13,022×75) + `.README.md`. 원본 csv 불변.
- 빌드/검증 스크립트: `scripts/{parse_fastsurfer_stats,build_clinical_join,check_file_exists,merge_full_manifest,verify_full_manifest}.py` (verify 19/19 PASS)
- **ROI↔MRI 시각 대조**: `scripts/roi_verify_viz.py` (`make_verify_figure(row)`) — MRI+ROI 오버레이 + usability/FS volume L/R/clinical 한 장 결합
  - 갤러리 JPG: `samples/roi_verify/` (UNUSABLE 5 + REVIEW 3 + cohort별 USABLE 7)
  - 인터랙티브 노트북: `notebooks/roi_inspection.ipynb` (TAG 바꿔 임의 세션 확인)
- 기존 tutorial ipynb 28개(`Clinical/`)는 전부 미수정 확인

## 남은 단계 (사람 손이 필요한 것)
1. REVIEW_REQUIRED 11 + ROI_UNUSABLE 5 사람 최종 확인
2. PASS subtle-error 정량화: 더 큰 표본 사람 κ-rating (montage 해상도로는 gross만 잡힘)
3. 사람 sign-off 후에만 `roi_final_ready=True` (numeric ∧ visual PASS ∧ human approval)

## Site/scanner shortcut + N4 검증 (2026-06-02)
- **v2에 N4 미적용 확인** (z-score만) → 메모리 `v2-no-n4-bias-correction.md`
- **site probe**(`scripts/probe_site.py`, 2800표본): APPEARANCE balanced_acc 0.565 vs chance 0.143; biology(brain_vox) 0.155≈chance → 누수는 강도/대비(스캐너 지배)
- **N4 mini-exp**(비파괴, `scripts/n4_extract_features.py`→`img_features_n4.parquet`, grid_match≥0.99 전수): N4를 FastSurfer 뒤 이미지에만 적용, ROI 무영향
- **반복 split 결과**(`scripts/probe_robust.py`→`reports/site_probe_robust.txt`, K=20):
  - cross-consortium 0.503→0.433 (19/20, 실제 감소)
  - **within-ADNI 벤더(모집단 고정) 0.748→0.589 (18/20, 실제)** = 순수 스캐너 bias 절반 감소, chance(0.333) 미달
  - within-NACC 판정불가(표본 부족)
- 결론: N4는 스캐너 bias 줄이고 생물학 보존, but 절반만. 단일벤더 AJU는 N4 무효(0.73→0.81). 상세: `research_notes/daily/2026-06-02.md`
- **harmonization 4-arm 테스트 완료(`scripts/{n4_ws,n4_nyul}_extract_features.py`, `probe_compare4.py`→`reports/site_probe_compare4.txt`):**
  - within-ADNI STRUCTURE(순수 스캐너): baseline 0.794 / N4 0.624 / N4+WS 0.713 / N4+Nyúl 0.614
  - **N4 ≈ Nyúl(동률, 0.01차<std), WS 최악 → N4 단독 확정.** Nyúl의 cross 이득은 모집단까지 정렬 위험(보존 대상).
  - intensity 천장: 순수 스캐너 0.62, chance 0.33 — 강도 보정만으론 한계.
- 다음 후보: ①**N4 단독 전체 13,022 재처리**(post-FastSurfer, 새 경로, 승인 필요, 레시피 확정) ②N4 pre/post 분할 민감도 ③ADNI 벤더 층화 ④train aug(모집단 누를 위험)

## "완벽한 manifest" 작업 (2026-06-02, 진행중)
목표: 1개 CSV에 식별·경로(원본+N4)·취득기하(voxel/scanner)·QC·FS vol·공통clinical·bias메타 100% 검증가능. 원본 불변, 누적.
- **Task 0 (완료)**: N4 전체 재처리 `scripts/n4_reprocess_full.py`(64w, shrink=2). **13,022/13,022, 0 에러, 279분, grid_match min 0.990.** 출력 각 `t1w/final_tensor_n4/`(원본 불변). 효과(`n4_prod_reprobe.py`, 2800표본 20/20): within-ADNI 순수스캐너 0.84→0.66(FULL)/0.82→0.61(STRUCT), cross 0.56→0.51. → 정밀 N4가 site 크게 감소.
  - verify(`n4_reprocess_verify.py`) 3 FAIL = **전부 양성**: ①brain_loss>1% 1개(NACC, 1.12%, 원본과 동일·crop고유) ②③near-no-op 47개(0.36%, AJU22/A420 = 이미 균일한 이미지라 N4 정당하게 무변경; median spread 1.73·diff 0.47로 본체는 강보정). 게이트가 "전수 절대"라 엄격했을 뿐.
- **Task 1 (완료)**: voxel native헤더 복구 `scripts/extract_acq_voxel.py`→`reports/acq_voxel.parquet`. **13,022/13,022=100%**, 전부 hdbet 헤더. → 메모리 [[manifest-acq-voxel-site]]
- **Task 2 (완료)**: `official_manifest_full_n4.{parquet,csv}` **(13,022×97) = 완벽한 manifest.** 75통합+10 N4+8 voxel+4 scanner. 원본 불변, row-invariant, 검증 PASS. 빌드: `scripts/{merge_voxel_into_n4_manifest,extract_scanner_meta}.py`.
  - voxel: 7코호트 100%. scanner(`acq_scanner`/`acq_scanner_raw`/`acq_field_strength`/`acq_scanner_source`): 88.9% (v7 9979 + a4_json 1811). **KDRC scanner는 익명화로 소실 → 909 전부 'unavailable'**(데이터 부재, 날조 안 함). A4는 JSON sidecar로 par 달성.
- **Task 3 (완료)**: 7코호트 해상도 probe `scripts/probe_resolution7.py`→`reports/site_probe_resolution7.txt`(측정만, manifest 무변경). **voxel-only 코호트 0.699**(chance 0.143): A4 0.99/NACC 0.95/OASIS 0.90/AIBL 0.85/AJU 0.80 식별, **KDRC·ADNI 0.2**(해상도 분포 넓어 서로 겹침 → 가설 부분 오류). within-ADNI voxel→벤더 0.639(순수 스캐너). **voxel이 N4 이미지에 +0.296**(0.513→0.808) = 거대 독립 축. ⚠️ 단 메타데이터 기준; image-level edge 차이는 완만 → blur로 줄일 실제량은 Task 4로 확인. floor 후보 ~1.2–1.5mm.
- **Task 4 (완료, NO-GO)**: blur-to-floor(T=1.3mm) 테스트 `scripts/blur_reprobe.py`→`reports/site_probe_blur.txt`(측정만). **image-level site 감소 없음**: cross FULL 0.511→0.542(악화), within-ADNI STRUCT 0.606→0.613(무변화), edge −2.7%(디테일만 손실). → Task3의 voxel +0.30은 메타데이터 한정, resample 이미지엔 blur-제거 가능 형태로 없음. **harmonization 3종(WS/Nyúl/blur) 전부 N4 대비 무이득 → 탐색 종료. N4가 유일 효과 레버.**

## clinical backfill (2026-06-03) — manifest 13,022×101
- `scripts/backfill_sex.py`: A4 sex 0→100%(manifest `sex`, raw 1=F/2=M), ADNI sex 0→100%(PTDEMOG PTGENDER 1=M/2=F).
- `scripts/backfill_clinical.py`: AIBL age 0→100%(aibl_manifest_labeled), AJU dx 0→96%+cdrsb(aju_session_labels), OASIS age/sex 29→100%+dx 29→85%+cdrsb(oasis_session_metadata/labels, sex 기존값과 100% 일치 검증).
- provenance: `clin_{sex,age,dx,cdrsb}_source`. NaN-only 채움, 기존 검증값 불변, dx 스킴 내, 재읽기 무결 — 전부 검증 PASS.
- **남은 결측=진짜 소스 부재(날조 안 함)**: clin_sex 139(KDRC), clin_age 182(KDRC139/ADNI43), clin_dx 439(OASIS211/KDRC139/AJU46/ADNI43), acq_scanner 1451(KDRC909 익명화/NACC361/AJU177 = reingest 미존재). AJU 177 scanner는 session_metadata에도 0개 → genuine 확정.

## 최종 결론 (harmonization 워크스트림)
- **`official_manifest_full_n4` (13,022×97) = 학습용 완성 manifest.** N4(스캐너 bias 절반 감소, 모집단 보존)+voxel(100%)+scanner(88.9%, KDRC 소실).
- 잔여 site = 강도 보정 천장 + 메타데이터 차이(blur 불가). 유일 미시도=train-time aug(RandSimulateLowResolution), 기대치 낮음, 학습 단계 사안.
- 원칙: 한 번에 하나씩, 검증 게이트, 동시 과다작업 금지

## 주의
- `auto_verdict ≈ PASS`는 **전송 자기일관성**일 뿐, FastSurfer 원본 분할 오류는 못 잡음 → vision 필수
- `sample/` (단수) 보호 디렉토리. 우리 산출물은 `samples/` (복수)
