# Tutorial — Foundation fine-tuning 공부 자료

현재 학습된 foundation(`resenc_s3d_wg0.5`)을 실제로 불러와 **fine-tuning 기법(frozen / low-LR / full-FT)이
어떻게 다른지** 코드·결과로 확인하고, 왜 작은 n에서 full-FT가 과적합하는지(내부 0.942 → hidden 0.658)
눈으로 보는 학습용 자료.

## 파일
| 파일 | 환경 | 역할 |
|---|---|---|
| `01_finetuning_techniques.ipynb` | **`.venv`** 커널 | 메인 학습 노트북. 셀별 설명 + 결과(이미 실행돼 출력 포함). 다시 돌려도 됨. |
| `run_demo.py` | **`.venv-train`** (GPU) | foundation 로드·encoder forward·3기법 학습곡선을 계산해 `_demo_cache/`에 저장 |
| `_demo_cache/model_facts.json` | — | 모델 구조·기법별 학습 파라미터 수·샘플 forward (run_demo.py 산출) |
| `_demo_cache/curves.npz` | — | frozen/lowlr/full-FT의 epoch별 train·val AUROC 곡선 |

## 왜 파일이 둘로 나뉘나 (환경 제약)
한 커널이 "모델 실행 + 그림"을 동시에 못 한다:
- **`.venv-train`** = torch2.12 + B200 → foundation 실행 O, 그러나 matplotlib/pandas 없음.
- **`.venv`** = matplotlib/pandas/nibabel O, 그러나 torch2.2라 B200서 모델 실행 불가(numpy2 ABI + sm_100 커널 없음).

→ **GPU 계산은 `run_demo.py`(.venv-train)** 가 미리 하고, **노트북(.venv)** 이 그 결과를 불러와 설명·시각화한다.
   단, frozen feature + 정규화(C) sweep 은 GPU가 필요 없어 **노트북에서 sklearn으로 라이브 실행**된다.

## 실행법
```bash
# (선택) GPU 곡선·모델 사실 재생성 — GPU 2가 비어있을 때 (GPU1=Flagship 보존)
CUDA_VISIBLE_DEVICES=2 .venv-train/bin/python Tutorial/run_demo.py

# 노트북 열기: Jupyter에서 .venv 커널로 01_finetuning_techniques.ipynb 실행
#   (이미 출력이 들어있어 그냥 읽어도 되고, 다시 실행하면 라이브 C-sweep·플롯이 재생성됨)
```

## 무엇을 배우나
1. foundation 구조: ResEnc-L encoder(27M) → SimPool → **320-d** 벡터(=downstream head 입력).
2. 세 기법의 차이 = **학습 파라미터 수**: frozen 321개 ↔ full-FT 2700만개(84,000배).
3. 작은 n(21)에서 full-FT는 train→1.0으로 외워 과적합(train-val gap 큼), frozen은 안정.
4. **내부 지표 ≠ hidden** — C grid 최댓값도, 단일 split val도 낙관 편향/noise → 일반화에 베팅.

## 관련 자료
- 일반화 원칙(필독): `docs/09_downstream_generalization.md` (위험 W17)
- 코드 상세: `downstream/eval_finetune.py`(full-FT), `Challenge_Submission/task1_infarct_cls/train_task1_v2_frozen.py`(frozen)
- 데이터 확인: `downstream/taskN/inspect.ipynb`, `downstream/inspect_data.py`
- 전체 여정: `docs/downstream_finetuning_journey.md`
