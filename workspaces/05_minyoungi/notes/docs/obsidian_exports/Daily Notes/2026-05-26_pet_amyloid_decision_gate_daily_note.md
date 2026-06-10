---
title: "2026-05-26 PET Amyloid Decision Gate Daily Note"
date: 2026-05-26
tags:
  - daily-note
  - brain-image-ai
  - pet-amyloid
  - mri-to-pet
  - decision-gate
  - b200
workspace: "/home/vlm/minyoungi"
status: "pipeline_passed_but_scientific_signal_unproven"
recommended_vault_destination: "D:/Obsidian Valut/Artificial Brain/Daily Notes/2026-05-26_pet_amyloid_decision_gate_daily_note.md"
---

# 2026-05-26 — PET Amyloid 방향성 판정 게이트 기록

오늘의 핵심 질문은 단순했다.

> **T1w MRI image가 PET amyloid / centiloid 예측에 실제로 쓸 만한 추가 신호를 주는가?**
> 아니면 이 방향은 접고, 더 강한 연구 주제로 shift해야 하는가?

감자 결론부터 적으면, 오늘은 **연구 주제를 바로 죽일 만큼의 증거는 아니지만, 직접적인 T1w→PET amyloid 예측을 headline으로 밀기에는 위험 신호가 꽤 뚜렷해진 날**이다. 파이프라인은 잘 돈다. 하지만 과학적 신호는 아직 약하다.

---

## 1. 작업 공간과 전제

작업 위치:

```text
/home/vlm/minyoungi
```

사용한 MRI input contract:

```text
/home/vlm/data/preprocessed_official/v2
```

오늘 사용한 frozen split manifest:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e02_dataloader_smoke_v0/linked_adni_oasis_within_365d_subject_split_v0.csv
```

이 manifest는 ADNI/OASIS MRI와 PET amyloid target을 ±365일 window 기준으로 연결한 뒤, subject-level split을 부여한 파일이다.

중요한 전제:

- split unit은 **subject_id**이다.
- row/session-level split은 금지했다.
- PET target은 centiloid-like continuous target과 `CL>=20` candidate binary label을 사용했다.
- 이 target은 연구적으로 유망하지만, label provenance / tracer / cohort shortcut caveat는 계속 남아 있다.

---

## 2. E02 — Dataloader / split / NIfTI smoke 통과

E02 artifact:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e02_dataloader_smoke_v0/
```

확인한 것:

- subject-level train/val/test split 생성
- subject overlap 없음
- `sample_id` duplicate 없음
- `final_tensor_path` duplicate 없음
- 모든 image path 존재
- sampled NIfTI header/value smoke 정상

주요 수치:

- train: 3,032 rows / 1,097 subjects
- val: 966 rows / 366 subjects
- test: 1,018 rows / 366 subjects
- subject overlaps:
  - train × val: 0
  - train × test: 0
  - val × test: 0
- final tensor path exists: 5,016 / 5,016
- sampled NIfTI shape: `192x224x192`
- orientation: all `RAS`
- finite ratio min: 1.0

해석:

> 데이터 연결과 split plumbing은 통과했다. 적어도 여기서 leakage나 missing path 때문에 실험이 망가지는 상황은 아니었다.

---

## 3. E03 — CPU tiny train-step 통과

E03 artifact:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e03_tiny_train_step_v0/
```

목적은 성능이 아니라, 진짜 tensor가 model/loss/backward/optimizer까지 흐르는지 확인하는 것이었다.

확인한 것:

- NIfTI tensor load
- downsample to `32x32x32`
- tiny 3D CNN forward
- regression + binary loss
- backward
- finite gradient
- optimizer parameter update

주요 수치:

- train batch shape: `[8, 1, 32, 32, 32]`
- val batch shape: `[4, 1, 32, 32, 32]`
- finite gradients: true
- grad norm: 2.3264
- max parameter delta: 0.0010001
- hard failures: none

해석:

> image tensor → model → loss → backward → optimizer step 경로는 정상이다. 코드는 익었다. 하지만 이것은 성능 증거가 아니다.

---

## 4. E04 — small GPU debug training 통과, 그러나 신호는 약함

E04 artifact:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e04_gpu_debug_training_v0/
```

실행 command:

