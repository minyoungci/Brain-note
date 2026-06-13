# DASHBOARD — 5개 워크스페이스 현황 요약

> **목적:** 5개 연구 워크스페이스의 상태·blocker·다음 게이트를 한 화면에 요약  ·  **출처:** 각 repo git log / SCRATCHPAD / 재생성된 `workspaces/<NN>/OVERVIEW.md`  ·  **갱신:** 2026-06-13 (전 행 재작성, 관찰자 기록)

진실의 원천은 각 워크스페이스다. 본 문서는 항법용 요약이며, 상세는 `workspaces/<NN_dir>/OVERVIEW.md`를 참조한다.
**디렉토리는 중요도 순 prefix(`01_`~`05_`)로 정렬**된다. 활동 상태 표기: **활발 / 진행중 / 신설 / 휴면**.

## 상태 요약 (2026-06-13)

| # | dir | 연구 요약 | 활동 | 다음 게이트 | 핵심 리스크 |
|---|---|---|---|---|---|
| 01 | **minyoung2** | RT-SSL(95 ROI-token masked-region SSL) 횡단 thesis **폐기**(`archive/rtssl_v1/`) → **종단 prognosis**로 전면 선회. downstream=CDR-SB 인지중증도 | 활발(6/13, e01~e07) | e07 native longitudinal cache(domain-shift 제거)로 e06 learned-delta 공정 재검 | 새 방향 전체가 **e04 단일 marginal(+0.036 CI[0.002,0.071])**에 의존 · learned 표현 ≯ morphometry는 프로젝트 전반 robust negative |
| 02 | **minyoung4** | 전 산출물 삭제 후 **리셋**(방향 미확정, 현재 VLM 아님). 살아남은 후보=**excess subspace-alignment separability diagnostic**("조화 전에 분리가능성부터 측정") | 휴면(커밋 0, uncommitted 다수) | 외부 traveling-subject calibration(자체 cal 통과) | site=population 비가역 · 6/13 scanner/pop decomposition **VERIFIED NEGATIVE**(prevalence artifact) · 미커밋 안전망 0 |
| 03 | **minyoung3** | **Q-ROUTE**: image-only ROI-grounded 3D VQA(질문-조건부 ROI 라우팅), shortcut-통제 벤치마크. ACCV 타깃 | 진행중(6/10 이후 커밋 0) | 라우팅 우위가 백본 키워도 살아남는지(표현 종속성 분리) | **`.git` 부재**(버전 안전망 0) · 루트 README/STUDY_DECISION(2.5D ROI SSL) stale · 진단 과대주장(0.91 bar 미달) |
| 04 | **plant** (microbrain) | T1w 부진이 **(a) site bias 오염 vs (b) morphometry 너머 천장**인지 *판정*. bias 제거 전에 분리·판정 | 활발(6/11 P2) | 2mm 핸디캡 제거한 **1mm/1.5mm + site-invariance 공정 재실행** | P0: bias 실재(voxel→site 3.3×chance)·N4 무효 · P2 2mm LOCO 0.630<0.72 bar(천장 아닌 해상도/shortcut로 진단) · voxel 수치 still smoke(350) |
| 05 | **minyoungi** | 언어지도 3D 뇌 MRI 치매 표현학습(VLM). 문헌·task설계·컨텍스트·manifest 전용(대형 모델링은 minyoung4) | 진행중(지원, 6/10 커밋) | PASS-only voxel-wise baseline + shortcut-audit로 이동 | ROI-volume teacher distillation **약하게 반증**(frozen bal_acc≈0.48) · ROI BLOCKED_PROVISIONAL · uncommitted 다수 |

> 정렬: 활동·방법론 중심성(2026-06-13). **공유 manifest `official_manifest_full_n4`(13,022)**는 여전히 minyoung2·3·4 횡단 기반.

## 연구 계보 — 같은 벽, 다섯 갈래 우회

