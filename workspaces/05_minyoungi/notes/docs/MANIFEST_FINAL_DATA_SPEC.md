# 최종 데이터 명세 — 코호트별 보유 모달리티·임상 + 사용 데이터 결정

_각 컨소시엄 **raw 디스크를 직접 전수 조사**(2026-06-15)한 결과 + canonical manifest 실측 + 독립 재검증.
**중요**: manifest의 `raw_*_path` 컬럼은 "manifest에 링크된 것"만 반영하며 **디스크 실제 보유분을 크게 과소
표현**한다(예: AJU `raw_pet_path`=0 이지만 디스크엔 amyloid PET 1,020세션 존재). 따라서 이 문서는 두 층위를
구분한다: **(A) raw 디스크 실보유** / **(B) canonical manifest 등재(현재 사용중)**._

---

## 0. 핵심 정정 & 요약

> ⚠️ **이전 오류**: manifest `raw_*_path`만 보고 "AJU/ADNI/NACC는 PET·멀티모달 없음"이라 기술했으나
> **틀림**. 디스크에는 PET 이미지·멀티모달 MRI·CT·lifelog·plasma·CSF·tau가 코호트별로 풍부.

**디스크 실보유 = 사용한 도구**: 컨소시엄별 병렬 디스크 조사(read-only) + 모든 headline 수치 독립 재검증.

| 코호트 | 권역 | raw 영상 (디스크) | PET (디스크) | manifest 등재 T1 |
|---|---|---|---|---|
| **ADNI** | 미국 | T1 1,756명/12,303session, fMRI 349명 (DICOM/NIfTI) | **amyloid PET(AV45) 1,537명** (tau 없음) | 4,742 |
| **NACC** | 미국(레지스트리) | ⚠️ raw 영상 **사실상 없음**(디스크 1명) | PET-유래 표만(amyloid·tau·FDG) | 1,866 |
| **A4** | 미국(예방시험) | T1 7,133/FLAIR 7,096/DWI 674 (NIfTI) | ❌ raw PET 없음, **유래값+plasma만** | 1,811 |
| **OASIS-3** | 미국 | MR 2,842session/1,376명, DWI 642명, fMRI 99 (NIfTI BIDS) | **PIB+AV45 412명/762session, tau AV1451** | 1,420 |
| **AJU** | **한국** | **V1/V2 종단**, 3D_T1 1,293, FLAIR 1,306, DTI 1,250, fMRI 1,154, SWI/ASL/MRA/DWI/ADC/T2 (DICOM) | **amyloid PET 1,020 + CT 711** | 1,287 |
| **AIBL** | 호주 | MPRAGE T1 692명/1,297session, SWI (DICOM, zip내) | amyloid PET **메타데이터만**(PIB 410·AV45 188·FLUTE 251) `[VERIFY 원본이미지]` | 987 |
| **KDRC** | **한국** | T1 944, FLAIR 946, T2 830, DTI 693 (NIfTI) | **amyloid PET 946** | 909 |

---

## 1. 두 층위 구분 (반드시 이해)

| 층위 | 내용 | 위치 | 상태 |
|---|---|---|---|
| **(A) raw 디스크** | 각 코호트가 실제 보유한 전체 모달리티·임상 원본 | `/home/vlm/data/raw/{C}/` | read-only. 멀티모달 대부분 **미전처리** |
| **(B) canonical manifest** | QC-PASS된 **T1만** + 파생 임상/amyloid 수치 | `official_manifest_full_n4_real_final.parquet` (13,022×141) | 즉시 사용 가능. 전처리 T1 텐서 7코호트 100% |

> manifest는 **T1 단일 모달리티 파이프라인**의 산물. raw의 PET·FLAIR·DTI·CT·lifelog 등은 manifest에
> 들어있지 않음(전처리하면 추가 가능). §6에서 "최종 사용 데이터"를 두 층위로 정리.

---

## 2. 코호트별 완전 인벤토리 (디스크 실측, 독립 재검증)

### 2.1 ADNI (미국) — `/home/vlm/data/raw/ADNI`
**영상**
- **T1/MPRAGE**: 1,756 subj / 12,303 session (DICOM). `ADNI_3_4_T1w/ADNI/<subj>`
- **amyloid PET**: 1,537 subj (DICOM). tracer = **AV45 florbetapir** (전량) + FBB florbetaben 2명. **tau PET 없음**(UCBERKELEY_AMY만 존재, TAU 테이블 없음) — 재검증 완료.
- **resting fMRI**: 349 subj (NIfTI).

