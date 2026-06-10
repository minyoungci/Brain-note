# Representation Learning Next Experiment Plan

작성일: 2026-05-22  
워크스페이스: `/home/vlm/minyoungi`  
상태: 실험 계획 + 돌입 가능성 점검 문서

## 0. 결론: 바로 돌입 가능한가?

부분적으로 가능하다.

```text
GO now:
  E1. 현재 flatpool encoder 재평가: CN/AD binary, disease-axis, MCI projection, age probe, cohort probe
  E2. Teacher-S vs Teacher-B same flatpool 80/class 비교 + cohort/axis probe
  E3. 100-region DKT volume teacher 확장 smoke: FastSurfer aseg+DKT.VINN.stats 기반
  E4. 3D-Neuro-SimCLR repository/weight integration feasibility check

NOT ready without extra setup:
  true cortical thickness teacher: 현재 sample FastSurfer output에는 surface/thickness stats가 없음
  BrainFound baseline: paper 확인됨, code/weight 위치는 별도 확인 필요
  large SSL pretraining: Min 승인 전 long/GPU job 금지
```

현재 가장 먼저 할 일은 **새 대형 모델 학습이 아니라, 현재 encoder와 외부 SSL baseline을 같은 평가축으로 비교하는 짧은 diagnostic**이다.

---

## 1. Readiness check 결과

### 1.1 Workspace / git

```text
pwd = /home/vlm/minyoungi
branch = main
```

주의:

```text
working tree에 기존 untracked/modified 파일이 많음.
현재 실험 산출물은 experiments/ 및 notes/context/에 이미 untracked로 존재.
commit/push는 Min 요청 전 하지 않음.
```

### 1.2 GPU 상태

점검 시점:

```text
GPU0: B200, 956 MiB / 183359 MiB, util 0%
GPU1: B200, 956 MiB / 183359 MiB, util 0%
GPU2: B200, 1136 MiB / 183359 MiB, util 1%
GPU3: B200, 4 MiB / 183359 MiB, util 0%
GPU4: B200, 4 MiB / 183359 MiB, util 0%
GPU5: B200, 24590 MiB / 183359 MiB, util 0%
GPU6: B200, 58784 MiB / 183359 MiB, util 1%
GPU7: B200, 50094 MiB / 183359 MiB, util 94%
```

판정:

```text
short diagnostic는 GPU0-4 중 하나로 가능.
GPU7은 사용 중으로 보이므로 피한다.
```

### 1.3 System resource

```text
RAM: 2.2 TiB total, 243 GiB used, 1.9 TiB available
Disk: /home/vlm 15T total, 11T used, 4.7T available, 69%
```

판정:

```text
image-cache diagnostic 가능.
large external model/weights download도 disk 관점에서는 가능.
```

### 1.4 Python dependency

```text
torch OK
nibabel OK
numpy OK
pandas OK
sklearn OK
scipy OK
```

### 1.5 Data readiness

Canonical manifest:

```text
/home/vlm/minyoungi/manifests/v2_integrated/canonical/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv
```

Ready rows:

```text
CN/MCI/AD classifiable image-ready rows = 11,199
cohorts:
  ADNI  4,849
  OASIS 1,609
  NACC  1,592
  AJU   1,241
  AIBL    988
  KDRC    920
```

Sample final tensor exists:

```text
/home/vlm/data/preprocessed_official/v2/ADNI/subjects/002_S_0413/20061115.0/t1w/final_tensor/t1w_brain_1mm_RAS_192x224x192_zscore.nii.gz
```

ROI CSV:

```text
/home/vlm/minyoungi/manifests/v2_integrated/captions/roi_v0/roi_captions_v0.csv
rows = 179,184
```

### 1.6 Existing result artifacts

Confirmed:

```text
/home/vlm/minyoungi/notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md
/home/vlm/minyoungi/notes/context/REPRESENTATION_LEARNING_ROOT_CAUSE_PLAN.md
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/run_flatpool_80class_latest.py
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_FLATPOOL_80CLASS_LATEST.json
```

---

## 2. Current hypothesis

현재 병목은 다음으로 정의한다.

