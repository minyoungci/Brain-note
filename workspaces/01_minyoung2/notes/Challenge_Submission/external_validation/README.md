# External-cohort Validation — ⚠️ Challenge official 결과와 분리

> **이 디렉토리는 외부 코호트(AIBL/AJU) 검증 *전용*이다.**
> Challenge 주최측이 제공한 downstream data(`/home/vlm/data/fomo26_downstream`)로 낸
> **official 제출/리더보드 결과와 절대 섞지 말 것.** 여기 산출물은 hidden test 제출에 들어가지 않는다.

## 왜 분리하나
- FOMO26 Methods Track은 **finetune에 추가 데이터 금지**. AIBL/AJU는 *검증(일반화 추정) 전용*이고
  제출 파이프라인에는 절대 안 들어간다(규칙 저촉 없음). 결과를 섞으면 official 점수로 오인할 위험.
- 제출 모델은 FOMO 제공 데이터로만 학습, foundation은 FOMO300K로만 사전학습. 외부는 오프라인 probe.

## 외부 코호트
- **AIBL**(호주 노화/AD, ~620 subj)·**AJU**(한국 병원, ~471 subj). 둘 다 `AAAI_external_yucca4`로
  FOMO와 **동일 yucca4 전처리**(crop+znorm[0,1]+1mm+RAS, full-head). age·CN/MCI/AD 라벨 보유.
- **DISJOINT 확인**: FOMO300K 사전학습 코퍼스(226,793)와 4-level leakage check 통과
  (`Flagship/AAAI/results/external_eval/LEAKAGE_CHECK.md`). 라벨: AIBL=`metadata/reingest_minyoung4/aibl_manifest_labeled.csv`,
  AJU=`korean_multimodal_manifest.csv`.
- challenge 5 task 중 **T3 brainage(reg)만 외부 라벨 존재**. cls는 대리(CN-vs-AD), seg는 외부 불가.

## 디렉토리 구조 (실험/분석별 분리)
```
external_validation/
├── common.py                      # 공유 코어: join·frozen feature+캐시·ridge·metrics
├── _feat_cache/                   # feature 캐시(gitignore, ckpt fingerprint 대조)
├── results_visualization.ipynb    # 그림4(E1·A·Exp3·seg 오버레이) — cross-cutting
├── 01_reg_brainage/               # reg pathway
│   ├── eval_frozen.py             # E1 (주력): frozen brain-age (AIBL-CN)
│   ├── eval_fullft.py             # E2 (보류): 제출 full-FT — skull-strip mismatch
│   ├── brainage_3cohort.py        # 3-코호트(AIBL·AJU·A4) 정확도·gap·ROI-importance
│   ├── brainage_deepdive.ipynb    # 심화 노트북(정확도·산점·ROI·per-subject·실제 ROI 오버레이)
│   └── external_frozen.json · brainage_3cohort.json
├── 02_cls_transfer/               # cls pathway
│   ├── eval_cls.py                # A: CN-vs-AD cross-cohort + domain-norm 진단
│   └── external_cls.json
├── 03_roi_interpretability/       # foundation 해석
│   ├── eval_roi.py                # Exp3: ROI 부피 vs brain-age 부분상관(age 통제)
│   └── roi_importance.json
└── 04_saliency/                   # per-subject 인과 attribution (XAI, post-hoc)
    ├── eval_occlusion.py          # occlusion + Δ-over-random(distribution-shift 상쇄)
    └── occlusion_summary.json
```
코호트: **AIBL**(호주, 620, CN/MCI/AD)·**AJU**(한국, 471, CN/MCI/AD)·**A4**(preclinical, 1787, dx없음). 전부 yucca4·DISJOINT.

| 실험 | 스크립트 | 결과 |
|---|---|---|
| **E1** reg | `01_reg_brainage/eval_frozen.py` | frozen brain-age, AIBL-CN MAE/Pearson·Δ-over-random·age-adjusted gap-by-dx |
| **E2** reg(보류) | `01_reg_brainage/eval_fullft.py` | 제출 full-FT 외부 — challenge=skull-strip vs 외부=full-head mismatch |
| **A** cls | `02_cls_transfer/eval_cls.py` | frozen CN-vs-AD cross-cohort AIBL↔AJU + domain-norm 진단 |
| **Exp3** 해석 | `03_roi_interpretability/eval_roi.py` | FastSurfer ROI 부피 vs brain-age 부분상관(age 통제) |

## 핵심 결과(요약, 상세=SCRATCHPAD insight-log 2026-07-01)
- **E1 (reg)**: frozen brain-age **외부 일반화 O** — AIBL-CN Δ-over-random +0.24, gap CN<MCI<AD monotonic(age-adjusted).
- **A (cls)**: within-cohort O(0.69~0.76), **cross-cohort 전이 X**(~0.5, Δ≈0, domain-norm 무효=깊은 site-entanglement) → 0.658 붕괴 설명.
- **Exp3 (해석)**: brain-age가 **뇌실확대(부분상관 +0.19)·해마/내후각위축(−0.13)** 읽음, age 통제 후에도 유의 → 형태학 직접(비-shortcut) = E1 메커니즘.

## 실행 (각 서브디렉토리에서)
```
CUDA_VISIBLE_DEVICES=1 .venv-train/bin/python 01_reg_brainage/eval_frozen.py   # E1
CUDA_VISIBLE_DEVICES=1 .venv-train/bin/python 02_cls_transfer/eval_cls.py       # A (캐시 재사용)
CUDA_VISIBLE_DEVICES=1 .venv-train/bin/python 03_roi_interpretability/eval_roi.py  # Exp3
.venv/bin/jupyter nbconvert --to notebook --execute --inplace results_visualization.ipynb  # 시각화(.venv)
```
공유코어 `common.py`(각 스크립트가 import). feature 캐시=ckpt fingerprint 대조(stale 방지). code-auditor 검증(C1/C2/W1/W2/W4 반영).
