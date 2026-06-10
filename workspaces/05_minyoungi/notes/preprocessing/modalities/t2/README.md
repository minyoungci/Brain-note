# T2 전용 파이프라인 (anisotropy-honest)

**주의: 우리 T2는 대부분 2D 축상 4–6.5mm.** 등방 해상도를 **날조하지 않는다**. 두 산출물 emit:
- `t2_native_anisotropic` (native res, T1w-oriented) — 2D/2.5D 인코더용 **(권장 사용)**
- `t2_in_t1w_1mm` (등방 192³, T1w 정렬) — `interpolated_through_plane=true` **플래그**, 정렬/early-fusion 편의용

- 체인: `[AJU dcm2niix]` → N4 → rigid → native 보존 + 등방격자(flag) → z-score → registration QC → through-plane 해상도 기록.
- **AD 가치 marginal** (FLAIR/PET 우선). AJU 커버리지 절반(T1+T2 ~525). **ablation으로 AUC 이득 실증 전 학습 투입 보류.**
- config: `configs/t2.yaml` · 근거: `docs/PRIOR_RESEARCH.md §2`
