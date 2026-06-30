# 02. 데이터 — 전처리 · 코퍼스 실측 · 무결성

> 데이터의 단일 출처(전처리 파이프라인 + 코퍼스 실측→설계 함의 + leakage 방어). 규칙은 [[00_challenge_rules]], 설계는 [[03_architecture_method]], 위험/모니터는 [[06_risk_register]].

## 0. 요약 (현재 상태)
- **학습 코퍼스 = 226,793 볼륨** (구조 anat 181,315 + DWI b800–1200대역 44,943 + orphan-reconcile 535 미분류), **~3.2TB float16**, 36/36 파티션. error 2(PT030 상수볼륨 정상격리). *(권위값=manifest ok 226,793; 535는 kill 후 복구된 행으로 zip_member 공백이라 카테고리 미태깅, 실볼륨 존재.)*
- 출력: `/home/vlm/data/FOMO300K_preprocessed/` (gpfs 영구). 원본: `/home/vlm/data/FOMO300K`(2.292TB / 81,195 zip / 36 PT).
- env: 전처리=`.venv`(yucca2.2.6/torch2.2, **완료**) / 학습=`.venv-train`(torch2.12+cu130, B200). [[fomo-env-split]]

## 1. 전처리 파이프라인 — 공식 Yucca 4단계만 (확정)
N4/QC/modality-tagging 등 추가단계는 **메인 제외(ablation-only, 현재 미구현)**. 근거: ① 공식 baseline N4 미사용 → pretrain↔downstream 도메인갭 방지 ② 251K scan N4 = 막대한 compute/실패모드 ③ robustness는 *전처리 제거가 아니라 augmentation 주입*으로. (옛 AD 프로젝트는 N4 사용했으나 FOMO는 별개 — 끌어오지 않음.)

scan별 독립(iid) 4단계:
1. **crop_to_nonzero** — 0 아닌 최소 bbox.
2. **volume_wise_znorm** — clamp(outlier)→z-norm(foreground)→**rescale [0,1]** (yucca 2.2.6 소스 확인).
3. **1mm isotropic resample** + **RAS** 정렬.
4. 저장: `.npy`(float16) + `.pkl`(메타: spacing/crop/orientation).

## 2. 실행 드라이버 — `preprocessing/preprocess_fomo300k.py` (검증완료)
공식 4단계를 yucca 함수 직접호출(출력 == 공식, dtype만 float16) + 스트리밍 + 안전장치 + 추적 CSV. code-auditor 2라운드 GO(H2 출력동등성 확인).

**디렉토리**: `FOMO300K_preprocessed/{npy/<PT>/*.npy(+.pkl), manifest.csv, run_meta_*.json, logs/, _tmp/}`
**파일명**: `{PT}_{scan_basename}.npy` — PT 접두어 + BIDS 전체명 → **전역 유일**(공식 preprocess의 파티션 간 sub-01 충돌 해결).
**안전장치(11)**: resume(manifest 기준)·startup orphan 재조정·atomic write(npy/pkl/manifest fsync)·per-scan 에러격리·corrupt-zip 추적·중복키 guard·disk guard(100GB)·출력검증(ndim/finite)·재현성(run_meta)·dry-run·worker-side temp.
**manifest 컬럼**: `pt, subject, session, modality, scan_basename, status(ok|error|skipped), reason, src_zip, zip_member, out_relpath, orig_dtype, dtype, shape, n_voxels, size_mb, vmin, vmax, finite, proc_sec, timestamp` → followup(완료/실패/커버리지/재시도).
```bash
PYTHONPATH=baseline-codebase/src .venv/bin/python preprocessing/preprocess_fomo300k.py --dry-run   # 점검
PYTHONPATH=baseline-codebase/src .venv/bin/python preprocessing/preprocess_fomo300k.py --modalities --num-workers 32   # 실행(자동 resume)
```
완주 이력: float16 round-trip err 2.44e-4, 전수 정합(npy=pkl=ok 226,793), 중간 외부kill 1회→resume(재작업 0), detached(setsid)로 완주.