```text
Primary bottleneck:
  supervision information bottleneck
  = 16-dim ROI-volume scalar teacher가 너무 약함

Secondary bottleneck:
  evaluation target mismatch
  = CN/MCI/AD hard 3-class가 representation quality를 noisy하게 측정함

Blocked route:
  voxel-wise ROI supervision
  = final_tensor-space affine-only ROI resampling 실패
```

이미 해결된 항목:

```text
label/CE plumbing
image tensor path
tiny overfit failure
GAP/lr collapse
flatpool diagnostic student
```

---

## 3. Phase 1: 1–2주 diagnostic plan

### E1. 현재 flatpool encoder 재평가

목적:

```text
현재 3-class frozen bal_acc ≈0.48이 진짜 representation failure인지,
MCI hard-class noise 때문에 묻힌 것인지 분리한다.
```

입력:

```text
existing flatpool script/result
same 80/class sample policy
final_tensor T1w images
```

평가:

```text
1. CN vs AD binary frozen probe
2. CN→AD disease-axis score
3. MCI projection on CN→AD axis
4. cohort probe from frozen embeddings
5. age prediction probe / MAE
```

성공 기준:

```text
CN vs AD bal_acc >= 0.65
MCI projection median between CN and AD
cohort probe not dominant
age MAE meaningfully below naive baseline
```

판정:

```text
좋으면: 3-class metric이 과도하게 noisy했던 것.
나쁘면: representation 자체가 약한 것.
```

즉시 돌입 가능성:

```text
GO. 새 데이터 필요 없음. 짧은 GPU/CPU diagnostic.
```

---

### E2. Teacher-S vs Teacher-B same flatpool 80/class 비교

목적:

```text
signal-preserving teacher와 bias-reduced teacher를 같은 student/eval protocol로 비교한다.
```

Teacher naming:

```text
Teacher-S = CN-only age/sex residual z ROI teacher
Teacher-B = ComBat cohort, age+sex preserved + CN-only residual z ROI teacher
```

평가:

```text
frozen internal_test bal_acc/macro_f1
CN/MCI/AD recall
CN vs AD binary
cohort probe
MCI projection
```

성공 기준:

```text
Teacher-B가 cohort probe를 낮추면서 diagnosis/axis signal을 크게 잃지 않으면 Teacher-B 우선.
Teacher-S가 확실히 더 강하면 Teacher-S는 main signal, Teacher-B는 bias audit/regularizer.
둘 다 <=0.50이면 ROI-volume teacher route 약함 확정.
```

즉시 돌입 가능성:

```text
MOSTLY GO. 기존 T1/T2 코드가 있으나 명명 정리 및 axis/cohort probe 추가 필요.
```

---

### E3. 100-region DKT volume teacher 확장 smoke

목적:

```text
16-dim ROI teacher의 정보량 병목을 직접 테스트한다.
```

중요 보정:

```text
현재 sample FastSurfer output에는 true cortical thickness/surface stats가 보이지 않음.
하지만 aseg+DKT.VINN.stats에는 DKT cortical/subcortical region Volume_mm3가 있음.
따라서 즉시 가능한 것은 cortical thickness가 아니라 DKT volume expansion이다.
```

입력:

```text
fastsurfer/*/stats/aseg+DKT.VINN.stats
Volume_mm3 columns for ~100 structures
```

평가:

```text
Teacher-DKT-Vol: 100-ish DKT/subcortical volume features
age/sex residual z
optional cohort ComBat branch
flatpool teacher-latent distillation
frozen probes same as E1
```

성공 기준:

```text
frozen internal_test bal_acc >= 0.55
or CN vs AD bal_acc >= 0.70
```

판정:

```text
개선되면: teacher information bottleneck 확정.
개선 안 되면: scalar anatomical teacher route 자체가 약함.
```

즉시 돌입 가능성:

```text
GO for DKT volumes.
NOT GO for true cortical thickness unless surface outputs or new FastSurfer recon-all/surface pipeline is available/approved.
```

---

### E4. External SSL pretrained frozen baseline

목적:

```text
ROI distillation을 우회한 외부 representation baseline을 만든다.
```

확인된 후보:

