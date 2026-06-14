# I07 — "무엇을 fuse하나"의 답(amyloid): 임상/유전 지배, T1 image는 marginal

## 무엇을 했나
강화된 manifest(full KDRC)로 amyloid를 표적으로 modality ablation(image-proxy=morphometry vs
age/sex/APOE/MMSE/site), subject-CV+LOCO+bootstrap CI, dx-층화. (`scripts/whattofuse_amyloid.py`)

## 발견 (실패 지점 + 인사이트)
- **임상/유전이 image보다 강함**: clinical(age+APOE+MMSE) 0.768 > image(morpho) 0.708 (ALL dx);
  CN 0.715 > 0.604.
- **T1 image는 임상 너머 거의 0**: image+clinical 0.787(+0.02, ALL) ; **CN에선 0.685 < clinical
  0.715 (image가 오히려 노이즈)**. → T1의 amyloid 신호는 임상에 redundant + CN에서 음의 기여.
- APOE 단독 0.664(최강 비-이미지), age+APOE 0.729. site는 LOCO 0.500=base-rate shortcut(전이 0).

## 재사용 가능한 인사이트
1. **"어떤 정보를 fuse"의 답은 target-의존이고, amyloid에선 임상/유전(APOE/age/MMSE)이지 T1
   image가 아니다.** image-only 표현학습으로 amyloid를 풀려던 프레임이 애초에 틀렸음(캐스케이드:
   amyloid는 분자-이른 사건, T1은 위축-늦은 하류 → CN에서 T1 신호 ~0).
2. **modality ablation을 GPU 전에 먼저 하라**: 어떤 modality가 신호를 갖는지 CPU로 확정하면,
   image-only로 헛GPU 쓰는 걸 막는다. image가 clinical에 0을 더하면 image-only는 음성 확정.
3. **site는 fuse 금지 신호**: within-CV에선 0.557처럼 보이나 LOCO 0.500 → 순수 base-rate shortcut,
   전이 안 됨. site-더미를 feature로 넣으면 누수성 과적합.
4. 함의: amyloid를 *예측*하려면 multimodal(image-secondary), *image 표현*을 연구하려면 amyloid는
   부적합 target(신호가 image에 없음). → causal deconfounding(이미지 신호=confound-매개 입증) 또는
   target 전환이 정직.

## 증거/포인터
- `scripts/whattofuse_amyloid.py`, `scripts/feasibility_confound_invariant.py`,
  [[I02_amyloid_null_and_morphometry_oracle]] (캐스케이드/천장), [[I06]] (longitudinal).

## 부록 — target 전수 탐색 (image-dominant 후보, `find_image_dominant_target.py`)
- 자명/해결: sex(img0.78)·age(0.74) — 연구가치 X.
- morphometry-포화(oracle 함정): AD_vs_CN(img0.885=clin0.64지만 morpho 포화), MMSE_low(0.82), vendor(0.86=harmonization nuisance).
- morphometry-weak(headroom 후보): **Fazekas/WMH morpho-volume 0.592** — 그러나 n=662·KDRC단독·age교란(age단독0.683>morpho)·T1<FLAIR → 약한 positive(병변을 부피가 놓치니 당연), strong 발견 아님.
- **결론: 이 multi-cohort 구조-T1에 "학습표현이 engineered feature를 강하게·일반화가능하게 이기는" 타깃 없음.** 분자=T1-blind / 형태=morphometry-포화 / 공간=소규모·교란. mechanism 규명됨.
