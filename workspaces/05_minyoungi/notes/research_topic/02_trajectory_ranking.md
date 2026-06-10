# 02 · 연구 trajectory 적부·우선순위 (F×N×R)

> 출처: research-advisor 독립 전략 분석(2026-06-07). 근거: 00 앵커, INSIGHTS, harmonization 04/07/08 RESULTS, 06 verdict, PLAYBOOK + 외부 검증.
> 판정 전제: **site==population → 단일 site-probe undecidable → biology-preserving 비순환 probe가 유일 판정자.**
> ⚠️ literature-scout(01)와 **독립적으로 같은 1·2순위에 수렴** — 신뢰도 보강.

---

## Part 1. 추가 사망확인서 (이미 확정된 5개 외에, "아직 안 해봤잖아"류)

| # | 죽은 주제 | 死因 | 증거 |
|---|---|---|---|
| D-1 | **GAN/image translation으로 site 지우고 정확도 ↑** | site==population에서 CycleGAN류는 병리 hallucinate(over-correction). backbone만 바꾼 같은 死因 — 절대 AUC는 올라도 **상대 결론 불변**(headroom~0) | 06 §1.3, 07, 04 |
| D-2 | **Foundation/SSL feature가 morphometry(0.91)를 *이긴다*** | regime(AD 희소+site==pop)에서 *상대* 우위가 뒤집힌다는 근거 0. "이긴다" claim은 죽음. *단 "언제 깨지나"는 살아있음(질문 재정의, T-3)* | 07, 04, PLAYBOOK §3② |
| D-3 | **CDR 회귀/staging 7코호트 pooled** | CDR 분포 site 극이질(AJU=MCI-heavy) → CDR 아닌 site 학습. A4/KDRC dx 없음, KDRC CDR은 한국과 공선 | INSIGHT 8, 08 §3 |
| D-4 | **option_b ROI mask voxel-level/SBM 정량** | 전수 `BLOCKED_PROVISIONAL`, 192³↔256³ 그리드 불일치, centroid ~31vox 오프셋 → "검증" 아닌 "후보", reviewer 첫 줄 reject | INSIGHT 5·6 |
| D-5 | **AJU(최강 한국 코호트) held-out CN/AD 일반화** | AJU CN n=23 → CN/AD held-target 구조적 불가. 가장 강한 반례가 검증 불가 | 04 주의, 06 |

**死因 구조**: D-1·D-2 = "더 센 모델" 환상(regime이 문제, 모델 아님). D-3·D-4·D-5 = **라벨·그리드·표본의 구조적 결손**(모델로 못 메움).

---

## Part 2. 생존 trajectory 랭킹

평가축: **F**(우리 자산만으로 first experiment가 도는가) · **N**(차별점 실재) · **R**(reviewer-risk, 낮을수록 좋음, undecidability 방어 반영 여부가 핵심).

| 순위 | Trajectory | F | N | R | 판정 |
|---|---|---|---|---|---|
| **1** | **T-1 Cross-population shortcut-audit** (confounded regime에선 site 성공/실패가 undecidable, 비순환 probe가 유일 판정자를 7코호트로 입증) | ★★★★★ | ★★★★ | **낮음** | **즉시 착수(CPU), 자산 절반 보유, 가장 reviewer-proof** |
| **2** | **T-2 Cross-population 일반화/공정성 감사** (한국 vs 서구에서 morphometry/image가 어디서 깨지나 + metric 무효화) | ★★★★ | ★★★★ | 중간 | T-1과 묶으면 강함. 단독은 D-5에 막힘 → T-1의 챕터로 |
| **3** | **T-3 Foundation/SSL feature가 0.91 바를 *언제/어떻게* 깨나** (audit으로 재정의, "이긴다" 아님) | ★★★ | ★★★ | 중~높 | GPU 필요. audit 프레임이면 생존, "SOTA" 프레임이면 D-2로 죽음 |
| 4 | T-5 Acquisition-conditioned (DSBN, condition-not-erase) | ★★★ | ★★★ | 중간 | 0.91 못 넘으면 negative. T-3의 *처방* 파트로 흡수 |
| 5 | T-7 Normative cross-population z-score | ★★ | ★★ | 높음 | 선행 PMC8369368이 Korean vs Caucasian norm "incompatible" 이미 보임 → 새로움 약 |
| 6 | T-4 CDR 공통타깃 staging | ★★ | ★★ | 높음 | D-3로 사망. **제외 권고** |
| 7 | T-6 Acquisition generalization gap 정량 | ★★★ | ★★ | 중간 | T-1/T-2 하위 분석으로만 가치 |