```text
3D-Neuro-SimCLR:
  repository reachable: https://github.com/emilykaczmarek/3D-Neuro-SimCLR.git
  git HEAD reachable: e061f3a19d20755d45361cb206b0803a6de804ff

BrainFound:
  paper exists: arXiv 2510.23415
  code/weights location still needs confirmation
```

평가:

```text
frozen encoder + linear/logistic probe
CN/MCI/AD secondary
CN vs AD primary
MCI projection
age probe
cohort probe
```

성공 기준:

```text
external SSL CN/MCI/AD frozen bal_acc >= 0.55
or CN vs AD bal_acc >= 0.70
```

판정:

```text
외부 SSL이 이기면: ROI-volume distillation main route 중단, SSL/foundation adaptation으로 이동.
외부 SSL도 비슷하면: data/evaluation/label/preprocessing issue 가능성 증가.
```

즉시 돌입 가능성:

```text
PARTIAL GO.
Repository 접근은 가능.
하지만 clone/weights download/import는 추가 확인 필요.
외부 source tree/weight를 어디에 둘지 정해야 함.
추천 위치: /home/vlm/minyoungi/experiments/external_ssl_baselines/ 또는 /home/vlm/models/
```

---

## 4. Go / No-Go summary

```text
Immediate GO:
  E1 current flatpool reevaluation
  E2 Teacher-S vs Teacher-B flatpool comparison update
  E3 DKT volume teacher expansion smoke

Needs setup:
  E4 3D-Neuro-SimCLR clone + weights + input adapter

Not now:
  large SSL pretraining
  true cortical thickness teacher unless surface outputs are available
  voxel-wise ROI mask supervision
  VLM scaling
```

---

## 5. Recommended execution order

가장 안전한 순서:

```text
Step 1. E1: current flatpool reevaluation script
Step 2. E2: Teacher-S/Teacher-B comparison with same eval axes
Step 3. E3: DKT volume teacher expansion smoke
Step 4. E4: external SSL baseline feasibility + frozen probe
```

왜 이 순서인가:

```text
E1은 새 학습 없이 평가축 문제를 먼저 확인한다.
E2는 기존 teacher branch의 공정 비교다.
E3는 teacher 정보량 병목을 직접 테스트한다.
E4는 외부 baseline이므로 setup risk가 있지만 가장 중요한 route decision evidence다.
```

---

## 6. Decision gates

```text
Case A: E1에서 CN/AD axis가 좋음
  => 3-class metric을 secondary로 내리고 disease-axis protocol로 전환.

Case B: E3에서 DKT volume teacher가 크게 개선
  => teacher information bottleneck 확정. Stronger anatomical teacher route 유지.

Case C: E4 external SSL이 크게 개선
  => ROI distillation main route 중단. SSL/foundation adaptation 우선.

Case D: E1/E3/E4 모두 약함
  => data/evaluation/label/preprocessing 자체를 재검토. VLM scaling 금지.
```

---

## 7. Safety constraints

```text
Do not delete raw data, checkpoints, logs, or manifests.
Do not use voxel-wise ROI supervision until transform chain is fixed.
Do not start large multi-GPU SSL pretraining without Min approval.
Do not clone large external repos/weights into clean workspace without deciding storage location.
Use GPU0-4 for short diagnostics; avoid GPU7 while it is active.
```

## 8. ROI final-tensor transfer decision

Min approved the safer direction for reopening voxel-wise ROI supervision:

```text
Option B: keep existing FastSurfer outputs and accurately transfer aparc/aseg into final_tensor space.
Do not rerun FastSurfer on final_tensor as the default route, because that may break FastSurfer input contract.
```

Dedicated plan:

```text
/home/vlm/minyoungi/notes/context/ROI_FINAL_TENSOR_TRANSFER_OPTION_B_PLAN.md
```

Target chain:

```text
FastSurfer aparc/aseg
→ native/HD-BET grid candidate
→ same RAS/1mm/crop-pad transform as final_tensor
→ physical volume + overlap + centroid + visual QC
→ approved ROI only gets roi_final_ready=True
```

This remains a setup/audit branch, not a reason to start voxel-wise ROI loss immediately.
