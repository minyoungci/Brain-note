# 03 · Novelty landscape와 진행 가능한 방향

> 문헌(literature-scout) + 최근 5년 동향 + 우리 제약 위 positioning 종합. 진행 가능 방향은 `notebook/06_feasible_directions.ipynb`로 데이터 근거 제시.
> ⚠️ 인용은 scout(WebSearch) 보고 — 사용 전 원문 검증 `[VERIFY]`.

## 1. 핵심 전환 — 우리 천장이 학계 전체의 천장

우리가 측정한 R2 천장은 우리만의 문제가 아니다. Cautionary Tale(arXiv 2601.16467, 2026)이 generic SSL이 FreeSurfer에 패배(p<1e-4)를 보였고 `[VERIFY]`, 그 결과 **2024–2026 top-venue 게재 기준이 이동**:

> raw accuracy ❌ → **external/LOCO 검증 + label-efficiency 곡선 + leakage-clean 평가 + deployability** ✅

이 넷이 정확히 우리 자산(12,978 SSL pool · leakage-clean nested-LOCO · per-cohort bias audit · inductive BN-adapt). **"morph 못 넘음"이 약점이 아니라 field 합의이고, 우리 rigor가 새 기준이다.**

## 2. Novelty landscape (무엇이 닫혔고 무엇이 열렸나)

| 방향 | 점유도 | 판정 |
|---|---|---|
| 아키텍처(Video Swin/hierarchical/patch-selection) 단면 진단 | saturated | ❌ 아키텍처-스왑은 novelty 아님. honest cross-site서 morph 못 넘음(Bron 2021). 다수 FreeSurfer 입력 |
| brain-MRI SSL 단면 | saturated | ❌ gap이 "비었으나 modality 천장 때문" = 함정. R-NCE(morph-residual SSL)가 niche 선점 中 |
| site-robust/TTA | saturated | △ fair-TTA는 gap이나 *기존 도구 교집합 = 약한 novelty* |
| **종단 변화율/spatiotemporal** | active(미포화) | ✅ 단일시점 morph가 *구조적으로* lossy한 유일 regime(O3). 단 prior 강 null |

문헌 확증: foundation model(BrainIAC 49k·BrainFound·FOMO25)은 **morphometry와 비교 자체를 안 함**(field-wide blind spot). Cautionary Tale은 비교했으나 *full-ADNI in-cohort*만 → **low-budget × held-out-site × confound cell은 미검정.**

## 3. 진행 가능한 방향 + 사전등록 kill-test (`notebook/06`)

### ⭐ Lane B (권장 spine) — label-efficiency × LOCO
**Thesis(positive claim):** morphometry-aware T1 SSL이 **low-label × leave-one-cohort-out**에서 FreeSurfer-morph 대비 label-efficiency 우위 + inductive BN-adapt가 site=population을 공정·배포가능 증분으로(full-label in-dist엔 둘 다 morph 못 넘어도 OK).
- 데이터: SSL pool **12,978** + ADNI 라벨. venue: MICCAI/IPMI/MedIA/NeuroImage:Clinical/npj Imaging.
- **kill-test(CPU/소-GPU):** frozen rep(off-the-shelf 3D encoder) vs fs_vol, ADNI 라벨예산{1,2,5,10,20,100%}, nested-LOCO. **GO=어떤 ≤20% 예산서 held-out site에 morph를 CI하한>0** + inductive BN-adapt 증분 CI하한>0. NO-GO=모든 예산 morph 우세 → Lane A pivot.

### Lane A (pivot, high-ceiling) — T1→미세구조 합성
**Thesis(positive claim):** 합성 미세구조 채널(FA/MD)이 morphometry *너머* disease 신호를 지고 LOCO transport. **구조적 저주가 ASSET**(KDRC/OASIS DWI **1722**=train 타깃 → ADNI 적용). DS-GAN(Stroke 2024) 선례.
- **kill-test:** 합성맵이 fs_vol partial-R²≈0 통제 후에도 disease 신호 보유(아니면 atrophy 재인코딩=illusory).

### O3 — deep spatiotemporal 변화패턴
유일 measurement-clean 열림(prior 강 null). ADNI same-scanner paired **757**. kill-test: denoised 변화측정이 static morph+인지를 CI하한>0 초과.

## 4. ⭐ load-bearing 측정 = GATE-3, 그리고 정직한 prior

- **GATE-3 `image→fs_vol R²`(cortical ROI별)를 가장 먼저** — cortical R²≈1이면 Lane A·C2 닫힘 확정(→benchmark), cortical R²≪1이면 재개방(→imaging arm 정당화). 닫힘의 절반을 가른다.
- **정직한 caveat:** 모든 lane의 지배 prior는 **null**(R2 천장이 "SSL/합성이 morph 못 넘김"을 예측). 양성 결과는 *놀라운* 것으로 취급, 나오면 누수 의심. scale은 못 이김 → 기여는 *평가-조건 축*에. window 수개월(R-NCE 후속 선점 위험). 모든 주장을 *low-label/held-out-site regime으로 엄격 scope*(unscoped "imaging>morph"는 Bron 2021 반사로 즉시 reject).

> 상세 닫힘 근거=`02_ceiling-and-baselines.md`, 데이터/bias 설계=`01_data-and-bias.md`, 음성 ledger=`../ledgers/`.
