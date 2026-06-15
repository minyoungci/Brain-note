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

## ⭐ 현재 확정 전략 (2026-06-14)
> **[`04_sci_clinical_pivot.md`](04_sci_clinical_pivot.md)** 이 현재 나침반이다. AI 컨퍼런스(정확도 SOTA)
> 프레이밍 종료 → **SCI 임상저널 피벗**: 서구→한국 **횡단** transportability & fairness(group-conditional
> conformal + domain-generalization). 00~03은 이 결론에 이르는 확정 선행 근거(보존).

## 읽는 순서
1. [`00_data_constraints.md`](00_data_constraints.md) — 적부 기준선(보유 자산 + 닫힌/열린 방향). 모든 주제가 통과해야 할 게이트.
2. [`01_literature_landscape.md`](01_literature_landscape.md) — 4 방향 문헌 SOTA·open problem·data-fit·verdict (피벗 전 근거).
3. [`02_trajectory_ranking.md`](02_trajectory_ranking.md) — 사망확인서 + F×N×R 랭킹 (피벗 전 근거).
4. [`03_processed_data_spec.md`](03_processed_data_spec.md) — 처리 데이터(Korean 임상+영상/ROI). _raw 디스크 전수·최신 정본은 [`../docs/MANIFEST_FINAL_DATA_SPEC.md`](../docs/MANIFEST_FINAL_DATA_SPEC.md)._
5. ⭐ [`04_sci_clinical_pivot.md`](04_sci_clinical_pivot.md) — **현재 전략(피벗 결정)**.
6. ⭐ [`05_flagship_reframe.md`](05_flagship_reframe.md) — **04 보완(2026-06-15)**: #6 플래그십을 "비식별성 형식화 + 비순환 probe"로 격상(ancestry-causal 주장은 traveling=0으로 死). scout 2건 + Bridgeford 2025 must-cite. conformal=도구로 강등.
7. ⭐ [`06_korean_richness_audit.md`](06_korean_richness_audit.md) — **Korean richness 실측 감사(2026-06-15)**: "AJU CN 23"=clin_dx_label 함정 정정(권위 dx_session **144**, subject 206, pooled CN 426) → D-5 재검토. richness=부분겹침 2개(AJU大/visual-amyloid, KDRC小/연속SUVR481; pool 한계 binary amyloid+멀티모달 **1,416**, 혈관·우울 척도비호환). audit 플래그십 불변 — richness는 substrate.

## 다음 액션 (권고)
- `04` §5 CPU 경로: 라벨/분모 정의 lock → 서구학습→Korean external **횡단 transportability harness**(LOCO + group-conditional conformal + calibration/NRI) → 독립검증 → 매뉴스크립트.
- foundation/종단 GPU는 사전 승인 후에만.

## 연결
- 모델링 규칙: `../roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md`
- feasibility verdict 원본: `../roi_qc/experiments/harmonization/06_feasibility_and_protocol.md`
- 데이터 이해: `../Clinical/INSIGHTS.md`
- 바(0.91) 실측: `../roi_qc/experiments/harmonization/04_loco_generalization/RESULTS.md` · 09
