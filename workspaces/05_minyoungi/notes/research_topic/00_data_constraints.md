# 00 · 연구 주제 적부 앵커 — 우리 데이터로 "실제로 가능한가"의 기준선

> 모든 후보 연구 주제는 이 문서의 **제약**을 통과해야 한다. 일반 문헌의 매력적 주제라도 우리 데이터가 닫아버린 것은 죽은 주제다.
> 근거: `Clinical/INSIGHTS.md`, `roi_qc/experiments/harmonization/{README, SCANNER_BIAS_PLAYBOOK}.md`(실험 01~09), memory `scanner-site-bias-axes`.
> 작성 2026-06-07. 수치는 검증본(RF+LogReg 이중검증) 인용.

## 보유 자산 (검증)
- **영상**: 13,022 세션 / 7 컨소시엄(ADNI·NACC·AIBL·OASIS·A4·AJU·KDRC) T1 MRI. N4 보정 + v2 텐서(192×224×192, identity affine, z-score). manifest `official_manifest_full_n4.parquet`(13022×101).
- **형태계측**: FastSurfer fs_vol 26 ROI + MaskVol(eTIV 프록시). cross-cohort robust.
- **ROI 마스크**: option_b — ⚠️ **BLOCKED_PROVISIONAL(후보, 검증 아님)**. voxel 정량 전 게이트 필수.
- **임상(서구 5종)**: dx(CN/MCI/AD, 코호트별 결측), CDR(전수 100%), age, sex. acquisition 메타(vendor/field/voxel).
- **임상(한국 AJU·KDRC, 06-09 보강)**: dx 100% + **MMSE·APOE 100% + amyloid PET(visual/SUVR) + 혈액검사 22종 + 공존질환·우울·WMH**. 코드 표준화·QC flag 완료. 통합 manifest 2종(subject 1,898 / session 2,196). ⚠️ 정확한 컬럼·커버리지·한계는 **[`03_processed_data_spec.md`](03_processed_data_spec.md)가 정본** — 이 줄은 요약일 뿐.
- **인구 축**: 한국(AJU·KDRC) + 서구 5종 동시 보유 = **드문 cross-population 벤치마크**. 단 traveling subject 0명.

## 🔴 닫힌 방향 (우리 실험이 이미 부정 — 재시도 금지)
| 죽은 주제 | 왜 죽었나 | 증거 |
|---|---|---|
| harmonization으로 **정확도/일반화 향상** | ComBat/N4/MixStyle 모두 morphometry baseline 못 이김. ComBat은 분류기 따라 부호반전 → 일반화 부스터 신뢰불가 | 02·03·05·07·09 |
| **이미지-레벨 SOTA 분류**가 형태계측을 이긴다 | MixStyle 3D CNN조차 held-cohort AUC < morphometry(Δ−0.03~−0.08, 6 run 전부) | 07 |
| **MCI→AD 전환 예측** | manifest dx가 subject당 static(58/2830만 변화, MCI→AD 30건+역전 = 노이즈). per-visit 재추출 없이는 불가 | conversion 점검, memory `clinical-manifest-join` |
| **CN/MCI를 harmonization으로 살리기** | within-ADNI 비순환 AUC RF 0.62(약신호는 site가 가린 게 아니라 원래 약함). ComBat 후 flat, pooled는 하락 | 08 |
| site를 chance까지 **제거** | site==population → 생물학(한국 vs 서구) 동반 삭제 | 01·INSIGHT 2 |

## 🟢 열린 방향 (미검증 = 탐색 가치) — 문헌으로 적부 판정 대상
| 후보 | 가설 | 우리 데이터 적합 | 게이트 |
|---|---|---|---|
| **Foundation/SSL 피처가 morphometry(LOCO 0.91 바)를 넘나** | 대규모 사전학습 표현이 site-robust + AD 신호 | 13k pooled, GPU | 바 0.91 LOCO 필수 |
| **Cross-population(한국 vs 서구) 일반화/공정성 감사** | 모델이 인구축에서 어떻게 깨지나 + metric 무효화 | 한국+서구 동시 보유(희소) | site==population 비순환 probe |
| **Scanner-shortcut 감사 프로토콜** (dual-probe) | site↓ + biology보존 + null의 3종 동시 판정 | 01의 3축 정량 보유 | Souza 2024와 차별화 |
| **Acquisition-conditioned 모델링(DSBN, condition-not-erase)** | consortium-id가 아니라 vendor×field×voxel 축만 조건화 | 메타 100% 복구 | 바 0.91 |
| **CDR 공통타깃 형태계측 staging** | 7코호트 공통 CDR로 해석가능 staging | CDR 전수 100% | site 학습 위험(05 §7) |

## 적부 판정 규칙 (각 주제에 적용)
1. **닫힌 방향과 겹치면 즉시 탈락.**
2. **Feasibility**: 우리 자산만으로 first experiment가 도는가 (CPU/GPU 명시).
3. **Novelty**: 우리만의 차별점(한국-confounded 벤치마크, dual-probe, condition-not-erase)이 있는가.
4. **Reviewer-risk**: site==population에서 단일 probe는 결정불가 → biology-preserving 비순환 probe가 유일 판정자.
