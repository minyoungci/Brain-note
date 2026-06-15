# 01 · 문헌 SOTA 지형 (4 방향) — 우리 데이터 적부 판정

> 출처: literature-scout 독립 조사(2026-06-07). 범위 2022–2026 top-tier 우선.
> 검증 등급: ★★★ peer-reviewed / ★★ peer-reviewed but not top-tier / [PREPRINT-ONLY] arXiv·medRxiv·bioRxiv 단독(근거로 인용 금지, 비교군/맥락으로만) / [VERIFY] 인증벽 미확인.
> 우리 바: **morphometry LOCO AUC ~0.91 (한국 KDRC 포함, site-shift 비용 ~0)**.

---

## D1 — Foundation / Self-Supervised Models for Brain MRI

**핵심 SOTA**
- **BrainIAC** — [Nature Neuroscience 2026] ★★★. SimCLR 32k 사전학습, 48,519 스캔 검증. 7 downstream에서 supervised-from-scratch·MedicalNet 상회(특히 low-data). 체크포인트 공개(비상업 학술 라이선스). ⚠️ **AD에서 morphometry와 직접 비교했는지 [VERIFY]**(인증벽).
- **y-Aware InfoNCE** — [Dufumier et al., MICCAI 2021] ★★★. age 등 연속 메타를 contrastive에 결합(biology-guided pretraining seminal).
- **AnatCL** — [Barbano et al., Pattern Recognition Letters 2026] ★★. cortical thickness+age weak-contrastive. 체크포인트 공개. travelling-heads에서 cross-scanner ICC 0.97(FreeSurfer 0.93 초과).
- **3D-Neuro-SimCLR** [PREPRINT-ONLY] — AIBL OOD fine-tune AUC 0.929 vs supervised 0.869. **단 morphometry 비교 없음**.
- **NeuroFM** [PREPRINT-ONLY] — 136k 볼륨. AD vs CN AUC **0.77**(우리 0.91보다 낮음).
- 메타리뷰 [PREPRINT-ONLY]: "Are We There Yet?"·"Towards Generalisable FMs" — 다수 FM이 within-study엔 좋으나 **cross-site external 증거 부족**.

**Open problem**: (1a) FM이 morphometry를 cross-site로 이긴다는 peer-reviewed 직접 증거가 빈약. (1b) **순수 SSL은 site-robust 아님**(D3 ICC 0.25–0.45) — robustness는 규모가 아니라 *biology-guided objective*에서 나옴.

**우리 데이터 적합**: 13k pooled로 공개 체크포인트 linear-probe **가능**. 최적 후보 = **AnatCL·y-Aware**(코드+가중치+biology-guided). 부족: 우리 입력(192³ z-score N4 identity-affine)과 FM 전처리 규격 불일치 위험 → 입력 정합 미확인 시 linear-probe가 site shortcut을 측정할 수 있음. 사전학습에 한국 미포함 → 한국이 진짜 시험대.

**Verdict**: **GPU-GATED + FEASIBLE(조건부)**. 반드시 **0.91 LOCO 바(한국 held-out)** 게이트. 낙관 금지 — 순수 SSL은 못 넘을 공산, 넘을 후보는 biology-guided.
**닫힌-방향 충돌?**: 부분(07=image from-scratch<morphometry)이나 **회피 가능** — linear-probe는 PLAYBOOK §3②가 명시한 *유일 미시도 우회로*. 단 dual-probe 게이트 필수.

---

## D2 — Multi-site & Cross-population(인종/민족) Generalization·Fairness

**핵심 SOTA**
- "Racial/Ethnic Disparities in Brain Age" [PREPRINT-ONLY] — African-American 정확도 저하. **아시아 없음, site vs biology 미분리**(우리 차별점).
- "When Brain Models Aren't Universal" [PREPRINT-ONLY] — 인종 간 인지예측 붕괴 벤치마크. [VERIFY 한국 포함].
- "Assessing demographic bias in brain age" [Pattern Recognition Letters 2025] ★★ — Asian 포함하나 brain-age(AD 아님).
- "Bias and generalizability of brain age" [Imaging Neuroscience 2025] ★★★ — 다중 코호트 일반화(brain-age 도메인).
- 선행 normative: **Korean vs Caucasian FreeSurfer norm "incompatible"** [PMC8369368, 2021] — *통계만*, 모델/audit 축은 비어 있음.

