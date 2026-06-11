# RESEARCH PROPOSAL — microbrain (근거 기반, 2026-06-11)

> P0 audit + harmonization scout + deep-research(104 agents) + 직접 경험 검증을 종합해, 우리 상황에
> **가장 맞는 연구**를 근거와 함께 제안한다. 핵심 원칙: 데이터가 말한 대로. null-robust.

---

## 1. 수렴하는 증거 — 5개 독립 각도가 같은 벽을 가리킨다

| # | 각도 | 측정/출처 | 결론 |
|---|---|---|---|
| 1 | **P0 audit** | voxel→site 0.475(3.3×), N4 −0.006, 잔차화 후 disease 0.722 생존 | bias 실재·이미지에 강함, 단 disease는 morphometry서 site와 **분리 가능(decidable)** |
| 2 | **morphometry 바** | LOCO AUROC: AD/CN **0.936**, impaired 0.77, MCI-vs-CN **0.614**, amyloid 0.725 | **AD/CN은 천장(no headroom). MCI/amyloid는 morphometry가 약함(headroom 존재)** |
| 3 | **harmonization scout** | top-tier 검토, IGUANe 최적이나 vs morphometry 증거 없음 | harmonization이 바를 넘는다는 문헌 근거 부재 |
| 4 | **deep-research** | D1~D4(fusion/tabular/distillation/VLM) crowded, **cross-site 증거 전무**; imaging SSL "matches morph" REFUTED | 멀티모달 방법론은 포화 + LOCO 미증명 |
| 5 | **blood-biomarker 직접 검증** | morph+age 대비 Δ: dementia +0.005, MCI +0.000, amyloid +0.007 | **혈액 패널은 morphometry 너머 기여 없음 → D5 종결** |

**수렴 결론:** T1w 기반 치매에서 **morphometry는 site-robust한 near-ceiling baseline**이고, 지금까지 시도된
어떤 것(bias 제거·harmonization·멀티모달·혈액)도 *AD/CN에서는* 이를 transportable하게 넘지 못한다. 이건 BRIEF의
**(b) 신호 천장 가설**을 다섯 방향에서 재확인한 것이다.

**그러나 결정적 틈:** morphometry가 강한 곳(AD/CN 0.94)이 아니라 **약한 곳(MCI 0.61, amyloid 0.73)에는
headroom이 있다.** 그리고 혈액은 그 틈을 못 메웠다(+0.00) → **그 틈은 *이미지* 질문이지 tabular 질문이 아니다.**

---

## 2. 제안 연구 (best-fit)

> **"T1w micro-structure는 morphometry가 약한 곳에서 transportable signal을 더하는가?
> — 7코호트 cross-site decidability 연구 (early/MCI·amyloid regime)."**

핵심 질문: **morphometry가 천장이 아닌 regime(MCI-vs-CN, amyloid status)에서, site-invariant하게 학습된
label-free 이미지 micro-표현이 morphometry baseline을 넘어 LOCO transport하는가?** 넘으면 (a)/(b) 중 "부피 너머
미세신호 존재"; 못 넘으면 morph-약한 곳에서도 천장 → 강한 (b) 결과. **어느 쪽이든 1차 결과.**

### 왜 이게 우리 상황에 가장 맞나 (근거)
- **headroom이 거기 있다** (§1-2): AD/CN(0.94)은 천장이라 minyoung4가 죽은 자리. MCI(0.61)·amyloid(0.73)는 morphometry가 약해 micro-signal이 더할 여지가 유일하게 남은 곳.
- **혈액·멀티모달은 그 틈을 못 메운다**(§1-4,5) → 이미지 표현 문제로 좁혀진다.
- **decidable**(§1-1) → (a)/(b) 판정이 가능한 regime.
- **다기관**(7코호트 LOCO) → 단일코호트 매력 부족 해소 + 문헌이 *전무*한 cross-site 평가를 채움.

### 기술적 novelty (방어 가능한 3가지)
1. **Cross-site decidability framework** — confounded regime에서 "(a)/(b)가 판정 가능한가"를 residualization probe + dual-gate(G1 site↓ ∧ G2 morph 초과·transport)로 형식화. deep-research가 "어떤 방법도 LOCO 평가 안 함"을 확인 → 이 평가 방법론 자체가 기여.
2. **morph-weak regime targeting** — AD/CN 분류(포화)가 아니라 MCI/amyloid(morphometry가 약한 곳)를 표적. AD-중심 선행연구가 안 본 영역.
3. **label-free micro-SSL + clean-subspace invariance** — ROI fail-closed 우회(label-free), site-invariance를 글로벌 삭제가 아니라 **P0서 식별한 clean subspace(A4/ADNI vendor⊥dx)** 에서 학습.

### 설계
- **코호트:** 7 전체, subject-level **LOCO**. amyloid 라벨 광범위(A4/AJU/OASIS/KDRC/NACC + ADNI raw).
- **Task:** 1차 MCI-vs-CN, amyloid-pos-vs-neg (morph-weak). 2차 AD/CN(천장 대조군), impaired.
- **Arms:** A(label-free micro-SSL) · B(+clean-subspace invariance) · C(IGUANe harmonization 대조) · D(무처리 control). 혈액/멀티모달은 *tested negative control*로 보고(+0.00).
- **바:** morphometry LOCO(task별 §1-2). **성공 = G1∧G2 동시 + transport.**
- **평가:** validation-lock, 5 seed, per-cohort, prevalence 병기, bootstrap CI.

### 정직한 전망 (낙관 금지)
- 선행(T1→amyloid 외부 0.62 < covariate 0.743; deep≈morph)은 morph-weak regime에서도 **(b)일 가능성**을 경고. **null이 여전히 유력한 1차 결과** — 단 "morphometry가 약한 곳에서도 이미지가 못 더한다"는 *강한* (b) 증거라 publishable.
- amyloid는 T1w로 어려운 target(선행 천장). MCI는 이질적. headroom이 있다고 이미지가 채운다는 보장은 없다 → 그래서 **판정 연구**로 프레이밍.

---

## 3. 이게 *아닌* 것 (그리고 왜)
- ❌ "novel method가 morphometry를 이긴다" (AD/CN) — 천장 0.94, minyoung2/4 재현 위험.
- ❌ harmonization으로 bias 제거 = 해법 — 문헌·우리 데이터 모두 음성. (IGUANe는 Arm C 대조만.)
- ❌ 혈액바이오마커+MRI — novel하나 **+0.00로 직접 반증**. (tested negative로만 보고.)
- ❌ 멀티모달 fusion(ShaSpec/HyperFusion류) headline — crowded + cross-site 미증명.

## 4. 다음 단계 (승인 시)
1. P2 설계서 `docs/P2_plan.md` — Arm A/B/C/D, morph-weak task, LOCO, dual-gate. GPU 게이트.
2. 그 전 P1: split/leakage 단위테스트 + trivial baseline(raw-voxel PCA) 고정.
3. 1차 결정 테스트(소형): morph-weak regime에서 단순 image feature(P0 voxel feature)가 morphometry에 incremental한가 — GPU 전 CPU 예비검정.
