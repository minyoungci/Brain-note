# AI Methods & Related Work (manuscript 내용)

_2026-06-16. 코드에서 추출한 실제 아키텍처 + OpenAlex 선행연구 비교. 출처 `openalex_related.json`._
_위치: Methods의 영상-AI 단락 + Discussion의 비교 단락으로 들어감. AI는 novelty 주장 아닌 **enabling method**로 기술._

---

## 1. 딥러닝 영상-AI 방법 (Methods 본문)

### 1.1 정량 WMH — WMH-SynthSeg (실제 구조, 코드 검증)
- **백본**: 3D U-Net (encoder–decoder, skip connection).
- **깊이/폭**: `num_levels=5`, base `f_maps=64` → 기하증가 64-128-256-512-1024.
- **블록**: `layer_order='gcl'` = GroupNorm(`num_groups=8`) → Conv3D(3×3×3) → LeakyReLU. pool 2×.
- **입출력**: `in_channels=1`(단일 FLAIR), 출력 = 33 해부+병변 라벨(softmax) + 보조 채널. WMH=label **77**, 해마=17/53, 피질=3/42.
- **학습 패러다임 (핵심)**: **SynthSeg domain randomization** — *실제 영상 0장*, 해부 라벨맵에서 대비·해상도·방향·bias field·artifact를 무작위화한 **합성영상만으로 학습** → **contrast-and-resolution agnostic**. acquisition-specific 편향 없음 (Billot 2023 SynthSeg; Laso/Iglesias 2024 WMH-SynthSeg).
- **추론**: 임의 해상도 FLAIR → 내부 1mm 리샘플 → CNN → 라벨 확률 → WMH 부피(+ICV+ROI). B200 GPU, 모델 `WMH-SynthSeg_v10_231110.pth`(790MB), standalone.
- **왜 이 모델인가 (정당화)**: 우리 코호트는 다-scanner + native FLAIR이 **비등방 2D 임상 영상(0.4×0.4×5mm)**. 지도학습 WMH 분할기는 특정 acquisition에 학습돼 **out-of-distribution서 성능 저하** — 우리가 입증한 site-bias(metadata 0.761)와 직결. domain-randomized WMH-SynthSeg는 *설계상* 이질성에 강건. 우리는 이를 **concurrent validity(시각등급 대비)·native-vs-registered robustness**로 검증.

### 1.2 T1 형태계측 — FastSurfer(VINN)
3D CNN(VINN) 기반 전뇌 분할 → 해마(L+R, 결과변수)·MaskVol(eTIV 프록시)·BrainSegVol. (Henschel 2020/2022.)

→ **두 딥러닝 모델: T1(FastSurfer)→해마, FLAIR(WMH-SynthSeg)→WMH. 서로 다른 영상·모델 = noncircular.**

---

## 2. AI-방법 비교 (WMH 분할기) — OpenAlex 근거

| 도구 | 유형 | 학습데이터 | 대비/해상도 강건성 | 비고 |
|---|---|---|---|---|
| LST-LGA/LPA | 비지도/로지스틱 | (없음/소량) | 중 | 임계값 민감 |
| **BIANCA** (NeuroImage 2016, 450cit) | k-NN ML | site별 라벨 필요 | 낮음 | 재학습 필요 |
| FCN-ensemble (NeuroImage 2018, 238cit; MICCAI'17 우승) | 지도 DL | 챌린지셋 | 중(같은 분포) | OOD 저하 |
| Triplanar U-Net ensemble (MedIA 2021) | 지도 DL | 라벨셋 | 중 | site 의존 |
| SAMSEG (2020, 154cit) | Bayesian, 대비적응 | atlas | 중-상(대비) | 해상도엔 덜 강건 |
| LST-AI (2024, 53cit) | DL ensemble | MS 병변 | 중 | **MS 편향**(age-WMH 아님) |
| nnU-Net WMH (2023-24) | 지도 DL | 라벨셋 | 중 | 등방 3D FLAIR 가정 |
| **WMH-SynthSeg (ours, 2024)** | **DL + domain randomization** | **합성(실영상 0)** | **상(대비·해상도)** | **재학습 불요·비등방 임상FLAIR OK** |

**핵심 비교 메시지**: 대부분 DL WMH 분할기는 *site-specific 학습 → OOD 저하*. 우리 다-scanner 한국 임상 FLAIR(비등방)엔 domain-randomization WMH-SynthSeg가 적합 — *우리가 검증으로 뒷받침*. (단 — 이건 도구 *선택 정당화*지 도구 *개발* 아님.)

---

## 3. 임상 선행연구 비교 — OpenAlex + scout 근거

| 연구 | 코호트 | 설계 | amyloid 층화 | WMH 측정 | 우리 대비 |
|---|---|---|---|---|---|
| **Freeze 2017** (JAD, PMID 27662299) | 네덜란드 memory-clinic N63 | 횡단 | CSF Aβ42 | 시각/반정량 | ⚠️**방향 반대**: WMH→해마 효과가 amyloid-*양성*서(우리=음성서). reconcile 척추 |
| 1946 British Cohort (Neurology 2022, PMC9280996) | 영국 N346 CN | 종단 | 연속 Aβ | — | additive, **무 상호작용** |
| KBASE (Alz Res Ther 2024, PMID 38454444) | 한국 N282 | 종단 | — | — | **반대 방향**(amyloid→WMH) |
| MITNEC-C6 (Alz Dem 2024, PMID 38574400) | 캐나다 | 횡단 | — | 정량 | 독립·공간 기여(층화 無) |
| Saito/Roseborough (Acta Neuropathol 2017, 279cit) | AD | 병리 | — | 두정 WM 병변 | WM 병변↔피질 신경퇴행 |
| Rabin/Vascular×Amyloid (JAMA Neurol 2018, 226cit) | clinically normal | 종단 | amyloid PET | — | 혈관위험×amyloid→인지(해마 아님) |
| PMID 33586848 | 건강 노인 | 횡단 | — | 부위별 | **e4-특이**(우리=e4-독립) |

**미점유 = 정량-DL-WMH + 한국 + amyloid-음성-특이 + 위축-독립 + 시각등급-부적합 입증.** 단일 논문 부재(scoop: CROWDED-BUT-GAP).

**STRIVE-2** (Lancet Neurol 2023, 959cit, "Neuroimaging standards for SVD") = WMH 정량 보고 표준 → Methods에서 준수 명시.

---

## 4. 집필 시 배치
- **Methods/Image analysis**: §1 (두 DL 모델 구조 + SynthSeg 학습 + 도구 선택 정당화 + STRIVE-2 준수).
- **Methods/Statistics**: 회귀·매개·robustness(별도).
- **Discussion 비교 단락**: §3 표 + Freeze reconcile(testable 기전) + "imaging>risk-factor".
- **Supplement**: §2 AI-도구 비교표(도구 선택 근거).
- ⚠️ AI는 **enabling method**로 일관(개발/SOTA 주장 금지).
