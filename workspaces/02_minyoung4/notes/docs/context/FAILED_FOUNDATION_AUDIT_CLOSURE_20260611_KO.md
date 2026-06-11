# Closure — Foundation-model / SSL / harmonization / longitudinal 탐색 (2026-06-11)

> 자체완결 기록. `FAILED_DECONFOUNDING_EXPLORATION_CLOSURE_20260611_KO.md` 후속.
> 질문: "왜 우리는 BrainIAC식 SSL 파운데이션이 안 되나, 가중치를 어떻게 쓰나, harmonization·longitudinal은?"
> 결론: **AD/aging을 구조 T1w로 푸는 *질문 자체*가 morphometry-ceiling + site=population이라 어떤 AI method도 novelty 공간이 없음.** 측정으로 확정.

## 0. 한 줄 결론
representation/SSL/foundation · de-confounding · harmonization · longitudinal-conversion — 네 출구 전부 *데이터로* 막힘 확인.
막힌 건 데이터 품질이 아니라 **풀려던 질문이 이미 풀린 문제**라서. top-AI method-win은 없음. audit/clinical 논문 2개만 real.

## 1. 측정 (전부 보존)

### 1.1 morphometry BAR (EXP-F0, fs_vol, leakage-clean AJU+KDRC)
- site-probe(fs_vol→cohort 7-way): **0.770** | brain-age MAE: **5.56yr**(per-cohort 4.5–5.6) | CN/AD AUC: **0.911**(KDRC-CV, cross 0.87).

### 1.2 BrainIAC frozen-probe (EXP-F2, ViT 768-d, 우리 v2 T1w; 전처리 공정 검증됨)
| 축 | BrainIAC | morphometry BAR | 승자 |
|---|--:|--:|---|
| site-probe ↓ | **0.842** | 0.770 | morpho (BrainIAC가 *더* site-loaded) |
| brain-age MAE ↓ | 5.73yr | 5.56yr | morpho |
| CN/AD ↑ | **0.735** | 0.911 | morpho (큰 차이) |
- BrainIAC: SimCLR 3D ViT, ~35 데이터셋(ADNI/OASIS 포함 추정 → 누수, AJU/KDRC만 clean), CC BY-NC. 셋업: monai 1.3.2 격리 env로 로드.

### 1.3 few-shot (EXP-F3) — BrainIAC 주장 강점도 패배
- CN/AD(KDRC): train N=20/40/80/372 → BrainIAC 0.671/0.704/0.693/0.744 vs morpho 0.878/0.874/0.872/0.909. **전 구간 morpho 우세.**
- brain-age(clean): N=50/150/400/1240 → BrainIAC 6.98/6.59/6.23/5.69 vs morpho 6.20/5.77/5.54/5.44. **전 구간 morpho 우세.**

### 1.4 3-way 수렴 (representation은 morphometry를 못 넘는다 — 독립 3회)
| 시도 | CN/AD | site/scanner |
|---|---|---|
| ① 팀 scratch SSL(intensity/contrastive, FAILED_3D_CNAD) | 0.88 < morpho 0.91 | scanner 0.95 |
| ② de-siting/morpho-distill(직전 closure) | = ROI morphometry | cohort 0.84 |
| ③ BrainIAC(SOTA foundation) | 0.735 ≪ 0.911 | 0.842(더) |

### 1.5 harmonization (팀 기존 audit, roi_qc/experiments/harmonization, 7실험+PAPER_PLANNING)
- morphometry CN/AD가 이미 LOCO **0.916–0.923** → harmonization headroom ≈ 0.
- ComBat이 CN/MCI를 **unmask 못 함**(within-ADNI 0.620→0.618 flat) — 약신호는 site에 가려진 게 아니라 *원래 약함*.
- pooled는 ComBat 후 *하락*(0.674→0.591) = site=population 지름길 제거 = **deflate, not unmask**.
- → 논문 형태 "When Harmonization Deflates Instead of Unmasks", target **NeuroImage: Clinical**(top-AI 아님), MUST-1(positive-unmask control) 미완.

### 1.6 longitudinal conversion — 라벨 부재 (결정적)
- `clin_dx_label`은 **subject-고정**(clin_level="subject_firstnonnull", 11,837세션): dx를 첫 진단으로 잡아 전 세션 복사.
- ADNI multi-session 849명 중 dx 변동 **0%** (NACC/AIBL/A4 0%). 002_S_1155=MCI×8 동일.
- ⟹ **MCI→AD 전환을 이 manifest로 셀 수 없음.** 하려면 원본 longitudinal 진단표(ADNI DXSUM 등) 세션별 재조인 필요(대작업), 영상有 converter는 수백 명 수준(소수).

## 2. 구조적 결론 (왜 *모든* 출구가 막히나)
1. **morphometry가 단면 신호의 ceiling** (CN/AD 0.91, brain-age 5.5yr — 넘을 mask 없음).
2. **site = population = severity 얽힘** + **traveling-subject 0** → 교란 제거 불가·검증 불가.
3. **longitudinal 핵심 라벨(conversion) 부재** (dx subject-고정).
→ "AD/aging을 구조 T1w로" = 풀린 질문. method-novelty 공간 없음. *데이터/질문의 성질*이지 method 실패 아님.

## 3. 그래서 가능한 것 / 불가능한 것
- ❌ **top-AI(CVPR/ICCV/NeurIPS) "method가 이긴다" (AD-구조MRI)**: 없음.
- ✅ **audit/negative 논문 2개 (clinical/imaging 저널)**: ① harmonization "deflate-not-unmask"(NeuroImage Clinical, MUST-1만) ② BrainIAC reality-check("foundation도 morphometry 못 넘고 site 더 싣음", 7코호트 leakage-통제).
- ↗ **top-AI를 이 데이터로 원하면**: 라벨/task를 *이미지가 진짜 필요한* 것으로 전환(lesion/tumor/segmentation 등) 또는 다른 데이터. AD-구조-임상 라벨로는 불가.

## 4. reset 보존/삭제
- **보존**: 공유 데이터(`/home/vlm/data/...`), manifest, 팀 harmonization 실험·PAPER_PLANNING(minyoungi), 이전 closure들.
- **삭제(이번 라운드 minyoung4 산출물)**: `experiments/foundation_audit/`(BrainIAC 7GB 가중치·clone·env·reports 포함 15GB), `SPEC.md`.

## 5. 다음 진입자에게
- 이 데이터로 representation/de-confounding/harmonization/conversion을 *또* 시도하지 말 것 — 4회 측정으로 닫힘.
- 강한 논문은 (a) 손에 있는 audit 2개 마무리, 또는 (b) image-headroom 있는 task/데이터로 전환.
