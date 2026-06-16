# Track 04 — Vascular SNAP: 결과 종합 문서 (manuscript-prep)

_생성 2026-06-16. 통계·검증 전부 완료 상태의 정본 결과 정리. 작업 로그는 `SCRATCHPAD.md`._

---

## 0. 한 줄 결과

> **amyloid-음성 한국인(AJU, n=643)에서 정량 WMH(WMH-SynthSeg/FLAIR) → 해마위축, 표준화 β=−0.12~−0.17, p<1e-4.**
> 비선형 age·비순환 전역위축·혈관위험인자·정합품질 보정 전부 생존. 32/32 명세 일관. 시각 등급으론 검출 불가(n.s.)였던 효과를 정량화가 드러냄.

---

## 1. 사용한 영상 (image) — 모달리티별 역할

| 영상 | 전처리/분할 | 이 연구에서의 산출물 | 역할 |
|---|---|---|---|
| **T1-weighted MRI** (3D) | FastSurfer(VINN) → 1mm RAS | 해마부피(L+R), `fs_MaskVol`(eTIV 프록시), `fs_BrainSegVol` | **결과변수**(해마) + head-size 정규화 |
| **FLAIR** (2D, native ~0.4×0.4×5mm) | **WMH-SynthSeg**(딥러닝, 본 연구 신규 도입) | **정량 WMH 부피**(label 77) + 피질GM(label 3/42) | **노출변수**(WMH) + 비순환 위축 control |
| **Amyloid PET** / 시각판독 | (KDRC SUVR 481 / 시각 read) | `amyloid_visual`(pos/neg), `amyloid_suvr`(KDRC) | **층화축**(A−/A+, 통제 공변량) |

**핵심**: 결과(해마)는 **T1→FastSurfer**, 노출(WMH)·위축control(피질)은 **FLAIR→WMH-SynthSeg** — *서로 다른 영상·다른 도구*라 noncircular. amyloid는 endpoint 아닌 *층화/통제*(pTau217 회피).

- **FLAIR 입력 2종**: ① 주분석 = 전처리된 `flair_brain_1mm_RAS_192x224x192_zscore`(N4+T1정합+z-score, 1mm) ② 정합검증 = raw DICOM → dcm2niix native(비등방 5mm, 정합 전혀 없음).
- WMH-SynthSeg = contrast/resolution-agnostic(합성데이터 학습) → z-score·비등방 둘 다 처리. 모델 `WMH-SynthSeg_v10_231110.pth`(790MB), standalone(`tools/wmh_synthseg/`).

---

## 2. 코호트 & 데이터

| | AJU (primary) | KDRC (정직 강등) |
|---|---|---|
| subject-level baseline | 1001 → cc **998** | 909 → cc **265** |
| amyloid-음성(A−) | **643** (분석 핵심) | 69 (underpowered) |
| 혈관위험인자 | **100%**(htn/dm/dyslipidemia/BP/labs) | ~58% |
| 영상 WMH coverage | 982/998 (98%) | 259/265 |

- 분석단위 = **subject-level, baseline(V1) 1인 1행** (pseudo-replication 방지; session-level first-pass는 아티팩트).
- amyloid_visual = 'positive'/'negative' 양코호트 표준화, sanity 통과(A+가 해마↓·MMSE↓).
- 데이터 정본 = `Clinical/consortiums/Korean/korean_multimodal_manifest.parquet`.

---

## 3. 파이프라인 (Phase)

```
P1 (CPU): subject-level cohort build + 시각등급 stratified regression → within-A− n.s.(p=0.08)
P2-A (GPU): WMH-SynthSeg 설치 + smoke(4샘플, 등급 단조)
P2-B (GPU): 정량검증 197샘플 — WMH↔시각등급 Spearman AJU 0.55/KDRC 0.70, Kruskal p<1e-7
P2-C (GPU 병렬): 전수추론 1,263 (분석코호트)
P2-D (CPU): 연속 WMH 재분석 → within-A− 살아남(p≈0)
검증: make-or-break / spec-curve / mediation / attenuation / WMH×APOE / vascular-RF / code-audit / 정합교란(E)
```

