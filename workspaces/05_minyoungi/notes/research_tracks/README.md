# Research Tracks — Korean Multimodal Brain Data

한국 코호트(AJU·KDRC) 멀티모달 데이터로 진행하는 **병렬 연구 track**. 각 track은
독립 진행 가능하되, 아래 **검증된 공통 발견**을 전제로 한다(재논쟁 금지).

데이터 정본: `Clinical/consortiums/Korean/korean_multimodal_manifest.parquet`
(영상 T1w+FLAIR+PET SUVR 경로 + 임상 + ROI), `korean_vlm_pairs.parquet`(VLM 페어
1,408 train_ready), `korean_clinical_text.parquet`(임상 텍스트 3변형).
적부 근거: `../research_topic/` dossier.

---

## ⚠️ 공통 전제 — 측정으로 확정된 사실 (2026-06-10)

모든 track은 이 제약 위에서 설계한다. 어기는 주제는 죽은 주제다.

| 발견 | 수치 | 함의 |
|---|---|---|
| **코호트=population confound** | 텍스트→코호트 AUC 0.999, 영상(fs_vol)→0.747 | cross-population *정확도* 주장 식별불가(traveling subj 0) |
| **영상은 amyloid에 무용** | 구조 ROI ΔAUC over 임상 = **+0.008/+0.018** | "영상이 amyloid 본다" 불가 → ΔAUC만 |
| **영상은 치매/위축에 강함** | 비인지임상 위 ROI ΔAUC = **+0.133/+0.053** | 형태계측=위축 직접측정. 단 텍스트 MMSE와 중복 |
| **혈액은 거의 무용(AD)** | ROI+임상 위 혈액 ΔAUC ≈ **±0.002** | 일반건강지표≠AD마커. 가치는 혈관성(T4) |
| **amyloid PET 영상은 깨끗** | SUVR→visual AUC AJU 0.97 | 단일모달 task는 confound 없이 유효 |

> 핵심: "풍부한 데이터 다 넣으면 더 좋은 VLM"(정확도 SOTA)은 dossier가 죽인 방향이고
> 측정이 재확인했다. 살아있는 건 **audit + 단일모달 clean task + 혈관성**이다.

---

## Track 맵

> ⚠️ **피벗 반영(2026-06-14)**: 현재 확정 전략은 단일 플래그십 `../research_topic/04_sci_clinical_pivot.md`
> (서구→한국 횡단 transportability & fairness). 정확도 SOTA/VLM 라인은 종료 → **Track 01(ADLIP VLM)·
> Track 04(혈관성, 미착수)는 제거**. 아래 02·03은 피벗 플래그십의 **audit/baseline 구성요소**로 존속.

| Track | 주제 | 상태 | 역할(피벗 후) |
|---|---|---|---|
| **[02](02_crosspop_confound_audit/)** | cross-population confound audit | 증거 일부 수집됨 | 플래그십 fairness/calibration audit의 상류 근거 |
| **[03](03_single_modality_tasks/)** | 단일모달 clean task (amyloid·atrophy) | 일부 실측 | 플래그십 정직-baseline(영상 천장·amyloid clean task) |

(구 Track 01/04 README는 죽은 라인으로 삭제됨. 멀티모달 raw 보유 현황은 `../docs/MANIFEST_FINAL_DATA_SPEC.md`.)
