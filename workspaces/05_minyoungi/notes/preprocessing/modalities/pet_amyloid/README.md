# Amyloid PET 전용 파이프라인 (SUVR)

**영상 + 바이오마커를 동시에 가진 유일 축** (visual/SUVR 라벨로 self-validation 가능). AJU/KDRC raw amyloid PET ~1,000/946, 현재 4명만 전처리 → official PET 로직 확장.

- 체인: `[AJU dcm2niix]` → 4D→static(average_frames) → rigid(BBR 고려) → 1mm-RAS T1w reference → crop/pad → **SUVR(whole cerebellum, FastSurfer aseg 7/8/46/47)** → `[Centiloid: 트레이서 확정 시만]` → clip(0–2.5)→[0,1] → registration QC + SUVR sanity.
- **raw intensity 입력 금지** (dose/scanner = site 신호). z-score 대신 SUVR.
- **선결**: T1w FastSurfer seg 필요(reference region). 없으면 SUVR BLOCKED.
- **트레이서 혼재 확인 선행** — AJU/KDRC 트레이서 다르면 Centiloid 식 상이 → 확정 전 SUVR까지만 [VERIFY].
- config: `configs/pet_amyloid.yaml` · 근거: `docs/PRIOR_RESEARCH.md §3`
