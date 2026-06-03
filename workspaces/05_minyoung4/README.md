# minyoung4 — full_n4 nuisance-aware 3D 표현학습 감시 카드

> **목적:** full_n4 manifest 기반 shortcut-aware 3D MRI 표현학습(scanner/source domain-adversarial)의 현황 요약  ·  **출처:** `/home/vlm/minyoung4/docs/context/full_n4_experiment_redesign_20260603/`  ·  **갱신:** 2026-06-03

## 주제 (2026-06-03 재가동 — 더 이상 휴면 아님)

⚠️ **이전 카드의 "휴면" 판정은 2026-06-03 무효.** minyoung4는 `full_n4_experiment_redesign`으로
재가동되어, **nuisance(scanner/source/site)를 domain-adversarial로 제거하면서 disease content(z_content)를
보존하는 3D MRI 표현학습**을 돌리고 있다(Stage 8 ladder, 오늘 05:32 산출물 갱신).

핵심 가설: T1w 표현에서 scanner/source/consortium shortcut을 GRL(gradient reversal) + nuisance
decorrelation으로 벗겨내면, deep 표현이 단순 부피 baseline을 넘는 transportable 신호를 남기는가.
(이는 minyoung2 EXP01의 "deep ≈ volumetry, shortcut 의심" 결론에 대한 표현학습 차원의 응답이다.)

## 데이터 정책 (full_n4)

base manifest = `official_manifest_full_n4.csv` (N4 bias 보정, `final_tensor_n4_path`/`final_mask_n4_path`).
strict CN/AD subject-first numeric-ROI-pass = **2,737 subj**.

| 역할 | 코호트 | 수 |
|---|---|---|
| supervised CN/AD | ADNI(75AD/832CN)·AIBL(51/422)·KDRC(130/255) | 1,765 subj |
| CN-only domain control | NACC(832CN)·OASIS(140CN) | — |
| alt. Dementia 정책(승인 필요) | ADNI·NACC 등 AD_or_Dementia | Min 명시 승인 전 미적용 |

## 현재 결과 — Stage 8N (ROI-conditioned scanner/source adversary)

disease classifier 미학습(표현 단계). 8M에서 global content/nuisance 분해가 full-cohort scanner/source
누수에 실패 → 8N은 ROI·consortium 조건부 adversary로 bounded Pareto frontier 개선 여부 검정.

| 조건 | ROI-ratio R²↓ | scanner-source bAcc↓ | held-consortium AUC | recon MSE |
|---|---:|---:|---:|---:|
| 8K-B bounded | 0.268 | 0.700 | 0.713 | 0.281 |
| **8N cond005** | **0.161** | **0.642** | **0.796** | **0.243** |
| 8N cond010(강) | 0.439 | 0.797 | 0.612 | 0.247 |

**판정(리포트):** 강한 ROI-conditioned adversary(cond010)는 사용 금지(전 지표 악화). cond005는
ROI-ratio·scanner-source·held AUC·recon은 개선했으나 **scanner-family/raw bAcc는 오히려 악화**
(0.328→0.356, 0.174→0.255) → "clear win 아님, 더 큰 샘플에서 재검 필요".

## 다음 게이트

8N cond005를 full/larger sample에서 재현하여 scanner-family 누수 악화가 표본 noise인지 확인.
이후 Direction 2(shortcut-aware ROI-text contrastive) 본학습 + disease head 부착.

## 한 줄 리스크

⚠️ n=55 subject / 275 ROI embedding의 **bounded smoke 규모**라 Pareto 비교가 noise에 취약하다.
또한 redesign 산출물이 git에 커밋됐는지 미확인(최근 커밋 05-29, 본 작업은 06-03 docs/context 아래) — `[VERIFY]`.
scanner-family/raw 누수가 남아 "nuisance-free 표현"은 아직 미달성.