**임상/바이오마커 (CSV)**
- APOE: `APOERES_07Jun2026.csv` (3,211 rec) · amyloid SUVR/centiloid: `UCBERKELEY_AMY_6MM_30Mar2026.csv` (4,728 rec; manifest엔 1,203만 외부조인) · MMSE 14,751 · CDR 14,608 · FAQ 13,463 · FreeSurfer morphometry `UCSFFSX7` 12,150 · CSF ELISA(비표준 마커) 74 · labs `LOCLAB` 8,589 · 진단/인구통계.

### 2.2 NACC (미국 레지스트리) — `/home/vlm/data/raw/NACC`
**영상**: ⚠️ **raw MRI 디스크에 거의 없음** — `MRI/`에 1명(NACC000868)뿐. **manifest의 NACC T1 1,866은
별도 처리분(원본 미보존)**. PET 이미지도 없음 — 전부 파생 표.
**임상/바이오마커 (CSV, 전체 레지스트리)**
- `commercial_nacc70.csv`: **48,595 subj / 178,052 visit / 1,024 col** (UDS 전체).
- PET-유래: amyloid NPDKA 2,178명 / GAAIN centiloid 1,759명 · **tau PET 1,489명** · FDG PET 409명 · PET QC 2,725명.
- 진단(NACCALZD/NORMCOG) · APOE(NACCAPOE/NE4S) · CDR(GLOB/SUM) · MMSE/MoCA · CSF flag(NACCACSF) · 신경병리 데이터셋(RDD).

### 2.3 A4 (미국 예방시험; A4+LEARN+SF) — `/home/vlm/data/raw/A4`
**영상 (NIfTI, 추출됨)**: T1 7,133 / FLAIR 7,096 / DWI 674 파일. unique ~1,787 subj(A4 1,522·LEARN 477·SF 29).
- ❌ **raw PET/tau 이미지 없음**(`ImageData`에 PET 0). 종단(다중 visit).
**임상/바이오마커 (매우 풍부)**
- amyloid SUVR(florbetapir): `imaging_SUVR_amyloid.csv` 45,968 rec · **tau PET SUVR 파생값**: `imaging_SUVR_tau.csv`, `imaging_Tau_PET_PetSurfer.csv`(446), Stanford · **plasma pTau217**: `biomarker_pTau217.csv` ✅ · plasma Roche 13,419 · PACC 인지 26,781 · APOE(`SUBJINFO.APOEGN`) · MMSE 26,766 · CDR · 볼류메트릭 MRI · 데이터딕셔너리 4종.

### 2.4 OASIS-3 (미국) — `/home/vlm/data/raw/oasis3`
**영상 (NIfTI BIDS)**: MR 2,842 session / 1,376 subj (T1w + session별 T2w/FLAIR/dwi/swi/bold/asl). amyloid PET **PIB+AV45** 412 subj / 762 session. DWI 642 subj. fMRI 99(FSL 전처리).
**임상/바이오마커 (CSV/PUP)**
- centiloid(PIB+AV45): `OASIS3_amyloid_centiloid.csv` 1,893 rec / 1,004 subj · **tau AV1451 PUP** 437 rec · FreeSurfer 2,682 · CDR/MMSE/MoCA · 진단(UDSd1) · 신경병리 Braak(manifest 148) `[VERIFY PET vs autopsy]`.

### 2.5 AJU (한국, 아주대 다기관) — `/home/vlm/data/raw/AJU`
**영상 (DICOM, 5.2M 파일; V1/V2 종단)** — 재검증 완료
- **amyloid PET 1,020** · **CT 711** · MRI: **3D_T1 1,293** · T2_FLAIR 1,306 · DTI 1,250 · fMRI 1,154 · T2_FSE 686 · MRA 559 · DWI 547 · SWI 547 · ASL 454 · ADC 504 · fgre/gre 변이.
- unique 영상 subj **1,161**, V2 보유 291(종단 25%). 사이트 8~9개(AJ/SW/IH/GJ/SS/AN/BS/CN).
**기타 모달리티**: **lifelog actigraphy** 350명(웨어러블 가속도 시계열 txt) — 7코호트 중 유일.
**임상**: `임상역학정보 분양_all.xlsx` (BL 1,325 / TFU 298, 876 col) + **SNSB 전 신경심리 배터리** + 진단·APOE·amyloid visual·MMSE·CDR.

