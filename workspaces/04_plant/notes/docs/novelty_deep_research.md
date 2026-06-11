# Novelty Deep-Research — 멀티모달/clinical 주제 탐색 + 경험적 검증

> deep-research workflow(104 agents, 22 sources, adversarial verify) + 우리 데이터 직접 검증. 2026-06-11.
> 질문: "멀티모달·clinical로 기술적 novelty를 가장 강조할 주제는?" 결론: **novel ≠ 작동함. 정직히 보고.**

## 1. 문헌 판정 (deep-research, top-tier 한정, 검증됨)

5개 방향 중 **4개는 crowded, 1개는 whitespace** — 그러나 **공통 제약: 어느 것도 cross-site(LOCO)로 morphometry(0.93)를 넘은 증거가 없다.**

| 방향 | 대표(venue) | novelty | cross-site 증거 |
|---|---|---|---|
| **D1 missing-modality fusion** | ShaSpec(CVPR23)·mmFormer(MICCAI22)·DMRNet(ECCV24)·MICCAI25 dropout | crowded | 거의 없음(대부분 BraTS seg, dementia LOCO 무) |
| **D2 imaging+tabular fusion** | HyperFusion(MedIA25)·DAFT(MICCAI21)·AlzFormer | crowded(FiLM/conditioning 지배) | 없음. HyperFusion margin도 marginal(BACC 0.673 vs DAFT 0.658), single-ADNI CV |
| **D3 privileged distillation(PET→MRI)** | mutual-KD·MDPI stop-grad·CVPR26 PET-free | **이미 dementia서 다수 출판=occupied** | 없음. MRI-only student 0.7956 single-ADNI(≪0.93 바) |
| **D4 VLM/tabular-to-text** | CLIP-tabular(2308.15469) | thin·weak | 없음(882 slice, single-ADNI, acc-only) |
| **D5 blood/metabolic/B12/inflammation labs + MRI** | — | **★ genuine whitespace** | 미시도(공개셋 ADNI/OASIS/AIBL/BioFINDER에 혈액패널 없음) |

핵심 meta(검증, high): **imaging-only 멀티모달 SSL이 0.93~0.96으로 "morphometry를 matches"라는 주장은 REFUTED(0-3).** cross-site degradation 실재(ADNI 0.96 → OASIS 78%/AIBL 77.5%, ComBat+histmatch+adversarial 써도).

## 2. ★ 경험적 검증 — D5는 정말 작동하나? (우리 데이터 직접 테스트)

D5(혈액바이오마커)가 유일 whitespace라 **선언 전 직접 검정**(Korean AJU/KDRC, 혈액 1821세션, subject-disjoint CV):

| feature set | dementia vs non-dem AUROC |
|---|---|
| morph + age | **0.787** |
| morph + age + **혈액 17종** | **0.792** |
| **Δ (labs add)** | **+0.005 (사실상 0)** |
| labs + age only | 0.621 |

→ **혈액 패널은 morphometry 너머 dementia 분류에 거의 기여 안 한다(+0.005).** "novel"이 "작동함"을 의미하지 않는다. 공개셋이 혈액을 안 가진 이유의 일부가 "신경퇴행 분류엔 별 도움 안 됨"일 수 있다.

**공정성 caveat:** 이 테스트는 dementia-vs-rest(morph가 강한 task, 0.787). 혈액(B12/갑상선/대사)은 본래 *가역적/대사성* 기여 마커라, **morph가 약한 task(MCI/early/amyloid status)** 에선 기여가 다를 수 있음 — 미검증. 또 2 코호트뿐이라 LOCO 아님.

## 3. 데이터 자산 (확인됨)
- Korean(AJU/KDRC): T1w+FLAIR(2148)+PET(1882)+**혈액패널(AJU 98-100%/KDRC 59%)**+동반질환+GDS+WMH/Fazekas. multimodal_full=1836. **공개셋이 못 가진 완전 멀티모달.** 단 **CN 195뿐**(disease-enriched).
- amyloid 라벨 7코호트 광범위(tracer 이질). raw FLAIR/DWI/PET 부분·미처리.

## 4. 정직한 판정

- **"가장 novel한 주제" = 혈액바이오마커+MRI(D5).** 문헌상 진짜 whitespace.
- **그러나 가장 obvious한 value-prop(혈액이 dementia 분류 개선)은 경험적으로 거의 죽음(+0.005).**
- 나머지 4방향은 crowded + cross-site 미증명. **morphometry 0.93 천장이 모든 방향의 공통 벽.**
- → **novel과 promising이 갈린다.** D5를 살리려면 **task 재정의**(가역/대사성 기여 subtyping, 혹은 morph-약한 early/amyloid task)가 필요하고 이는 speculative + 라벨 불명확.

## 5. 권고 (낙관 금지)
1. **D5를 "혈액이 AD 분류를 올린다"로 팔지 마라** — 이미 +0.005로 반증.
2. 살아있는 후보 두 갈래:
   - (A) **혈액-privileged distillation** (D3 메커니즘 + D5 novel 신호): 혈액을 train-only teacher로, MRI-only student가 전 코호트 transport. novelty=privileged 신호가 혈액(신규). 단 +0.005가 시사하듯 upside 작음 + Korean(CN-poor)→Western 이중 transfer 위험.
   - (B) **방법론/benchmark 기여**: 문헌에 cross-site 증거가 *전무*하므로, 7코호트 LOCO로 "무엇이 transport되나"를 최초로 규명(멀티모달 포함). null-robust.
3. **다음 결정적 테스트(미실행)**: 혈액이 *morph-약한 task*(MCI-vs-CN, amyloid status)에서 기여하나? 여기서도 +0이면 D5 완전 종결.

## 출처 (peer-reviewed; preprint [VERIFY])
ShaSpec CVPR23(2307.14126) · mmFormer MICCAI22(2206.02425) · DMRNet ECCV24(2407.04458) · MICCAI25 p2038 ·
HyperFusion MedIA25(2403.13319) · DAFT MICCAI21(2107.05990) · mutual-KD(medRxiv 2023.08.24.23294574) ·
MDPI Diagnostics 15(24):3135 · CLIP-tabular(2308.15469). 전체 vote는 task output w76297voh.
