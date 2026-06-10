# Korean 코호트 (AJU·KDRC) — 데이터 자산 정리 & 활용 로드맵

작성: 2026-06-09. 근거 문서: `README.md`(스키마), `../KOREAN_AJU_KDRC_CLINICAL_CROSSWALK_EDA.md`(전수 EDA).
관련 메모리: [[korean-cohort-enrichment-v3]] [[aju-clinical-rich]] [[kdrc-clinical-rich]] [[csf-absent-all-cohorts]] [[manifest-real-final]].

---

## 1. 지금까지 한 일 (요약)

1. **raw 전수 EDA** — AJU `임상역학정보 분양_all.xlsx`(1,322×**876**), KDRC `clinical.xlsx`(576×**287**)를 도메인별로 직접 검증. 로드 표준화 캐시: `../_korean_cache/`.
2. **공통 도메인 cross-walk** — 12+ 도메인(인구학·진단·인지·APOE·amyloid·혈액검사22·공존질환·우울·WMH·ADL·신경심리) 정렬, 코드 반대방향·단위 차이 규명.
3. **통합 manifest 2종 생성** — 공통 51컬럼, 코드 표준화, QC flag(raw 보존).
   - `korean_clinical_subject_level` (1,898 subject)
   - `korean_manifest_session_level` (2,196 영상 세션 + ROI)
4. **독립 검증** — 코드 표준화 정확성·QC flag·진단별 MMSE 단조성 cross-check 통과.

---

## 2. 데이터 자산 한눈에

| | AJU | KDRC |
|---|---|---|
| 영상 세션 | 1,287 | 909 |
| 진단(3-class) | MCI 754 / AD 252 / CN 206 / OtherDem 110 | 치매 304 / MCI 210 / CN 62 (raw 576) |
| MMSE·CDR·APOE | 100% | 89% / · / 100%(raw) |
| amyloid | **visual** (양성 34%) | **SUVR 정량** + visual (양성 66%) |
| 혈액검사 | 22+종 (+소변 12종, Homocysteine, Hs-CRP) | 22종 |
| 고유 강점 | 신경학검사 29, Ischemia(Hachinski/Rosen), MADRS, **Scheltens 해마위축 1,126명**, TFU 추적 | **amyloid SUVR**, 치매가족력 구조화, CERAD-K 완본, e4율 49% |

**공통 자산이 ADLIP 텍스트보다 두껍다**: ADLIP = MMSE+APOE+CSF+FAQ. 여기 = MMSE+APOE+**amyloid(SUVR/visual)**+혈액검사22+공존질환+우울+WMH.

---

## 3. 핵심 제약 (활용 전 반드시 인지)

| 제약 | 내용 | 영향 |
|---|---|---|
| **CN 부족** | AJU 206 + KDRC 62 = 268 | 3-class·정상감별의 병목. 서구코호트(ADNI/A4) 보강 필요 |
| **KDRC 임상 59%** | clinical.xlsx 576 ↔ 영상 909, 534세션만 매칭 | session-level KDRC 임상 부착 상한 59% |
| **CSF 전무** | 7코호트 공통 ([[csf-absent-all-cohorts]]) | ADLIP의 CSF 축 불가 → amyloid PET로 대체 |
| **코호트 confound** | AJU(MCI편중) vs KDRC(치매편중), 진단분포 상이 | LOCO 평가 시 코호트 추측 shortcut 위험 |
| **척도 비호환** | 우울(SGDS-K vs GDS), WMH(visual vs Fazekas) | 점수 직접비교 금지, 별도 컬럼 유지 |
| **KDRC 환자 교육** | raw에 환자값 없음(보호자만) | 교육연수 전부 NaN |

---

## 4. 활용 시나리오 (우선순위 순)

### 🟢 A. ADLIP식 영상–임상 VLM (contrastive) — **최우선 권장**
- **무엇**: 3D T1 MRI ↔ 구조화 임상을 자연어로 변환한 텍스트를 InfoNCE로 정렬. AD/MCI/CN zero-shot.
- **데이터**: `session_level`의 영상경로 + `dx_session`/`mmse_session` + 공통 임상.
- **차별점**: ADLIP(ADNI 단일·CSF) 대비 **amyloid PET + 혈액검사 패널**로 텍스트 강화. 한국 코호트 = under-represented 인구.
- **전제**: 임상→자연어 템플릿(시나리오 B) 선행. CN 보강 위해 서구코호트 병합 권장.
- **실패지점**: CN 268명 → contrastive 음성쌍 다양성 부족. 코호트 confound로 site shortcut. → ComBat/harmonization([[combat-fsvol-harmonization]]) + LOCO 평가 필수.

