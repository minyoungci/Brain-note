# SCRATCHPAD — FOMO26 현재 상태 (매 게이트 업데이트)

> 최종 업데이트: 2026-06-20. 단계: **pretrain 전처리 결정 확정 — 파일럿 재검증 + 디스크 정리 대기.**

## 🔒 전처리 결정 확정 (2026-06-20)
- **목표 = full 300K 전체 전처리 → foundation** (subset 회귀 아님; thesis "300K 규모 입증"과 정합).
- **전처리 = 공식 Yucca 4단계만**(crop_to_nonzero / volume_wise_znorm[0,1] / 1mm·RAS / save). **N4·QC·modality 제외**(미구현·도메인갭·compute) → ablation-only.
- **저장 dtype = float16**(출력 [0,1], bf16 학습보다 정밀 → 무손실. round-trip<5e-4 검증 예정). 원 dtype(f32/f64)은 파일럿 실측 [VERIFY].
- **스트리밍 = zip풀기→전처리→임시 nii.gz만 삭제(zip 유지)**. per-volume라 출력 bit-identical.
- **디스크**: gpfs 단일 4.0T 여유(공유), `/` overlay 사용불가(ephemeral+무권한). FOMO300K raw=2.3T. ⚠️ `hee`(2.4T)·`hyerin`(565G)=**동료 추정, 건드리지 말 것**. `data/raw`(ADNI+PET/AJU)=옛 AD raw, du 15분 timeout=다TB, **mtime 최근(Jun19~20)→활성 여부 확인 후 삭제**. `preprocessed_official`(875G)=옛 AD 전처리(명백 폐기가능).
- ✅ **파일럿 검증 PASS(2026-06-20)**: float16 왕복 err=2.44e-04, 실측 12.8MB/scan(f16).
- ✅ **드라이버+2라운드 감사 GO**(`d200cac`): 안전장치 11종, manifest CSV, H2 출력동등성 확인.
- ⚠️ **dry-run이 잡은 커버리지 버그(수정완료)**: zip의 56%(45,377/81,195)가 깊이4 중첩(`PT030_OpenNeuro/ds*/sub-*/ses.zip`, 880 ds). 기존 `PT/sub-*/` 순회는 **PT030 전체(최대 파티션) 누락**. → `os.walk` 임의깊이 + 경로기반 유일 scan_basename(`{zip_id}__{member}`)으로 수정·검증(PT030 66,405 포착, 중복0, PT001 회귀없음).
- **실제 모달리티 분포**(깊이3만 집계): anat 98,796 / dwi 65,371(4D, 제외) / other 1,651. anat 정규4종(T1/T2/FLAIR/PD)=82,349, 그외 anat 16,447(T1c 12,358·MP2RAGE·gre 등). **PT030 포함 진짜 총수는 full dry-run 재집계 중.**
- **scope 미결정**: "full 300K"=① canonical 4종 vs ② all-anat(+T1c/MP2RAGE 등) — thesis 규모주장·디스크 좌우. dwi/func(4D)는 SSL 부적합으로 제외 확정.
- **디스크**: f16 ~12.8MB/scan. 현재 여유 ~4.4T. hee/hyerin 불가침. all-anat~2.3TB라 정리 없이 수용(disk guard 100GB floor).
- 🔒 **결정(2026-06-20)**: scope=**all-anat 3D (182,404)**, RSS 실측 worker당 1.66GB→32 worker 안전(~53GB/1TB), **full run launch 승인**.
- ✅ **H3 RSS 측정**: 7T/HighRes 최대 파티션 worker당 peak 1.66GB → 32 worker OK.
- 🔁 **scope 정정(2026-06-20): DWI 포함으로 변경.** "300K"=전체 3D 볼륨 306,207(anat 182,404 + dwi 118,509 + perf 5,294). ⚠️ 앞서 "dwi=4D 제외"는 **오판** — FOMO300K dwi는 **b값별 3D 볼륨**(dwi_bval0/900/1200, 실측 40/40 3D)이라 동일 파이프라인 처리가능. 근거: ① 공식 pretrain=single-channel modality-agnostic ② downstream Task1(infarct)/Task2(meningioma)가 dwi_b1000·ADC 입력 사용 → dwi 사전학습 정합. dwi f16 ~4.5MB → +0.54TB. **scope=anat+dwi≈300K, ~2.9TB**(여유 4.5T 충분). perf(asl 4D/cbf 정량맵)는 제외 유지.
- 드라이버 `--categories`(default anat,dwi) 추가. anat-only run(22,784) 정지→anat+dwi resume 재시작(완료분 skip+dwi 추가).
- 🔁 **DWI 큐레이션 확정(2026-06-20, 사용자 결정)**: 실용=b1000로 큐레이션·all-b 중단 / 전처리=4단계 primary·최소전처리는 Phase-A ablation. 드라이버 `--dwi-bval-min/max`(기본 800~1200) 추가 → b0·고b drop, 진단 DWI 대역+trace만. (검증: PT008 curated 95 vs all-b 392 = ~24%.)
- ⚠️ 이전 all-b run서 처리된 out-of-band dwi(b0/고b ~6K npy)는 manifest에 잔존(무해 ~0.03TB) → **학습 데이터리스트는 manifest를 b값 필터**(anat + dwi b800-1200)로 구성.
- ✅ **전처리 완료(2026-06-21)**: out=`/home/vlm/data/FOMO300K_preprocessed`. **학습 코퍼스 226,908 볼륨** = anat 181,965 + dwi-b1000대역 44,943, **3.20TB(f16)**, error 2(PT030 상수볼륨 정상격리), 36/36 파티션. manifest=학습셋 일치(out-of-band 7,129/79GB 삭제, 백업 `manifest_allruns_backup.csv`). detached(setsid) 실행으로 완주(중간 외부kill 1회→resume). 무결성 독립검증 PASS(중복0·dtype f16·범위[0,1]·manifest↔disk 일치).
- ✅ **학습 env 구축 완료(2026-06-21)**: numpy2/torch ABI 문제 = 사실 **2중 충돌**(numpy 브릿지 깨짐 + torch 2.2.2가 B200 sm_100 미지원, "no kernel image"). baseline `torch<2.3` 핀 ↔ B200(torch≥2.7) 상호배타. → 전처리 `.venv`(torch2.2, 완료) 보존하고 **신규 학습 env `.venv-train`**(torch 2.12.1+cu130, numpy2.4.6, MONAI 1.5.2) uv로 구성. 검증 PASS: numpy↔torch·B200 bf16 matmul·np→GPU→Conv3d·8 GPU·MONAI 전부 OK. [[fomo-env-split]]
- 다음: SSL 사전학습 코드 셋업(`.venv-train/bin/python` 사용). ⚠️ 남은 점검 ① Task1/2 finetune full vs frozen ② Phase-A [A1] corpus-composition + 전처리형태 ablation([[docs/02_architecture_method]] ④).
- ✅ **research-critic + literature-scout 검증(2026-06-20) — DWI 형태**: 비평="consistency=DWI필수"는 비약. 문헌=brain FM 전부 구조중심(all-b DWI 선례0), 큐레이션>규모(DINOv2), FM관행=최소전처리, DWI표준=b1000 trace, norm=percentile-clip+z. **결론: ① 학습 DWI=b1000-family로 큐레이션(b0/고b drop), ② 전처리 더 최소화(DWI native·percentile-clip) 검토, ③ ablation(조성×전처리)=novelty(선례無).** ADC는 corpus에 없음(per-b-value만). 운영: 전처리 all-DWI 유지(유연풀, b값태그)+학습 혼합비 샘플링; 해상도/norm 변형은 Phase-A DWI 재처리. b값실측: b0 32%·b1000-family ~23%·고b≥1500 27%. [[docs/02_architecture_method]] ④.
- ⚠️ **학습 전 미해결**: ① numpy2/torch ABI 불일치(.venv, 전처리 무해/torch 학습 전 점검) ② Task1/2 finetune full-backbone vs frozen(등록 후 config) ③ 선행 DWI-fraction ablation 유무(literature-scout).

