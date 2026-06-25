# ADNI benchmark comparison + 우위 문헌검증 (2026-06-25)

> 설계: AJU main, ADNI research-cohort benchmark. **pooled 아님** — 동일 모델 코드를 각 코호트에 따로 적용, 방향·효과크기 병렬. *external validation 아님 = benchmark comparison.*
> 코드 `experiments/incremental_value/15_adni_comparator.py`. amyloid=UCBERKELEY_AMY_6MM(`data/UCBERKELEY_AMY_6MM_30Mar2026.csv`, PTID=subject_id 직접조인 1317/1580, AMYLOID_STATUS+CENTILOIDS).

## Side-by-side (harmonized 공통 공변량: age·sex·mmse·cdrsb·interval; edu는 ADNI manifest 부재로 제외)

| Question | AJU 실세계 MCI (n=252) | ADNI 연구코호트 (n=309) | 판정 |
|---|---|---|---|
| N → ΔMMSE | β−0.71 **p0.001** | β−0.35 **p0.025** | ✅ 양쪽 재현(AJU 강) |
| A 이진 → ΔMMSE | p0.054 | p0.12 | 양쪽 약함 |
| **A 연속 → ΔMMSE** | SUVR **p0.006** | Centiloid **p0.001** | ✅ 양쪽 재현(amyloid 부담) |
| A+N 동시(독립) | N robust, 이진A 약 | N robust, 이진A 약 | ✅ 동일 패턴, corr(A,N)≈0.2 |
| 이진 OR(ΔMMSE≤−3) | A OR2.48 / N OR1.34 | A OR1.57 / N OR1.11 | A>N, 둘 다 약화(공통 공변량) |
| **A×age 교호** | +1.15(이진)/+0.39(연속) **p0.004/0.043** | −0.48/−0.25 **p0.069/0.064** | ❌ **비재현(반대)** |

age 분포 동일(AJU 72.2±7.4 / ADNI 71.1±7.5, range 45-90) → A×age divergence는 **range 인공물 아님**.

## 해석 (사전선언 준수, heads-I-win 회피)
- **확증·강화(2-코호트):** AT(N)의 N축 + 연속 amyloid 부담이 연구→실세계로 **일반화**. *이진 amyloid 양성이 양쪽 약함* = AJU 결함 아닌 일반현상(연속>이진).
- **반증·강등:** amyloid×age는 **AJU-특이, 비일반화**(ADNI 반대 트렌드). 이전 제목/secondary 헤드라인에서 **폐기**. benchmark가 정확히 이 false-positive를 차단.

## 우위 문헌검증 (lit-scout, named anchor)
| 후보 | 판정 | 점유/anchor |
|---|---|---|
| 실세계 멀티모달 종단 | 부분점유 | **Younes 2025 Alz&Dem**(US ADRC). 빈자리=Asian+정량WMH |
| full 동시통제 | 약함 | **Bachmann 2026 ART 18:106**(amy+hippo+WMH+plasma) |
| **ADNI↔Asian head-to-head 종단** | 🟢 **빈자리** | Yim 2025 Neurology=횡단만 |
| WMH null | 점유(역) | **Ye 2015 Neurology**(한국 SVaD, WMH positive)·Li 2024 |
| 연속>이진 amyloid | 상식 | delta 아님 |
| Korean 실세계 MCI 종단 | 부분점유 | K-ROAD 횡단·Ye SVaD |

## 방어 가능한 delta (검증됨) — single 없음, 묶음
> AT(N) 예후구조(신경퇴행+연속 amyloid 부담 가산)가 ADNI에서 **혈관/혼합 미배제 Asian 실세계 memory-clinic MCI로 일반화**되며, **정량 WMH 동시통제 시 WMH 독립 예후기여 소실** — 이 세팅의 예후 운반자는 혈관부담이 아니라 amyloid+신경퇴행.

묶음 = ①head-to-head 일반화 설계(유일 빈자리) + ②WMH **경계조건**(발견 아님; Ye2015 반례) + ③amyloid×age 비재현. **JCN급 충분, "single delta" 포장 시 Ye2015/Younes2025/Bachmann2026 3 reject 노출.**

## 🚫 인용 위생
"Lee BS 2016 Neurology 한국 amyloid 종단" = lit-scout 특정 실패, **hallucination 의심 → 사용 금지.**

## [VERIFY] / 미해결
- Bachmann 2026 본문(WMH 독립효과 AD마커 조정 후 유의?)·Ye2015 도메인 계수 직접 확인.
- K-ROAD 종단 출판 임박 시 우위1·6 즉시 잠식 — 투고 전 재확인.
- ADNI harmonization caveat: K-MMSE vs MMSE·FS 파이프라인 차(within-cohort z로 완화).
