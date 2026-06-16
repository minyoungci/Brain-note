# Track 04 — Vascular SNAP (한국 횡단 임상 특성화)

## 한 줄 주장 (scoop 감사 후 재프레임)
**"amyloid-음성 한국인에서 해마 신경퇴행은 혈관부담과 연관되며(vascular SNAP),
이 연관은 amyloid/혈관 *측정도구를 바꿔도* 두 독립 코호트(AJU·KDRC)에서 재현된다."**
→ 헤드라인 = **external validity + 측정 robustness**(transportability/replication),
*not* interaction-shape 발견(아래 한계 참조).

## 데이터 정본
`Clinical/consortiums/Korean/korean_multimodal_manifest.parquet` (2196 session × 89).
캐시·full_labels.parquet 사용 금지(이미지텐서 + clin_dx_label 함정).

## 설계
- **주연**: AJU (N≈1,285, 공변량 완비, SNAP n≈217 = 통계력 원천)
- **확증**: KDRC (연속 SUVR로 "visual 아닌 정량 amyloid에서도 같은 방향")
- **outcome**: 해마부피 = (L+R) / fs_MaskVol × 1000  (eTIV 프록시 = MaskVol, *not* BrainSegVol)
- **exposure**: 혈관부담 — AJU `wmh_grade_visual`(1/2/3), KDRC `fazekas_pv`+`fazekas_deep`
- **stratifier**: amyloid (음성/양성) — **endpoint 아님, 통제 공변량/층화축**
- **covariates**: age, sex, APOE e4 count, education_years
- **분석**: A=0/A=1 층화 회귀 + A×WMH 상호작용항(2차). pooling 금지(척도 비호환) → 병렬 replicate.

## Phase
- **Phase 1 (CPU, 지금)**: 보유 visual grade로 핵 association lock. AJU 주연 + KDRC 확증. 최소 publishable backbone.
- **Phase 2 (GPU, 사전승인·하네스)**: FLAIR→정량+공간 WMH 빌드 → AJU 재분석. visual 천장 제거 + 공간 토포그래피 novelty + 저널티어↑. 이미지가 주연이 되는 단계.

## 정직한 한계 (논문에 명시)
1. **횡단뿐** — 인과 언어 금지("연관"). Korean 종단 없음(KDRC 0세션).
2. **interaction-shape는 2차·caveat 부착** — Freeze 2017(amyloid-*양성*서 강화, 반대) + British 1946(additive null) + leverage 아티팩트(composition). 헤드라인 금지.
3. **KDRC composition 갭** — amyloid-enriched(A+ 68%), SNAP n≈10 → AJU A+ 포화 복제 *못 함*. 측정정밀도 문제 아니라 표본구성. 정량 WMH로도 못 고침.
4. **pTau217 맥락** — amyloid surrogate 경쟁 안 함(amyloid 안 맞힘 → 우회).

## scoop 상태 (2026-06-15 감사)
**CROWDED-BUT-GAP-EXISTS**. 정확한 패키지(한국·횡단·A−N+ 층화·2코호트 2도구) 선점 없음.
- must-reconcile: **Freeze 2017** (JAD, PMID 27662299) — 반대 방향, #1 인용
- must-cite: 1946 British Cohort(Neurology 2022), KBASE 2024(PMID 38454444, 반대방향), Vos 2018(SNAP 정의), MITNEC-C6 2024(PMID 38574400, 공간)
- ⚠️ 제출 전 KoreaMed/RISS 한국어 잔여 스쿱 패스 1회 필수.
- 타깃 저널: Alzheimer's Research & Therapy > Alz&Dementia:DADM > JAD/CCCB.

## 상태
2026-06-16 셋업. Phase 1 정의 lock 검토 대기 → SCRATCHPAD.md 참조.
```
```