## 3. DWI 큐레이션 (확정) + 정량맵 삭제
- **DWI 포함**(dwi_bval0/900/1000…은 4D 아닌 **b값별 3D 볼륨** → 동일 파이프라인 처리). downstream Task1/2가 dwi_b1000·ADC 입력 사용 → 정합.
- **b800–1200(b1000-family)+trace만 유지**, b0(T2중복)·고b(≥1500, 노이즈) drop. ADC는 corpus에 없음(per-b-value만). 드라이버 `--dwi-bval-min/max`(기본 800~1200).
- 🆕 **퇴화 정량맵 삭제(2026-06-22)**: T1map435·R1map105·R2starmap105·MTRmap5 = 650개(정량 파라미터맵, R2starmap 거의 상수=퇴화) 제거, 7.82GB 회수. MESE/UTE는 실영상이라 유지. 백업 `manifest_pre_mapdelete_backup.csv`.

## 4. 코퍼스 실측 → 설계 함의 (`analyze_corpus.py`, 전수 manifest + 표본 1,241)
| 측정 | 설계 함의 |
|---|---|
| **세션 54.2%가 ≥2 모달**(T1w+dwi 8,252 1위) | **cross-sequence(②) 주요 novelty축 확정**. downstream(dwi+구조) 정합 |
| **foreground 중앙 0.46**(배경 ~54%) | **MAE 고masking(60~90%)·foreground-aware·register token** 정당화 |
| **native 0.5~2.43mm 이질**(dwi 2.0·T1c 1.97 업샘플=매끈 / T2starw 0.5 선명) | **16³ 기본, 8³는 Phase A 비교**(매끈한 다수엔 8³ 효율↓). resolution-aug |
| **강도 mean 0.24~0.83**(모달 변동 큼) | **intensity/bias-field/스캐너 aug 1급** + modality embedding 검토 |
| **shape 변동**(W 64~256) | 고정 96³ crop + foreground-centered + padding(256³ 가정 금지) |

모달리티 구성(전수): T1w 39%·dwi 20%·T2w 15%·FLAIR 10%·T1c 6%·gre 4%·MP2RAGE 2%·… → T1w·OpenNeuro 비대 → **샘플링 재weighting** 검토(Task7 fairness·일반화). 재현: `.venv-train/bin/python preprocessing/analyze_corpus.py`.

## 5. 무결성 (비타협 — AD 실패 교훈)
| 원천 | 방어 |
|---|---|
| **pretrain↔downstream subject 중복** | FOMO300K 36-source(OpenNeuro 46%·HBN·HCP·BraTS·OASIS1·2·IXI… — **ADNI/AIBL/NACC/A4/AJU/KDRC 미포함**) ∩ downstream test = ∅ 를 subject-ID/hash로 **코드 강제 검증**, 겹치면 제외. OpenNeuro umbrella가 유일 사각지대(하위까지 hash 대조). (등록 후 필수 — W13.) |
| split 누수 | pretrain-val / finetune train·val·test 전부 **subject-disjoint**(같은 subject 다른 session도 분리). |
| normalization | per-volume z-norm(무누수). SSL BatchNorm 금지(batch 누수·collapse) → Instance/GroupNorm. |
| confound | scanner/demographic은 *train-time 억제(invariance)*만, **inference feature 미사용**. |
| probe(Task6,7) | frozen feature, probe train/test도 subject-disjoint. |

**Overfitting 방어**: few-shot finetune(21~200)이 최대 위험 → frozen/light-FT + subject-disjoint early-stop + strong aug. 작은 모델(과적합↓, 디테일은 *objective*에서). **3+시드+CI**(few-shot OOD 고분산). validation 3회 제한 → 모든 선택 내부 val로. **baseline-first**: novel이 같은 split서 baseline(3DINO additive/S3D/well-tuned λ) 못 넘으면 정직 보고(negative=자산), test 1회만.
