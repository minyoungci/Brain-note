# DASHBOARD — 5개 워크스페이스 한 장 요약

_갱신: 2026-06-02 (각 repo git log / SCRATCHPAD 기준)_

> 진실의 원천은 각 워크스페이스. 이 표는 빠른 항법용 요약이다. 상세 → `workspaces/<dir>/`.

## 상태 한눈에

| dir | 연구 한 줄 | 상태 | 다음 게이트 | 최대 리스크 |
|---|---|---|---|---|
| **minyoung2** | EXP01: shortcut 통제 후 T1w가 CDR 신호를 incremental하게 담는가 (LOCO control battery) | 🟢 성숙·활발 | full-res 3D CNN strong-deep baseline(IMG-020/021/022) ledger 확정 | headline 후퇴: deep ≈ regional volumetry (+0.018만), LOCO **seed 불안정** |
| **plant** | Longitudinal: 단일 baseline scan→미래 CDR 진행 예측 (EXP01 시간축 확장) | 🟢 신설(6/1)·설계중 | prereg 설계 lock 후 4코호트(ADNI/AIBL/A4/OASIS) 파이프라인 | **converter 극소수**(ADNI 130·A4 96), git 없음 |
| **minyoung3** | F04: 2.5D axial MAE SSL + ROI-informed 표현학습 | 🟡 진행중 | official-label enriched F04 slab manifest 검증 | MAE 백본 full-train 0회, **git 없음**, ROI fail-closed |
| **minyoungi** | 문헌 triage + clinical 데이터 이해(ipynb) + ROI QC(Gate05b) | 🟢 활발(지원역) | Gate05b NACC per-target ROI 실패 audit | ROI 공식 "잠정(BLOCKED)", 과거 데이터 버그 전례 |
| **minyoung4** | 리셋된 모델링 워크스페이스(방향 미확정) | ⚪ 휴면 | 연구질문·validation 정의 후 재시작 | 활성 연구 없음 — 감시 우선순위 낮음 |

## 연구 계보 (한 줄기로 읽기)

```
minyoungi (데이터 이해·문헌·ROI QC)  ──공급──┐
                                            ▼
minyoung2 EXP01 (cross-sectional, LOCO)  ──성숙── 결론: deep ≈ volumetry, seed 불안정
                                            │
                                            ▼ 시간축으로 확장
plant Longitudinal (baseline→future CDR)  ──신설── 같은 incremental+transport 프로토콜
                                            │
minyoung3 F04 (2.5D MAE SSL)  ──표현학습 축, 아직 백본 미학습──┘
minyoung4 (휴면)
```

핵심: **minyoung2의 평가 프로토콜(nuisance 통제 → incremental value → LOCO transport)이 전체의 척추**다.
plant는 이를 시간축으로, minyoung3는 표현학습(SSL)으로 확장하려는 시도.

## 지금 가장 중요한 3가지 (insights/MUST_KNOW.md 발췌)

1. **deep ≈ regional volumetry.** EXP01에서 deep 2.5D MIL이 5-ROI FreeSurfer 부피 baseline을
   5/5 fold에서 못 이기고 pooled에서만 +0.018 AUROC. → 정직한 thesis는 "deep이 가치를 더한다"가
   아니라 **parsimony/cautionary**. plant·minyoung3도 이 bar(부피 baseline)를 반드시 깔아야 한다.
2. **LOCO transport은 seed 불안정.** NACC/AIBL 일부 seed에서 붕괴. 단일 run 주장은 위험 →
   multi-seed 필수. in-dist val 체크포인트 → OOD gap이 원인 후보.
3. **데이터 함정은 공유된다.** `cdr_global`은 string(→`to_numeric`), single-cohort 함정
   (APOE·MoCA=NACC only / MMSE=ADNI 없음 / sex NaN=A4·ADNI), ROI는 fail-closed 잠정, RAM 1TB 상한.

## 즉시 권고 (감시자 관점)

- **minyoung3·plant에 git 없음** → 버전 안전망 0. 최소 `git init` + 첫 커밋 권장.
- **plant converter sparsity** → 양성 표본이 작아 LOCO 통계력 빈약. 부트스트랩 CI 설계를 prereg에 못박을 것.
- **minyoung2 RAM 압박 신호** (최근 커밋: disconnect 생존·RAM 90% 캡) → 1TB 상한 모니터링과 연동.