## 현재 단계
- ✅ 선행연구 3 deep-research + 에이전트 종합 → [[docs/01_prior_research]]
- ✅ 아키텍처·method 확정(ViT-3DINO) → [[docs/02_architecture_method]]
- ✅ 규칙 정리 → [[docs/00_challenge_rules]] | 무결성 → [[docs/03_data_integrity]] | 전략 → [[docs/04_strategy_timeline]]
- ✅ 전처리 파이프라인 검증(파일럿) → [[preprocessing/PREPROCESSING]]
- ✅ 모니터링 시스템 검증 → `pretrain/monitor.py`
- ✅ 경고 레지스터 → [[Warning]] (가설·실패모드 W1~W15를 monitor.py 신호·임계·fallback에 묶음)
- ⏳ **다음 게이트 = FOMO26 등록 → downstream 7 task 데이터 → Phase A pilot**

## Branch별 상세 status

### 전처리
| branch | status | 다음 |
|---|---|---|
| pretrain-prep | **드라이버 `preprocess_fomo300k.py` 빌드+실측+감사 완료**. 4단계/float16/스트리밍/안전장치 9종/manifest CSV. code-auditor 라운드1 지적(C1~3/H1~3/M1) 반영, 재감사 중 | ① 재감사 통과 확인 → ② disk 정리(preprocessed_official, 승인 후) → ③ 최대파티션 RSS 측정(H3) → ④ full 실행 |
| downstream-prep | 미착수 | 등록 후 run_preprocessing.py per task |

