# 전처리 파이프라인 (상세)

> FOMO26 규칙(전처리 자유, 추가 supervision 금지)은 [[../docs/00_challenge_rules]]. 무결성은 [[../docs/03_data_integrity]].

## 개요 — "전처리 어떻게 구성했나"
**결정(2026-06-20): 공식 Yucca 4단계만 무수정 사용. N4/QC/modality 등 추가단계는 메인에서 제외(ablation-only).**
근거: ① 공식 baseline이 N4 미사용 → pretrain↔downstream 도메인갭 방지(무결성 핵심) ② N4를 251K scan에 돌리면 막대한 추가 compute+실패모드 ③ 추가단계는 *현재 코드에 미구현*(grep 확인, 계획일 뿐). robustness는 *전처리 제거가 아니라 augmentation 주입*으로(임상 OOD 대비). ⚠️ 옛 AD 프로젝트는 N4를 썼으나(`preprocessed_official`의 n4 manifest), FOMO는 별개 파이프라인 — 끌어오지 않음.

## 공식 4단계 (Yucca, 무수정 사용)
입력 `subject/session/*.nii.gz` → 스캔별 독립(iid):
1. **crop_to_nonzero** — 0 아닌 최소 bounding box.
2. **volume_wise_znorm** — clamp(outlier) → z-norm(foreground) → **rescale [0,1]** (yucca 2.2.6 실제 동작, 소스 확인).
3. **1mm isotropic resample** + **RAS** 정렬.
4. 저장: `.npy`(이미지) + `.pkl`(메타: spacing/crop/orientation).
- 실행: `.venv/bin/python baseline-codebase/src/data/fomo-60k/preprocess.py --in_path=<raw> --out_path=<out> --num_workers=N`

## 추가 단계 — ❌ 메인 제외, ablation-only (현재 전부 미구현)
> 규칙(FAQ)상 허용되나, 위 결정에 따라 *메인 사전학습엔 쓰지 않는다*. 시간 남으면 ablation으로만. **아래는 전부 계획이며 코드 없음.**
- ~~N4 bias field 보정~~ — 도메인갭+compute 비용으로 메인 제외.
- ~~알고리즘 QC 필터~~ — 공격적 컷이 데이터 다양성 훼손 위험. 메인 제외.
- ~~modality 태깅~~ — 멀티모달(②) 필요 시 ablation에서만. (cross-seq recon은 별도 결정.)
- ~~skull-strip·정합~~ — domain gap 위험, ablation만.

## Branch별 상세

### Branch A: pretrain-prep (FOMO300K → SSL) — ✅ 완료(2026-06-21)
- **목표 달성: full 전체 전처리 → foundation 사전학습** (thesis "FOMO300K 규모로 처음 입증"과 정합). subset 아님.
- 흐름: FOMO300K zip(`/home/vlm/data/FOMO300K`, 2.292TB / 81,195 zip / 36 PT) → **`preprocess_fomo300k.py`**(아래 "실행 드라이버" 섹션) → `FOMO300K_preprocessed/npy/<PT>/*.npy`(float16). *(구 `extract_arrange.py`는 파일럿 추출 전용 — 프로덕션은 드라이버로 대체.)*
- **결과**: 학습 코퍼스 **227,443 볼륨 = anat 181,965 + DWI b1000대역 45,478**, **~3.2TB(float16)**, 36/36 파티션, error 2(PT030 상수볼륨 정상격리). DWI=b800~1200 큐레이션(b0/고b drop). float16 round-trip err 2.44e-4. out-of-band dwi(7,129/79GB) 정리 완료(백업 `manifest_allruns_backup.csv`).
- **검증**: 전수 정합(npy=pkl=manifest ok=227,443, 고아/누락 0) + 무작위 300개 무손상 + `.venv-train` DataLoader 멀티워커 로드 PASS.
- **디스크 히스토리**: gpfs 공유. float16 덕에 full이 ~3.2TB로 수용(애초 6~9TB는 float32 추정). 옛 AD `preprocessed_official` 등 정리. `/` overlay는 ephemeral+무권한이라 사용 불가 → gpfs만 영구.
- **스트리밍/안전**: zip 풀기→전처리→임시 nii.gz만 삭제(zip 유지), per-volume라 출력 bit-identical. 중간 외부kill 1회→resume(재작업 0)로 완주.

## 실행 드라이버 & 산출물 — `preprocess_fomo300k.py` (프로덕션, 검증완료 2026-06-20)

공식 4단계를 yucca 함수로 직접 호출(출력 == 공식과 동일, dtype만 float16) + 스트리밍·안전장치·추적 CSV 일체화. 파일럿(PT001/002/008/015, 25+30 scan)으로 전 기능 실측 검증.

