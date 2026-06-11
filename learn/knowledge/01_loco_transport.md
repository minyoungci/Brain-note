# 01 · LOCO · transportability · nuisance control

> **목적:** EXP01이 정립한 평가 프로토콜(전체의 척추) 이해 — plant가 시간축으로 계승  ·  **출처:** minyoung2 SCRATCHPAD, reports/EXP01_OVERVIEW.md  ·  **갱신:** 2026-06-02

## 1. 왜 이 프로토콜인가 (문제의식)

뇌 MRI 표현이 "치매를 맞춘다"고 할 때, 모델이 실제로 본 게 **질병 신호**인지 **nuisance
shortcut**(촬영 site, 라벨 출처, tracer, scan timing, 뇌 전체 부피)인지 구분이 안 된다.
다기관 데이터에서는 코호트마다 이런 shortcut이 라벨과 상관되어 **가짜 성능**을 만든다.
EXP01의 1차 기여는 SOTA 성능이 아니라 **"shortcut을 통제한 뒤에도 신호가 남는가"를 재사용
가능하게 측정하는 음성-결과-내성(negative-result-tolerant) 평가 프로토콜**이다.

## 2. 핵심 개념 3가지

### (a) Nuisance control battery (통제군 사다리)
모델 성능을 단독으로 보지 않고, **점점 강해지는 baseline 사다리**와 비교한다:
- `shuffled` (라벨 셔플) → chance(~0.50)여야 한다. 아니면 **누수**.
- `nuisance-only` (site/provenance/tracer/뇌부피 메타데이터만) → "shortcut만으로 얼마나 맞나"의 bar.
- `mask-only` (뇌 마스크 기하만, intensity 제거) → "뇌 기하만으로"의 bar.
- `image-full` (실제 T1 intensity 포함) → 위들을 **이겨야** 신호가 intensity에 있다고 말할 수 있다.
- ⚠️ 강화된 bar: **5-ROI regional volumetry**(FreeSurfer 부피). 단순 전뇌부피보다 훨씬 센 baseline.

### (b) Incremental value (증분 가치)
image가 nuisance를 **추가로** 이기는가. 공식 H1:
> `nuisance + image > nuisance` 가 LOCO test에서 **부트스트랩 CI 하한 > 0**.
단순히 image AUROC가 높은 게 아니라, nuisance에 **얹었을 때 증분**이 있어야 한다(paired bootstrap ΔAUROC).

### (c) LOCO (Leave-Cohort-Out) = transportability
한 consortium **전체**를 test로 빼고 나머지로 학습. within-cohort CV가 아니라 **새 site로의
전이(transport)**를 직접 측정. 핵심 성질:
- held-out cohort의 `consortium`/`cdr_source`는 train에 없던 **novel 상수** → OneHot(handle_unknown=ignore)로
  0벡터화 → 직접 누수 불가. 따라서 nuisance metadata-only가 test에서 near-chance인 게 **정상**이고,
  이것 자체가 "site shortcut은 transport 안 된다"는 결과.
- **mask-volume(뇌부피)는 연속·cross-site라 transport됨** → nuisance baseline의 실질 신호는 주로 뇌부피.
- 코호트마다 class balance가 크게 다름(KDRC CN280/IMP629, OASIS 518/200) → **반드시 코호트별 보고, 단일 평균 금지.**

## 3. EXP01이 실제로 알아낸 것 (결과)

- ✅ image-full이 6/6 fold에서 nuisance bar 초과, shuffled=chance(누수 없음). → 신호는 뇌기하 너머 T1에 있다.
- 🟡 그러나 bar를 **5-ROI regional volumetry**로 강화하자 deep 2.5D MIL이 **5/5 fold 무승부**, pooled에서만 **+0.018 AUROC**. → 정직한 결론: **deep ≈ volumetry (parsimony/cautionary)**.
- ❌ LOCO transport은 **seed 불안정**(NACC/AIBL 일부 seed 붕괴). in-dist val 체크포인트 → OOD gap이 원인 후보.
- ❌ falsified: amyloid 라인, discrete tokenizer, "brain-pretrain이 transport 안정화", "group-DRO가 transport 고침"(코호트 의존).

## 4. 다른 연구가 반드시 지킬 교훈

1. **부피 baseline을 항상 깔아라.** deep이 FreeSurfer regional volume을 못 이기면 "deep이 가치를 더한다"는 주장 불가. plant·minyoung3 모두 해당.
2. **multi-seed 필수.** 단일 run의 LOCO 성공은 seed 운일 수 있다.
3. **코호트별 보고.** pooled 평균은 불균형을 숨긴다.
4. **음성도 출판 가능하게 설계.** "신호 없음"이 버그가 아니라 결과가 되도록 통제군을 미리 박는다.
