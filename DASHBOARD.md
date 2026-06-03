# DASHBOARD — 5개 워크스페이스 현황 요약

> **목적:** 5개 연구 워크스페이스의 상태·blocker·다음 게이트를 한 화면에 요약  ·  **출처:** 각 repo git log / SCRATCHPAD  ·  **갱신:** 2026-06-03

진실의 원천은 각 워크스페이스다. 본 문서는 항법용 요약이며, 상세는 `workspaces/<NN_dir>/`를 참조한다.
**디렉토리는 중요도 순 prefix(`01_`~`05_`)로 정렬**된다. 활동 상태 표기: **활발 / 진행중 / 신설 / 휴면**.

## 상태 요약 (중요도 순)

| # | dir | 연구 요약 | 활동 | 다음 게이트 | 핵심 리스크 |
|---|---|---|---|---|---|
| 01 | **minyoung2** | EXP01: shortcut 통제 후 T1w가 CDR 신호를 incremental하게 담는가 (LOCO control battery) | 활발 | full-res 3D CNN strong-deep baseline(IMG-020/021/022) ledger 확정 | headline 후퇴: deep ≈ regional volumetry (+0.018), LOCO seed 불안정 |
| 02 | **minyoung3** | F04: ROI-evidence encoder + 정규화 보정 기반 **해부학 QA/VQA 생성** (2.5D MAE SSL 폐기) | 활발(6/3) | 생성 QA 외부 anchor(MTA·progression) 검증 + anatomical-evidence scope 감사 | 진단 과대주장 위험, ROI evidence hippo/MTL 약(R²≈0.19), git 부재 |
| 03 | **plant** | Longitudinal: 단일 baseline scan으로 미래 CDR 진행 예측 (EXP01 시간축 확장) | 신설(6/1) | prereg 설계 lock 후 4코호트(ADNI/AIBL/A4/OASIS) 파이프라인 | converter 희소(ADNI 130·A4 96), git 부재 |
| 04 | **minyoungi** | 문헌 triage + clinical 데이터 이해(ipynb) + ROI QC(Gate05b) | 진행중(지원) | Gate05b NACC per-target ROI 실패 audit | ROI BLOCKED_PROVISIONAL, 과거 데이터 버그 전례 |
| 05 | **minyoung4** | 리셋된 모델링 워크스페이스 (방향 미확정) | 휴면 | 연구질문·validation 정의 후 재시작 | 활성 연구 없음 — 감시 우선순위 낮음 |

## 연구 계보

```
04_minyoungi (데이터 이해·문헌·ROI QC)  ──공급──┐
                                              ▼
01_minyoung2 EXP01 (cross-sectional, LOCO)  ──성숙──  결론: deep ≈ volumetry, seed 불안정
                                              │
                                              ▼ 시간축 확장
03_plant Longitudinal (baseline → future CDR)  ──신설──  동일 incremental + transport 프로토콜
                                              │
02_minyoung3 F04 (ROI-evidence → 해부학 QA/VQA)  ──표현/데이터 축, 2.5D MAE SSL 폐기──┘
05_minyoung4 (휴면)
```

minyoung2의 평가 프로토콜(nuisance 통제 → incremental value → LOCO transport)이 전체의 척추다.
plant는 이를 시간축으로, minyoung3는 ROI-evidence 기반 QA 데이터 생성 축으로 확장한다.

## 최우선 인지 사항 3건 (상세: `insights/MUST_KNOW.md`)

1. **deep ≈ regional volumetry.** EXP01에서 deep 2.5D MIL이 5-ROI FreeSurfer 부피 baseline을
   5/5 fold에서 능가하지 못하고 pooled에서만 +0.018 AUROC. 정직한 thesis는 "deep이 가치를 더한다"가
   아니라 parsimony/cautionary. plant·minyoung3도 이 부피 baseline을 반드시 깔아야 한다.
2. **LOCO transport은 seed 불안정.** NACC/AIBL 일부 seed에서 붕괴. 단일 run 주장은 위험하며
   multi-seed가 필수. in-dist val 체크포인트 → OOD gap이 원인 후보.
3. **데이터 함정은 공유된다.** `cdr_global` string(→`to_numeric`), single-cohort 함정
   (APOE·MoCA=NACC only / MMSE=ADNI 없음 / sex NaN=A4·ADNI), ROI fail-closed 잠정, RAM 1TB 상한.

## 감시자 권고 (즉시)

- ⚠️ **minyoung3·plant에 git 부재** → 버전 안전망 0. 최소 `git init` + 첫 커밋 권장.
- ⚠️ **plant converter 희소성** → 양성 표본이 작아 LOCO 통계력이 빈약. 부트스트랩 CI·MDE를 prereg에 명시.
- ⚠️ **minyoung2 RAM 압박 신호**(최근 커밋: disconnect 생존·RAM 90% 캡) → 1TB 상한 모니터링과 연동.
