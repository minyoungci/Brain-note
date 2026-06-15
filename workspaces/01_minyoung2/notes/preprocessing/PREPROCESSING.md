# 전처리 파이프라인 (상세)

> FOMO26 규칙(전처리 자유, 추가 supervision 금지)은 [[../docs/00_challenge_rules]]. 무결성은 [[../docs/03_data_integrity]].

## 개요 — "전처리 어떻게 구성했나"
공식 `baseline-codebase`의 Yucca 전처리(검증 완료, 파일럿 IXI 15scan 성공)를 **그대로 사용** + 규칙 허용 범위 내 최소 추가(N4/QC/modality 태깅). robustness는 *전처리 제거가 아니라 augmentation 주입*으로(임상 OOD 대비).

## 공식 4단계 (Yucca, 무수정 사용)
입력 `subject/session/*.nii.gz` → 스캔별 독립(iid):
1. **crop_to_nonzero** — 0 아닌 최소 bounding box.
2. **volume_wise_znorm** — clamp(outlier) → z-norm(foreground) → **rescale [0,1]** (yucca 2.2.6 실제 동작, 소스 확인).
3. **1mm isotropic resample** + **RAS** 정렬.
4. 저장: `.npy`(이미지) + `.pkl`(메타: spacing/crop/orientation).
- 실행: `.venv/bin/python baseline-codebase/src/data/fomo-60k/preprocess.py --in_path=<raw> --out_path=<out> --num_workers=N`

## 추가 단계 (규칙 준수 — 코드/메타데이터만, 외부 supervision 無)
- **N4 bias field 보정** — 스캐너 intensity 불균일 제거(공식 4단계엔 없음). FAQ 허용.
- **알고리즘 QC 필터** — 손상/모션/저SNR 스캔 제외(SNR/sharpness metric, *외부 QC 모델 아님*).
- **modality 태깅** — `mri_info.tsv`의 Modality/SeriesDescription에서 T1/T2/FLAIR/PD/DWI 식별 → 멀티모달(②) 활성화.
- (skull-strip·정합은 ablation으로만 — domain gap 주의.)

## Branch별 상세

### Branch A: pretrain-prep (FOMO300K → SSL)
- FOMO300K zip(`/home/vlm/data/FOMO300K`, 세션별 zip) → **`extract_arrange.py`**(subject/session/*.nii.gz 정렬) → 공식 `preprocess.py` → npy.
- **용량**: scan당 ~35MB. full(165K~260K)=6~9TB > 디스크 3.6TB **초과** → **30~60K subset**(findings: scaling 무효). 배치 단위 추출→전처리→임시 nii.gz 삭제로 temp 관리.
- status: 스크립트 검증 완료(파일럿). subset 선정·실행은 데이터/Phase A에서.

### Branch B: downstream-prep (7 task → finetune/probe)
- 공식 `run_preprocessing.py --taskid=N --source_path=<raw>` (task별).
- **⚠️ pretrain과 *동일* 전처리**(crop/znorm/1mm/RAS + 동일 추가단계) = **domain gap 방지**(무결성 핵심).
- status: downstream 데이터 미확보(등록 필요).

## 무결성 (필수)
- **subject-disjoint**: pretrain ∩ downstream-test = ∅ 코드 검증([[../docs/03_data_integrity]] #1).
- **pretrain = downstream 전처리 동일**.
- per-volume 처리 → 교차 누수 없음.

## 파일
- `extract_arrange.py` — FOMO300K zip → 공식 입력 구조 정렬(modality 필터 지원).
- (공식 전처리 코드: `baseline-codebase/src/data/`)
