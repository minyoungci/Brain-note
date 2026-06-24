# ΔMMSE 주-outcome 확정 + 추가 인사이트 (2026-06-24)

> 1번 확정(임상의 지적·진단필드·2-wave 한계 우회). 코드 `experiments/incremental_value/11_dmmse_primary.py`.

## 주 결과 (ΔMMSE, full 임상바 보정, n=286)
- **amyloid β=−1.39 [−2.26,−0.52] p=0.002** · **vascular β=−1.28 [−2.16,−0.41] p=0.004**
- 보조 **ΔCDR-global**: amyloid p=0.019 · vascular p=0.047 (두 outcome 일관)
- **순수 가산**: amyloid×vascular 교호 p=0.889 (시너지 없음, 독립 2축)
- 용량반응: 연속 SUVR β=−5.7 p<0.001(강). WMH 부피 p=0.102(null, age-교란 — 기존과 일관).

## ★추가 인사이트 — amyloid 예후효과의 *나이 의존성*
- **amyloid × age 교호 β=+1.39, p=0.001** → amyloid의 쇠퇴 예측력이 **젊은 MCI에서 강, 고령서 소멸**(−1SD≈−2.8 / +1SD≈0).
- 해석: 젊은-발병 amyloid+ = 순수 prodromal AD(강 예후); 고령 amyloid+ = 혼합병리·경쟁위험에 희석. 문헌(amyloid 특이성 age↓)과 일치.
- **actionable:** amyloid를 예후마커로 쓸 때 나이 층화 필요.
- **정직(다중비교):** 효과수정 8검정 중 amyloid×age(p=0.001)만 Bonferroni(0.006) 통과 = 진짜. amyloid×edu(p=0.041, 인지예비능 시사)·vascular×sex(p=0.066)=탐색적·미보정. APOE 효과수정 없음(amyloid 통해 작용).
- caveat: 고령 amyloid+ 바닥효과 가능(baseline MMSE 통제됨), 관찰자료 효과수정 한계.

## 헤드라인 정정
- ~~"전환 47%"~~ → **"실세계 Asian MCI에서 baseline amyloid·vascular etiology가 2년 인지쇠퇴를 독립·가산적으로 예측; amyloid 예후효과는 나이 의존적(젊은 MCI서 강)."**
- 전환은 "치매 진행(병인불문)" 보조 + 진단필드 한계 명시. 병인별 치매 트랙은 follow-up 세분 부재로 주장 불가.

## 한계 (확정)
2-wave 단일변화(궤적 아님)·MMSE screening급·단일기관·n=286·29% 추적(대표성 확인됨). 혈액=루틴검사(혈장 AD마커 미통제). vascular=임상 라벨(미래 outcome이라 비순환, 단 CV예측증분 약). 체급=JCN급.
