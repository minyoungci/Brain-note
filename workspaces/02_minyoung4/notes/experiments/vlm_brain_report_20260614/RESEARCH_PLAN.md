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

**정규화·등급화**:
- head-size = **residual 회귀**(eTIV를 공변량), **division 금지**(Voevodskaya 2014 [12]).
- age/sex 보정 = CN군에서 `vol ~ age+sex+eTIV` → **w-score**(La Joie 2012) 또는 **GAMLSS centile**(Bethlehem 2022, brainchart.io).
- band = 임의값 아니라 **CN 분위수**: ≥10th=normal / 5–10th=mild / 2–5th=moderate / <2nd=severe (분포 기반, 레퍼런스로 프레임).

**finding별 레퍼런스(정당화용, 수치는 자체 산출)**:
- 해마: Nobis 2019(UKB 19.7k nomogram), Bethlehem 2022(centile). 
- AD-signature region 정의: Dickerson 2009 — ⚠️ *원전은 두께 신호*인데 우리는 부피 → 보고서에 명시.
- 뇌실: **Evans index 불가(linear)** → ICV-정규화 ventricular volume percentile로 재정의(Brix 2017은 관련척도 언급만).
- 전반 위축(BPF): Vågberg 2017(정상 BPF·age 감소율).
- 해마 비대칭: 단일 hard cutoff 약함 → CN 분포 percentile(Woolard&Heckers 2012 "~10% 정상" 프레임).
- WMH: Fazekas 1987 원전 + ARWMC(Wahlund 2001). **deep Fazekas ≥2 = 임상 의미** 관용. 이미 ordinal → 해석만.

[VERIFY]: AD-signature region별 published numeric cutoff 부재(자체 w-score), w-score 원전(Jack1997), FastSurfer eTIV bias(GitHub issue·non-peer-reviewed→자체확인).

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
