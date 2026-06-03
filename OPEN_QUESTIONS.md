# OPEN_QUESTIONS — 미해결·검증대기 추적기

> **목적:** 5개 워크스페이스 + 데이터에서 모인 `[VERIFY]`·blocker·결정대기 항목을 한곳에서 추적  ·  **갱신:** 2026-06-02

해소되면 줄을 지우고 해당 카드/문서에 결과를 반영한다. 상태: ☐ 미해결 / ☑ 해소.
우선순위: 🔴 연구 결론에 영향 / 🟠 설계·운영 / 🟡 정밀화.

## 🔴 연구 결론에 영향

- ☐ **KDRC 라벨 권위 모순.** 노트북 01은 diagnosis 전수 보유·CDR 36.9% 결측, master_df join은 정반대
  (diagnosis 전무·CDR 전수). 학습 라벨로 어느 소스를 쓸지 확정 필요. → `knowledge/data/cohorts/KDRC.md`
- ☐ **OASIS 진단 삼중값 재현 불가.** master_df의 CN1126/MCI42/AD252가 `cdr_global`·raw_input 어느 쪽으로도
  재현 안 됨. 출처 컬럼/필터 확인. → `knowledge/data/cohorts/OASIS.md`
- ☐ **minyoung2 3D CNN(IMG-020/022) 결과 미생성.** run 디렉토리 비어 있음 → 6-fold LOCO 결과 확인 후
  strong-deep baseline 결론 확정. → `workspaces/minyoung2/risks.md`
- ☐ **F10 +0.018 통계.** pooled exchangeability 가정 과대, equivalence test(TOST)·random-effects meta 미수행
  → "음성"과 "검정력 부족" 미분리. → `workspaces/minyoung2/risks.md`
- ☐ **plant converter 통계력.** converter ~270~272(A4 96 vs 98 불일치)로 LOCO 통계력 빈약. MDE 분석 필요. → `workspaces/plant/risks.md`

## 🟠 설계·운영

- ☐ **minyoung3·plant git 부재.** 버전 안전망 0 → `git init` 권장. → `DASHBOARD.md`
- ☐ **ROI 전수 BLOCKED_PROVISIONAL.** 사람 visual sign-off 전까지 ROI/부피 정량은 "후보". 게이트 정책 필요. → `knowledge/data/roi_volumes.md`
- ☐ **ComBat/within-cohort 누수.** 05·06의 AUC≈0.9는 LOCO 미적용(site 누수 포함). train-fit ComBat 미검증. → `knowledge/data/cdr_target_and_harmonization.md`
- ☐ **NACC 결측코드(88/99/-4).** 정수 저장이라 `isna()` 오판 → 디코딩 전 통계 금지(전수 점검). → `knowledge/data/cohorts/NACC.md`
- ☐ **minyoungi 역할 경계.** README는 "실험 코드 없음"이나 `experiments/`에 GPU 산출물 존재. source of truth 명시. → `workspaces/minyoungi/risks.md`

## 🟡 정밀화

- ☐ `cdrsb` 실값 vs placeholder 여부(minyoungi 2026-05-31 daily 숙제). → `workspaces/minyoungi/findings.md`
- ☐ `Official/potato/Reset_Audits/` 부재 — minyoung3 pre-delete inventory 실제 위치 불명. → `workspaces/minyoung3/risks.md`
- ☐ AIBL 세션 카운트 991(per-cohort) vs 987(통합 manifest) 4세션 차이. → `knowledge/data/cohorts/AIBL.md`
- ☐ 코호트별 sex 코딩(1/2 ↔ M/F) 규약 확인(ADNI·AIBL·KDRC). → `knowledge/data/cohorts/`

## 갱신 방법

- 새 `[VERIFY]`가 카드/데이터 문서에 생기면 여기로 승격. 해소 시 ☑ 후 다음 갱신에 줄 삭제.
- daily note의 `## 메모`에서 그날 해소한 항목을 이 파일에 반영하면 추적이 유지된다.
