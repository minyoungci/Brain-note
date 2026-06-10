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

| Track | 주제 | 상태 | gate |
|---|---|---|---|
| **[01](01_adlip_multimodal_vlm/)** ⭐현재 | ADLIP식 multimodal contrastive VLM | 데이터 준비완료, 설계 단계 | confound 통제·ΔAUC·cohort-balanced |
| **[02](02_crosspop_confound_audit/)** | cross-population confound audit | 증거 일부 수집됨 | 식별성·dual-probe |
| **[03](03_single_modality_tasks/)** | 단일모달 clean task (amyloid·atrophy) | 일부 실측 | within-modality, harmonize |
| **[04](04_vascular_vs_degenerative/)** | 혈관성 vs 퇴행성 (혈액 활용처) | 미착수 | AJU 단독 |

진행 순서: **01 먼저** (사용자 결정). 01은 02의 증거 substrate로도 직결된다.