**Open problem**: **AD classification에서 비서구(특히 한국) 일반화·공정성 peer-reviewed 벤치마크가 사실상 공백**(존재하는 건 brain-age 회귀·White/Black 위주·preprint). **metric이 site-confound로 무효화되는 현상을 정면으로 다룬 연구 희소** — 우리 INSIGHT 2(site==population)와 정확히 맞물림.

**우리 데이터 적합**: 한국+서구 동시 = 문헌에 없는 조합. 부족: traveling subject 0 → "인종 효과" 인과 분해 불가. AJU CN n=**144**(~~23~~=clin_dx_label 함정 정정→[`06`](06_korean_richness_audit.md)), KDRC/A4 dx 0%.

**Verdict**: **FEASIBLE(감사·현상보고로서) / NOT-WITH-OUR-DATA(인과적 "인종 효과" 주장으로서)**. 프레이밍을 "population-confounded site에서 fairness metric이 어떻게 무효화되나"로 한정해야 방어 가능.
**닫힌-방향 충돌?**: 없음(핵심 자산과 정렬). 단 "harmonization으로 fairness 고치기"는 INSIGHT 4/X4 충돌(한국 생물학 over-correction).

---

## D3 — Scanner/Site Shortcut Auditing & Representation Validity  ⭐

**핵심 SOTA**
- **Souza et al. "Is the Disease Classifier a Secret Site Classifier?"** [IEEE J-BHI 2024] ★★★ — 41 센터. PD acc 74%인데 동일 feature로 scanner-type 79%/site 71% 회복. **우리 dual-probe의 직접 선행**.
- **Dinsdale et al. Unlearning scanner bias** [NeuroImage 2021] ★★★ — confusion-loss로 scanner-invariant. 코드 공개. *"erase" 진영 — 우리가 X4로 부정한 방향(감사 도구로만 인용)*.
- **Glocker et al.** multi-site scanner effect 정량 ★★★ [VERIFY venue/year].
- "Disentangling Anatomy and Contrast" [PREPRINT-ONLY] — demographic 예측을 anatomy vs contrast로 분해(우리 INSIGHT 1 3축의 최신 변주).
- **Cross-Scanner Reliability of FM Embeddings (Travelling-Heads)** [PREPRINT-ONLY] — ON-Harmony 20명×8스캐너. **순수 SSL ICC 0.25–0.45, embedding 분산의 23–58%가 scanner identity. biology-guided(AnatCL 0.97, y-Aware 0.81)·FreeSurfer 0.93가 우위.**

**Open problem**: **site==population(교란) 상황의 감사 프로토콜이 미해결.** Souza/Dinsdale/Glocker/travelling-heads 모두 site와 population이 *분리 가능*하다고 가정(traveling subject 보유 or 균질 인구). 우리처럼 traveling 0이면 single site-probe도 unlearning도 결정 불가 → **biology-preserving 비순환 probe + null 3종 동시가 유일 판정자**라는 점이 아직 표준화 안 됨. **traveling 없이 cross-scanner validity를 판정하는 대안**이 공백.

**우리 데이터 적합**: 강함 — INSIGHT 1이 이미 3축 정량(metadata 0.761 > appearance 0.556 > N4 0.517 ≫ biology 0.151) + dual-probe 인프라 보유. 부족: traveling 0 → travelling-heads식 ICC(황금검증)는 자체 데이터로 불가(외부 인용 필요).

**Verdict**: **FEASIBLE — CPU/소GPU 즉시.** feature-space dual-probe+null은 이미 돌려본 인프라. 신규성 = Souza/Glocker 프레임 위에 "site==population에서 감사 무효화 + 비순환 probe가 유일 판정자".
**닫힌-방향 충돌?**: 없음(고치기 아닌 감사 = 우리 D6 철학). 단 Dinsdale unlearning을 *해법*으로 채택 시 X4 충돌.

