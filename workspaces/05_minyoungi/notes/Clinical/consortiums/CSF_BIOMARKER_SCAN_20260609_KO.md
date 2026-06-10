# CSF 바이오마커(Aβ42 / p-tau / t-tau) 전 컨소시엄 스캔 (2026-06-09)

7개 컨소시엄 raw clinical 파일 전수를 CSF 패턴(`csf, abeta, ab42, ptau, ttau, elecsys,
fujirebio, lumipulse, upennbiomk`)으로 헤더 스캔하고, PET/MRI 부피 오탐을 맥락으로 배제한 결과.

## 결론 (한 줄)

**어느 컨소시엄도 로컬 raw에 사용 가능한 연속 CSF 농도값(pg/mL)이 없다.** NACC·OASIS는
*가용성 지표(0/1)*만, ADNI는 풍부한 CSF가 있으나 **미다운로드**.

## 컨소시엄별

| 컨소시엄 | CSF 발견 | 정체 | 판정 |
|---|---|---|---|
| **NACC** | `AMYLCSF, CSFTAU, NACCACSF, NACCPCSF, NACCTCSF, NACCCSFP` (commercial_nacc70.csv) | UDS 폼 **가용성/이상여부 지표(0/1)**, 농도값 아님. NACCACSF=1은 12,945 visit-row(전체 178k 중) | 지표만 |
| **OASIS** | `amylcsf, csftau` (OASIS3_UDSd1_diagnoses.csv) | NACC UDS-D1 동일 지표(OASIS-3는 UDS 폼 사용) | 지표만 |
| **ADNI** | (로컬엔 `CSF_SUVR/CSF_VOLUME` = PET 기준영역만) | 실제 CSF(UPENNBIOMK Elecsys Aβ42/pTau/tTau)는 **LONI 별도, 미다운로드** | 로컬 없음 |
| **A4** | `PVC_CSF, NumVoxels_CSF, Mean.CSF` (Tau PET PetSurfer/Stanford) | PET 부분용적보정 CSF 구획. **plasma pTau217·Roche plasma 보유**(CSF 아님) | 없음(plasma만) |
| **AIBL** | 0 | 2018 meta dump에 CSF 파일 없음(PET/labdata만) | 없음 |
| **AJU** | `csf`(BL col71) | = **`천식 가족력`**(asthma family hx)의 우연한 약어. amyloid는 PET read만 | 없음 |
| **KDRC** | `아밀로이드 PET 촬영 금기`만 | amyloid PET SUVR/visual 보유, CSF 없음 | 없음 |

## 오탐 주의 (CSF처럼 보이나 아님)
- `CSF_SUVR` / `CSF_VOLUME` (ADNI·NACC PET) = PET 기준영역/부피.
- `PVC_CSF` / `Mean.CSF` / `NumVoxels_CSF` (A4 Tau PET) = 부분용적보정 CSF 구획.
- `FRONTCSF/OCCIPCSF/PARCSF/TEMPCSF/CSFVOL/CERECSF` (NACC MRI) = MRI CSF 부피.
- `NPTAU/NPTAUHAP` (NACC) = **neuropathology** p-tau(부검), CSF 아님.

## 대안 (amyloid 축은 PET/plasma로 존재 — manifest 반영됨/가능)
- **KDRC**: `kdrc_amyloid_suvr` + `kdrc_amyloid_visual` (PET) — real_final 반영됨.
- **AJU**: `aju_amyloid` (PET read; 1=정상→neg / 2=비정상→pos) — real_final 반영됨.
- **OASIS**: amyloid PET centiloid(`OASIS3_amyloid_centiloid.csv`) → **real_final 반영됨**(`oasis_amyloid_centiloid`+positive(CL≥20)+tracer, 1048세션). 또 UDS-b4로 **MMSE 29%→100%·CDRSUM** 보강.
- **ADNI**: amyloid PET(`UCBERKELEY_AMY`) — 미반영(후보).
- **A4**: plasma pTau217 (`biomarker_pTau217.csv`) — CSF 대용 plasma 축 후보.

## ⚠️ ADNI CSF처럼 보이나 AD triad 아님 (2026-06-09 추가 확인, manifest 미반영)
사용자 제공 2파일을 확인했으나 **둘 다 Aβ42/p-tau/t-tau 아님** → real_final 미반영(그대로 둠):
- `ADNI/LOCLAB_08Jun2026.csv`: **CSF 루틴화학**(단백 median 43mg/dL·당 58·백혈구·적혈구). overlap 1385/1580명이나 값 nonnull 38%·결측코드(-1/9999). AD 특이 아님.
- `ADNI/UBristol_CSFSER_ELISA_08Jun2026.csv`: **BBB/혈관 마커**(sPDGFRβ·Qalb·ANGPT2·PLGF, CSF+serum). **74명만**(ADNI 1.6%). AD triad 아님.
- 진짜 ADNI AD-CSF는 여전히 **`UPENNBIOMK*`(Roche Elecsys)** 미download. 위 둘로는 불가.

## CSF를 원하면 (실행 경로)
1. **ADNI**: LONI IDA에서 `UPENNBIOMK*` (Elecsys) 다운로드 → PTID+검사일 nearest-join (ADNI MMSE와 동일 방식). 가장 풍부.
2. **NACC/OASIS**: 별도 NACC 'fluid biomarker' 투자자 데이터셋 신청 시 연속값 확보 가능(현 UDS엔 지표만).

## 재현
```bash
# 헤더 CSF 패턴 스캔 (NACC/A4/AIBL/ADNI) + KDRC/AJU/OASIS 키워드
# roi_qc/scripts 에 1회성 스캔 코드, 본 문서가 그 산출물.
```