### 2.6 AIBL (호주) — `/home/vlm/data/raw/AIBL`
**영상 (DICOM, `AIBL-VLM-v1.zip` 내 — 미추출)**: MPRAGE T1 **692 subj / 1,297 session** + **SWI**(메타데이터 636).
- amyloid PET = **메타데이터 테이블만**(PIB 410명·AV45 188명·FLUTE flutemetamol 251명). raw PET 이미지가 zip에 있는지는 `[VERIFY]`(주 zip은 MPRAGE+SWI).
**임상 (`meta/` 18 CSV)**: **APOE 862명** · 진단(DXCURREN) 862 · MMSE 862 · CDR · labs · MRI 1.5T/3T 메타.
> ⚠️ manifest엔 AIBL `clin_apoe`=0%이지만 **raw엔 APOE 862명 존재** → manifest under-fill(보강 가능).

### 2.7 KDRC (한국 치매코호트) — `/home/vlm/data/raw/KDRC`
**영상 (NIfTI, 추출됨)** — 재검증: T1 944 · FLAIR 946 · **amyloid PET 946** · T2 830 · DTI 693. 952 subj, **단일세션(종단 0)**. + DICOM zip 아카이브 1,312개.
**임상**: `clinical.xlsx` (578×286) + zip내 3개 `데이터통합` xlsx(이전 세션 4-파일 병합으로 보강). scanner 모델 · amyloid SUVR+visual · APOE · Fazekas(PV/deep) · CERAD/SNSB · K-MMSE/CDR · labs · 동반질환 · GDS · 가족력.

---

## 3. 통합 모달리티 매트릭스 (raw 디스크 실측; ✅=원본이미지, 📄=파생수치/메타만, –=없음)

| 모달리티 | ADNI | NACC | A4 | OASIS | AJU | AIBL | KDRC |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **T1 구조** | ✅1,756명 | ⚠️1명만 | ✅~1,787명 | ✅1,376명 | ✅1,293 | ✅692명 | ✅944 |
| FLAIR | – | – | ✅7,096 | ✅(session별) | ✅1,306 | – | ✅946 |
| T2 | – | – | – | ✅ | ✅686(FSE) | – | ✅830 |
| DWI/DTI | – | – | ✅674 | ✅642명 | ✅1,250(DTI)+547(DWI) | – | ✅693 |
| SWI | – | – | – | ✅ | ✅547 | ✅636 | – |
| ASL(관류) | – | – | – | ✅ | ✅454 | – | – |
| fMRI | ✅349명 | – | – | ✅99 | ✅1,154 | – | – |
| MRA(혈관) | – | – | – | ✅ | ✅559 | – | – |
| CT | – | – | – | – | ✅711 | – | – |
| **amyloid PET** | ✅1,537명 | 📄1,759명 | 📄(SUVR) | ✅412명 | ✅1,020 | 📄449명 | ✅946 |
| **tau PET** | – | 📄1,489명 | 📄(SUVR) | ✅(AV1451) | `[VERIFY]` | – | – |
| FDG PET | – | 📄409명 | – | – | – | – | – |
| lifelog | – | – | – | – | ✅350명 | – | – |

---

## 4. 임상·바이오마커 가용 매트릭스 (raw 디스크; 원본 표 기준)

| 항목 | ADNI | NACC | A4 | OASIS | AJU | AIBL | KDRC |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 진단 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| APOE | ✅ | ✅ | ✅ | ✅ | ✅ | ✅(862) | ✅ |
| amyloid 정량(SUVR/centiloid) | ✅ | ✅ | ✅ | ✅ | visual | ✅ | ✅ |
| **tau** | – | ✅PET | ✅PET+plasma | ✅PET | – | – | – |
| **plasma pTau217** | `[VERIFY]` | – | ✅ | – | – | – | – |
| **CSF** | 일부(74) | flag | – | flag | – | labs | – |
| MMSE | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| MoCA | – | ✅ | – | ✅ | – | – | – |
| CDR | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 신경심리 배터리 | – | – | PACC | UDS | **SNSB** | neurobat | CERAD/SNSB |
| WMH/Fazekas | – | – | ✅QC | ✅ | – | – | ✅ |
| scanner 모델 | ✅ | ✅ | – | ✅ | – | ✅ | ✅ |
| 종단(다중 visit) | ✅ | ✅ | ✅ | ✅ | ✅(V2 291) | ✅(m18~m72) | ❌ |

---

## 5. manifest 누락/주의 (raw↔manifest 격차)

