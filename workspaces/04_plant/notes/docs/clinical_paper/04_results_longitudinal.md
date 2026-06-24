# Round-2 결과 — 종단 prognosis (2026-06-24)

> goal: (A)(B) 확인 후 확실한 주제 finding 존재 여부. cross-sectional 전부 사망 후 **종단 탈출구** 검증.

## 데이터 (검증)
- AJU 종단: **286 subject × 2 timepoint** (longitudinal manifest 572행). 반복 MMSE/CDR/dx 286 전원, 반복 T1 286, FLAIR 271. **반복 PET=0**(baseline만). K-ROAD 한계("예후 연구 제약")와 대비되는 차별점.
- ⚠️ **치명적 데이터 갭: 추적 간격(개월) manifest에 없음** — longitudinal age 전부 NaN, korean age 세션불변, 날짜컬럼 없음. raw TFU(오프로드)에서 복구 필요. **현재 ΔMMSE는 interval 미보정.**

## 파일럿 (n=285, ΔMMSE, KFold 5×25seed Ridge)
ΔMMSE mean −0.72(sd 3.37), decliner(≤−3) 76명.

| 블록(cum) | R² | 증분 |
|---|---|---|
| C_clinical | 0.067 | — |
| +T1morph | 0.088 | +0.021 (>0 전부) |
| +FLAIR | 0.081 | −0.007 (null) |
| +blood+APOE | 0.076 | −0.005 (null) |
| **+amyloid-PET** | **0.131** | **+0.055 [+0.037,+0.072] robust** |

## 판정
- **baseline amyloid-PET가 인지쇠퇴 예후에 임상+구조 위 실질 증분(+0.055)** → 게이트 통과. 모달리티-특이: amyloid만 예후 기여, FLAIR·혈액 null.
- cross-sectional(status)에선 amyloid가 비선형·작음(Giorgio/MEMENTO 점유)이나, **예후(decline)에선 선형·실질·차별화** — 이게 살아있는 첫 신호.

## Gate 1 — 통과 (interval 복원·보정 검정, 2026-06-24)
- **간격 복원 성공:** `aju_session_labels.csv` edate로 V1→V2 = 295명, median **1.94yr**(mean 2.39, 1.4–7.65). conversion(dx악화) 26 events.
- **interval 보정 후 amyloid 증분 유지·강화:** ΔMMSE Δ+amyloid **+0.058 [+0.040,+0.077]**; conversion Δ+amyloid **+0.031 [+0.012,+0.047]** (둘 다 robust >0). T1 ΔMMSE에만 +0.021; FLAIR·혈액 null.
- → amyloid 효과는 추적기간 교란 아님. **두 outcome 일관 modality-specific 예후 지도.**

## 남은 게이트
2. **점유 확인 (Gate 2, 진행 중)** — "real-world Asian 멀티모달 위 amyloid-only 예후 증분"이 출판됐나. lit-scout.
3. **robustness (Gate 3) — 통과.** GBM 재현: Δ+amyloid **+0.092 [+0.050,+0.130]**(Ridge +0.058보다 큼=비선형 성분). GBM에선 T1조차 0 → **amyloid가 유일 예후 모달리티** 더 선명. Ridge·GBM·ΔMMSE·conversion 전부 동의. (conversion events 23-26 작음=검정력 caveat, ΔMMSE primary.)

## 현재 종합 (Gate 2 대기)
- Gate 1(interval)·Gate 3(robustness) 통과. **경험적으로 finding 단단:** real-world Asian 종단에서 baseline amyloid가 유일하게 인지쇠퇴/conversion을 임상+구조+혈관+혈액 위 예측.
- 확정은 **Gate 2(점유)** 결과에 달림 — 공백이면 확실한 주제, ADNI 포화면 정직한 강등.

## 후보 claim (잠정)
"실세계 Asian memory clinic에서, 가용한 전체 멀티모달+혈액 스택 중 **baseline amyloid-PET만이** 인지쇠퇴에 임상·구조 위 예후 증분을 주며(+0.055 R²), 구조·혈관·혈액 마커는 더하지 않는다 — K-ROAD의 불완전한 종단이 아직 답 못하는 modality-specific 예후 지도."