### 디렉토리 구성 (출력 루트 = `/home/vlm/data/FOMO300K_preprocessed/`, gpfs 영구)
```
FOMO300K_preprocessed/
├── npy/<PT>/<PT>_<scan_basename>.npy   # float16 이미지 + .pkl(메타: crop/spacing/orientation)
├── manifest.csv                        # ★ 스캔별 followup (resume의 source-of-truth)
├── run_meta.json                       # 재현성: config·yucca버전·git commit·workers
├── logs/run_<ts>.log                   # 실행 로그 + 에러 traceback
└── _tmp/                               # 스트리밍 임시(추출 nii.gz) — 배치마다 삭제, 종료시 제거
```

### 산출물 파일명 (충돌 불가)
`{PT}_{scan_basename}.npy` 예: `PT001_ClevelandCCF_sub-01_ses-01_T1w.npy`
- scan_basename은 BIDS 전체명(sub/ses/acq 포함) → PT 내 유일 + PT 접두어 → **전역 유일**. (공식 preprocess는 PT 접두어가 없어 파티션 간 sub-01 충돌 → 본 드라이버가 해결.)

### 안전장치 (9)
1. **resume/idempotent** — manifest의 `status==ok`는 skip. 중단 후 재실행=이어서.
2. **atomic write** — `*.partial` 작성 후 `os.replace` → 반쪽 파일 없음.
3. **per-scan 에러격리** — 손상 스캔 1개가 전체 306K run을 죽이지 않음. error로 기록 후 계속.
4. **temp cleanup** — 추출 nii.gz는 배치마다 삭제(zip 유지). temp 상한=batch 크기.
5. **disk guard** — 여유 < `--min-free-gb`(기본 100GB)면 `STOPPED_LOW_DISK` 남기고 graceful 종료(resume 안전).
6. **출력 검증** — ndim==3 / finite(nan·inf 없음) / float16 캐스팅 후 재확인.
7. **no-overwrite** — 기존 ok 출력 미덮어씀(`--force` 시만).
8. **재현성** — run_meta.json에 config·yucca버전·git commit 기록.
9. **dry-run** — `--dry-run`으로 처리 없이 대기 scan 수만 열거.

### 추적 CSV (`manifest.csv`) 컬럼
`pt, subject, session, modality, scan_basename, status(ok|error|skipped), reason, src_zip, zip_member, out_relpath, orig_dtype, dtype, shape, n_voxels, size_mb, vmin, vmax, finite, proc_sec, timestamp`
→ followup 쿼리: 완료/실패/skip 수, 총 용량, PT별 커버리지, 재시도 대상(`status!=ok`).

### 스코프 / 제외
- **구조(anat) 3D만**: zip 내 `/anat/*.nii.gz` + `ndim==3`. **dwi/func(4D)는 자동 제외**(로그/skip). 모달리티 기본 `T1w,T2w,FLAIR,PDw`(`--modalities`로 변경, 빈 리스트=anat 전체).

### 실행
```bash
# 사전 점검(처리 없이 대기 수)
PYTHONPATH=baseline-codebase/src .venv/bin/python preprocessing/preprocess_fomo300k.py --dry-run
# 전체 실행 (36 PT, 자동 resume)
PYTHONPATH=baseline-codebase/src .venv/bin/python preprocessing/preprocess_fomo300k.py --num-workers 32 --batch-size 256
# 중단 시 동일 명령 재실행 → manifest 기준 이어서
```
- 속도: 파일럿 ~2.4s/scan(CPU). 32 worker → full ~306K ≈ 6~7h 추정(I/O·파티션 편차로 변동).
- ⚠️ **실행 전 디스크**: f16 full ≈ ~4TB ≈ 현재 여유 4.x T. 마진 위해 `preprocessed_official`(875G, 옛 AD) 정리 권장. **삭제는 사용자 승인 후.**

### Branch B: downstream-prep (7 task → finetune/probe)
- 공식 `run_preprocessing.py --taskid=N --source_path=<raw>` (task별).
- **⚠️ pretrain과 *동일* 전처리**(crop/znorm/1mm/RAS, **4단계만** — 추가단계 없음) = **domain gap 방지**(무결성 핵심).
- status: downstream 데이터 미확보(등록 필요).

## 무결성 (필수)
- **subject-disjoint**: pretrain ∩ downstream-test = ∅ 코드 검증([[../docs/03_data_integrity]] #1).
- **pretrain = downstream 전처리 동일**.
- per-volume 처리 → 교차 누수 없음.

## 파일
- `extract_arrange.py` — FOMO300K zip → 공식 입력 구조 정렬(modality 필터 지원).
- (공식 전처리 코드: `baseline-codebase/src/data/`)