```
                   공통의 벽 (전 워크스페이스가 측정으로 부딪힘)
        ┌─────────────────────────────────────────────────────┐
        │ ① learned deep 표현 ≤ hand-crafted morphometry        │
        │ ② site = population 얽힘(비가역) · deep de-conf 2회 실패 │
        └─────────────────────────────────────────────────────┘
                                 │  각자 다른 축으로 우회
   ┌──────────────┬──────────────┼──────────────┬──────────────┐
   ▼ 종단(변화)축    ▼ 측정-우선      ▼ image-only QA   ▼ 원인 판정      ▼ voxel·audit
 01_minyoung2   02_minyoung4   03_minyoung3   04_plant       05_minyoungi
 prognosis      separability   Q-ROUTE VQA    microbrain     voxel baseline
 (e04 marginal) diagnostic     (라우팅)        (bias vs 천장)  + shortcut-audit
```

핵심 전환: 6월 초까지 "deep 표현으로 morphometry를 이긴다"는 공통 베팅이 **다섯 워크스페이스에서 독립적으로 측정 기각**됐다. 단 morphometry 자체는 유용하다(진단 AUC, 그리고 minyoung2 e05에서 prognostic 3/3) — 실패는 *learned 표현이 morphometry 위에 추가 가치를 못 낸다*는 데 국한된다. 각 워크스페이스는 이 벽을 다른 축(변화·측정·QA·원인판정·voxel)으로 우회 중이며, 전부 미확정이다.

## 최우선 인지 사항 (상세: 각 OVERVIEW.md)

1. **프로젝트 전반 robust negative: learned 표현 ≤ morphometry.** minyoung2(횡단 rtssl comparable, 종단 e01/e06 미초과)·minyoung4(deep ≤ morphometry 천장)가 독립 확인. **morphometry는 유용**(prognostic e05) — 못 넘는 건 *learned 표현이 hand-crafted 위에 더하는 가치*다. 모든 워크스페이스가 morphometry baseline을 반드시 깔아야 한다.
2. **site = population 비가역 얽힘.** minyoung4 closure + plant P0(voxel→site 3.3×chance, N4 무효). plant의 열린 질문: 부진이 bias 오염인가 신호 천장인가 — P0는 "disease는 morphometry 수준에서 decidable".
3. **현재 살아있는 "novel 신호" 후보 3개(전부 미확정):** (a) minyoung2 e04 변화축 marginal prognostic, (b) minyoung4 separability diagnostic, (c) plant 1mm 공정 재실행. 하나라도 재현되면 thesis 후보.
4. **데이터·안전 함정.** `cdr_global` string(→`to_numeric`), single-cohort 함정(APOE·MoCA=NACC only / MMSE=ADNI 없음 / sex NaN=A4·ADNI), ROI fail-closed 잠정, **RAM 1TB 상한**, minyoung3 `.git` 부재.

## 감시자 권고 (즉시)

- ⚠️ **minyoung3 `.git` 부재** → 활발히 움직이는 ACCV 초안 작업이 버전 안전망 0. `git init` 권장(plant는 6/11 git 도입됨).
- ⚠️ **미커밋 노출(minyoung4·minyoungi)** → 대규모 작업이 untracked. minyoung4 6/13 scanner_pop_decomp(VERIFIED NEGATIVE) 포함 — git 종합엔 안 잡히고 OVERVIEW 미러로만 포착됨. `git add/commit` 권장.
- ⚠️ **minyoung2 방향 공백** → "종단 피벗"이 e04 단일 marginal 위에 섰는데 SCRATCHPAD에 방향 정의 부재(커밋 규칙 위반). 재현·표본·minyoung3 의존 미확인.
- ⚠️ **plant converter 희소** → 양성 표본 작아 LOCO 통계력 빈약. P2 재실행 시 부트스트랩 CI·MDE 명시.

---
> 본 문서는 OBSERVATORY 관찰자가 각 워크스페이스의 git·results·재생성된 OVERVIEW를 대조해 기록한 항법 요약이다. 실험 설계·결정은 각 워크스페이스/Min의 몫이다.
