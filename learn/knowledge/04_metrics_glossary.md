# 04 · 지표·통계·용어 사전

> **목적:** 5개 연구 결과를 읽는 데 필요한 지표·통계·임상/모델 용어 정리  ·  **출처:** minyoung2/3 reports, plant prereg, minyoungi clinical notebooks  ·  **갱신:** 2026-06-02

각 워크스페이스 카드의 수치를 해석할 때 참조. 정의는 이 프로그램에서 쓰이는 의미에 한정한다.

## 평가 지표

| 용어 | 의미 | 이 프로그램에서 주의 |
|---|---|---|
| **AUROC** | ROC 곡선 아래 면적. 0.5=무작위, 1.0=완벽 | 클래스 불균형에 둔감 → 불균형 코호트에선 AUPRC 병행 |
| **AUPRC** | Precision-Recall 곡선 아래 면적 | 양성 희소(plant converter) 시 AUROC보다 민감. 체크포인트 선택에 `val_auprc` 사용(minyoung2 표준) |
| **부트스트랩 CI** | 재표집으로 추정한 신뢰구간 | 채택 기준 = CI 하한 > 0(증분 양성). 코호트별로 계산 |
| **paired bootstrap ΔAUROC** | 같은 표본에서 두 모델 AUROC 차의 부트스트랩 | EXP01 공식 H1(`exp01_incremental_value.py`)의 판정 통계 |
| **balanced accuracy** | 클래스별 recall 평균 | 불균형에서 accuracy 대체 |

## 통계 검정·설계

| 용어 | 의미 | 함의 |
|---|---|---|
| **LOCO** (leave-cohort-out) | 한 consortium 전체를 test로 빼는 교차검증 | transportability(새 site 전이)를 직접 측정 → `01_loco_transport.md` |
| **transport / OOD gap** | train 분포 밖(held-out cohort) 성능 저하 | in-dist val 체크포인트가 OOD에서 무너지는 현상이 seed 불안정의 원인 후보 |
| **nuisance / shortcut** | 라벨과 상관되나 질병과 무관한 변수(site·tracer·뇌부피 등) | 통제 후에도 신호가 남아야 incremental value 주장 가능 |
| **incremental value** | baseline 위에 추가로 얻는 성능 | "image AUROC 높음"이 아니라 "nuisance+image > nuisance" |
| **equivalence test (TOST)** | 사전 마진 δ 내 동등성 검정 | 미구현 → EXP01에서 "음성"과 "검정력 부족"을 못 가름(`[VERIFY]`) |
| **MDE** (최소검출효과) | 주어진 표본·검정력에서 검출 가능한 최소 효과크기 | plant converter 희소 → MDE가 deliverable |
| **group-DRO** | 최악 그룹 손실 최소화(분포 강건) | EXP01에서 transport 보편 안정화 실패(코호트 의존) → falsified |
| **ComBat** | site/scanner 배치효과 보정(harmonization) | full-fit이면 누수 → train-fit 필요. site 신호 제거하며 질병 신호 보존 확인됨(06 노트북) |

## 모델·표현학습

| 용어 | 의미 |
|---|---|
| **2.5D** | 얇은 slab(인접 슬라이스)로 3D 맥락 일부를 싸게 얻는 절충 → `02_ssl_mae_2p5d.md` |
| **MAE** | Masked Autoencoder — 입력 패치 마스킹 후 복원하는 SSL(자기지도) |
| **SSL** | self-supervised learning. 라벨 없이 입력 자체로 학습 |
| **MIL** | Multiple-Instance Learning. slice-bag → subject 단위 예측(gated attention) |
| **ConvNeXt / resnet18** | 백본. EXP01에서 ConvNeXt-ImageNet은 whole-brain 2.5D 학습 죽음, resnet18은 정상 |
| **EMA** | 가중치 지수이동평균(안정화 옵션) |

## 임상 라벨·변수

| 용어 | 의미 | 주의 |
|---|---|---|
| **CDR global** | Clinical Dementia Rating. 0=정상 / 0.5=questionable / 1·2·3=경도·중등도·중증 | manifest에서 string 가능 → `to_numeric`. 7코호트 100% 보유 |
| **CDR-SB (cdrsb)** | CDR Sum of Boxes(6개 도메인 합, 0–18 연속) | 세밀한 중증도. null 7.7% |
| **cdr_bin** | 0 / 0.5 / ≥1 의 3-class 또는 CN(0) vs IMPAIRED(≥0.5) 이진 | EXP01 endpoint = 이진 |
| **diagnosis (CN/MCI/AD)** | 진단 라벨 | A4·KDRC 부재(master 기준), subject-level 상수 → conversion 인코딩 불가 |
| **APOE / MoCA / MMSE** | 유전위험(e4)·인지선별검사들 | MoCA=NACC only / MMSE=ADNI final 테이블 없음 / APOE는 NACC+A4 |
| **amyloid / Centiloid / SUVR** | 아밀로이드 PET 정량 | OASIS centiloid 위주, 81.9% 결측(EXP01 amyloid 라인 NO-GO 원인) |
| **ICV / eTIV / MaskVol** | 두개내용적·추정TIV·뇌마스크 부피 | FastSurfer VINN은 eTIV 미산출 → MaskVol을 ICV 프록시로 |
