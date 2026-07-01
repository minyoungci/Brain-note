# 다중모델 외부비교 — 종합 (연구 트랙, P1/P2/BrainIAC)

> dataset-disjoint 외부(AIBL/AJU/A4)·frozen linear probe·같은 프로토콜. 검증 전용, 제출과 분리.
> 결과 JSON: `p2_architecture.json`·`brainiac_comparison.json`·`multi_task_{aju,aibl}.json`·**`capability_stats.json`(bootstrap CI+BH-FDR, 통계 rigor)**.
>
> **⚠️ 통계 rigor 정정(capability_stats.json)**: ① objective효과(infonce>wg0.5) **10/15셀 FDR-유의**(morphometry 강함)=논문핵심 방어. ② capability경계(APOE4 전모델 ns·amyloid BrainIAC ns)=FDR-robust. ③ **cross-population(BrainIAC 한국<서양)은 trend지만 CI가 0포함=통계 유의 아님** → 아래 "cross-population" 주장은 **KDRC(AJU+KDRC≈2200) 검정력 확보 후에만**. 지금은 trend.

## 핵심 비교표 (brain-age pearson, within-cohort CV)

| 모델 | 종류 | AIBL | AJU | A4 | 뇌실 partial(AIBL) | cls_cross(AIBL→AJU) |
|---|---|---|---|---|---|---|
| **resenc_infonce** | ResEnc+MAE+InfoNCE (S3D 없음) | **0.658** | 0.637 | 0.614 | +0.19 | **0.739** |
| vit_ibot | ViT+iBOT (3DINO식) | 0.442 | **0.681** | 0.450 | +0.18 | 0.578 |
| resenc_s3d_full | S3D wg1 | 0.345 | 0.476 | 0.292 | +0.18 | 0.560 |
| **resenc_s3d_wg0.5** | **우리 챌린지 선택**(S3D+InfoNCE) | 0.324 | 0.447 | 0.355 | +0.19 | 0.475 |
| resenc_s3d_pure | S3D wg0 | 0.053 | 0.517 | 0.133 | +0.14 | 0.573 |
| **BrainIAC** | **독립 foundation**(ViT-SimCLR, ⚠️Path B) | 0.319 | 0.404 | n37불가 | **+0.47** | 0.677 |
| (FreeSurfer-morphometry) | classical 15-ROI 회귀 | 0.490 | 0.504 | 0.408 | — | — |

## 검증된 결론 (정직)

1. **✅ pathway 법칙은 범용** (R1 해소): reg(brain-age) 전이 + **뇌실 읽기**가 우리 5개 모델 *및 독립 BrainIAC* 전부서 성립(BrainIAC 뇌실 partial +0.47로 가장 강함). = 우리 모델 quirk 아님.
2. **✅ 사전학습 objective가 외부 transfer를 지배** (검증됨, fair·internal): **순수 MAE+InfoNCE(0.658) ≫ S3D-dense(0.324)**. S3D는 seg용이라 global morphometry 전이엔 해로움. → 논문 핵심.
3. **⚠️ "cls는 전이 안 됨"은 표현-의존** (기존 주장 좁힘): 약한 표현(wg0.5 0.475)은 ~chance이나 강한 표현(infonce 0.739·BrainIAC 0.677)은 cls도 상당히 전이. = foundation 법칙 아니라 표현 강도 문제.
4. **🔴 FreeSurfer(classical)가 모든 foundation을 이김**(0.49~0.50) — "좋은 brain-age" 주장 금지. foundation 가치=정확도 아니라 표현/범용성.

## ⚠️ 한계 (반드시 명시)
- **BrainIAC = Path B**(우리 HD-BET'd T1, BrainIAC의 정확한 NIHPD registration 아님) → **BrainIAC 핸디캡**. "infonce가 BrainIAC 이김"은 **불공정, 주장 불가**. BrainIAC는 *법칙 확인용*이지 horse-race 대상 아님.
- 전부 노년 범위제한(효과 modest). A4 ROI/HD-BET 저검정(n36~37).
- 우리 모델 전부 FOMO300K 학습 → "아키텍처-robust within our training"(BrainIAC만 독립).

## 방어 가능한 논문 주장
> "brain-MRI SSL 표현의 외부 transfer는 **사전학습 objective가 지배**한다 — dense-masking(S3D)은 seg를 돕지만 morphometry 외부전이를 희생하고, global-contrastive(InfoNCE)가 우수하다. reg-morphometry(뇌실)는 아키텍처·독립 foundation 불문 전이되나(범용), cls는 표현 강도에 의존한다. 단 어느 foundation도 classical morphometry(FreeSurfer)는 못 넘는다."

## Capability battery — foundation이 외부(AJU 한국)서 *무엇을* 하나 (`multi_task_aju.json`)

frozen feature 재사용, task별 head만 fit. 10 task (easy→hard). cls=AUROC, reg=pearson.

| Task | 유형 | wg0.5 | **infonce** | vit_ibot | BrainIAC | 난이도 |
|---|---|---|---|---|---|---|
| sex | cls | 0.93 | **0.96** | 0.95 | 0.74 | 쉬움(sanity ✓) |
| age | reg | 0.46 | **0.64** | 0.43 | 0.27 | 중(morphometry) |
| CN-vs-AD | cls | 0.76 | **0.82** | 0.72 | 0.72 | 중 |
| MMSE | reg | 0.37 | **0.44** | 0.33 | 0.20 | 중(인지) |
| CDR | reg | 0.33 | 0.35 | 0.34 | 0.25 | 중(중증도) |
| CN-vs-MCI | cls | 0.63 | 0.65 | 0.58 | 0.64 | 중~난 |
| WMH grade | reg | 0.32 | 0.42 | 0.38 | **0.44** | 혈관(FLAIR 필요) |
| amyloid+ | cls | 0.63 | **0.67** | 0.59 | 0.52 | 어려움 |
| amyloid SUVR | reg | 0.16 | 0.29 | 0.15 | 0.04 | 어려움 |
| **APOE4** | cls | 0.51 | 0.47 | 0.52 | 0.52 | **불가(유전은 구조에 없음)** |

**capability map 결론**:
- **명확한 경계**: 쉬움(sex ~0.9) → 중(morphometry: age/dx/MMSE/CDR) → **불가(APOE4 ~chance, amyloid 낮음)** = 유전·분자 신호는 구조MRI에 없어 foundation도 못 함(정직한 negative control).
- **objective가 battery 전반 지배**: infonce가 형태학 task 대부분 최고 → S3D-dense가 global 표현 희생 재확인.
- **capability는 task-의존** — 단일 "brain-age 전이"보다 훨씬 풍부한 특성화. FreeSurfer 제외 정당(task-specific 도구=대부분 task 불가).

## 후속(선택)
- fair-BrainIAC(정확한 N4+NIHPD registration+HD-BET 재전처리) — horse-race 원하면. 비추천(law 확인엔 Path B로 충분·불공정 리스크).
- objective 축 정밀화(S3D wg 스윕 vs pure-MAE+InfoNCE)로 "무엇이 전이를 결정하나" 정량화.