### 🟢 B. 임상 → 자연어 텍스트 스키마 (A의 선결 + 독립 가치)
- **무엇**: 51 공통컬럼을 임상 문장으로 직렬화. 예: *"72세 여성, MMSE 24, CDR 0.5, APOE E3/E4, amyloid PET 양성(SUVR 1.4), 고혈압 있음, WMH 중등도."*
- **데이터**: `subject_level` 그대로. 결측·QC flag 반영한 조건부 문장 생성.
- **즉시 가능**. 코드 표준화가 끝나 있어 템플릿만 작성하면 됨.

### 🟡 C. 멀티모달 진단 분류 (영상 + 임상 fusion)
- **무엇**: FastSurfer ROI(해마/내후각피질 등) + 혈액검사/APOE/amyloid → 진단.
- **데이터**: `session_level`의 `fs_vol_*` + 공통 임상.
- **한계**: 임상에 amyloid/CDR 포함 시 라벨 누수 위험(진단 정의에 인지·amyloid가 들어감). feature 선택 신중.

### 🟡 D. Amyloid status 예측 — **한국 코호트 고유 강점**
- **무엇**: 영상(±비침습 임상)으로 amyloid 양성 예측. KDRC SUVR = 회귀 타깃, AJU visual = 분류.
- **데이터**: AJU `amyloid_visual`(1,022) + KDRC `amyloid_suvr`(481)/visual.
- **가치**: amyloid PET는 고가·침습. 영상→amyloid 대리는 임상적 수요 큼. 서구코호트엔 부족한 축.
- **한계**: AJU visual ↔ KDRC SUVR 척도 통합 필요(visual을 SUVR 임계로 정렬하거나 분리 학습).

### 🟡 E. 혈관성 vs 퇴행성 감별 — **AJU 고유 강점**
- **무엇**: WMH·Lacune·Ischemia(Hachinski/Rosen)·신경학검사로 SVaD/MID vs AD 감별.
- **데이터**: AJU `wmh_grade_visual`, `fazekas_*`, 신경학 29종(raw cache), Ischemia(raw).
- **한계**: KDRC엔 신경학·Ischemia 없음 → AJU 단독. OtherDementia(110) 라벨 활용.

### 🔵 F. KDRC를 외부검증(held-out) 세트로
- **무엇**: AJU+서구로 학습 → KDRC로 일반화 검증 (ADLIP의 HABS-HD 역할).
- **가치**: KDRC = amyloid+ enriched, e4 49% → AD 신호 강한 독립 시험대.
- **기존 활용**: 이미 `vlm_gate_04*` 실험들이 KDRC를 held-out으로 사용 중.

---

## 5. 즉시 가능 vs 선결과제

| 즉시 가능 | 선결 필요 |
|---|---|
| B 텍스트 스키마, D amyloid(코호트별), E 감별(AJU), F held-out | A VLM(B+CN보강+harmonization), C fusion(누수 통제), AJU·KDRC amyloid 척도 통합 |

---

## 6. 권장 다음 스텝
1. **시나리오 B 구현** — `subject_level` → 자연어 임상 텍스트 생성기(`build_korean_clinical_text.py`). 결측/QC flag 조건부 처리. → A의 입력.
2. **CN 보강 설계** — 서구코호트(ADNI/A4 CN) 병합 스키마를 동일 51컬럼으로 확장(컬럼 호환성 이미 확보).
3. **harmonization 점검** — 코호트 confound 정량화(site probe) 후 ComBat/이미지 harmonization 적용.
4. 이후 **A ADLIP-style VLM** 학습.

> 모든 시나리오는 `session_level`(영상 페어) 또는 `subject_level`(임상 분석)에서 바로 시작 가능. 추가 raw 도메인(신경학·소변검사·SNSB 전배터리)이 필요하면 `../_korean_cache/`에서 확장.
