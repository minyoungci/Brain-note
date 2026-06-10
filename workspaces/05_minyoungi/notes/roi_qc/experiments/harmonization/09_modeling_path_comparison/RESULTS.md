# 09 — Modeling-path comparison (scanner/bias를 어떻게 다뤄야 학습이 잘 되나) 결과

_생성: 2026-06-04. 원본 READ-ONLY(manifest sha256 `5ae141a4…` 전후 동일). 스크립트 `exp_modeling_path.py`, 검증 `verify_modeling_path.py`._
_목적(모델링): CN/AD LOCO held-AUC로 feature 전처리를 줄세워 이미지 방법(GPU)이 넘어야 할 '바'를 확정 + ComBat이 일반화에 도움인지 판정._
_데이터: CN/AD subject-first n=4,745. held ∈ {ADNI,NACC,AIBL,KDRC}. RandomForest(생성) + LogReg(검증). baseline=held 코호트 within-cohort random split(Reviewer-2 ATTACK2 수정)._

## 결과 (RF, held-cohort CN/AD AUC)

| held | raw | icv | train_z | combat_icv | within-cohort | site-shift 비용 |
|---|---|---|---|---|---|---|
| ADNI | 0.900 | 0.893 | 0.892 | 0.905 | 0.903 | +0.011 |
| NACC | 0.854 | 0.862 | 0.868 | 0.876 | 0.896 | +0.034 |
| AIBL | 0.934 | 0.953 | 0.953 | 0.938 | 0.928 | −0.025 |
| KDRC(한국) | 0.929 | 0.927 | 0.925 | 0.858 | 0.893 | −0.033 |
| **평균** | 0.904 | 0.909 | **0.910** | 0.894 | 0.905 | **−0.003** |

## 결론 (RF+LogReg 교차검증 후 — 견고한 것만)

1. **morphometry는 cross-cohort로 견고히 일반화한다 (~0.90), 한국 KDRC 포함.** RF KDRC 0.93, LogReg KDRC 0.91. **site-shift 비용 ≈ 0**(within-cohort 기준선으로도 −0.003) → Reviewer-2의 "pooled baseline" 우려를 수정해도 04 결론 유지. **이미지 편향을 안 지워도 morphometry 공간에선 학습이 잘 된다.**
2. **simple normalization(train-z/icv)이 feature-space 승자 = 0.910.** 이미지 방법(DSBN/foundation, GPU)이 넘어야 할 **바 = 0.91**.
3. **ComBat은 cross-cohort 일반화의 신뢰할 레버가 아니다 — 효과가 작고 분류기 의존적.**
   - RF: combat 0.894 vs icv 0.909 = **Δ−0.014 (해침)**, held-KDRC 0.927→0.858.
   - **LogReg(검증): combat 0.908 vs icv 0.886 = Δ+0.022 (도움)**, held-KDRC 0.907→0.907(무변).
   - → **부호가 분류기마다 뒤집힘.** "ComBat이 한국 코호트를 망친다"(RF의 KDRC −0.069)는 **RF 아티팩트로 기각**(LogReg 미재현). 일반화 관점에서 ComBat은 신뢰성 있는 향상을 주지 않는다(±0.02, 방향 불안정).

> ⚠️ **생성/검증 분리 사례**: RF만 봤으면 "ComBat이 한국 코호트 손상"으로 과대결론. LogReg 검증이 이를 RF 전용 아티팩트로 밝힘. 02(ComBat이 *in-distribution* feature site↓+biology보존)는 유효하나, 그것이 *cross-cohort 일반화 향상*을 뜻하진 않는다(별개 질문).

## 모델링 함의 (PLAYBOOK 근거)
- **학습 잘 되게 = morphometry(ROI 부피) + simple norm(icv/train-z) + pooled 학습.** 이미 site-robust(~0.90, 비용~0).
- **ComBat은 in-distribution 정량분석엔 쓰되, cross-cohort 일반화 부스터로 기대하지 말 것**(±0.02, 분류기 의존). KDRC 같은 disjoint 코호트에서 RF로는 손상 위험.
- 이미지 방법은 **0.91 바를 LOCO로 넘을 때만** 가치. (DSBN/foundation = GPU, 미실행.)

## 한계
- combat_icv는 transductive(held 이미지 포함 동시 ComBat; held 라벨 미사용) — 배치 단위 배포 가정. 1건씩 inductive면 ComBat 적용 불가(raw/icv가 fallback).
- LOCO held는 단일 fit(seed 분산 없음); 견고성은 RF/LogReg 2분류기로 확보. within-cohort 기준선은 8-split 평균.
- AJU(가장 site-특이)는 CN 22뿐이라 held 제외(04/07/08과 동일 한계).

## 산출물
- `out/modeling_path_results.json` (RF 전체 수치 + summary + leaderboard)
- `verify_modeling_path.py` 출력(LogReg 교차검증 — ComBat 방향 반전 입증)