### method (Phase A에서 검정)
| branch | status | 검정할 가설 |
|---|---|---|
| 백본 ViT-DINO | 확정(3DINO 검증) | ⚠️ **최우선**: 우리 데이터서 수렴·probe·**120초 추론** |
| ① balancing (A~D) | 설계 완료 | *unvalidated* — well-tuned λ 넘나? (equal-λ 아님) |
| ② cross-seq recon | 설계 완료 | single-modal 넘나? (modality-inv는 금지) |
| ③ scanner-invariance | 설계 완료 | seg(50%) 안 깎고 Task7 올리나? |
| dense: iBOT vs MAE | ablation 설계 | head-to-head(선행 없음) |
| Gram anchoring | 강등 | ablation으로만(MedDINOv3 −0.04) |

### downstream task (셋업·명령은 [[docs/05_downstream_setup]])
| task | dataset ID | split | 다운로드 | 전처리 | baseline | novel |
|---|---|---|---|---|---|---|
| 1 infarct cls | CLS002 | 75_15_10 | ⬜ | ⬜ | ⬜ | ⬜ |
| 2 meningioma seg ⭐25% | SEG009 | 40_10_50 | ⬜ | ⬜ | ⬜ | ⬜ |
| 3 brain age reg | REGR002 | 75_15_10 | ⬜ | ⬜ | ⬜ | ⬜ |
| 4 trigeminal seg ⭐25% | SEG010 | 40_10_50 | ⬜ | ⬜ | ⬜ | ⬜ |
| 5 polymicrogyria cls | CLS003 | 75_15_10 | ⬜ | ⬜ | ⬜ | ⬜ |
| 6 linear probe (no-FT) | =Task1 | 75_15_10 | — | ⬜ | ⬜ | ⬜ |
| 7 fairness (no-FT) | =Task6 | 75_15_10 | — | ⬜ | ⬜ | ⬜ |
- 다운로드: erda `sid.erda.dk/sharelink/fmeuvo1EdF` (~6GB). split=config 기본(PDF 80/10/10 아님).
- ⚠️ **공식 baseline 모델=ResEnc U-Net(CNN)** → ViT 쓰려면 Asparagus custom model 등록(통합 마찰). Phase A 결정.

## 열린 결정 / 리스크
- novelty 무게중심: ① balancing(borderline) vs ③ fairness(가장 열림) — Phase A 결과로 확정.
- seg(2,4)=리더보드 50% → 인프라 최우선.
- 8/21 마감 ~9주 → 공저 안전판 먼저.

## 핸드오프 노트
- 환경: `.venv`(yucca2.2.6/torch2.2), 공식 코드 `baseline-codebase/`.
- git: AD 작업은 태그 `exploratory-v1/rtssl-v1/experiments-v1/fomo-planning-v1` 보존. 현재 working tree = FOMO only.
- 데이터: FOMO300K `/home/vlm/data/FOMO300K`(minyoung2 밖).
