# I09 — 첫 POSITIVE: multimodal alignment이 cross-cohort 전이를 개선

## 무엇을 했나
T1↔임상상태(age/sex/cognition, 결측 마스킹) CLIP-style contrastive alignment vs unimodal aug-SSL,
frozen image-only probe로 dx/conv/amyloid 평가 (data-efficiency + LOCO). `run_multimodal_align.py`.

## 발견 (첫 positive)
- within-cohort: align>aug, **MCI/CN +0.044(10%label도 일관)**, AD/CN @10% +0.048.
- **cross-cohort LOCO→AJU(한국): align>>aug — AD/CN +0.141, conv +0.183, amyloid +0.112.**
- 메커니즘: 임상상태 정렬이 표현을 코호트-불변 임상축에 anchor → held-out 전이↑. unimodal SSL은
  site/scanner 통계에 latch해 전이 약함.

## 재사용 가능한 인사이트
1. **method 기여는 accuracy가 아니라 cross-cohort *transfer* 축에서 나온다** — 여기선 morphometry-oracle
   천장에 안 막힘(transfer는 within-accuracy와 다른 문제). 4방향 negative 끝에 나온 첫 positive.
2. **임상상태 정렬(privileged, image-only at test)이 SSL 표현의 도메인-일반화를 개선** — 단 alignment
   메커니즘 자체는 known(Hager/Petersen); novelty는 *structured-missingness cross-cohort transfer* framing.
3. **caveat**: LOCO 대형 이득은 single-seed → seed+bootstrap으로 firming 필수. concat-fusion·morphometry-
   transfer 대비도 필요. AD/CN은 cognition→dx near-circular(MCI/CN으로 1차 판정).

## 증거/포인터
- `scripts/run_multimodal_align.py`, `scripts/agg_multimodal_align.py`, `results/multimodal_align/`.

## 정정 — proper 바(morphometry-transfer)에서 positive deflate
align vs morphometry cross-cohort transfer:
- AJU: conv align0.647 < morpho0.710(❌), MCI 0.622>0.606(미미✅), AD 0.845>0.832(미미✅)
- OASIS: MCI 0.676<0.725(❌), conv 0.556<0.738(❌)
→ **align>unimodal-aug는 사실이나 aug는 약한 baseline. morphometry가 transfer에서도 여전히 천장**
  (conv/MCI에서 morpho 우위). 정렬은 SSL의 site-overfit을 morphometry 근처까지 끌어올릴 뿐, 못 넘음.
**교훈(재확인): "약한 baseline 위 이득"을 positive로 오인 말 것. proper engineered 바를 항상 먼저.**
morphometry-oracle가 *transfer 축*에서도 성립 — 4방향 meta-finding 일관. (I02/I05 M2 규칙.)
