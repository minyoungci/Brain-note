# I05 — 방법론·설계 인사이트

## M1 — leakage-safe multimodal fusion (privileged information)
다운스트림 레이블(amyloid 등)을 인코더 **입력**으로 fuse하면 test 시 누수. 해결: 인코더는
**image-only**로 두고 tabular는 **auxiliary 예측 타깃**(privileged-info distillation)으로만 fuse.
→ "정보 X를 예측하도록 표현을 형성하면 다운스트림이 좋아지는가"를 누수 없이 검증. test는
image-only 임베딩 → 레이블 필드 미투입, pretrain/test subject disjoint.

## M2 — gating 검증을 GPU 전에 (CPU로 morphometry 바부터)
새 target은 항상 **morphometry(±age±APOE±baseline-severity) 바를 CPU로 먼저** 측정.
- oracle(≈1.0)이면 vision headroom 없음 → 중단.
- 강하지만 비-oracle(0.7–0.8)이면 headroom 존재 → 단, 기여는 method/efficiency/transfer로 framing.
이 한 번의 CPU 검증이 수 시간 GPU 낭비를 막는다.

## M3 — 정직한 바와 stratum
- dx-층화(CN 별도), age(+sex)-matched 다중-draw, subject-bootstrap CI를 항상.
- pooled/혼합-dx 헤드라인 금지(교란 인플레이션). CN/교란-통제 셀이 honest number.

## M4 — 표현 강도 통제(null 주장 시)
from-scratch 음성은 "약한 표현" 반론에 취약. **강한 사전학습 표현(brain-age/ROI-volume/foundation)
+ frozen probe + fine-tune** 여러 regime에서 일관되면 modality 천장으로 결론. 단일 regime로 null 금지.

## M5 — 소데이터 종단 fusion: 우리의 novelty 가설(검증 대상)
선행연구 gap(확정): 종단 SSL(LSSL→LNE→SSL-AD)=imaging-only; image-tabular fusion(DAFT/CLIP)=
single-timepoint. **교집합(종단 within-subject SSL + 유전/바이오마커 fusion + 3D brain + 소데이터)
열림.** #1 각도 = **covariate(APOE/amyloid)-conditioned longitudinal direction**(LSSL 축을 유전으로
재형성). 빌드 기반 = BrainIAC(Nature Neuro 2026, 공개·소데이터 검증) + DAFT/FiLM. 주의: contrastive-
fusion 소데이터 이득은 미검증 → DAFT/FiLM 대비 ablation 필수.

## M6 — "어떤 정보를 fuse"의 실험 설계
무엇을(none/demo/APOE/MMSE/amyloid/clin/gene+mol/all) × 어떻게(aux-predict / FiLM-privileged /
contrastive-align) 매트릭스를, frozen-probe 다운스트림 + **data-efficiency(저-레이블)** + LOCO
transfer로 측정. 단일 task 금지 — 다중 다운스트림 + 효율 곡선으로 표현 품질을 평가.

## 증거/포인터
- 선행연구 brief(세션 로그), `scripts/run_fusion_ssl.py`(M1 구현), `results/longitudinal/BARS.md`(M2),
  `results/amyloid_vision/*`(M3/M4), `SPEC.md`/`LONGITUDINAL_DIRECTION.md`(M5).
