# research_topic/ — Brain Image 연구 주제 탐색 (실제 가능성 적부)

_"우리가 보유한 7-컨소시엄 T1 MRI 데이터로 **실제로 가능하고 차별화된** AD representation-learning 연구 주제는 무엇인가"_ 를 문헌(top-tier) + 우리 실험(harmonization 01~09)으로 적부 판정한 dossier.
_생성 2026-06-07. 독립 2-에이전트(literature-scout + research-advisor)가 같은 1·2순위에 수렴._

## ⭐ 직답 — "실제로 가능한가?"

| 등급 | 주제 | 컴퓨트 | 근거 |
|---|---|---|---|
| ✅ **가능·즉시·차별화** | **Cross-population shortcut-audit** — "site==population(한국 vs 서구) confounded regime에선 shortcut 제거 성공/실패가 단일 probe로 *판정 불가(undecidable)*, biology-preserving 비순환 probe가 유일 판정자"를 7코호트로 입증 | **CPU** | 자산 절반 보유(01 3축 probe + 02 v2 비순환 장치). Souza 2024(J-BHI)의 *separable* 가정의 빈틈 |
| 🟡 **가능·조건부(GPU)** | **biology-guided foundation feature linear-probe** — 사전학습 인코더가 morphometry 바(LOCO 0.91)를 *언제 깨나*. "이긴다"가 아니라 **audit**으로 | GPU(추론+linear, 사전승인) | 순수 SSL은 site-robust 아님(travelling-heads ICC 0.25–0.45), biology-guided만 FreeSurfer(0.93) 초과(AnatCL 0.97) |
| ❌ **죽음** | 정확도 SOTA / harmonization으로 일반화↑ / image>morphometry / MCI 전환예측 / CDR staging / option_b voxel ROI / GAN site 제거 | — | 우리 실험 02·03·04·07·08·09 + 구조적 라벨·그리드 결손 |

**한 줄 결론**: 이 데이터로 *정확도 경쟁* 논문은 죽었다(07/04가 못 박음). 살아있는 건 **"무엇이 결정 가능한가/어디서 깨지나를 측정하는 audit"** 계열이고, 그중 **한국-confounded 벤치마크가 있어야만 쓸 수 있는 undecidability 명제**가 우리만의 차별점이다. **성패는 실험이 아니라 프레이밍에서 갈린다.**

## 읽는 순서
1. [`00_data_constraints.md`](00_data_constraints.md) — 적부 기준선(보유 자산 + 닫힌/열린 방향). 모든 주제가 통과해야 할 게이트.
2. [`01_literature_landscape.md`](01_literature_landscape.md) — 4 방향 문헌 SOTA·open problem·data-fit·verdict (citations, [PREPRINT-ONLY]/[VERIFY] 태그).
3. [`02_trajectory_ranking.md`](02_trajectory_ranking.md) — 사망확인서 + F×N×R 랭킹 + 상위 3개 first experiment + reviewer 방어 + 한 줄 권고.
4. [`03_processed_data_spec.md`](03_processed_data_spec.md) — **처리 데이터 정본(Korean 임상+영상/ROI)**. provenance→산출물→검증 커버리지→한계→재현. 모든 수치 manifest 재계산(06-10). 연구·VLM은 이 위에서 출발.

## 다음 액션 (권고)
- **T-1을 CPU로 즉시 착수**: 입력 `roi_qc/reports/img_features.parquet`(site-leaky) vs fs_vol morphometry(site-robust), LOCO held-KDRC/AIBL, AJU는 site-probe 전용(CN n=23로 held 불가). 성공기준=dual-probe(site↓ + biology 0.91 보존 + null).
- foundation(T-3, GPU)은 backbone 입력 호환성(192³ z-score identity-affine) 선확인 + 사전 승인 후에만.

## 연결
- 모델링 규칙: `../roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md`
- feasibility verdict 원본: `../roi_qc/experiments/harmonization/06_feasibility_and_protocol.md`
- 데이터 이해: `../Clinical/INSIGHTS.md`
- 바(0.91) 실측: `../roi_qc/experiments/harmonization/04_loco_generalization/RESULTS.md` · 09