---

## 4. 결과 (정본 숫자)

### 4.1 주효과 (AJU A−, robustness battery → `figA_forest_robustness.jpg`)
| 모델 | β (표준화) | 95% CI | p |
|---|---|---|---|
| 1. Primary (eTIV, linear age) | −0.165 | [−0.216, −0.115] | 2.5e-10 |
| 2. + spline age | −0.167 | [−0.217, −0.116] | 1.5e-10 |
| 3. + 비순환 피질 위축보정 | −0.120 | [−0.174, −0.066] | 1.7e-5 |
| 4. + 혈관위험인자 | −0.118 | [−0.173, −0.063] | 2.7e-5 |
| 5. + 정합품질(NMI) | −0.119 | [−0.173, −0.065] | 1.8e-5 |
| 6. Fully adjusted | −0.118 | [−0.173, −0.063] | 2.8e-5 |

→ 전역위축 보정서 ~27% 감쇠하나 p<1e-4 유지, CI가 0 배제. **특이적·강건.**

### 4.2 검증
- **시각→정량 rescue**: 시각등급 β=−0.072 p=0.08(n.s.) → 정량 β=−0.12 p<1e-4. attenuation: visual/continuous std-β ratio 0.28 ≈ ρ²(0.30) = 측정오차 감쇠의 예측치 → p-hacking 아님.
- **Spec curve**: 32 명세{정규화×변환×age×위축×혈관RF} 전부 유의·음성.
- **Mediation**: WMH는 age와 독립(b p≈0), age→해마 효과의 22.5%만 매개.
- **Positive control**: HTN→WMH β+0.22 p=0.004, DM→WMH β+0.33 p=0.0002 → WMH가 실제 혈관병리 ("vascular" 방어).
- **WMH×APOE**: 상호작용 무(p=0.59), e4±둘 다 유의 → APOE-독립.
- **정합 교란(E)**: native↔registered WMH Spearman 0.83 + flair_nmi 보정 후 효과 불변(−0.1199→−0.1192). → 정합 아님.
- **code-audit(독립)**: 결과-제조 버그 없음.

### 4.3 KDRC (정직 강등)
주모델 β=−0.193 p=0.015이나 **비순환 위축보정서 탈락(p=0.29)** + A+에서도 유의(비특이적) + n=69. → "replication" 아닌 "정직 공개되는 underpowered 일관성". 삭제 안 함(forking-path 회피).

### 4.4 ⭐ 혈관위험인자의 역할 (제목 framing 결정) — verified
| 검증 | 결과 |
|---|---|
| 혈관부담(htn+dm+dyslip 0-3) → WMH (positive control) | β+0.11 **p=0.004** ✅ |
| 혈관부담 → 해마 (total/직접) | β−0.008 **p=0.76** ❌ |
| 혈관부담 → WMH → 해마 (indirect 매개) | −0.019 **CI[−0.036,−0.006]** ✅ |
| (개별, 탐색적·미보정) 당뇨 → 해마 | β−0.118 p=0.04 |

**해석**: 혈관위험인자는 ① WMH를 예측(positive control=WMH가 혈관성 입증) ② 매개경로(혈관→WMH→해마) 유의, *그러나* ③ **해마를 직접 예측 못 함(total~0).** → **해마위축을 끄는 건 risk factor 상태가 아니라 그 뇌 발현물인 WMH.** = 이미지 접근의 직접 근거(RF는 distal, WMH는 proximal operative marker).
⚠️ 매개 prop>1(inconsistent/suppression: indirect 음성 vs direct 양성 상쇄) → "indirect 유의 + total null"로 명확 서술.
→ **제목은 WMH 중심**("cerebrovascular WMH burden"). 혈관RF가 위축을 *유발*한다고 함의 금지(overclaim).

---

