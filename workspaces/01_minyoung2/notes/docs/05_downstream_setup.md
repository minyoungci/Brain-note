# Downstream 데이터 셋업 & Finetuning (공식 — Asparagus)

> ⭐ **공식 내용** (PDF 가이드 + erda 실제 파일 + GitHub Asparagus config 실제 기본값 통합). split 비율은 PDF 80/10/10이 아니라 **config 실제 기본값**으로 보정됨. 규칙은 [[00_challenge_rules]], 우리 모델은 [[03_architecture_method]].

## ⓘ Task별 입력 모달리티·샘플수 (실데이터 확정 2026-06-22)
다운로드·추출·검증 완료 (`/home/vlm/data/fomo26_downstream/raw/Task_N`, repo symlink `downstream/taskN/data`):
| Task | subjects | 입력 모달(실데이터) | 라벨 |
|---|---|---|---|
| 1 infarct cls | **21** | adc·dwi_b1000·flair·swi/t2s | 0/1 |
| 2 meningioma seg | **23** | dwi_b1000·flair·swi/t2s | seg mask |
| 3 brain age reg | **494** | **t1w** (predict는 t1+t2였으나 실데이터=t1w) | 나이값 |
| 4 trigeminal seg | **40** | **t2w** (←미확인이었음, 확정) | seg mask |
| 5 polymicrogyria cls | **48** | Zhang PPMR coronal T1 변환 | 0/1 case/control |
| 6,7 probe/fairness | =Task1(21) | =Task1 | =Task1 |
- 구조: `Task_N/preprocessed/sub-XX/ses-01/<modal>.nii.gz` + `labels/sub-XX/ses-01/label.txt`. 5개 zip 크기 무결성 정확 일치.
- ⚠️ **여전히 미확인**: Task1~5 **full-backbone vs frozen+head finetune**(Task6/7만 frozen 확정), 제출 컨테이너 형식. (W13 pretrain↔downstream subject overlap=0 검증은 데이터 확보됐으니 *지금 가능*.)

## 0. 다운로드 파일 (erda: `sid.erda.dk/sharelink/fmeuvo1EdF`)
| 파일 | 용량 | 용도 |
|---|---|---|
| Task_1.zip | ~150MB | Task1 Infarct 분류 |
| Task_2.zip | ~499MB | Task2 Meningioma 분할 |
| Task_3.zip | ~2.16GB | Task3 Brain Age 회귀 |
| Task_4.zip | ~2.28GB | Task4 Trigeminal 분할 |
| Task_5_extract.py | ~26KB | Task5 추출 스크립트 |
| Zhang_Lingfeng_2022_PPMR_Dataset.zip | ~743MB | Task5 Polymicrogyria 원본 |

총 ~6GB. (데이터는 **erda 공유링크에서만** — finetuning 추가데이터 금지, 규칙.)

## 1. 환경변수
```bash
export FOMO_ROOT="/path/to/fomo26"
export ASPARAGUS_SOURCE="${FOMO_ROOT}/raw/hf_data/datasets_downloaded_from_hf"
export ASPARAGUS_CONFIGS="${FOMO_ROOT}/asparagus/configs"
export ASPARAGUS_DATA="${FOMO_ROOT}/processed_data"
export ASPARAGUS_MODELS="${FOMO_ROOT}/models"
export ASPARAGUS_RESULTS="${FOMO_ROOT}/results"
export ASPARAGUS_RAW_LABELS="${FOMO_ROOT}/raw_labels"
export WANDB_ENTITY="<your_wandb_entity>"   # config 기본 team-asparagus
```

## 2. 다운로드/추출
```bash
cd "$ASPARAGUS_SOURCE"; SHARE="https://sid.erda.dk/share_redirect/fmeuvo1EdF"
for n in 1 2 3 4; do wget "${SHARE}/Task_${n}.zip"; unzip "Task_${n}.zip" -d "Task_${n}"; done
wget "${SHARE}/Task_5_extract.py"; wget "${SHARE}/Zhang_Lingfeng_2022_PPMR_Dataset.zip"; python Task_5_extract.py
```

## 3. Asparagus .pt 변환
```bash
asp_process --dataset CLS002 --save_as_tensor --num_workers 8   # Task1
asp_process --dataset SEG009 --save_as_tensor --num_workers 8   # Task2
asp_process --dataset REGR002 --save_as_tensor --num_workers 8  # Task3
asp_process --dataset SEG010 --save_as_tensor --num_workers 8   # Task4
asp_process --dataset CLS003 --save_as_tensor --num_workers 8   # Task5
```

## 4. ⚠️ Split 생성 — config 기본값에 *반드시* 일치 (PDF 80/10/10 아님)
| 유형 | config train_split | --vals |
|---|---|---|
| 분류(cls)/회귀(reg)/linear-probe | `split_75_15_10` | 75 15 10 |
| 분할(seg) | `split_40_10_50` (+ `TEST_40_10_50`) | 40 10 50 |
```bash
asp_split --dataset CLS002_FOMO26_Infarct             --vals 75 15 10
asp_split --dataset SEG009_FOMO26_Meningioma          --vals 40 10 50
asp_split --dataset REGR002_FOMO26_BrainAge           --vals 75 15 10
asp_split --dataset SEG010_FOMO26_TrigeminalNeuralgia --vals 40 10 50
asp_split --dataset CLS003_FOMO26_Polymicrogyria      --vals 75 15 10
```

