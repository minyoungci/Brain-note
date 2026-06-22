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

## E. prior-art pass (2026-06-22, literature-scout + research-critic 수렴) — Conflict-Aware 재정의 근거
**판정: 일반 아이디어("적응적 SSL balancing이 좋다")는 부분선점, 우리 좁은 방법(per-step gradient-level adaptive dense+global × brain MRI 3D)은 미점유.** → thesis 무게중심을 *기법*에서 *충돌 측정 + Pareto dominate*로 이동(= [[03_architecture_method]] §1 Conflict-Aware).
- **Galileo(ICML2025, RS)** ⚠️위협: local-global "충돌 → 결합이 해소"를 *문자 그대로* 주장(우리 동기와 동일). 단 둘 다 contrastive·target/masking 분리·dual이지 **adaptive gradient balancing 아님**, **충돌을 측정 안 함**(특히 brain MRI). → 인용+delta 필수. [VERIFY] §3 원문 직독.
- **ControlG(ICML2026, graph)** ⚠️최대위협: "고정=Pareto-suboptimal → closed-loop 적응(MGDA gradient-conflict)" 명제 선점. 단 **graph + temporal allocation(시간분할)** → 이미지 dense+global은 공간 얽힌 단일 forward라 temporal 불가 = **per-step 필연(우리 delta)**. baseline arm으로 포함.
- **고정 λ 확인(우리 토대)**: DINOv2(TMLR24)·iBOT·MedDINOv3·MTV = 전부 고정 weight. 3DINO `L_image+L_patch` 고정가산 [VERIFY] 본문 수식 직독(baseline 정당화 핵심).
- **②③ 위협**: ② cross-seq recon은 BrainFM(2511.03014)·CCSD가 사실상 선점 → 강등. ③ scanner-inv-in-SSL은 미점유(가장 열림, 단 정확도 trade-off).
- **FOMO25 findings(2604.11679)**: CNN이 ViT 지배(우승=U-Net CNN+anatomical prior) → balancing을 **backbone-agnostic**으로(ViT·ResEnc 양쪽 입증).
- **related work 보강 필요**: Galileo·ControlG·BrainFM·BrainSegFounder·BrainIAC 인용 추가.

## F. prior-art pass 2 (2026-06-22, literature-scout) — decoder-transfer thesis **선점 확인**
**판정: C(SSL decoder-transfer for few-shot 3D seg)는 이미 선점(borderline-dead).**
- **⚠️ 최대 위협 = S3D (Wald et al., CVPR 2025, arXiv 2410.23132)**: **같은 그룹**(DKFZ/nnU-Net = OpenMind 원저자·심사자 가능성), **brain MRI**, **full ResEnc U-Net sparse-MAE 사전학습**, **encoder+decoder vs encoder-only 전이 ablation(Table 3)** + **저데이터 곡선 10~40 img(Table 6)** 전부 수행. 마진 작음(+0.42 DSC full-data) → "우월" 주장 CI tie 위험.
- **Models Genesis (MedIA 2021)**: "encoder+decoder 통째 전이 for seg" 개념 원조(few-shot·ablation 없음).
- full U-Net 사전학습은 CNN 계열서 사실상 표준(S3D·HySparK·VoCo·Models Genesis). "encoder-only가 표준"은 MIM/ViT 라인만 참.
- **유일 생존 틈(얇음)**: few-shot N-곡선에서 디코더 전이의 *한계 기여 분리 측정*(S3D 미수행). tie/negative 위험 → negative-results paper로만 가치.
- 보조 Q5: dense/global **깊이별 분업**은 기존 현상(Local Multi-Scale MIM, CVPR2023 [VERIFY]) → 우리 conflict pilot 관찰은 *재확인*이지 발견 아님.
- **scout 권고**: C 포기. 대안 — (옵션2) FOMO26 고유 제약 **단일 체크포인트→7 이질 task(seg+cls+reg)** balancing(S3D=seg-only라 미점유), (fairness) scanner-invariance-in-SSL(가장 열림), (옵션1) decoder regime-dependent negative-results.

