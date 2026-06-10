# AJU Clinical 상세 파싱 (2026-06-09)

아주대 컨소시엄(만성뇌혈관 기반 코호트) raw 임상역학 데이터 전수 파싱 기록.
KDRC와 동일한 깊이로 한국어 엑셀을 디코드하고 최종 manifest(real_final)에 통합했다.

## 1. 원본 파일

`/home/vlm/data/raw/AJU/metadata/`
- **`임상역학정보 분양_all.xlsx`** (본체) — 5 시트
  - `BL(1013+63+98+78+70)_1322` : **baseline 1322명 × 876열** (전체 임상+SNSB 배터리)
  - `TFU(80+51+54+50+60)_295` : follow-up 295명 × 877열 (visit_timeline 컬럼이 col2에 삽입 → **인덱스 +1 시프트**)
  - `임상정보`(520×13), `SNSB 요약`(52×11), `SNSB 통합`(311×6)
- **`임상역학정보_all_설명서.xlsx`** (코드북) — `임상정보 / SNSB 요약 / SNSB 통합` 시트에 변수·라벨·**값코드** 정의

### 헤더 레이아웃 (BL/TFU 공통)
- row0 = 섹션 타이틀(`임상역학정보`), row1 = **영문 변수코드**(`site, epid, sex, age, ...`), row2 = **한글 라벨**, row3~ = 데이터.
- 파싱은 **반드시 영문 변수명(row1) 기준**으로. TFU는 컬럼 시프트가 있어 인덱스 사용 금지.
- ⚠️ 한글 파일명은 NFC/NFD 정규화 차이로 직접 경로 매칭이 실패할 수 있음 → `glob` + 공백 유무로 본체/코드북 구분.

## 2. 조인 키

- BL/TFU `epid`(연구대상자 ID) = `ABD-AJ-0001` 형식, **manifest `subject_id`와 정확히 1:1 일치**.
- manifest AJU = **1287 세션 / 1001 subject** (V1=954, V2=287, ses-1=46). BL=1322 subject(⊇ manifest), TFU=295.
- **세션-aware 통합**: session `V2` → TFU 값(시변 항목), `V1`/`ses-1` → BL 값. APOE·amyloid는 baseline 1회 측정 → 항상 BL.

## 3. 핵심 필드 & 값코드 (설명서 디코드)

| 항목 | 변수(BL idx) | 코드/단위 | 비고 |
|---|---|---|---|
| **MMSE** | `mmse_s`(296, 임상)·`MMSE`(564, SNSB요약)·`K_MMSE_total_score`(770, SNSB통합) | 0–30 | 3소스 coalesce → **100%** |
| **주진단** | `ck_dcode`(513) | 1.Normal/2.OtherCI_SMI/3.OtherCI/4.AD/5.VaD_SVD/6.VaD/7.FTLD/8.OtherDegen/9.Other | 100% |
| **세부진단** | `ck_sdcode`(511) | 1.Healthy/2.SMI/3.aMCI/4.naMCI/5.vMCI/6–9.AD변이/10–12.혈관성치매/13.FTD/16.DLB/17.PDD/…/23.Other | **CN/MCI/AD 매핑 소스** |
| **APOE** | `APOE_opi`(508) | 1.e2e2/2.e2e3/3.e3e3/4.e2e4/5.e3e4/6.e4e4 | 100%(1286). e4보유 27% |
| **Amyloid PET** | `Amy_opi`(506) | **1.정상→negative / 2.비정상→positive** | 검사 1022/1322. 양성 349subj(34%) ⚠️ KDRC와 코딩 반대 |
| **CDR** | `cdr`(389) Global · `cdr_sb`(390) SB | 0/0.5/1/2/3 | 100%. 0.5 우세(MCI 코호트) |
| **GDS** | `gds`(391) | 1–7 (전반적퇴화척도) | 100% |
| **교육연수** | `edu`(8) | years | 100% |
| **성별** | `sex`(4) | **0=여 / 1=남** | 여851/남471 |
| MRI 소견 | `MRI_test`(498)+WMH/lacune/Scheltens(499–504) | — | **scanner 모델 필드 없음** |
| 우울 SGDS-K | `sgdsk1..15`(297–311)+`sgdsks` | 0/1 문항 | |
| SNSB 전배터리 | 518–841 | Digit span·BNT·SVLT·RCFT·COWAT·Stroop 등 raw/z/percentile | 309컬럼 |
| 혈액검사 | ~445–497 | CBC·간기능·지질·당 등 | |
| 동반질환 | htn/ab/mv/de/… +_d(약물)/_f(가족력) | 0/1 | 고혈압·당뇨·이상지질 등 21종 |

전수 인벤토리(876컬럼 + 코드북 값코드 + 커버리지): `aju_clinical_field_dictionary.csv`.

## 4. ⚠️ scanner 부재 (정직)

KDRC는 `JT`에 MRI 기종(1–4)이 있었으나, **AJU 임상에는 scanner 모델/제조사/자장강도 필드가 없다**. MRI 관련은 소견(WMH·lacune·해마위축 Scheltens)뿐. (키워드 스캔 결과 'csf' 토큰은 `천식 가족력`의 우연한 약어, 'tesla/제조/모델' 미존재.) → AJU scanner-bias 분석은 manifest의 다른 acq 소스에 의존해야 함.

## 5. CSF 바이오마커

AJU 임상 전수 스캔 결과 **CSF Aβ/p-tau/t-tau 없음**(amyloid는 PET read만). 7코호트 공통 결론과 동일 — 로컬 raw에 연속 CSF 농도값 보유 코호트 없음.

## 6. manifest 통합 결과 (real_final)

`enrich_aju_adni_clinical_v3.py` → `official_manifest_full_n4_real_final`:
- `clin_mmse` AJU **1287/1287 (100%)**, `clin_education` +1286, `clin_apoe`(+e4n) +1286
- 신규 컬럼: `aju_dx_sdcode·aju_dx_detail·aju_dx3`(CN144/MCI801/AD239/OtherDem94/Other9), `aju_amyloid`(neg851/pos435), `aju_cdr_global`, `aju_gds`, `aju_mmse_visit`(bl/tfu)
- NaN-only fill(기존값 불변) + 13,022행 불변 + 비대상 컬럼 byte-동일 — `verify_v3_clinical.py` 18/18 PASS(독립 재계산).

## 7. 재현

```bash
uv run python roi_qc/scripts/enrich_aju_adni_clinical_v3.py   # 생성
uv run python roi_qc/scripts/verify_v3_clinical.py            # 독립 검증
uv run python roi_qc/scripts/finalize_real_final_manifest.py  # real_final 승격
```