```bash
CUDA_VISIBLE_DEVICES=0 python manifests/v2_integrated/audits/pet_amyloid_e04_gpu_debug_training_v0/e04_gpu_debug_training.py \
  --epochs 3 \
  --train-n 256 \
  --val-n 128 \
  --batch-size 16 \
  --num-workers 4 \
  --downsample 64 \
  --lr 1e-3
```

GPU/resource:

- Device: `cuda`
- GPU: `NVIDIA B200`
- RAM 사용량은 안전 범위였다.
- GPU0을 사용했고 run 종료 후 GPU0은 다시 idle 상태가 되었다.

E04 결과:

- hard failures: none
- train subset: 256 rows / 220 subjects
- val subset: 128 rows / 98 subjects
- final val MAE: 34.6553 centiloid
- final val RMSE: 43.2271 centiloid
- final val AUC `CL>=20`: 0.4766
- final balanced acc @0.5: 0.5
- predicted positive rate @0.5: 0.0
- regression prediction std: 0.7618
- binary prob std: 0.000694

같은 sampled rows에서 age+sex+cohort ridge baseline:

- MAE: 32.5116
- RMSE: 40.5617
- Pearson: 0.3333
- Spearman: 0.3831
- AUC: 0.7173

해석:

> E04는 GPU training plumbing은 통과했지만, image-only tiny model은 baseline보다 못했다. 특히 binary head는 거의 0.5 주변에서 collapse했고, positive prediction도 거의 하지 못했다.

중요한 점:

- 이것만으로 “이미지는 PET 예측에 영향이 없다”고 결론내릴 수는 없다.
- 하지만 “이미지가 PET 예측에 유용한 추가 정보를 준다”는 증거도 없다.
- 현재 증거는 **no evidence yet**, not **evidence of no effect**이다.

---

## 5. E05 CPU baseline / shortcut decision audit

E05 artifact:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/
```

실행한 CPU audit script:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/e05_cpu_baseline_shortcut_audit.py
```

생성된 주요 파일:

```text
summary.json
REPORT.md
baseline_shortcut_metrics_long.csv
```

이 audit은 image tensor를 전혀 쓰지 않고, tabular/clinical/shortcut feature만으로 PET target이 얼마나 예측되는지 확인했다. 목적은 image model이 넘어야 할 최소 bar를 정하는 것이다.

### 5.1 mean-only baseline

Validation:

- MAE: 34.5572
- RMSE: 43.3267
- AUC: 0.5
- balanced acc: 0.5

Test:

- MAE: 34.0794
- RMSE: 42.8351
- AUC: 0.5
- balanced acc: 0.5

해석:

> 평균 예측만 해도 MAE가 34 전후이다. E04 image model의 val MAE 34.65는 평균 baseline보다도 거의 나아지지 않았다.

### 5.2 allowed age+sex baseline

Validation:

- MAE: 32.7942
- RMSE: 42.5790
- R2: 0.0305
- Spearman: 0.2168
- AUC: 0.6459
- balanced acc: 0.6253

Test:

- MAE: 31.8558
- RMSE: 41.5048
- R2: 0.0590
- Spearman: 0.2155
- AUC: 0.6572
- balanced acc: 0.6194

해석:

> age+sex만으로도 binary amyloid positivity AUC가 약 0.65 나온다. 이건 image model이 반드시 넘어야 할 clean low-bar baseline이다.

### 5.3 age+sex+diagnosis proxy baseline

Validation:

- MAE: 30.9950
- RMSE: 40.4451
- R2: 0.1253
- Spearman: 0.3018
- AUC: 0.7020
- balanced acc: 0.6368

Test:

- MAE: 29.9114
- RMSE: 38.9975
- R2: 0.1693
- Spearman: 0.2995
- AUC: 0.6918
- balanced acc: 0.6223

해석:

> diagnosis를 넣으면 성능이 더 오른다. 이는 PET amyloid target이 disease severity / clinical status와 강하게 연결되어 있음을 의미한다. MRI image가 실제로 추가 가치가 있으려면 이 proxy baseline을 넘어야 한다.

### 5.4 cohort/scanner/tracer shortcut controls

흥미롭게도 `cohort`, `scanner`, `field_strength`, `pet_tracer`, `target_source_column` 등을 추가한 shortcut control이 diagnosis proxy보다 크게 좋아지지는 않았다.

예: forbidden full metadata

Validation:

- MAE: 31.1856
- RMSE: 40.5650
- R2: 0.1201
- Spearman: 0.3289
- AUC: 0.6983

Test:

- MAE: 29.9680
- RMSE: 38.9986
- R2: 0.1692
- Spearman: 0.3139
- AUC: 0.6889

해석:

> 이 split에서는 단순 cohort/scanner/tracer shortcut이 모든 것을 설명하는 패턴은 아니다. 그러나 age, sex, diagnosis 같은 clinical/proxy 변수가 이미 상당한 설명력을 가진다.

---

## 6. E05 image full-ish debug run은 interrupt됨

E05에서 full train/val subset을 쓰는 image-only debug run도 시작했다.

Script:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/e05_image_fullish_debug_training.py
```

Command:

```bash
CUDA_VISIBLE_DEVICES=0 python manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/e05_image_fullish_debug_training.py \
  --epochs 5 \
  --train-n 3032 \
  --val-n 966 \
  --batch-size 16 \
  --num-workers 8 \
  --downsample 64 \
  --lr 1e-3
```

그러나 이 command는 대화 interrupt로 중단되었다.

관찰된 상태:

```text
exit_code: 130
[Command interrupted]
```

부분 artifact:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/image_fullish_debug_training/
```

생성된 파일:

```text
debug_train_rows.csv
debug_val_rows.csv
metrics.jsonl
resource_snapshot.json
```

중요:

- `metrics.jsonl` size는 0이었다.
- 즉 epoch metric은 아직 기록되지 않았다.
- 이 run은 완료된 실험으로 해석하면 안 된다.
- E05 image-only full-ish evidence는 아직 없다.

---

## 7. 오늘의 과학적 판정

오늘 기준으로 가장 정직한 결론은 다음이다.

> **PET amyloid direct prediction 방향은 아직 완전히 kill할 단계는 아니다. 그러나 현재 증거만으로는 headline 연구 방향으로 밀기 어렵다.**

이유:

1. 파이프라인은 통과했다.
   - split OK
   - dataloader OK
   - train-step OK
   - GPU train loop OK

2. 하지만 image-only debug model은 약했다.
   - E04 image AUC: 0.4766
   - E04 image MAE: 34.6553
   - binary prediction은 거의 collapse

3. tabular baseline은 생각보다 강했다.
   - full split age+sex val AUC: 0.6459
   - full split age+sex test AUC: 0.6572
   - age+sex+diagnosis val AUC: 0.7020
   - age+sex+diagnosis test AUC: 0.6918

4. 따라서 image model의 연구적 가치는 단순 성능이 아니라 **incremental value**로 증명해야 한다.

---

## 8. Continue vs Shift — 현재 권고

### 바로 shift하지는 말 것

아직 E05 full-ish image run이 interrupt되어서 완료되지 않았다. 그래서 “이미지 신호 없음”으로 확정하는 것은 과학적으로 성급하다.

### 하지만 방향을 수정해야 함

기존 질문:

```text
Can T1w MRI predict PET amyloid centiloid?
```

이 질문은 너무 약하고 reviewer에게 쉽게 맞는다.

더 나은 질문:

```text
Do MRI-derived representations add PET-validated information beyond age/sex/diagnosis and cohort/scanner shortcuts?
```

또는:

```text
Can PET-validated MRI representation serve as a calibrated biomarker-related representation rather than direct PET replacement?
```

### 판정 gate

다음 조건을 만족하면 PET amyloid 방향을 계속 진행한다.

- image-only가 `allowed_age_sex` baseline을 유의미하게 넘는다.
- fusion 또는 residual model이 `age+sex+diagnosis` proxy baseline을 일부라도 안정적으로 넘는다.
- ADNI/OASIS subgroup에서 방향성이 유지된다.
- multiple seeds에서 metric 방향이 유지된다.
- prediction collapse가 사라진다.

다음 조건이면 shift한다.

- full-ish image-only도 mean/age+sex baseline을 못 넘는다.
- fusion도 baseline improvement가 없다.
- residual centiloid prediction이 거의 zero signal이다.
- subgroup 하나에서만 좋아지고 다른 cohort에서 무너진다.
- 성능이 diagnosis proxy를 따라가는 수준이면, PET prediction headline은 접는다.

---

## 9. 다음 실행 계획

