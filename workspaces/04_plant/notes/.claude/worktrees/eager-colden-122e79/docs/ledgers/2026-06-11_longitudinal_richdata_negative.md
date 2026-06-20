# NO-GO ledger — "rich-data가 빛날 종단/멀티모달 연구" 가능성 점검 (음성)

> 2026-06-11. "AJU/KDRC의 풍부한 clinical+모달리티로 가능한 연구가 있나"를 데이터로 직접 점검. 결론: **세 가지 구조적 어긋남으로 음성.**

## 점검한 가설
풍부한 멀티모달(T1+FLAIR+PET+혈액+WMH)이 빛날 자리 = 종단 진행(progression) 또는 etiology subtyping. label만 살아나면 가능.

## 측정 (직접)
1. **혈액 incremental (재확인):** morph+age 대비 Δ = dementia +0.005 · MCI-vs-CN +0.000 · amyloid +0.007. → 혈액은 어떤 task에도 morphometry 너머 기여 없음.
2. **종단 구조 — 전체 manifest:** multi-session subject 2,830. cdrsb가 subject 내 *변하는* 경우 1,021(39%). 단 **session_id가 날짜로 파싱되는 코호트는 ADNI/AIBL뿐**(나머지는 날짜 아님). 날짜+cdrsb 궤적 = **849 subjects 전부 ADNI**(median span 2,090d≈5.7y, 진행자 Δcdrsb≥1 246명).
3. **종단 구조 — Korean(rich) 코호트:** korean manifest 2,196세션, **mean 1.15 session/subject = 사실상 cross-sectional**. multi-session 286(전부 AJU, KDRC=0), 그중 CDR 변하는 경우 **35명뿐**. cdr_session vs baseline 차이 36건.

## 결론 — 세 가지 어긋남
1. **feature ↔ label 어긋남:** 가진 label(static AD/CN)은 morphometry 천장(0.94)인 곳. 풍부한 feature가 빛날 label(progression/etiology)은 없음.
2. **rich ↔ longitudinal 어긋남:** 종단 궤적은 **ADNI**(feature-poor, 혈액·멀티모달 없음). 풍부한 멀티모달은 **Korean**(cross-sectional). 둘이 disjoint cohort → "rich multimodal longitudinal" 불가.
3. **rich ↔ transport 어긋남:** 풍부한 축이 CN-poor(CN 195) Korean 2코호트에 몰림 → cross-site 일반화 시 풍부한 축을 버려야 함.

## 판정
- ❌ rich Korean 데이터를 엔진으로 한 *별도의 flashy 멀티모달/종단 win* 연구는 불가.
- ✅ rich 데이터의 정당한 역할 = **cross-site 멀티모달 audit/benchmark의 유일하게-완전한 testbed**(공개셋이 못 가짐). 결론은 PROPOSAL(morph-weak regime decidability)로 수렴.
- ADNI 단독 progression은 가능하나 crowded + 우리 고유데이터 미사용 → headline 부적합.
