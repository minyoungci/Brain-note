# ComBat harmonization on FastSurfer ROI volumes — 실험 결과

_생성: 2026-06-04. 원본(manifest/raw/v2 텐서) READ-ONLY로만 사용. 출력은 `out/` 에만._
_스크립트: `exp_combat_fsvol.py`(v1), `exp_combat_fsvol_v2.py`(비순환·null), `verify_combat.py`(독립검증)._

## 질문
"scanner/site 잡음은 줄이되 age/sex/diagnosis 생물학은 보존되는가?"
대상 = FastSurfer ROI 부피 `fs_vol_*` 26개 (complete-case n=12,579 / subjects 6,823).
ComBat: batch=consortium, 보존 covariate=age(연속)+sex,dx3(범주). dx3=CN/MCI/AD 축약.

## 핵심 결과

| 지표 (subject-grouped CV, 8 splits) | raw | ComBat A (dx 보존) | ComBat B (dx **미**보존) |
|---|---|---|---|
| **site7 balanced_acc** (chance 0.143) | 0.238 | **0.175** | 0.164 |
| site7 shuffled-label (null) | 0.143 | 0.143 | 0.143 |
| **age R²** | 0.284 | 0.278 | — |
| **CN-AD AUC (pooled)** | 0.893 | 0.896 | 0.852 |
| **CN-AD AUC (within-ADNI)** | 0.884 | 0.885 | **0.885** |
| fake random-label AUC (null) | 0.498 | 0.495 | 0.498 |

(ICV 정규화 특징셋도 동일 패턴: site7 0.240→0.177, age R² 0.268 불변, CN-AD AUC 0.905→0.904.)

## 결론 (검증된 것)
1. **ComBat은 fs_vol의 잔여 site 신호를 chance 쪽으로 줄인다** (0.238→0.175, chance 0.143). LogReg(다른 분류기)로도 0.355→0.163으로 재현 — 분류기 아티팩트 아님.
2. **생물학은 진짜로 보존된다 (비순환 증명).** dx를 보존하지 **않은** ComBat B에서도 **within-ADNI CN-AD AUC=0.885로 불변**. AD 위축 신호는 covariate 보존 덕이 아니라 site-독립 신호이기 때문. pooled가 0.852로 떨어진 것은 site 조성(AJU=AD多, A4=CN뿐)에 편승한 가짜 dx 신호가 제거된 것 = 올바른 동작.
3. **허위신호 없음 (null control 통과).** 가짜 라벨 AUC≈0.50, 셔플 site≈chance. ComBat이 신호를 날조하지 않음 (Saponaro 2022 경고 통과).
4. **site×age interaction 약함.** 코호트별 age→해마/ICV 기울기 전부 음수(-0.025~-0.048), 부호 일관 → ComBat 선형-covariate 가정이 깨지는 최악(부호 역전)은 아님. (단 A4 -0.048 vs AJU -0.025로 ~2배 차 → ComBat-GAM[Pomponio 2020]이 약간 더 방어적일 여지.)

## 중요한 한계 (정직성)
- **이건 feature-level(fs_vol) 문제만 해결한다.** 이미지 외형 probe 0.565(원본 image-appearance)는 픽셀 수준 shortcut으로, 추출 특징에 거는 ComBat으로는 **건드리지 못함**. 이미지 표현학습 shortcut은 별개 레이어(augmentation / vendor-adversarial)로 다뤄야 함.
- ComBat은 전체 데이터에 fit(표준 용법). 따라서 site-probe 하락은 일부 기계적 → **판정 기준은 biology 보존**(위 2·3번이 그 근거).
- 잔여 site 0.164~0.175(>chance 0.143)는 covariate 조성 차이(site==population)에서 오는 **정당한 잔존**. chance까지 강제로 낮추는 것은 모집단 생물학 삭제이므로 바람직하지 않음.

## 권고
- **정량 ROI-부피 분석**: ComBat(covariate=age,sex,dx) 적용 후 분석. 가능하면 ComBat-GAM.
- **이미지 표현학습**: 별도 — augmentation(bias/해상도/노이즈) + vendor/voxel 적대(consortium 아님) + leave-one-consortium-out.
- 모든 harmonization 결과는 **site-probe↓ + biology-probe보존 + null control** 3종 동시 검증(본 실험 틀) 필수.

## 산출물
- `out/combat_fsvol_results.json`, `out/combat_fsvol_v2_results.json` (전체 수치)
- `out/fsvol_combat_raw.parquet` (raw/combat 특징, 다운스트림 재사용용; 원본과 분리)
