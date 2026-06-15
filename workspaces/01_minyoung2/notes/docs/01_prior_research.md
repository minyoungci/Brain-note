# 선행 연구 통합 (검증된 문헌)

> 3회 deep-research(SSL 패러다임 / 아키텍처 / 멀티모달) + literature-scout + research-advisor 종합. 전부 adversarial 검증(2/3 refute로 kill) 통과한 peer-reviewed 우선. preprint는 [VERIFY].

## A. SSL 패러다임 & 핵심 미해결 문제 (1차 deep-research, 20 confirmed)
- **3대 패러다임**: ① DINOv2 self-distillation(DINO image-level + iBOT patch-level + SK-centering + KoLeo) ② MAE/MIM(reconstruction) ③ JEPA. 3D 적용 = **3DINO**(npj Digital Medicine 2025, ViT-L 16³, ~99K).
- **⭐ 핵심 미해결 문제(OpenMind ICCV2025 + CVA + 3DINO 검증)**: *단일 백본이 local/dense(seg)와 global(cls)를 동시에 잘 못 배운다.* reconstruction→seg 강함/cls 약함, contrastive→cls 강함/seg 약함. 메커니즘: contrastive=global similarity, reconstruction=pixel-wise dense.
- **빈틈(CVA 저자 명시)**: 기존 hybrid(MiM `L=L_R+0.1·L_C`; CVA RoIAlign cosine)는 **가산(additive) 결합만**. *원리적 balancing(adaptive weighting/curriculum/gradient surgery)은 미개척.* naive "doubly-contrastive"는 cls를 해침.
- **fairness**: confirmed claim 0개 → **가장 열린 축**(단 미검증=정확도 깎을 risk).
- **존재증명**: 3DINO는 한 백본으로 seg+cls 둘 다 개선(저-라벨 영역 집중 = FOMO26 few-shot 정합).

## B. 아키텍처 & backbone (2-3차 deep-research, 22+5 confirmed)
- **backbone = ViT(3DINO식)로 확정**: "CNN>transformer"는 *segmentation 지도* 근거지 SSL 아님. **3DINO가 ViT-L로 3D self-distillation 입증한 유일 peer-reviewed** = 검증된 길. PrimusV2(TMLR2026): 순수 Transformer가 nnU-Net 7/9 능가·ResEnc-L parity = ViT viable. *단 "ViT>CNN 명백"은 refuted — ViT는 저위험 선택이지 우월 입증 아님.* CNN-DINO-at-scale은 미입증(최대 리스크).
- **dense 경로 머신러리(import)**: **S3D**(CVPR2025, MAE-on-3D ResEnc U-Net, sparse conv+densification+dynamic 60~90% masking, nnU-Net +3 Dice). **SparK**(ICLR2023, hierarchical UNet skip = dense 이득 최대). **SimPool**(ICCV2023, CNN/ViT 공통 attention-pool — *CNN 대안일 때만 필요, ViT는 네이티브 토큰*). **DeSD**(MICCAI2022, 3D ResNet DINO + multi-depth distillation).
- **강등**: **Gram anchoring** — MedDINOv3에서 DSC −0.04 "optional/marginal" → 중심 금지, ablation만. 큰 커널 — 9³ 포화.
- **balancing 정당화**: Swin UNETR(CVPR2022)가 static λ1=λ2=λ3=1 사용 = 우리가 대체할 대상. 지도 MTL에선 adaptive>static 입증(Kendall CVPR2018, GradNorm ICML2018, PCGrad NeurIPS2020) — *단 SSL split-head 전이는 미입증(우리가 검정)*.

## C. 멀티모달 (3차 deep-research)
- **⚠️ modality-invariance는 seg 해침**(2511.11311): MCL+MIM 0.478 vs CL+MIM 0.494. *각 모달 고유 조직정보 → modality-specific 보존이 invariance보다 중요.*
- **설계공간 점유**: BrainFM(2511.03014, single encoder+modality embedding, *단 MAE only, self-distill 아님*). 결측 robust 빌딩블록 검증됨: modality dropout(mmFormer/ShaSpec CVPR2023), per-modality stem(BM-MAE/MultiMAE, Dirichlet 마스킹 cross-recon, missing-FLAIR 38.9 vs 14.4 Dice), MoE(MoME).
- **결론**: 멀티모달 정렬 이득은 *결측/OOD 상황 국한*(full-modal은 tie). 멀티모달 novelty ≤ balancing — "새 아키텍처"가 아니라 *self-distill×cross-seq×FOMO300K 규모* 조합 gap.

## D. 전략 (literature-scout + research-advisor)
- **infra risk > method risk**: 9주에 죽이는 건 seg 추론 파이프라인+컨테이너 제출(70% infra 걱정).
- **공저 게이트**: unmodified baseline=trivial 제외 → 7 task에 *의미있는 수정* 필요.
- **통합 SSL 금지**: FOMO25가 "단일 목적이 모든 task 못 잡음"을 *결론*으로 반증 → 시도 말 것.
- **Open 트랙**: 한국데이터(~1900)는 306K의 0.6% → 본격 추구는 자원분산, 단일 ablation만.
- **AD 함정 가드레일**: baseline 먼저 고정, 3+시드+CI, negative=자산.

## 핵심 출처 (peer-reviewed)
OpenMind(ICCV2025, 2412.17041) · 3DINO(npj Digital Medicine 2025) · MiM(IEEE TMI 2025, 2404.15580) · CVA(MICCAI2025, 2509.13846) · DINOv2(2304.07193) · PrimusV2(TMLR2026) · nnU-Net Revisited(MICCAI2024, 2404.09556) · MedNeXt(MICCAI2023) · S3D(CVPR2025, 2410.23132) · SparK(ICLR2023, 2301.03580) · SimPool(ICCV2023, 2309.06891) · DeSD(MICCAI2022) · Swin UNETR(CVPR2022) · MedDINOv3(2509.02379) · Kendall(CVPR2018)·GradNorm(ICML2018)·PCGrad(NeurIPS2020) · BM-MAE/MultiMAE · mmFormer/ShaSpec(CVPR2023) · 2511.11311(modality-inv negative) · Ouyang(IPMI2021) · BrainFM(2511.03014)[VERIFY].

→ 모델 계획은 [[02_architecture_method]], 데이터 무결성은 [[03_data_integrity]], 전략·일정은 [[04_strategy_timeline]].