**랭킹 논리**: 상위 3개는 전부 "정확도 ↑"가 아니라 **"무엇이 결정 가능한가/어디서 깨지나를 측정"** 계열 — 우리 regime이 reviewer로부터 보상받는 유일한 claim type(06 verdict, 04/07/08이 음성결과로 reviewer-proof화). 4~7위는 "처방"인데 **처방은 진단(audit)이 선 후에야 방어된다.**

---

## Part 3. 상위 3개 first experiment

### ⭐ T-1 — Cross-population Shortcut-Audit (지금 최적 베팅)
- **Thesis**: *site와 population이 near-collinear한 confounded regime(한국 vs 서구)에서는 표현의 shortcut 제거 성공/실패를 단일 site-probe로 판정 불가(undecidable)이며, biology-preserving 비순환 probe가 유일 판정자임을 7코호트 dual-probe+null로 정량 입증.*
- **차별점**: Souza 2024는 site≠population(분리 가능) 서구에서 "진단기=비밀 site 분류기"를 보임 → "지우면 됨"이 성립하는 세계. 우리는 site==population이라 site-probe↓가 harmonization 성공인지 biology 공제거인지 **단일 probe로 결정 불가** — 이 undecidability 자체가 기여. 02 v2(dx 미보존 harmonize에도 within-ADNI 0.885 불변)가 비순환 probe 작동의 자산 절반.
- **First experiment**: **CPU only**(feature-level). 입력 ① fs_vol 26 ROI(site-robust 기준) ② `roi_qc/reports/img_features.parquet`(site-leaky 대조). LOCO subject-first, held-KDRC(한국, AD 충분)·held-AIBL. **AJU는 site-probe에만 포함, CN/AD held-target에서 제외**(D-5).
  - 성공기준(음성결과 기준, 비대칭): (1) site-probe — image-feat은 held에서 chance 위, morphometry는 chance 근처, 차이 유의(RF+LogReg, null shuffle→chance). (2) biology-probe(유일 판정자) — morphometry LOCO **0.91 유지**, image-feat는 site-probe 높은데 held biology 안 따라옴=site만 인코딩. (3) undecidability 데모 — harmonize 후 site-probe↓가 biology 보존을 *동반 안 하는* 케이스를 한국 코호트로 구성.
- **치명적 reviewer 반박 + 방어**:
  - R2 "Souza+코호트 더 많은 것=incremental"(06 §3.2.1 1순위 리스크) → 규모를 novelty로 팔지 말고 기여를 **"confounded regime에선 판정이 undecidable, 비순환 probe가 유일 판정자"**로 못박음. Souza의 separable regime엔 이 undecidability가 없으므로 질적으로 다름. Bayer 2022(confound over-correction) 이론 앵커 + 02 v2 실증.
  - R3 [정직성] "한국이 population 차이냐 acquisition 차이냐?" → 01의 3축 분해로 *부분* 분리. **traveling 0이라 완전 분리 불가**는 한계로 명시(숨기면 더 큰 reject). "완전 분리 불가가 곧 undecidability의 데이터적 근원"으로 약점을 thesis로 전환.

### T-2 — Cross-population 일반화/공정성 감사
- **Thesis**: AD 모델(morphometry vs image)이 한국↔서구를 넘을 때 일반화가 어디서·왜 깨지나 + 표준 fairness metric이 site==population에서 어떻게 무효화되나.
- **차별점**: 기존 fairness는 서구 내 하위집단(PMC12782832, Hispanic) 또는 데이터셋 내 인종. 우리는 **별도 코호트로 수집된 한국 vs 서구** = metric이 가장 험하게 깨지는 극한. PMC8369368은 norm 통계만, 모델/공정성 축 공백.
- **First experiment**: CPU(morphometry) + GPU 선택(07 patch cache 재사용). held-KDRC vs held-AIBL 대칭. subgroup={한국,서구}×{CN,AD}. 일반화 비용 분해(held-한국 vs held-서구 AUC 격차) + fairness metric(equalized-odds/AUC-gap) 무효화 데모(비순환 probe). 바: morphometry LOCO 0.91 + held-KDRC 0.919(04 실측).
- **반박+방어**: R2 "morphometry가 한국서 이미 0.92면 non-problem 아니냐" → 정확히 그게 발견: **feature(morphometry)는 인구축 거의 안 깨지는데 image/foundation은 깨진다**는 비대칭 + "AUC 공정해 보여도 fairness metric은 site==pop에서 해석 불가". 단 반박이 강해 **T-1의 챕터로 묶는 게 안전**(그래서 2순위).

