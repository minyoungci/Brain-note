# Multimodal Preprocessing Pipeline

T1w 외 공통 모달리티(**FLAIR · T2 · amyloid PET**)를 기존 official T1w 격자에
정렬해 멀티모달 학습 입력으로 만드는 **모달리티별 전용 전처리 scaffold**.

> ⚠️ **실행 안전**: 기본 dry-run. 외부 도구(dcm2niix/N4/FLIRT)는 `--execute`로만 실행.
> raw(`/home/vlm/data/raw`)는 read-only, write는 `preprocessed_official/v2`만.
> GPU/대량 실행은 CLAUDE.md상 **사전승인 대상** — 이 scaffold는 코드·계획까지만.

## 왜 이렇게 설계했나 (선행연구 = 우리 official 파이프라인 + top-tier 문헌)

- **단일 transform chain**: 보조 모달리티를 final cropped tensor가 아니라 **1mm-RAS T1w
  reference grid에 등록** → 동일 crop/pad(T1w brain centroid) 적용. 보간은 **한 번만**.
  (official note §7.2; petBrain; Greve & Fischl 2009 BBR)
- **T1w mask 전파**: 보조 모달리티의 brain mask를 재추출하지 않고 T1w에서 전파 → 모달리티 간 일관성.
- **PET는 SUVR**: raw PET intensity는 dose/scanner 의존 → 순수 site 신호라 **금지**. whole-cerebellum
  reference SUVR(Centiloid 표준, Klunk 2015), PVC 기본 off(Schwarz 2019).
- **T2 anisotropy 정직**: 2D 4–6.5mm를 등방으로 **날조 금지**. native 보존 + 등방격자는 flag.
- **N4는 모달리티별 독립**, spatial QC(overlap/centroid), PASS/WARN/FAIL 게이트.

근거 전문: [`docs/PRIOR_RESEARCH.md`](docs/PRIOR_RESEARCH.md) · 정합 원리: [`docs/TRANSFORM_CHAIN.md`](docs/TRANSFORM_CHAIN.md)

## 구조

```
preprocessing/
  ── dicom_to_nifti/        DICOM → NIfTI (AJU · ADNI · NACC)
  │     aju.py              AJU: 3D_T1 / T2_FLAIR / T2_FSE / DTI / PET
  │     adni.py             ADNI: T1w (adni_t1w_dicom_list.csv 기반)
  │     nacc.py             NACC: zip unpack → dcm2niix
  │     README.md
  │
  ── raw_manifest/          raw_*_path 컬럼을 manifest에 부착
  │     build.py            전체 실행 스크립트 (--dry-run / --verify)
  │     resolvers/
  │       aju.py · adni.py · nacc.py  (conversion 후 경로 조회)
  │       kdrc.py · a4.py · oasis.py · aibl.py  (이미 NIfTI)
  │     README.md
  │
  ── shared/     paths · nifti_io · transform_chain · external · qc · pet_suvr · config
  ── configs/    flair.yaml · t2.yaml · pet_amyloid.yaml
  ── modalities/ base.py + flair/ t2/ pet_amyloid/  (각 pipeline.py = 전용 driver)
  ── docs/       PRIOR_RESEARCH.md · TRANSFORM_CHAIN.md
  ── tests/      test_transform_chain.py · test_qc_and_safety.py
  run_inventory.py
```

## raw_*_path 컬럼 구축 순서

```bash
# 1) DICOM → NIfTI (대량 배치, 사전승인 필요)
uv run python -m preprocessing.dicom_to_nifti.aju   # AJU
uv run python -m preprocessing.dicom_to_nifti.adni  # ADNI
uv run python -m preprocessing.dicom_to_nifti.nacc  # NACC

# 2) 경로 확인 (dry-run, manifest 저장 안 함)
uv run python -m preprocessing.raw_manifest.build --dry-run

# 3) manifest 업데이트 + 경로 존재 검증
uv run python -m preprocessing.raw_manifest.build --verify
```

## 모달리티별 전처리 사용 순서 (보수적)

```bash
# 0) 환경/도구 확인 (실행 안 함)
uv run python -c "from preprocessing.shared import external; print(external.check_tools())"

# 1) readiness 인벤토리 — raw/T1w-ref/입력QC/게이트 집계 (read-only, GPU 불필요)
uv run python -m preprocessing.run_inventory --modalities flair t2 pet_amyloid --limit 20

# 2) 단일 row 계획(plan) 출력 — dry-run
uv run python -m preprocessing.modalities.flair.pipeline AJU ABD-AJ-0001 V1

# 3) (승인 후) smoke 실행 — 외부 도구 실제 호출
uv run python -m preprocessing.modalities.flair.pipeline AJU ABD-AJ-0001 V1 --execute
```

## 게이트 의미

| gate | 뜻 |
|---|---|
| `READY` | raw + T1w reference + 입력QC 통과 → 실행 가능 |
| `BLOCKED_NO_T1W` | T1w native HD-BET brain/mask 부재 → 정합 기준 없음 |
| `BLOCKED_NO_RAW` | 해당 모달리티 raw 없음 |
| `FAIL_INPUT` | raw 로드/차원 실패 |

## 알려진 선결조건 / 위험

1. **T1w native HD-BET brain+mask 필요** — transform chain의 1mm-RAS reference를 결정적으로 재구성하는 입력. v2 출력에 이 파일이 있어야 함(없으면 `BLOCKED_NO_T1W`). → inventory로 먼저 커버리지 확인.
2. **트레이서 혼재** — AJU/KDRC amyloid PET 트레이서가 다르면 Centiloid 변환식이 달라짐. 확인 전 SUVR까지만, Centiloid 변환 보류([VERIFY]).
3. **FastSurfer seg 필요(PET)** — SUVR reference region(소뇌)용. 없으면 SUVR 단계 BLOCKED.
4. **T2 한계 기여** — AD 비핵심 + AJU 커버리지 절반. ablation으로 증명 전 학습 투입 보류 권장.
5. **다기관 harmonization** — FLAIR/T2/PET 대비는 T1w보다 site 의존 큼. LOCO/dual-probe 검증 필수.