---

## D4 — Acquisition-Conditioned Modeling (condition-not-erase)

**핵심 SOTA**
- **DSBN** [Chang et al., CVPR 2019] ★★★ — 도메인별 BN 분리(condition-not-erase 원조, 일반 도메인적응).
- **FiLM** [Perez et al., AAAI 2018] ★★★ — 조건 임베딩 scale/bias(우리 vendor×field×voxel 조건화 수단).
- **y-Aware/AnatCL** [MICCAI 2021/PRL 2026] ★★★/★★ — site를 지우는 대신 biology를 *조건/앵커*로 → site-robust. **condition>erase의 직접 비교 증거**(ICC 0.97/0.81 vs unlearning계 SSL 0.25–0.45).
- "Contrastive Anatomy-Contrast Disentanglement" [MICCAI 2025] ★★★ — anatomy↔contrast 분리(erase 아닌 *분리* 최신 peer-reviewed).
- MRI Harmonization Survey [PREPRINT-ONLY, survey] — harmonization-as-removal이 cross-site 일반화를 보편 개선한다는 결론 없음(우리 INSIGHT 4와 정합).

**Open problem**: (1) "erase vs condition" 정면 성능 비교가 AD downstream에서 부족(ICC reliability는 비교됐으나 LOCO AUC는 아님). (2) **consortium-id가 아니라 vendor×field×voxel 축만 조건화**한 AD 연구가 공백(우리 X6 경고 지점).

**우리 데이터 적합**: acquisition 메타 100% 복구 → DSBN/FiLM 조건 키 즉시 사용. 부족: 0.91 바를 이기려면 이미지 인코더 학습 필요(GPU), from-scratch는 07로 부정 → **반드시 D1 pretrained 인코더 + acquisition-conditioned head로 결합**.

**Verdict**: **GPU-GATED.** 메타 준비됨, 메커니즘 표준이나 단독 from-scratch는 07 함정 반복. D1 성공 전제의 후속.
**닫힌-방향 충돌?**: 없음(우리 §4 핵심 원리 그 자체). 단 조건 키를 consortium-id로 주면 X6 충돌.

---

## 문헌 결론 (literature-scout)
- **순수 SSL ≠ site-robust. morphometry에 필적·초과하는 유일한 이미지 경로 = biology-guided pretraining**(AnatCL/y-Aware) — 외부 travelling-heads가 직접 증거.
- **유망 1순위 = D3**(즉시·고신규성·충돌 없음), **2순위 = D1**(GPU, biology-guided만, 0.91 게이트). 권장 동선 **D3 → D1 순차**, D2는 D3의 cross-population 사례로 흡수, D4는 D1 성공 전제 후속.

## Sources (주요)
- Souza, *Is the Disease Classifier a Secret Site Classifier?*, IEEE J-BHI 2024 — https://pubmed.ncbi.nlm.nih.gov/38198251/
- Dinsdale, *Unlearning scanner bias*, NeuroImage 2021 — https://www.sciencedirect.com/science/article/pii/S1053811920311745
- Dufumier, *y-Aware*, MICCAI 2021 — https://link.springer.com/chapter/10.1007/978-3-030-87196-3_6
- Barbano, *AnatCL*, Pattern Recognition Letters 2026 — https://arxiv.org/abs/2408.07079 (code: github.com/EIDOSLAB/AnatCL)
- BrainIAC, Nature Neuroscience 2026 — https://www.nature.com/articles/s41593-026-02202-6 (code: github.com/AIM-KannLab/BrainIAC)
- DSBN, CVPR 2019 · FiLM, arXiv 1709.07871 · Contrastive Anatomy-Contrast, MICCAI 2025
- [PREPRINT-ONLY] Travelling-Heads FM reliability (medRxiv 2026.03.23) · 3D-Neuro-SimCLR (arXiv 2509.10620) · NeuroFM (medRxiv) · Disentangling Anatomy/Contrast (arXiv 2603.04113)
- 선행 normative: Korean vs Caucasian FreeSurfer norms, PMC8369368 (통계만)