## deep-research 종합 (2026-06-21, 24소스→25주장 검증, 17확정/8기각)
우리 셋업(226,793볼륨·8×B200·local-global balancing thesis·seg 50%·120초) 정조준 다축 조사.
- ✅ **local-global tension 실재**(OpenMind ICCV25, 3-0): 어떤 3D SSL도 dense+global 둘 다 못함(contrastive→cls, MAE→seg). **우리 thesis의 직접 동기.**
- ✅ **3DINO가 최근접 선행**(npj Dig Med25, 3-0): ViT-L 16³·96/112 crop·2+8 multi-crop·EMA, DINO+iBOT 한 백본. **단 두 목적을 `L_image+L_patch` 고정가산** → 적응적 비가산 미선점(단 검색한계, prior-art pass 필요).
- ⚠️ **biggest risk**(3-0): 3D seg는 **ResEnc-L CNN 평균최강 + MAE>DINO-distill**. seg=50%니 순수 DINO-objective ViT 위험 → dense를 MAE로 강하게 + ResEnc baseline 벤치.
- ✅ 채택 요소: **register token**(dense에 비대칭 이득, ICLR24) · **Gram anchoring**(긴 학습 dense 퇴화 해결, DINOv3) · **KoLeo/prototype reg**(K 키워도 cluster 안 늚) · **FlashAttn+FSDP**(DINOv2 2×빠름·1/3 메모리).
- ✅ **큐레이션>규모**(DINOv2): "더 많은 데이터"가 무조건 이득 아님 → 조성(DWI/정량맵) 큐레이션 정당.
- 🚫 **기각(믿지 말 것)**: "CNN이 ViT 큰 격차로 이김"(0-3, ViT 격차는 평균최강이지 압도 아님) · "PrimusV2=ResEnc seg 동등"(1-2, ViT seg 동등성 미해결) · "DINOv3 frozen이 SOTA 광범위 격파"(0-3).
- 미해결(우리가 측정/조사): ~~adaptive SSL balancing 선점 여부~~(✅ §E 해소: 부분선점 → Conflict-Aware 재정의) / **dense-global cos<0 실측(GATE, 선결)** / 8×B200 throughput·120초 / dense MAE vs iBOT / 구조+DWI 단일채널.

## 핵심 출처 (peer-reviewed)
OpenMind(ICCV2025, 2412.17041) · 3DINO(npj Digital Medicine 2025) · MiM(IEEE TMI 2025, 2404.15580) · CVA(MICCAI2025, 2509.13846) · DINOv2(2304.07193) · PrimusV2(TMLR2026) · nnU-Net Revisited(MICCAI2024, 2404.09556) · MedNeXt(MICCAI2023) · S3D(CVPR2025, 2410.23132) · SparK(ICLR2023, 2301.03580) · SimPool(ICCV2023, 2309.06891) · DeSD(MICCAI2022) · Swin UNETR(CVPR2022) · MedDINOv3(2509.02379) · Kendall(CVPR2018)·GradNorm(ICML2018)·PCGrad(NeurIPS2020) · BM-MAE/MultiMAE · mmFormer/ShaSpec(CVPR2023) · 2511.11311(modality-inv negative) · Ouyang(IPMI2021) · BrainFM(2511.03014)[VERIFY].
**prior-art pass 추가(§E)**: Galileo(ICML2025, 2502.09356) · ControlG(ICML2026, 2602.05036) · FOMO25 findings(2604.11679) · CCSD(2511.14599)[VERIFY] · MTV(2601.13886)[VERIFY].

→ 모델 설계는 [[03_architecture_method]], 데이터/무결성은 [[02_data]], 전략·일정은 [[04_strategy_plan]].
