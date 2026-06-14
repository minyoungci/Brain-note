# Scanner 분포 — 컨소시엄별 (model-level)

_2026-06-14. `roi_qc/scripts/extract_scanner_model.py` → `roi_qc/reports/acq_scanner_model.{parquet,csv}` (per-session). manifest 미수정._


## 1. 커버리지 & 소스

| 코호트 | n | model 복구 | vendor | 소스 |
|---|---|---|---|---|
| A4 | 1811 | 0 (0%) | 1811 (100%) | BIDS json — Manufacturer only (vendor) |
| ADNI | 4742 | 4739 (100%) | 4739 (100%) | DICOM 0008,1090 (raw/ADNI/ADNI_3_4_T1w) |
| AIBL | 987 | 987 (100%) | 987 (100%) | experiment_manifest_v7 (model in source) |
| AJU | 1287 | 1241 (96%) | 1241 (96%) | DICOM raw/AJU/*/*/{subj}/{visit}/MRI/3D_T1 |
| KDRC | 909 | 831 (91%) | 831 (91%) | clinical xlsx ×4 merged (codebook-coded) |
| NACC | 1866 | 1592 (85%) | 1592 (85%) | DICOM in per-scan zip (raw/NACC/MRI) |
| OASIS | 1420 | 0 (0%) | 1419 (100%) | NIfTI anonymized — vendor only |

## 2. Vendor 분포

| 코호트 | SIEMENS | GE | PHILIPS | 미상 |
|---|---|---|---|---|
| A4 | 1175 (65%) | 442 (24%) | 194 (11%) | 0 (0%) |
| ADNI | 2791 (59%) | 1132 (24%) | 815 (17%) | 4 (0%) |
| AIBL | 987 (100%) | — | — | 0 (0%) |
| AJU | 35 (3%) | 1038 (81%) | 168 (13%) | 46 (4%) |
| KDRC | 130 (14%) | 47 (5%) | 654 (72%) | 78 (9%) |
| NACC | 1148 (62%) | 357 (19%) | 87 (5%) | 274 (15%) |
| OASIS | 1419 (100%) | — | — | 1 (0%) |

## 3. Model-family 분포 (복구된 코호트)


**ADNI** (model 4739/4742):  Siemens Prisma 1340(28%) · GE Discovery MR750 766(16%) · Siemens TrioTim 654(14%) · Siemens Skyra 496(10%) · Philips Achieva 446(9%) · GE SIGNA/other 367(8%) · Siemens Verio 258(5%) · Philips Ingenia 227(5%) · Philips Intera 107(2%)

**NACC** (model 1592/1866):  Siemens Prisma 574(31%) · Siemens Skyra 279(15%) · Siemens Biograph(PET/MR) 243(13%) · GE SIGNA/other 200(11%) · GE Discovery MR750 125(7%) · Philips Achieva 40(2%) · Philips Ingenia 36(2%) · Siemens TrioTim 34(2%) · GE SIGNA PET/MR 32(2%)

**AJU** (model 1241/1287):  GE Discovery MR750 964(75%) · Philips Achieva 145(11%) · GE SIGNA/other 74(6%) · Siemens TrioTim 33(3%) · Philips Ingenia 21(2%)

**AIBL** (model 987/987):  Siemens TrioTim 793(80%) · Siemens Verio 194(20%)

**KDRC** (model 831/909):  Philips Ingenia 522(57%) · Philips Achieva 132(15%) · Siemens Skyra 130(14%) · GE SIGNA/other 47(5%)

_A4·OASIS: 소스에 모델명 없음(A4 json=제조사만, OASIS NIfTI 익명화) → vendor-level이 한계._


## 4. 핵심 발견 & caveat

- **KDRC 임상파일 4개 분산**: 원본 `KDRC*.zip` 안 중첩 `데이터분양_데이터통합_*.xlsx` 3개 + `clinical.xlsx`. 기존 파이프라인은 1개만 사용(scanner 456) → 4개 병합 시 **831/909(91%)**, 충돌 0. 코드맵(1=Achieva·2=Ingenia·3=Skyra·4=GE)은 `MCD 설명` row96 검증.

- **DICOM이 manifest vendor를 정정**: KDRC PHILIPS 38→72%, AJU PHILIPS 3→13% (manifest acq_scanner는 부정확/저커버였음).

- **vendor=코호트 지문(site 교란)**: AIBL 100% Siemens(2모델), OASIS 100% Siemens, AJU 75% GE Discovery MR750, KDRC 72% Philips. ADNI/NACC만 다벤더·다모델로 혼재. leave-one-consortium-out + 잔차 site 점검 권장.

- **데이터 품질 소수 이상치**: ADNI Manufacturer 'MPTronic software' 1건(잡음 문자열), 희귀 모델 Allegra(10)/Gemini(11)/Ingenuity(1).

- **field strength**: 거의 전부 3.0T(OASIS 1.5T 19, AJU 1.5T 3). 변별 축 아님.
