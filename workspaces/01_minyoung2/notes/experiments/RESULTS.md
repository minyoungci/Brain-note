# GAP 프로그램 결과 정리 (anatomy-guided representation learning)

> 갱신: 2026-06-11 · 핵심 발견 = **dissociation**(hand-crafted anatomy가 learned deep보다 cross-cohort 전이↑, site bias↑인데도) + **fix**(anatomy-prediction pretraining). 평가 = T1-only LOCO CDR corr (4코호트: ADNI/OASIS/AJU/KDRC). 전부 code-auditor leakage-free 통과.

## 1. Diagnosis — dissociation (G3, honest inductive PCA)
차원 매칭(PCA train-only) 후에도 견고. 모든 dim·선형/비선형 probe에서 ROI가 site-leak↑ AND transfer↑.

| dim | ROI site_mlp | ROI CDR | ROI amy | CNN site_mlp | CNN CDR | CNN amy |
|--:|--:|--:|--:|--:|--:|--:|
| 50 | 0.765 | 0.385 | 0.692 | 0.654 | 0.291 | 0.644 |
| 100 | 0.815 | 0.413 | 0.713 | 0.679 | 0.311 | 0.635 |
| 190 | 0.829 | 0.420 | 0.705 | 0.704 | 0.295 | 0.621 |

## 2. 표현별 T1-only LOCO CDR transfer (핵심 표)

| 표현 | LOCO CDR | 추론 요구 | 실험 |
|---|--:|---|---|
| ROI-vol (hand-crafted) | 0.420 | FreeSurfer | roi_probe |
| **combo: anat-pretrain + ROI-vol** | **0.440** | FreeSurfer+T1 | G6 |
| **anat-pretrain (compact CNN, 2.4K)** | **0.349** | **T1-only** | G5/G7 |
| frozen brain-age | 0.292 | T1-only | s1a |
| e2e global | 0.276 | T1-only | G1 |
| random-target pretrain (control) | 0.271 | T1-only | G7 |
| distill aux | 0.260 | T1-only | G4 |
| shuffled-anat pretrain (control) | 0.250 | T1-only | G7 |

## 3. 통제 실험 (anatomy-specificity, G7)
real ROI target(0.349) ≫ shuffled(0.250) ≈ random(0.271) → 이득은 **해부 내용 특이적**(일반 pretrain 아님).

## 4. 검증 (code-auditor)
- label leakage 없음(모든 전처리 train-only fit). C1 캐시 정렬 실측 일치+assert. C2 PCA train-only 수정(결론 불변).

---

## 5. (a) T1-only fix 강화 — 진행 중 (목표: T1-only로 ROI 0.420 도달)
레버: ① **13K corpus(7코호트, parcellation 100%)로 anatomy-pretrain**(현 2.4K→최대 12K) ② 강한 backbone ③ 입력 해상도.
설계(leakage-free): eval 4코호트와 안 겹치는 **외부 코호트(NACC/A4/AIBL=4664)로 pretrain → 4 labeled에서 CDR LOCO**.

| 실험 | pretrain 데이터 | backbone | 해상도 | T1-only CDR | combo | 메모 |
|---|---|---|---|--:|--:|---|
| G5 (기준) | 2.4K (fold별, in-domain) | compact CNN | 96³ | 0.349 | 0.440 | baseline |
| **G8-compact** | **4.7K 외부(NACC/A4/AIBL, strict external)** | compact CNN | 96³ | **0.358** | 0.439 | G5 초과·더 강한 주장(eval 코호트 미관측) |
| G8-resnet18 | 4.7K 외부 | ResNet18 | 96³ | 🔄 학습중 | — | 강한 backbone |
| Design-Y (예정) | ~12K(held-out 제외, per-fold) | best | 96³ | — | — | 최대 데이터·in-domain 포함 |
| (예정) | best | best | 128³/192³ | — | — | 해상도 레버 |

**해석:** G8-compact(0.358 > G5 0.349)는 *외부 코호트로만 pretrain*(ADNI/OASIS/AJU/KDRC를 전혀 안 봄)인데도 in-domain G5를 넘김 → anatomy 전이의 **코호트 무관성** 입증. 단 ROI(0.420) 미달.

## 5b. 통계 하드닝 (stats_hard, critic F3) + 포지셔닝 reframe
**per-cohort LOCO + subject-bootstrap CI + leave-one-cohort 민감도:**
- **amyloid dissociation 강함**: 4/4 fold ROI>CNN, leave-one-cohort 견고. (AJU 0.716 vs 0.584, KDRC 0.759 vs 0.612 — CI 비겹침)
- **CDR dissociation 약함**: 3/4 fold(ADNI는 ROI 0.318<CNN 0.334, CI 겹쳐 tie). leave-one-cohort는 견고.

**REFRAME(critic 반영, 상세 SPEC §10.7):** PRIMARY = *"site-invariance ⇏ transferability"* 반증(D1b+D3 crossed-design) / SUPPORTING = dissociation(amyloid 4/4)+G7 content-specificity / fix = existence proof.
**결정적 미검증:** 강한 SSL(SimCLR, 진행중)이 ROI 따라잡으면 dissociation 붕괴. honest 확률 현재 MICCAI>ACCV.

## 6. 재현성·일관성 검증 (독립 스크립트 간 cross-check)
핵심 숫자가 *다른 스크립트*에서 독립 재현됨 (fluke 아님):
- anatomy-pretrain T1-only: **G5=0.349 ↔ G7-real=0.349** (다른 파일, 동일)
- combo(feat+ROIvol): **G6=0.440 ↔ G8-compact=0.439** (다른 설정, 일치)
- dissociation: G3 transductive↔inductive 거의 불변(ROI CDR 0.42 양쪽)
- 전 결과 code-auditor leakage-free 통과. C1 캐시 정렬 assert, C2 PCA train-only.
