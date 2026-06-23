# RESEARCH_FOCUS — 단일 source-of-truth (매 턴 갱신)

> 목적: 주제 shift로 맥락이 흩어지지 않도록, *현재 무엇을 왜 하는지* + *검증된 데이터 사실* 만 한 곳에.
> 규칙: 추측 금지(사실은 manifest/데이터 직접 inspect). 결론은 검증 후에만. 매 작업 후 이 문서 갱신.
> 최종 갱신: 2026-06-23 (clean restart)

---

## 0. 현재 초점 (CURRENT FOCUS)
**주제(잠정 확정): AJU 기억클리닉 — 임상 혈관성 vs AD 인지장애의 멀티모달 특성화 + 혼합병리 유병률**
- 코호트: AJU n~1001 (임상 아형 ck_sdcode + amyloid + WMH(583) + SNSB 전배터리 + 위축). within-cohort(측정 일관).
- 핵심 검증된 발견(2026-06-23):
  - 인지 **이중해리**: 순수AD=기억저하 / 피질하혈관치매=집행저하, 그룹×도메인 p=0.0009.
  - 바이오마커가 임상아형 검증: AD계열 amyloid 76–86%+ vs 혈관계열 10–16%+; WMH는 혈관진단서 최고(피질하혈관치매 14954).
  - **혼합병리**: 임상-혈관계열의 38%가 amyloid+ (n=254).
- Aims: ①아형별 멀티모달 signature ②인지 이중해리(바이오마커 anchored) ③혼합병리 유병률·영향 ④(선택)임상-바이오마커 불일치.
- Tier(정직): solid 임상/dementia 저널. 이중해리 자체는 교과서적(기여=멀티모달anchoring+한국혼합병리+불일치). **단 검증 통과한 첫 viable 주제.**
- 다음 엄격화: 교육연수 보정(AJU raw)·다중비교·효과크기·전아형 확장·민감도 → claim-leveling.

---

## 1. 검증된 데이터 사실 (durable, 직접 inspect로 확인)

### Canonical 데이터
- manifest: `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet` — **13,022 세션 / 7,231 subject × 141열**. 전처리 T1 텐서 100% 실존(192×224×192 N4).
- 7 코호트: ADNI 4742·NACC 1866·A4 1811·OASIS 1420·AJU 1287·AIBL 987·KDRC 909 (세션).

### 한국 코호트 (가장 풍부한 임상 자산)
- **AJU 임상**: `Clinical/consortiums/_korean_cache/aju_bl.parquet` (1322×876). 조인키 = `epid`(="ABD-AJ-0001", manifest subject_id와 매칭). **SNSB-II 전배터리 z-score**: SVLT_DR_z 99%·RCFT_DR_z 98%·RCFT_C_z 99%·COWAT_animal_z 98%·COWAT_PH_z 72%·Digit_span_Forward_z 99%. 혈관아형 진단 `ck_sdcode` 100%. amyloid(visual)·APOE 보유.
- **KDRC 임상**: `_korean_cache/kdrc.parquet`. amyloid visual+SUVR, Fazekas(pv/deep), APOE.
- 멀티모달 전처리(korean_multimodal_manifest, 2196세션): T1+FLAIR 2148·T1+PET 1882·trimodal 1836.
- **WMH 정량**(WMH-SynthSeg): AJU 583 = `research_tracks/06_wmh_tool_benchmark/results/deep_wmh_decomp.csv` (subject_id, pv_wmh/deep_wmh/total_wmh). KDRC는 미산출(Fazekas만).

### 검증된 robust 임상 효과 (한국 코호트, 2026-06-23 실측)
- 진단 분리: 해마부피 AD-vs-CN Cohen's d=+1.32, MMSE d=+2.30.
- amyloid+vs−(KDRC): MMSE d=+1.03, 해마 d=+1.01 (amyloid+ 417 / − 492).
- APOE-e4 용량효과: → 해마 ρ=−0.21·MMSE ρ=−0.21 (p~1e-11, n=1000; e4 0/1/2 = 707/260/33).
- SNSB 도메인 CN→MCI→AD 단계적 저하(언어기억 +0.65→−0.99→−2.09 등).

### 데이터 제약 (사실)
- 한국 종단 없음(KDRC 단일세션·AJU 최대 2). MCI→AD conversion = manifest에 per-visit dx 없음(subject-level backfill).
- amyloid 라벨: OASIS centiloid 비교적 검증, NACC/AJU/KDRC LABEL_UNVERIFIED, A4 단일클래스(forbidden).
- raw 영상: 현재 `/home/vlm/data/raw`엔 AJU만(DICOM 미변환 DTI/ASL/SWI/MRA/fMRI). KDRC/OASIS/A4 raw 이동됨.
- traveling subject = 0 (동일인 다기관 스캔 없음).

---

## 2. 이미 확인하고 보류 (재탐색 금지 — 시간낭비 방지, 중립 기록)
- "deep가 morphometry/simple baseline을 정확도로 이김"(T1 CN/AD·진행·생성): 이 데이터선 구조적으로 안 됨. → big-AI 야망은 FOMO(별도 디렉토리)에서.
- amyloid×혈관 상호작용, WMH→인지 도메인 이중해리: 한국 데이터서 미지지(약함/비특이).
- FOMO26: MICCAI2026 foundation 챌린지 = **별도 프로젝트(다른 디렉토리)**, 이 프로젝트와 분리.

## 3. 기존 자산 (보존, 활용 가능)
- `research_tracks/04`(삭제됨, memory만)·`06_wmh_tool_benchmark`(WMH 도구·정량)·`07_medical_agent`.
- `tools/wmh_synthseg` 설치됨. spec-curve/mediation 코드 자산(Track04).
- 루트 `SCRATCHPAD.md`(기존 핸드오프, 별개).

---

## 4. 상태/결정 로그 (최신이 위)
- **2026-06-23 (3)**: AJU 지형 매핑 → **주제 확정**(혈관 vs AD 멀티모달 특성화). 이중해리 p=0.0009 검증 통과. 아형분포: MCI기억형371·비기억형131·SMI114·혈관성MCI104·AD순수94·AD+소혈관58·피질하혈관치매44·AD+혈관38. 스크립트: scratchpad/aju_map.py, dissoc_group.py.
- **2026-06-23 (2)**: Western vs KDRC 비교 시도 → 해마-인지 coupling 차이는 **MMSE 측정 비동등성 artifact**(나이·뇌실도 동일 약화). cross-cohort 정량비교 = 측정 비동등성으로 본질적 한계. → within-cohort(AJU)로 전환.
- **2026-06-23 (1)**: clean restart. 세션 thrashing 산출물 삭제(Tracks 08–12 + 메모리 2건). 단일 source-of-truth 신설.
