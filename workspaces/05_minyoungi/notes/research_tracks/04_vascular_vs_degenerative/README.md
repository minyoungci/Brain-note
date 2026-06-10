# Track 04 — 혈관성 vs 퇴행성 감별 (혈액 데이터의 진짜 활용처)

## 목표
혈액검사·신경학검사·WMH·ROI로 **혈관성 인지장애(SVaD/MID) vs 퇴행성(AD)**을 감별.
혈액이 AD 예측엔 무용(ΔAUC≈0)이었지만, **혈관성 맥락에선 가치가 있는지** 검증.

## 왜 혈액이 여기선 의미 있을 수 있나
- AD-amyloid 예측엔 혈액 무용(측정 확정). 하지만 혈관성은 **대사·혈관 위험인자(당뇨·지질·
  homocysteine·Hs-CRP)**가 병태생리에 직접 관여 → 혈액이 정보일 *가능성*.
- AJU 고유 강점: **신경학검사 29종, Ischemia scale(Hachinski/Rosen), Homocysteine·Hs-CRP,
  소변검사, WMH grade, Scheltens 해마위축 1,126명** ([[aju-clinical-rich]]).

## ⚠️ 제약
- **AJU 단독** — KDRC엔 신경학검사·Ischemia 없음. cross-cohort 불가(= cohort confound 회피 부수효과).
- 라벨: AJU `ck_sdcode` 23-class에 SVaD/MID/AD 구분 있음(OtherDementia 110 포함).
- 혈액의 실제 증분은 **측정 필요**(AD에선 0이었음 — 혈관성에서도 0일 수 있음을 먼저 의심).

## 측정 (TODO)
- [ ] AJU ck_sdcode → 혈관성/퇴행성 라벨 정리.
- [ ] baseline(WMH+ROI) 위 **혈액·Hachinski·homocysteine ΔAUC** — 혈관성 감별에서 혈액이 실제 더하나?
- [ ] 더하면 이 track 유효, 0이면 혈액은 이 데이터셋에서 정말 활용처 없음(정직한 결론).

## 위치
혈액·신경학·소변 raw는 `../../Clinical/consortiums/_korean_cache/aju_bl.parquet`(876컬럼)에서 확장.

상태: 미착수. 혈액 가치를 마지막으로 검증하는 track(AD에서 0이었으니 기대 낮춰 시작).
