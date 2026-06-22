# GATE-3 Plan — 해상도×영역 통제 표현 측정 (pre-registration)

> 상태: **사전등록 (코드 전 합의용)** · 작성 2026-06-22 · revert point = 현재 commit
> 원칙: null도 1차 결과(사전 수용). 같은 arm 3회 NO-GO → 폐기 후 상위 결정점 복귀.

## ⛔ DE-RISK 결과 (2026-06-22) — §2 AMAES pooling 반증, Track C frozen 경로 NO-GO

smoke + pooling probe(`src/microbrain/gate3_amaes_smoke.py`, `gate3_amaes_pooling_probe.py`)로 확인:
- **통과:** AMAES unet_b strict load(미스매치 0/66, 원본 encoder 재사용)·1mm/192³ forward finite·InstanceNorm으로 OOD(192³) 안전·텐서 공통공간 정합(cross-cohort mask Dice 0.89).
- **반증:** §2의 **"bottleneck GAP" pooling은 degenerate** — random 입력과 실제 뇌의 GAP feature가 cos 0.9994(거리 0.0006), 뇌끼리도 0.9999. GAP/GMP/std/multi-scale 전부 brain≈random. AMAES 정보는 global 통계가 아니라 **공간 배치**에 있음(seg backbone, embedding 모델 아님 — 정찰 경고의 실측 확인).
- **구조적 막힘:** bottleneck x4=12×14×12=**16mm 유효해상도**(4×stride2 풀링) → cortical 디테일이 bottleneck에 없음(BrainIAC 2mm보다 거침). cortical이 사는 early layer(x0 1mm/x1 2mm)는 수천만~억 차원, pooling 미해결. AMAES cortical 신호의 정공법 = decoder fine-tuning(=frozen 아님, 학습).
- **설계 교란:** BrainIAC(ViT global CLS) vs AMAES(U-Net 공간피라미드) feature 타입 불일치 → "해상도 통제 비교"가 아키텍처 차이와 교란.

**판정: Track C(off-the-shelf 1mm frozen extraction으로 cortical GATE-3)는 cheap·clean 둘 다 실패 → frozen 경로 폐기.** 아래 원안 §2–6은 기록 보존용(Track S 부분만 잔존 유효). 다음 결정은 본문 아래가 아니라 사용자 fork(Track S only / fine-tune 투자 / Korean 축 피벗)에서.

## 0. 한 줄

기존 4개 frozen-encoder 실험(BrainIAC/F04/MAE/RT-SSL)은 전부 image→**dx**를 보고 ≤morph로 닫혔다.
GATE-3는 다른 질문 — image→**fs_vol**(표현이 morphometry를 *복원*하나) + 그 위 headroom — 을
**해상도(2mm vs 1mm) × 영역(subcortical vs cortical)** 통제실험으로 결정짓는다. self-train 불필요(둘 다 frozen extraction).

## 1. 가설 (positive-framable)

> **H**: 3D brain SSL 표현의 cortical 신호 손실은 *SSL 목적함수*가 아니라 *입력 해상도*에 병목된다.

- subcortical(해마·편도·시상·뇌실)은 큰 구조 → 2mm/96³로도 복원 가능 → **통제(control) 영역**.
- cortical(entorhinal·fusiform·inferiortemporal·middletemporal·parahippocampal·precuneus·posteriorcingulate·isthmuscingulate)은
  피질 두께 → 2mm는 뭉갬, 1mm 필요 → **검정(treatment) 영역**.
- interaction(해상도×영역)이 핵심 측정량.

## 2. 인코더 (off-the-shelf, 학습 0)

| arm | 인코더 | 입력 | 해상도 | 출처 | 비고 |
|---|---|---|---|---|---|
| LOW-RES | BrainIAC (ViT-B SimCLR, 768-d CLS) | 96³ MNI 고정 | ~2mm | HF eugenehp/brainiac (Nat.Neurosci 2026) | CLS embedding 그대로 |
| HIGH-RES | AMAES (U-Net/MedNeXt, MAE) | 128³ | **1mm** | Zenodo (asbjrnmunk/amaes) [VERIFY download] | seg backbone — **pooling 우리 정의** |