### T-3 — Foundation/SSL feature audit (GPU-gated, 양방향 안전 베팅)
- **Thesis**: 대규모 사전학습 인코더 표현이 morphometry site-robustness(0.91)를 따라잡나, site==population shortcut을 morphometry보다 더/덜 인코딩하나 — linear probe + dual-probe로 측정.
- **차별점**: foundation feature를 "SOTA"가 아니라 **audit 대상**으로. 07의 from-scratch data-limited(train AD 107~205) 우회하는 유일 미시도 레버(PLAYBOOK §3②). **biology-guided(AnatCL/y-Aware)만 후보**(01: 순수 SSL은 ICC 0.25–0.45로 탈락).
- **First experiment**: **GPU(추론만, frozen+linear probe → 비용 낮음) → 사전 승인 필수.** 입력=frozen foundation feature[backbone-입력 호환성 선확인 필수, 우리 192³ z-score identity-affine] → linear probe. LOCO held-KDRC/AIBL(07과 동일 split, 공정 비교).
  - 성공기준: ≥0.91이면 "이긴다" 부분 생존(정확도 claim 가능) / <0.91이면 T-1·T-2 audit 증거로 흡수("큰 backbone도 못 넘음"). site-probe로 foundation이 site를 더 인코딩하나 점검(07 MixStyle은 +0.026).
  - **양방향 다 논문이 되는 설계** = 베팅 안전. 단 "이긴다"로 시작하면 D-2로 죽으니 audit 프레임 유지가 조건.
- **반박+방어**: R2 "어차피 못 이긴다고 04/07이 예측" → 결론은 "이긴다/진다"가 아니라 **"foundation조차 site==pop shortcut을 morphometry 수준으로 못 떨군다"**가 audit 기여. R3 [실질 리스크] backbone 입력 규격 호환 — first experiment 전 확인, 불호환 시 re-preprocessing 비용(이게 T-3을 3순위로 내린 이유, F=★★★).

---

## Part 4. 한 줄 권고

> **T-1(Cross-population shortcut-audit)을 즉시 CPU로 착수하라.** 자산 절반(01 probe·02 v2 비순환 장치) 보유, GPU 승인 불필요, "confounded regime에선 shortcut 판정이 undecidable, biology-preserving 비순환 probe가 유일 판정자"라는 thesis가 **한국-confounded 벤치마크 없이는 쓸 수 없는 유일한 차별점**. T-2/T-3은 이 audit의 챕터로 흡수, foundation(T-3 GPU)은 "0.91 넘으면 positive, 못 넘으면 audit 강화"의 양방향 안전 베팅으로만 켜라.

**이 권고가 깨질 지점 (Risks)**
- **R-1(치명)**: T-1이 "Souza+코호트 더"로 읽히면 incremental reject → undecidability를 thesis 첫 문장에 박고, fallback(한국 포함 confounded 벤치마크 공개)을 주 기여로 승격 준비.
- **R-2(원리적)**: traveling 0이라 nuisance(scanner) vs population 완전 분리 **불가** → "측정한 게 population이냐 acquisition이냐" 반박은 완전 방어 불가. 약점을 thesis로 전환하는 것 외 해법 없음(숨기면 더 크게 터짐).
- **R-3(시간낭비)**: T-4(CDR staging)·T-7(normative)·D-1(GAN)에 GPU 쓰지 마라 — 라벨 구조로 죽었거나 같은 死因.
- **Blind spot**: option_b ROI 게이트(D-4) 통과 시 voxel-level audit이라는 새 차원이 열리나, T-1은 fs_vol/cached feature로 도므로 **게이트를 기다리지 마라**(`Clinical/VOXEL_ANALYSIS_PLAN.md`는 별도 선행).

**Honest opinion**: 이 데이터로 "정확도 SOTA" 논문은 죽었고(07/04), audit/undecidability 피벗이 옳다. 다만 audit 논문의 진짜 적은 **"당연하다"는 reviewer 반응** — 음성결과가 *우리 눈엔* 명백해도 undecidability를 한국 코호트로만 보일 수 있음을 매 단락 증명 못 하면 "negative result + 큰 데이터셋"으로 평가절하된다. **성패는 실험이 아니라 프레이밍에서 갈린다.**
