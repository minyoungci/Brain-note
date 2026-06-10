# 01 — 7-Consortium Scanner/Site Bias Check (결과)

_생성: 2026-06-04. 원본 READ-ONLY. 출력 `out/`. 스크립트 `scanner_site_bias_check.py`, 검증 `verify_bias_check.py`._
_방법: 세 축을 각각 "7-way consortium 식별 balanced_acc"(chance=1/7=0.143)로 정량화. subject_id 기준 GroupShuffleSplit(8), RandomForest. 독립검증=LogReg 재현 + subject 누설 점검._

## 핵심 결과 — site는 어느 축에 얼마나 새겨져 있나

| 축 | 무엇으로 식별 | balanced_acc (chance 0.143) | 비고 |
|---|---|---|---|
| **AXIS 1 metadata** | vendor + field strength + voxel | **0.761** | 가장 강함. 이미지 안 읽어도 site가 거의 다 드러남 |
| **AXIS 2 appearance(원본)** | 히스토그램·조직대비·엣지 | **0.556** | 픽셀 외형 shortcut (이전 0.565 재현) |
| **AXIS 3 appearance(N4 후)** | 〃 (N4 production) | **0.517** | N4가 소폭만 ↓ (0.556→0.517) |
| 음성대조 biology | brain_vox(뇌 부피)만 | **0.151** | ≈chance ✓ — probe가 생물학으로 site를 보는 게 아님 |

독립검증(LogReg): orig 0.492 / N4 0.521 — 분류기 달라도 chance의 ~3.4배, 누설 없음.

## 가장 중요한 발견

**1. site는 이미지 픽셀보다 acquisition metadata에 더 강하게 박혀 있다 (0.761 > 0.556).**
vendor·field strength·voxel 해상도만으로 컨소시엄을 0.761로 맞춘다. 즉 image harmonization(N4 등)을 아무리 해도, **메타데이터·해상도 축의 site 정보는 그대로 남는다.**

**2. 일부 컨소시엄은 "지문" 수준으로 식별된다** (per-consortium recall):

| consortium | metadata | appearance(orig) | appearance(N4) | 왜 |
|---|---|---|---|---|
| A4 | **0.991** | 0.487 | 0.598 | 단일 프로토콜·좁은 voxel(1.10mm) |
| KDRC | **0.994** | 0.576 | 0.551 | scanner 전부 익명화(MISSING) → 결측 자체가 지문 |
| AJU | **0.946** | 0.822 | 0.718 | GE 지배 + sub-mm voxel(중앙 0.854, 최소 0.479) |
| AIBL | 0.836 | 0.540 | 0.409 | 100% SIEMENS 3.0T |
| OASIS | 0.619 | 0.569 | 0.526 | |
| NACC | 0.633 | 0.664 | 0.616 | multi-site지만 외형 특이 |
| ADNI | 0.308 | 0.236 | 0.204 | **멀티벤더로 섞여 식별 어려움** |

→ ADNI처럼 멀티벤더 코호트는 흐릿하고, 단일벤더/특이해상도 코호트(A4/KDRC/AJU/AIBL)는 거의 완전 식별.

**3. KDRC의 결측 scanner 메타데이터 자체가 완벽한 site 신호** (909개 전부 MISSING). 메타데이터 결측 패턴조차 누설 경로다.

**4. N4는 이미지 외형 site를 소폭만 줄인다 (0.556→0.517).** AIBL(0.540→0.409)·AJU(0.822→0.718)는 도움받지만 A4(0.487→0.598)는 오히려 ↑. 잔여 site는 N4가 못 건드리는 **텍스처·해상도·모집단**.

**5. 상위 appearance 특징 = edge_mean·csf_mean·tissue_contrast·edge_density·deepgm_mean** — 전부 외형/텍스처, 생물학 아님.

## 연구적 함의
- **이미지-레벨 harmonization만으로 site를 못 지운다**: 가장 강한 site 축(metadata 0.761, 특히 voxel 해상도)은 픽셀 후처리(N4)로 제거 불가.
- **split 설계가 결정적**: A4/KDRC/AJU/AIBL는 거의 식별되므로 random split이면 site로 코호트를 외워버린다 → **leave-one-consortium-out 필수**.
- **site == 모집단 교란**: AJU/KDRC(한국)의 해상도·벤더 특이성은 모집단과 얽혀 있어, 강제 제거 시 생물학 손상.
- 정량 분석은 [`../02_combat_fsvol`](../02_combat_fsvol/RESULTS.md)의 ComBat(특징단)으로 site↓+biology보존이 가능하지만, 이미지 표현학습의 0.556은 별개 레이어 문제.

## 산출물
- `out/bias_summary.json` (전체 수치)
- `out/tab_scanner_by_consortium.csv`, `tab_voxel_by_consortium.csv`, `tab_per_consortium_recall.csv`
- `out/fig_scanner_vendor.png`, `fig_voxel_resolution.png`, `fig_confusion.png`, `fig_per_consortium_recall.png`