**Pooling(사전등록, forking 방지):** bottleneck activation의 **global average pooling(GAP)** → feature vector 단일 정의.
AMAES 192³ OOD 회피 = **sliding-window 128³ 타일**(stride 64), 타일별 GAP를 평균. BrainIAC는 96³ 단일 forward.
(주의: AMAES feature가 cortical을 보존하는지는 논문이 보장 안 함 = **Gate A가 곧 이 검증**.)

## 3. 데이터 / split

- **ADNI baseline만**: 4739 세션 → **subject-level baseline collapse**(1578 subjects 중 baseline 1개/subject). 종단 중복·dup_group 제거 선행.
- 평가: subject-level **5-fold CV**, validation-lock, **multi-seed(≥3)**, bootstrap 95% CI.
- 입력 누수 금지: 인코더 입력 = 이미지만. fs_vol/dx = target 전용.
- (확장 보류) LOCO·타 코호트는 ADNI에서 PASS 후에만.

## 4. Gates + NO-GO (숫자)

### Gate A — 표현 품질 & 해상도 interaction (1차 결과)
encoder-feature → fs_vol(영역군 평균) ridge, 5-fold CV R².
1. **rep 생존 sanity**: 각 인코더 **subcortical R² ≥ 0.70**. 미달 시 추출/pooling 깨짐 → 해석 전 수정(신호 결론 금지).
2. **핵심 측정 — 해상도 interaction**:
   - ΔR²_cort = R²_cort(AMAES 1mm) − R²_cort(BrainIAC 2mm)
   - ΔR²_sub  = R²_sub(AMAES)  − R²_sub(BrainIAC)  ← 통제(≈0 기대)
   - **"해상도가 병목" 성립**: ΔR²_cort ≥ **+0.10** AND 95%CI가 0 제외 AND |ΔR²_sub| < 0.05.
   - **NO-GO(해상도 병목 아님)**: ΔR²_cort 95%CI가 **0 포함** → 1mm가 cortical rep을 안 살림 → 그 문 닫음(목적함수 병목 가설로 전환).

### Gate B — morphometry 위 headroom (Gate A 통과 인코더만)
dx(CN-vs-AD, baseline) 계층 바: `fs_vol`(morph baseline) vs `fs_vol + encoder-feat`. ΔAUC.
- **NO-GO**: ΔAUC 95%CI가 **0 포함** → 인코더가 morph 위 증분 없음 → 정확도 천장 재확인(해당 축 닫힘).
- (사전확률: Gate B는 4회 선례상 탈락 가능성 큼. **positive의 진짜 후보는 Gate A의 interaction.**)

## 5. 비용 / 승인 게이트

- **GPU 추출 2배치**(BrainIAC 96³ + AMAES 128³ sliding-window), ADNI baseline ~1578 subjects, bf16/B200, **frozen forward = 시간 단위(학습 아님)**. → **Min 승인 필요.**
- AMAES weight = Zenodo 다운로드 [VERIFY 가용성; 401이면 FOMO25 fallback도 [VERIFY]].
- 산출물 쓰기 = `results/gate3/`, `data/derived/` 한정. `/home/vlm/data` 쓰기 금지.

## 6. 정직한 사전확률 / 예측

- Gate A subcortical: 둘 다 통과 예상(큰 구조).
- Gate A cortical interaction: **진짜 미정**. 여기가 유일하게 positive·미지 영역.
- Gate B: 탈락 우세(선례 4회). 통과하면 그게 곧 positive headroom.
- **최선의 시나리오 = "1mm가 cortical 표현을 회수한다(ΔR²_cort 큼)"** → 필드의 96³ 관행 비판 + 우리 1mm 데이터 고유가치 = positive 기여.
- 최악 = 둘 다 NO-GO → cortical 정확도 축까지 깨끗이 닫고 Korean 감별병리 축으로 피벗.

## 7. revert / kill

- 시작 전 git checkpoint. NO-GO 충족 시 즉시 중단·`docs/ledgers/`에 음성 기록·`DECISION_LOG.md` 갱신.
- 같은 arm 하이퍼파라미터만 바꿔 3회 반복 금지(진단 먼저: bias / 신호천장 / 구현버그).
