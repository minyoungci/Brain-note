# minyoungi — 검증된 발견

_갱신: 2026-06-02 (커밋 2bfa860)_

범례: ✅확정 / ❌반증 / 🟡잠정 / [VERIFY]추측

---

## 1. Clinical 데이터 이해 (2026-05-31 daily 기준, 전수 검증)

### 1.1 코호트·라벨 구조

- **7개 컨소시엄, 13,022 세션** (`preprocessed_official/v2`): ADNI/NACC/AIBL/OASIS/A4/AJU/KDRC. ✅
- 핵심 텐서: `final_tensor`(192×224×192, identity affine, z-score) + option_b final_tensor-grid ROI/aseg + `official_manifest.csv`. ✅
- **diagnosis 라벨은 A4·KDRC에서 0%.** `CDR Global`만 7개 컨소시엄 100% 존재 → **유일한 공통 라벨**. ✅
- CDR↔진단 극단 일치: CDR0→CN 99.0%, CDR≥1→AD 99.7%. ✅
- 전수 ROI→(CN vs AD) AUC `0.865` (샘플 500에서는 0.807), 해마 CN(7931) vs AD(6609) p=3e-246. ✅ (단, ROI 정체는 §3 caveat)

### 1.2 FastSurfer stats 100% 존재 — "39% 결측"은 오진단이었다 ❌→✅

- 초기 보고: "FastSurfer stats가 500건 중 39% 없다."
- 전수 검증 결과 **13,022건 전부(100%) stats 존재**. ✅
- 원인: ADNI 세션 디렉토리가 `20061115.0`처럼 `.0`로 끝나는데 manifest 정규화가 `.0`를 절단 → ADNI 경로만 전부 깨짐. 데이터 결함이 아니라 **경로 정규화 버그**. ✅
- 수정: 경로를 `session_id` 재구성 대신 `final_tensor_path`에서 유도. ✅
- **교훈**: 사용자의 "정말 그게 맞아?" 의심이 정확했다. 결측처럼 보이는 것의 1차 용의자는 데이터가 아니라 join/normalize 버그.

### 1.3 Single-cohort 함정 (적대적 비평이 잡음)

- **"CDR0.5 = 89% MCI"는 전역 통계가 아니다.** dx 보유 코호트 한정 수치. 정작 CDR0.5 다수인 **KDRC(464)+A4(530)=994건은 dx 100% 결측** → 이들에 89% 적용은 표본 외 추정. ✅(직접 검증)
- **사이트마다 CDR 분포가 근본적으로 다름**: AJU CDR0=2.3%(memory clinic) vs OASIS 79.8%(community) vs A4(preclinical). 단일 코호트 통계를 전체로 일반화 금지. ✅
- **AUC 0.9를 "유효 타깃" 근거로 쓰지 말 것** — random split은 site 누수. leave-one-consortium-out 전엔 낙관치. 🟡

### 1.4 ComBat site harmonization 실증

`06_harmonization_combat.ipynb`, batch=consortium, CDR class를 보존 공변량으로:

| 지표 | BEFORE | AFTER |
|---|---|---|
| site 분류 정확도 | 0.407 | 0.362 (다수클래스 기저선 0.364) |
| CN 내 site Kruskal p | 1.1e-13 | 0.18 (유의성 소멸) |
| CDR↔해마 Spearman (보존) | −0.297 | −0.389 |
| ROI→(CDR0 vs ≥1) AUC (보존) | 0.905 | 0.908 |

→ site 정보를 chance까지 지우면서 CDR 신호는 보존(강화). ✅ 단 누수 없는 평가는 train-fit→test-apply여야 하고 consortium은 거친 site 단위(스캐너 내부 미모델링). 🟡

### 1.5 Clinical↔manifest join 커버리지 (검증)

ADNI 99% · NACC 100% · AIBL 100% · A4 100% · AJU 100% · KDRC 85% · **OASIS 29%(부분집합)**. ✅

---

## 2. Gate05b NACC ROI audit 결과 (2026-05-28)

### 2.1 NACC는 b1에서 회귀한다 (stress cohort)

primary/stress 분리 정책: **primary = ADNI/AIBL/KDRC, stress = NACC** (버리지 않고 별도 보고). ✅

| | b0 frozen AUC | b1 frozen AUC | ΔBaseline06 |
|---|---|---|---|
| primary 평균(ADNI/AIBL/KDRC) | 0.8092 | 0.8415 | b1 +0.0234 |
| **stress NACC** | 0.7994 | **0.7526** | b1 **−0.0442** |

- NACC AD ROI cosine: b0 `0.0657` → b1 `-0.4009` (음수로 전환). ✅
- 직접 AD 정답률: b0 0.5444 → b1 0.3846 (AD 민감도 손실), CN은 보수성↑. ✅
- ROI-cos 가중치 낮추거나 CE 높여도 NACC 회복 안 됨 → b0가 여전히 NACC 최선. ✅

### 2.2 per-target 실패 패턴 (NACC 실패의 국소화)

b1 도입 시 음의 cosine 기여가 큰 ROI-stat 타깃 (반복 재현됨): ✅
- `roi_std__lateral_ventricle` (−0.0529), `roi_std__amygdala` (−0.0510), `roi_std__thalamus` (−0.0449), `roi_q75__lateral_ventricle` (−0.0397), `roi_q75__thalamus` (−0.0343).
- AD/CN 방향 flip 타깃 `21/35` (AD-relevant flip 15). NACC AD shift 평균 절대값 1.0625.
- **해석**: b1 global ROI-cos loss가 특정 ROI-stat 타깃의 alignment를 망가뜨림. → b2는 global row-text alignment를 피하고 위 5개 타깃을 per-target 모니터링해야 함. 🟡(진단일 뿐, anatomical causality나 VLM readiness 증명 아님)