## 5. Task ↔ 데이터셋 ↔ 명령 ↔ config
| Task | dataset ID | 명령 | config | split |
|---|---|---|---|---|
| 1 Infarct cls | CLS002_FOMO26_Infarct | `asp_finetune_cls` | default_finetune_cls.yaml | 75_15_10 |
| 2 Meningioma seg | SEG009_FOMO26_Meningioma | `asp_finetune_seg` | default_finetune_seg.yaml | 40_10_50 |
| 3 Brain Age reg | REGR002_FOMO26_BrainAge | `asp_finetune_reg` | default_finetune_reg.yaml | 75_15_10 |
| 4 Trigeminal seg | SEG010_FOMO26_TrigeminalNeuralgia | `asp_finetune_seg` | default_finetune_seg.yaml | 40_10_50 |
| 5 Polymicrogyria cls | CLS003_FOMO26_Polymicrogyria | `asp_finetune_cls` | default_finetune_cls.yaml | 75_15_10 |
| 6 Linear probe | (Task1 데이터 CLS002) | `asp_linear_probe` | default_linear_probe.yaml | 75_15_10 |
| 7 Fairness | (Task6과 동일) | `asp_linear_probe` | default_linear_probe.yaml | 75_15_10 |

## 6. 실제 config 기본 하이퍼파라미터 (저장소 검증값)
- **cls** (default_finetune_cls.yaml, 1gpu40cpu): epochs 50, batch 2, warmup 10, decoder_warmup 0, limit_train/val_batches 250/50, target_size [128³], split_75_15_10, fold 0, check_val_every 3, **load_decoder True**.
- **seg** (default_finetune_seg.yaml, 1gpu40cpu): epochs 1000, batch 2, warmup 50, decoder_warmup 50, train/val_batches_per_epoch 250/50, **patch [160³]**, split_40_10_50, test TEST_40_10_50, **load_decoder False**.
- **reg** (default_finetune_reg.yaml): epochs 50, batch 2, warmup 0, limit 250/50, target [128³], split_75_15_10, load_decoder True, check_val_every 1.
- **linear probe** (default_linear_probe.yaml): epochs 15, batch 4, warmup 0, limit 1.0, target [160…], split_75_15_10.
- **pretrain 참고** (default_pretrain.yaml): batch 16, patch [160³], **mask_ratio 0.6**, max_samples 6,000,000, split_99_01_00, 2gpus.

## 7. Finetune 실행 예시
```bash
# Task1 cls
asp_finetune_cls task=CLS002_FOMO26_Infarct +model=resenc_unet_b_clsreg \
  checkpoint_run_id=<PRETRAIN_RUN_ID> load_checkpoint_name=last.ckpt \
  data.train_split=split_75_15_10 data.fold=0 hardware.num_workers=8 \
  logger.wandb_logging=true logger.wandb_entity=<your_wandb_entity>
# Task2 seg
asp_finetune_seg task=SEG009_FOMO26_Meningioma +model=resenc_unet_b \
  checkpoint_run_id=<PRETRAIN_RUN_ID> load_checkpoint_name=last.ckpt \
  data.train_split=split_40_10_50 data.test_split=TEST_40_10_50 data.fold=0 hardware.num_workers=8
# Task6·7 linear probe (finetune 불가, Task1 데이터)
asp_linear_probe task=CLS002_FOMO26_Infarct +model=resenc_unet_b_clsreg \
  checkpoint_run_id=<PRETRAIN_RUN_ID> load_checkpoint_name=last.ckpt
```
Task3/4/5도 위 매핑대로 명령·split만 교체. W&B 끄려면 `logger.wandb_logging=false`.

## 8. 반드시 기억 (규칙)
- 데이터는 erda 링크에서만, finetune 추가데이터 금지.
- **모든 task = 동일한 사전학습 체크포인트 하나**.
- 제출 시 `checkpoint_run_id`는 *사전학습이 아니라 finetuned 모델*을 가리켜야 함.
- split 비율 = PDF 80/10/10이 아니라 위 config 기본(75_15_10 / 40_10_50). (단 finetune 전략은 규칙상 자유 — 조정 가능.)

---

## ⭐ 우리 설계 함의 (중요 — [[03_architecture_method]] 반영)
- **공식 baseline 모델 = ResEnc U-Net(CNN)** (`+model=resenc_unet_b` / `resenc_unet_b_clsreg`). 즉 **공식 finetune 파이프라인은 CNN U-Net 중심**.
- 우리 plan은 백본을 **ViT(3DINO식)**로 정했는데 — Asparagus finetune은 `+model=`로 아키텍처 지정 → **ViT를 쓰려면 Asparagus에 custom model 등록 필요**(통합 마찰).
- ⚠️ **Phase A 결정사항**: (a) 마찰 줄이려 *공식 ResEnc U-Net*으로 가서 CNN-DINO/MAE 사전학습 → finetune 그대로, vs (b) ViT custom model 등록. **공식 baseline이 CNN이라는 점이 ViT-vs-CNN 결정에 새 변수** — Phase A에서 ResEnc(공식) 기준으로 먼저 돌리고, ViT는 추가 통합으로 비교하는 게 현실적일 수 있음.
- seg config가 patch [160³]/epochs 1000 → **seg(50% 가중)가 무겁다**(인프라 최우선 재확인).
- pretrain config: mask_ratio 0.6, patch 160³ — 우리 SSL 설계의 출발 기본값.
