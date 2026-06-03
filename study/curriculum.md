# study · 학습 커리큘럼

> **목적:** 이 연구 프로그램을 처음부터 이해하기 위한 학습 순서  ·  **출처:** 본 허브 knowledge/insights + 각 워크스페이스 원본  ·  **갱신:** 2026-06-02

## 학습 순서 (의존성대로)

### STEP 0 — 전체 지도 (30분)
1. `../DASHBOARD.md` — 5개 워크스페이스의 역할을 한 화면으로 파악.
2. `../insights/MUST_KNOW.md` — 핵심 교훈 우선 숙지.

### STEP 1 — 데이터 (가장 먼저, 모든 연구의 토대)
1. `../knowledge/00_data_manifest.md` 정독 → 이어서 `../knowledge/data/README.md`(세밀 확장: 코호트별 카드·ROI·ComBat·표현학습 난점).
2. 직접 확인: official_manifest를 열어 코호트표·`cdr_global` 타입·결측 컬럼을 **손으로** 재현.
   - 체크: `cdr_global`을 `to_numeric` 없이 정렬하면 어떻게 깨지나?
   - 체크: NACC에만 있는 컬럼, ADNI에 없는 컬럼을 직접 세어보기.
3. minyoungi `Clinical/notebooks/00~04` ipynb를 읽고(가능하면 실행) 데이터 함정을 체감.

### STEP 2 — 평가 프로토콜 (이 프로그램의 척추)
1. `../knowledge/01_loco_transport.md` 정독: nuisance battery / incremental value / LOCO.
2. minyoung2 `reports/EXP01_OVERVIEW.md` 원본 읽기.
3. 코드 읽기: `scripts/build_exp01_cdr_split.py`(LOCO split), `exp01_incremental_value.py`(paired bootstrap),
   `exp01_regional_volume_baseline.py`(F9 부피 bar).
   - 체크: LOCO에서 held-out 코호트의 site 메타데이터가 왜 near-chance가 정상인가?
   - 체크: 부피 baseline이 왜 단순 전뇌부피보다 센 bar인가?

### STEP 3 — 두 확장 축 (병렬)
- **ROI-evidence → 해부학 QA/VQA 생성** (minyoung3): `workspaces/02_minyoung3/README.md` + `reports/F04_VQA_*`·`F04_ROI_NORMATIVE_*`.
  (2.5D MAE SSL은 폐기 — 개념은 `../knowledge/02_ssl_mae_2p5d.md` 참고용으로만)
  - 체크: ROI evidence R²(ventricle 강·hippo 약)가 QA 라벨 신뢰도에 어떤 상한을 거나? 왜 진단이 아니라 'anatomical evidence'인가?
- **종단 예측**: `../knowledge/03_longitudinal.md` → plant prereg(`docs/plans/2026-06-01-...prereg.md`).
  - 체크: 왜 NACC를 종단에서 빼야 하나? converter 270개로 LOCO가 가능한가?

### STEP 4 — 비판적 종합
- `../insights/MUST_KNOW.md`의 `[VERIFY]` 목록을 하나씩 추적: 미해결 항목 식별.
- 각 워크스페이스 `risks.md`를 reviewer 2 관점에서 검토: 가장 취약한 지점 도출.

## 외부 배경지식 (필요 시 보강 — 본 허브 범위 밖)

> 아래는 도메인 기본기. 정확한 인용·DOI는 minyoungi `literature/` index에서 확인하고,
> 미검증 항목은 [VERIFY] 처리할 것 (웹 검증 전엔 단정 금지).

- **CDR / CDR-SB**: 치매 임상 척도(Clinical Dementia Rating). 0=정상, 0.5=questionable, ≥1=치매.
- **FreeSurfer / FastSurfer 부피측정**: aseg ROI(hippocampus, ventricle 등) 자동 분할. 위축이 신호.
- **MAE (He et al. 2022)**, **ViT (Dosovitskiy et al. 2021)**: SSL 표현학습 백본 기초.
- **domain generalization / group-DRO (Sagawa et al. 2020)**: cross-site transport 이론.
- **생존분석 / Cox PH**: 희소 양성(converter) 종단 예측에 유리한 프레이밍.

## 학습 원칙 (CLAUDE.md 계승)

- **생성 ≠ 검증.** 읽고 "이해했다"가 아니라, 코드를 돌리거나 수치를 재현해 확인.
- **출처를 의심하라.** 이 허브는 2차 자료다. 결론이 중요하면 원본 report/코드로 내려가라.
- **음성을 두려워 말라.** 이 프로그램은 "안 된다"를 정직하게 측정하는 게 기여다.