### 2.3 KDRC shortcut 진단 (Gate04e/05c)

- direct-head Grad-CAM이 **brain 바깥/배경에 집중**, medial-temporal ROI 마스크와 거의 0 겹침. ✅(단 mask source는 option_b candidate)
- 그러나 brain-only 입력 = original 입력 (final_tensor가 이미 skull-strip/zero-background) → "raw 배경 강도 shortcut" 주장은 약화. 병목은 **brain 내부 disease-relevant 3D feature를 약하게/오정렬해서 쓰는 것**. ✅

### 2.4 Shortcut baseline (Baseline07) — 반드시 넘어야 할 하한선

- ROI quality/status + severity 텍스트만으로(이미지 없이) CN/MCI/AD: internal macro OvR AUC `0.7212`, LOCO mean bACC `0.5411`. ✅
- **의미**: ROI-language/VLM 모델이 이 baseline을 못 넘으면 MRI representation이 아니라 deterministic ROI status/QC metadata 재포장일 가능성. 모든 후속 VLM claim의 게이트.

---

## 3. ROI QC: BLOCKED_PROVISIONAL — 가장 뼈아픈 발견

### 3.1 내가 써온 ROI는 공식적으로 "잠정(BLOCKED)"이었다

전수 13,022건 manifest QC 플래그: ✅
```
do_not_use_for_atlaswide_roi_features = True
roi_final_ready                       = False
roi_final_grid_qc_status              = BLOCKED_PROVISIONAL
roi_block_reason = "FastSurfer-to-native transfer requires ROI-specific
                    visual approval; candidates are provisional."
```
→ 03/05/06/컨소시엄 노트북이 의존한 option_b ROI는 **시각 승인 전 candidate**. 결과가 틀렸다는 게 아니라 모든 ROI 기반 결론을 "검증됨"→"후보"로 강등해야 함. ❌(검증된 데이터 아님)

### 3.2 centroid 좌표계 불일치

- summary JSON의 `centroid_voxel`은 256-conformed 좌표라 final_tensor 그리드와 **~31 voxel 어긋남**. ✅
- 큐브 크롭 중심은 `expected_centroid_final_voxel` 또는 마스크 재계산값을 써야 함. (다행히 `roi_tools.centroid()`는 마스크 재계산이라 기존 오버레이는 정상.) ✅

### 3.3 ROI QC 전수 결과 (2026-06-01)

13,022건 auto-anatomical-QC 완료: ✅
```
USABLE_AUTO        12932   numeric + auto-geometry pass (vision pending)
USABLE_W_CAVEAT       30   FLAG benign (ventricle asym 22 / thin-frag 8)
REVIEW_REQUIRED       11   borderline asym → human read
ROI_UNUSABLE           5   한쪽 반구 MTL ROI under-seg (vision 확인)
NOT_CANDIDATE         44   numeric fail (39 A4 + 5)
```
- 자동 게이트 통과 99.54%, **`roi_final_ready`는 전부 False (fail-closed)**. ✅
- **3-게이트 weakest-link**: ① numeric transfer ② auto-geometry ③ **vision QC(미완)**. Gate2 PASS ⇏ Gate3 PASS. 올바르게 위치하고 대칭이며 single-component인 boundary error는 게이트1·2가 못 잡는다. 🟡
- PASS 표본 21개 사람 검토: gross 오류 0/21. 단 montage 해상도로는 gross만 잡힘 → subtle(few-mm) error 미정량. 🟡

### 3.4 site/scanner shortcut + N4 (2026-06-02)

- v2는 N4 미적용(z-score만). site probe: APPEARANCE balanced_acc 0.565 vs chance 0.143; biology(brain_vox) 0.155≈chance → **누수는 강도/대비(스캐너 지배)**. ✅
- N4 비파괴 mini-exp(ROI 무영향): within-ADNI 벤더 고정 site 분류 0.748→0.589(18/20 실제 감소) = 스캐너 bias 절반 감소, but chance 미달. 단일벤더 AJU는 N4 무효(0.73→0.81). 🟡

---

## 4. 메타 교훈 (전례로 기록)

1. **데이터 버그 전례**: "39% 결측"은 데이터가 아니라 `.0` 절단 경로 정규화 버그였다. 결측·이상치의 1차 용의자는 데이터가 아니라 join/normalize 코드.
2. **생성 ≠ 검증**: 구조가 목표와 1:1로 맞는 노트북 5개 중 4개가 현재 데이터에서 깨져 있었다(sex 타입 혼합, FastSurfer 경로 누락, eTIV 부재). 구조가 맞다고 돌아가는 게 아니다.
3. **검증 ≠ 적대적 검증**: 단독 작업이 절대 못 잡은 두 가지(BLOCKED_PROVISIONAL 플래그, centroid 좌표계 불일치)를 멀티에이전트 적대적 비평이 잡았다.
4. **자기일관성 ≠ 정확성**: `auto_verdict≈PASS`는 전송 자기일관성일 뿐, FastSurfer 원본 분할 오류는 못 잡음 → vision 필수.