1. E05 image full-ish run을 새로 재시작한다.
   - 기존 interrupt artifact를 완료 run으로 쓰지 않는다.
   - 새 output dir 또는 run tag를 써서 덮어쓰기 위험을 피한다.

2. E05 image-only 결과를 full split baseline과 비교한다.
   - target: centiloid regression
   - binary: CL>=20
   - compare against:
     - mean-only
     - age+sex
     - age+sex+diagnosis

3. 가능하면 fusion/residual probe를 추가한다.
   - clinical baseline residual을 MRI가 예측하는지 확인
   - image embedding + clinical fusion이 baseline을 넘는지 확인

4. 최종 판정:
   - continue as PET-validated representation direction
   - or shift to safer topic:
     - longitudinal MRI SSL/JEPA representation
     - diagnosis/progression prediction
     - atrophy trajectory / disease staging
     - PET target은 external validation/probing label로만 사용

---

## 10. 한 줄 결론

오늘의 결론은 이것이다.

> **코드는 통과했다. 데이터도 연결됐다. 하지만 PET amyloid 직접예측의 과학적 신호는 아직 baseline보다 약하다. 다음 E05 full-ish image/fusion/residual gate에서 baseline을 못 넘으면, 이 방향은 headline에서 내리고 PET-validated representation/progression 쪽으로 shift하는 것이 맞다.**

감자 메모 🥔: 파이프라인은 잘 익었지만, 논문 주장은 아직 설익었다. 다음 실험은 더 큰 GPU가 아니라 **baseline을 이기는지**를 보러 가야 한다.

---

## 11. 참고 artifact index

E00/E01/E02/E03/E04/E05 audit family:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/
```

핵심 파일:

```text
pet_amyloid_e02_dataloader_smoke_v0/summary.json
pet_amyloid_e03_tiny_train_step_v0/summary.json
pet_amyloid_e04_gpu_debug_training_v0/summary.json
pet_amyloid_e05_decision_gate_v0/summary.json
pet_amyloid_e05_decision_gate_v0/REPORT.md
pet_amyloid_e05_decision_gate_v0/baseline_shortcut_metrics_long.csv
```

Workspace validation log:

```text
/home/vlm/minyoungi/docs/context/VALIDATION_LOG.md
```


---

## 추가 업데이트 — E05 full-ish image-only run 재시작 및 판정

Interrupted 되었던 E05 image-only run을 새 immutable run dir로 재시작했고 완료했다.

Run dir:

```text
/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/image_fullish_debug_training_20260526_0934_gpu1_seed20260526
```

설정:

- GPU: physical GPU1 via `CUDA_VISIBLE_DEVICES=1`
- train: 3,032 rows / 1,097 subjects
- val: 966 rows / 366 subjects
- input: `64x64x64` downsampled T1w
- epochs: 5
- batch size: 16

결과:

- best image-only val MAE: `33.9242`
- final image-only val MAE: `34.3081`
- best image-only val AUC `CL>=20`: `0.4850`
- final image-only val AUC `CL>=20`: `0.4947`
- balanced accuracy: `0.5`
- predicted positive rate @0.5: `0.0`
- regression prediction std: about `0.5` centiloid while target std is about `43.24`

Baseline 비교:

- mean-only val MAE: `34.5572`, AUC: `0.5`
- allowed age+sex val MAE: `32.7942`, AUC: `0.6459`
- age+sex+diagnosis proxy val MAE: `30.9950`, AUC: `0.7020`

판정:

> **Direct T1w MRI → PET amyloid prediction을 headline으로 계속 미는 것은 현재 증거상 비추천.**

이 결과는 “MRI image에 PET 관련 정보가 절대 없다”는 수학적 증명은 아니다. 하지만 full-ish image-only gate가 mean/age+sex baseline을 못 넘고, binary head가 all-negative로 collapse했기 때문에, 이 방향을 더 큰 GPU로 밀어붙이는 것은 전략적으로 약하다. PET은 main target replacement가 아니라, representation probing / validation label로 쓰는 쪽이 더 안전하다.

다음 추천 방향:

1. main headline은 longitudinal MRI SSL/JEPA representation, progression/staging, 혹은 PET-validated representation으로 shift한다.
2. PET amyloid는 auxiliary/probing target으로 유지한다.
3. 정말 계속하려면 image+clinical fusion과 residual centiloid prediction이 age+sex/diagnosis baseline을 넘는지 먼저 확인한다.
