# VLM 연구 계획 — FastSurfer-grounded 3D Brain MRI → Radiology Report VLM
> 생성 2026-06-14. 단일 현행 연구(디렉토리 클린슬레이트 후).
> **정직한 tier**: incremental — *automated morphometry reporting / FastSurfer distillation*. top-tier 방법론 win 아님
> (이 데이터의 측정된 천장: `insights/INDEX.md` #1/#6/#9/#11/#13/#14/#15). 합의된 scope.

## 1. 목표
3D 뇌 T1 MRI를 입력받아, FastSurfer 정량(형태계측) 소견을 서술하는 **radiology report를 생성**하는 generative VLM.
inference 시 FastSurfer 파이프라인 없이 *이미지만으로* 구조 소견 보고.

## 2. 아키텍처 — 2-stage (핵심)
### Stage 1 — pseudo-label 생성 (tabular → report, **text-only**, GPU 경량)
- 입력: FastSurfer 30-region 정량값 (ICV/age/sex 보정) + **normative 임계**(SCI 레퍼런스)
- 출력: radiology report 텍스트 = **학습 타깃**
- 도구: **MedGemma-27B-it**(방사선 리포트 생성 튜닝).
- ⚠️ **고정 단일 템플릿 금지**(템플릿-암기 함정): boilerplate가 토큰을 지배하면 모델이 구조만 외워
  loss 착시(perplexity↓)가 생기고 이미지-의존 content를 안 배움. → **다양 phrasing**으로 생성:
  같은 소견을 여러 문장구조·순서·어휘로 paraphrase하되 *모든 값 정확 유지*(생성문서 값 재추출→FS GT 대조로 검증, 불일치 폐기).
- **image-grounded만**: 해마/편도/피질 위축·뇌실·비대칭 + (가용시) FLAIR Fazekas WMH.
  **amyloid/dx/APOE 제외**(이미지 비디코딩 → 넣으면 hallucination, INDEX 천장).

### Stage 2 — VLM 학습 (**image → report**, 이게 연구 본체)
- 입력 = **3D T1 (192³)**. (tabular 아님! tabular는 Stage1 타깃 재료일 뿐.) [+가용시 FLAIR/PET = 부차, INDEX #14로 비중복]
- 구성: **3D 인코더(MONAI) → projector → text LLM 백본(Qwen3-32B)**. 백본은 text-only면 충분 — 멀티모달은 우리가 3D 인코더로 *부여*.
- **grounding(핵심 설계)**: 인코더에 보조 head로 **FS 30-volume 회귀**(leakage-clean) → 리포트에 필요한 feature를 인코더가 학습.
- loss: report 생성(next-token CE) + 보조 FS-volume MSE.

## 3. LLM 후보 (HuggingFace 실측 2026-06-14)
| 모델 | params | license | arch | 우리 역할/적합성 |
|---|--:|---|---|---|
| **Qwen3-32B** ⭐(백본 확정) | 32.8B | **Apache-2.0** | dense text | Stage2 VLM 백본. >8B·클린·강함·ungated |
| **MedGemma-27B-it** ⭐(Stage1) | 28.8B | other(gated) | dense, **radiology-report 튜닝** | Stage1 report 합성 / 대안 백본. 의료 phrasing 최강 |
| Qwen3-14B | 14.8B | Apache-2.0 | dense text | 빠른 iteration / ablation |
| Gemma-3-27B-it | 27.4B | gemma(gated) | dense MM | 대안 백본 |
| Qwen3-VL-32B | 32B | Apache-2.0 | dense VLM | projector 패턴 참고(2D vision은 폐기 — 우리는 3D) |
| DeepSeek-V4-Pro/Flash·V3.2 | 671B+ | MIT | **거대 MoE** | ❌ 과잉·MoE-VLM 개조 고통·templated 언어엔 낭비 |
| Kimi-K2.6/K2.7 | ~1T | other | **초거대 MoE** | ❌ 동일 이유 |

**선택 근거(>8B 사용)**: 8×B200으로 32B dense는 여유. sweet spot 4–32B dense, 상한 ~32B. >100B MoE는 이 task(템플릿 morphometry 리포트)에 이득 0. **bottleneck은 LLM 크기가 아니라 3D 인코더**(이미지→morphometry 추출).

## 4. 데이터 (실측 확인)
- manifest: `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet` (13,022행, 7코호트)
- T1 텐서: `final_tensor_n4_path`, 192×224×192 z-score, **전수 가용**(로드 검증됨)
- FS 30-region volume + `fs_BrainSegVol`(ICV): 전수
- modality 가용: FLAIR(A4 1807/KDRC 907/OASIS 665), PET-SUVR(KDRC 903) — **부차**(fusion 비중복, INDEX #14)
- split: subject-level, cohort-stratified, **결정적 해시**(누수 0 — VQA v0서 검증한 split_of)

## 5. 3D 인코더
- MONAI 3D (SwinUNETR-encoder 또는 3D ResNet) → ~256 token pool → projector.
- **FS-volume 보조 회귀로 grounding**(pretrained 불필요 — 보조 supervision이 대체). BrainIAC 재취득은 선택.

## 6. Normative threshold — 확정 방법론 (literature-scout 2026-06-14)
> **핵심 원칙**: 외부 절대 cutoff 직접 적용 ❌(FastSurfer≠FreeSurfer 비호환). → **우리 CN 정상군 내부 norming + 외부 레퍼런스로 region·방법·band 정당화** ✅. (reviewer 방어 유일 경로.)

**필수 선행 작업**:
- **(P1) eTIV *재계산*** (stats에 eTIV 없음·변환 미저장 → 복구 불가, 계산 필요):
  ⚠️ brain-extracted(native_hdbet)로 등록하면 affine 스케일이 brain 크기 따라가 **atrophy 교란** → 부적절.
  → **full-head `orig.mgz`(FastSurfer 256³, 두개골 포함, 7코호트 전수)** → MNI152 12-dof affine → **eTIV=ICV_MNI/det(M)**
  (Buckner 2004, 두개강 기준 = atrophy-불변). 도구 검증됨(FSL flirt + `MNI152_T1_1mm`). 13k 배치 = **사전승인**.
  상세 설계: **`00_etiv_batch/DESIGN.md`**.
  ⚠️ `fs_BrainSegVol`(brain vol)로 나누기 금지(위축 상쇄, Voevodskaya 2014).
- **(P2) CN 정상군 정의**: `clin_dx_label∈{CN,CN_preclinical}` (amyloid-neg 우선)에서 norm 적합 → 전체에 적용.
- **(P3) scanner 통제**: ComBat(Fortin 2018) 또는 within-cohort norming (우리 F=10.5 측정 근거).

**정규화·등급화 (확정 2026-06-15, OpenAlex 전수 검증)**:
- head-size = **residual 회귀**(eTIV를 공변량), **division 금지**(Voevodskaya 2014).
- age/sex 보정 = CN-**train**군에서 `vol ~ age+sex+inv_det+cohort` → **w-score**(La Joie 2012). (train-only = val/test 누수 차단.)
- **band = 명명된 정규편차 임계에 앵커**(임의값 ❌):
  | 등급(위축) | percentile | z(=Φ⁻¹) | 앵커 근거 |
  |---|---|---|---|
  | normal | ≥10th | ≥ −1.28 | 최저 decile = 연령보정 정상 하한 |
  | mild | 2.5–10th | −1.96 ~ −1.28 | — |
  | moderate | 0.5–2.5th | −2.58 ~ −1.96 | **2.5th = z−1.96** (양측 5% outlier, normative 표준선) |
  | severe | <0.5th | < −2.58 | **0.5th = z−2.58** (양측 1% 극단편차) |
  뇌실 확장 = 상측 대칭(p 0.90/0.975/0.995, z +1.28/+1.96/+2.58).
- **경험적 검증(우리 데이터 ↔ Nobis 2019)**: 해마 w median = AD −1.84(≈3.3th, "AD<5th" 정합) / MCI −0.53·p25 −1.38(5–25th 정합) / CN −0.01(≈0). → CN-internal norm이 UKB nomogram을 재현. dx gradient(해마 mild+) CN 9.9% < MCI 27.3% < AD 65.7% 단조.

**레퍼런스 표 (전부 OpenAlex 검증 — DOI·연도·저널·피인용수 확정, 2026-06 기준; preprint 0)**:
| Ref | DOI | 저널·연도 | 피인용 | 용도 |
|---|---|---|--:|---|
| Scheltens 1992 | 10.1136/jnnp.55.10.967 | J Neurol Neurosurg Psychiatry | 1,772 | MTA(내측두) 시각평가 원전 |
| Fazekas 1987 | 10.2214/ajr.149.2.351 | Am J Roentgenol | 352 | WMH(Fazekas 0–3) 원전 |
| Koedam 2011 | 10.1007/s00330-011-2205-4 | Eur Radiol | 418 | 후방위축(PA) scale — precuneus/PCC |
| La Joie 2012 | 10.1523/jneurosci.2170-12.2012 | J Neurosci | 390 | w-score 방법 + MTL/AD-cortex grouping |
| Voevodskaya 2014 | 10.3389/fnagi.2014.00264 | Front Aging Neurosci | 481 | ICV=공변량(division 금지) |
| Ferreira 2015 | 10.1111/joim.12358 | J Intern Med | 121 | 연령층별 실용 cut-off(MTA/GCA/PA) |
| Harper 2015 | 10.1136/jnnp-2014-310090 | J Neurol Neurosurg Psychiatry | 182 | 시각평가 scale 종합 비평 |
| Brix 2017 | 10.1016/j.ejrad.2017.07.013 | Eur J Radiol | 135 | Evans index 연령·성보정(단일 0.3 비특이) |
| Nobis 2019 | 10.1016/j.nicl.2019.101904 | NeuroImage Clin | 229 | UKB 19.7k 해마 nomogram(AD<5th·MCI 5–25th) |
| Bethlehem 2022 | 10.1038/s41586-022-04554-y | Nature | 1,770 | lifespan GAMLSS centile |

⚠️ reviewer 방어 명시사항: 이들 visual scale은 두께/sulcal 시각평가이고 우리는 부피 w-score 
→ **방향성 정합("MTA/PA abnormal 진입 ≈ 우리 mild 진입")만 주장, grade-to-z 결정론적 등가는 비주장**. 
[VERIFY]: 편도·내후각 단독 published numeric cutoff 부재(자체 w-score), `inv_det`↔eTIV residual 동등성(상관 별도 제시 필요), Pasquier GCA 원전 DOI 미확정(global은 Bethlehem centile+Harper로 앵커).

## 7. 학습 / 평가
- 인프라: **8×B200(183GB×8)**, torch 2.10 / transformers 5.4 / monai 1.5.2 / peft / accelerate (검증됨).
- 학습: 백본 LoRA + projector full + 인코더 full(단계적). bf16(fp16 금지).
- 평가: **token-loss/perplexity 금지(템플릿 gaming에 속음)**. 대신:
  ① **content-fidelity** — 생성 리포트에서 소견 파싱 → FS GT와 대조(예: 해마 z-bin 일치율).
  ② **no-image / image-shuffled baseline (필수·결정적)** — 이미지 제거/무작위화 후 content-fidelity 측정.
     with-image가 no-image를 *유의하게* 이겨야 "이미지를 읽는다" 입증. 천장(raw≤morpho) 때문에 실제 위험 →
     **학습 초기에 먼저 돌리는 acid test**. (옵션: boilerplate 토큰 loss 마스킹.)
  ③ 다코호트 일반화, ④ **임상의 subset 검수**(circularity 방어), ≥3 seed.

## 8. 정직한 한계 (insights/INDEX 연결 — 자기기만 방지)
- **lossy-FastSurfer**: raw-image ≤ morphometry → VLM은 FS의 lossy 재현. tier incremental.
- **FLAIR/PET fusion 무의미**(INDEX #14, LOMO 음수) → T1-중심.
- **amyloid/dx 비디코딩**(천장) → report 제외(hallucination 방지).
- **평가 circularity 경계**: FS-fidelity = tool-mimicry 충실도지 임상 정확도 아님 → 임상의 검수 필수.
- scanner 교란 → threshold/norming에서 통제.

## 9. 결정 로그 (2026-06-14 세션)
- 산출물 타입 = generative VLM(encoder+LLM), **not** contrastive(CLIP) — closed-set엔 generative 과잉이나 사용자 (a) 선택.
- 백본 multimodal 불필요 — text LLM + 자체 3D 인코더(우리가 멀티모달 부여).
- **백본 = Qwen3-32B**(>8B, Apache, 서버 가용). **Stage1 합성 = MedGemma-27B**(radiology-report 튜닝).
- benchmark/resource 방향은 사용자 거부 → methods/model로.

## 10. 비-목표 (재부검 금지, `insights/INDEX.md`)
- 범주형 AD/amyloid 예측 win(#1/#6/#9/#11 dead), 연속 amyloid·multimodal fusion·conditional diffusion(#13/#14/#15 dead/scooped), amyloid/dx를 report에 주입(hallucination).

## 다음 단계
1. **literature-scout**: FS-region normative cutoff(SCI) 확정 + scanner 교란 처리법.
2. Stage1 report 생성 규칙 + 샘플 리포트 검수.
3. Stage2 파이프라인 코드(데이터로더·3D 인코더·projector·Qwen3-32B·loss).