1. **`raw_*_path`는 디스크 실보유를 과소표현** — AJU PET 1,020·CT 711, ADNI PET 1,537, OASIS PET 412 등이 manifest엔 미반영(`raw_pet_path`=0). 멀티모달은 manifest 파이프라인(T1 only)에 미포함.
2. **AIBL APOE**: raw 862명 보유하나 manifest `clin_apoe`=0% → 보강 가능.
3. **ADNI amyloid**: manifest에 없음 → `UCBERKELEY_AMY` 외부조인 필요(검증 1,203).
4. **NACC raw 영상 부재**: 디스크에 원본 MRI 1명뿐. manifest T1 1,866은 별도 처리분(원본 미보존) → 재처리 불가, 텐서만 사용.
5. **A4는 amyloid-positive subset만 manifest 등재(1,811)**; raw엔 LEARN(음성)·SF 포함 ~1,787 subj 영상 + 6,945 임상.

---

## 6. ⭐ 최종 사용 데이터 결정 (2층위)

### Tier 1 — 즉시 사용 (canonical manifest, 전처리 완료)
- **T1w 전처리 텐서** (192×224×192 RAS 1mm z-score, N4+비N4) — **7코호트 13,022세션 100%**.
- **morphometry** 26 fs_vol(ICV-proxy) — 100%.
- **파생 임상**: 진단·age·sex·MMSE·CDR·APOE (코호트별 커버리지: `MANIFEST_AND_DATA_PATHS.md` §clinical).
- **amyloid 파생값**: manifest 내부 5,516세션(A4·OASIS·NACC·AJU·KDRC) + ADNI 외부조인 1,203.
- 경로/141열 사전 = `MANIFEST_AND_DATA_PATHS.md`.

### Tier 2 — 추가 가용 (raw 보유, 전처리 필요)
| 추가 자산 | 보유 코호트 | 비용/주의 |
|---|---|---|
| **amyloid PET 원본 이미지** | ADNI 1,537·AJU 1,020·OASIS 412·KDRC 946 | DICOM/NIfTI→정합·SUVR 파이프라인 필요. KDRC는 NIfTI라 가장 저렴 |
| **FLAIR/WMH** | A4·OASIS·AJU·KDRC | WMH 정량 가능 |
| **DWI/DTI** | A4·OASIS·AJU·KDRC | 확산지표 |
| **SWI** | AJU·AIBL·OASIS | 미세출혈 |
| **tau PET** | OASIS(AV1451)·NACC/A4(파생) | OASIS만 원본이미지 |
| **plasma pTau217** | A4 | 혈액 바이오마커(테이블만) |
| **lifelog actigraphy** | AJU 350명 | 활동/수면 시계열(독특) |
| **CT** | AJU 711 | 비전형 |
| AIBL APOE 보강 | AIBL | manifest 누락분 채우기(저비용) |

> ⚠️ Tier 2는 **횡단 intersection이 작고**(코호트마다 보유 모달리티 상이) 전처리 비용이 큼. 단일 코호트
> (특히 멀티모달 최다 = **AJU/KDRC**) 내 활용이 현실적. **NACC 영상은 재처리 불가**(원본 부재).

---

## 7. 검증 로그 (generation ≠ verification)

- **1차 생성**: 컨소시엄별 read-only 디스크 조사 7건 병렬(Explore agent). 각 모달리티/임상 카운트 + 사용 명령어 보고.
- **2차 독립 재검증(내가 직접 재실행)**:
  - ADNI: PET subj **1,537**, tracer 전량 **AV45(amyloid)** — 에이전트의 "FBP=tau" **오분류 정정**(tau PET 없음, UCBERKELEY_TAU 부재).
  - AJU: PET **1,020**(prune), 3D_T1 **1,293**, unique subj **1,161**, V2 **291**, lifelog **350**.
  - A4: `ImageData` PET 이미지 **0**, `biomarker_pTau217.csv`·`imaging_SUVR_tau.csv` 존재 확인.
  - OASIS: tau AV1451 PUP **437 rec**, centiloid **1,893 rec**.
  - KDRC: T1 **944**/FLAIR **946**/PET **946**/T2 830/DTI 693, 종단 **0**.
  - AIBL: zip내 subj **692**.
- **manifest 측**: parquet 직접 inspect(13,022×141), raw/amyloid 합계 기존 docs와 일치.
- **미확정 `[VERIFY]`**: AIBL raw PET 원본이미지 존재 여부 · AJU tau PET · ADNI plasma pTau217 · OASIS Braak 출처(PET/autopsy).

> 관련 문서: `MANIFEST_AND_DATA_PATHS.md`(경로·141열 사전), `DATA_INVENTORY.md`, `SCANNER_DISTRIBUTION.md`.