## 5. NOVELTY (정직하게 — scoop audit + critic 반영)

scoop 판정 = **CROWDED-BUT-GAP-EXISTS.** 개념은 crowded, 정확한 패키지는 미점유.

**novel 아닌 것 (인정):** WMH↔해마위축 연관 / vascular-SNAP 개념(Vos 2018) / amyloid×WMH(서구 다수).

**우리의 차별점 (방어 가능):**
1. **측정 업그레이드 발견** ⭐ — *시각 WMH 등급은 이 연관을 놓치고(n.s.), 딥러닝 정량 WMH가 드러낸다*(p<1e-4). attenuation으로 정량 입증. → "임상 시각등급은 amyloid-음성 WMH-해마 연관에 부적합"이라는 *방법론적 메시지 + 실용 함의*.
2. **amyloid-음성-특이 + 위축-독립** — 효과가 amyloid-*음성*에서, *비순환 전역위축 보정 후에도* 특이적. **Freeze 2017(서구·amyloid-양성-특이)과 정반대** → population/측정-의존 coupling.
3. **한국(과소대표) 코호트** + 혈관위험인자 100% + positive control(HTN/DM→WMH) 검증.
4. **규모·엄밀** — WMH-SynthSeg를 임상코호트 1,263에 적용 + concurrent validity + native-vs-registered robustness + spec-curve.

**미점유 조합 = 정량WMH + 한국 + amyloid-음성-특이 + 위축-독립 + 시각등급-부적합 입증.** 단일 논문 부재.

**Freeze reconcile (제출 전 집필)**: 우리=A−효과+sub-additive(interaction +0.16) vs Freeze=A+효과+potentiation. testable 기전 = A+는 AD-tau로 해마 이미 floored → 혈관 추가효과 saturate(천장). + 코호트(memory-clinic N63 vs 우리 large)·측정(시각 vs 정량)·CSF-Aβ vs visual-amyloid 차이.

---

## 6. FIGURE 인벤토리

| Fig | 파일 | 내용 | 상태 |
|---|---|---|---|
| 분할 예시 | `results/wmh_smoke/viz/comparison_all4.jpg` | WMH-SynthSeg 오버레이(등급별 빨강 WMH, 양코호트) | ✅ 생성됨 |
| 정량검증 | `results/stageB/validation_boxplot.jpg` | WMH 부피 vs 시각등급(AJU/KDRC, ρ·AUC) | ✅ 생성됨 |
| **주효과 robustness** | `results/figures/figA_forest_robustness.jpg` | 6모델 forest — "모든 보정서 생존" | ✅ 생성됨 |
| **주효과 scatter** | `results/figures/figB_partial_residual.jpg` | partial-residual(WMH→해마, 공변량 보정 후) | ✅ 생성됨 |
| 연구 흐름도 | (미생성) | 코호트·N·층화·WMH-SynthSeg 파이프라인 | ⬜ 집필시 |
| mediation 도식 | (미생성) | age→WMH→해마 경로 | ⬜ 선택 |

권장 본문 배치: Fig1=흐름도, Fig2=분할예시(comparison_all4), Fig3=정량검증(boxplot), Fig4=forest(figA), Fig5=scatter(figB).

---

## 7. 정직한 한계 (논문 명시)

1. **횡단뿐** — 인과 금지("연관"). Korean 종단 0.
2. **단일 primary 코호트** — KDRC는 underpowered 일관성(특이성 미확립).
3. **Freeze와 방향 반대** — reconcile 필요(§5).
4. **two-ICV** — WMH=SynthSeg-ICV, 해마=FastSurfer-MaskVol(z-score라 분석 무관하나 공개).
5. **native WMH magnitude 2× 차이** — 두꺼운슬라이스 partial-volume(분석은 z-score 무관).
6. **연속 BP/glucose 입력오류**(sbp=11 등) → binary RF 사용.

타깃 저널: **Alzheimer's Research & Therapy** > Alz&Dementia:DADM > JAD/CCCB.
