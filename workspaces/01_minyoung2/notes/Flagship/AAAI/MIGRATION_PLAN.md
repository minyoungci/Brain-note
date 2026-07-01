# AAAI 폴더 이사 계획서 (→ /home/vlm/minyoung4)

**목표**: 현재 `/home/vlm/minyoung2/Flagship/AAAI`를 `/home/vlm/minyoung4`로 독립 이사시켜
옮긴 곳에서 **그대로 실행 가능**하게 만든다.
**결정(확정)**: (1) `minyoung2`는 **그대로 유지** → venv/checkpoint는 심링크·참조 가능.
(2) `minyoung4/` = **AAAI 내용 직접**(minyoung4/docs, minyoung4/scripts, …).

> ⚠️ **실행 시점: Phase 1 재학습이 완전히 끝난 뒤에만.** 학습이 `experiments/`에 쓰는 중
> 이동/심링크하면 손상. 실행 전 `bash scripts/phase1_status.sh`로 두 run `DONE`(step 149999) 확인 + watchdog 종료.

---

## 1. 의존성 지도 (audit 실측)

| 구성물 | 원위치 | 크기 | 이사 처리 |
|---|---|---|---|
| AAAI 본체 (docs/scripts/results/draft) | `Flagship/AAAI` | 8.7M | **복사** → `minyoung4/` |
| 모델/파이프라인 코드 | `pretrain/`(453K)·`preprocessing/`(210K)·`baseline-codebase/`(474K) | ~1.1M | **복사** → `minyoung4/` (import self-contained) |
| 학습 venv | `.venv-train` (torch2.12+cu130, B200 검증) | 5.4G | **심링크** (재생성 위험 회피) |
| 전처리 venv | `.venv` (torch2.2.2) | 수 GB | **심링크** |
| 체크포인트 (selector eval 입력) | `experiments/phase_b/resenc_s3d_{pure,wg0.25,wg0.5,wg0.75,full}` | 각 ~530MB | **심링크** (읽기 전용 입력) |
| 데이터 | `/home/vlm/data/FOMO300K_preprocessed`, `/home/vlm/data/AAAI_external_yucca4` | 대용량 | **절대경로 그대로 참조** (이동 금지=data-safety) |

## 2. minyoung4 목표 레이아웃

```
/home/vlm/minyoung4/
├── docs/  scripts/  results/  draft/      # AAAI 본체 복사
├── pretrain/  preprocessing/  baseline-codebase/   # 코드 복사 (self-contained)
├── .venv-train -> /home/vlm/minyoung2/.venv-train   # symlink
├── .venv       -> /home/vlm/minyoung2/.venv         # symlink
├── experiments/phase_b/
│   ├── resenc_s3d_pure  -> /home/vlm/minyoung2/experiments/phase_b/resenc_s3d_pure   # symlink (기존5)
│   ├── resenc_s3d_wg0.25 -> …  wg0.5 -> …  wg0.75 -> …  full -> …
│   └── (새 실험은 여기 real dir로 생성 — minyoung2 오염 안 함)
└── (데이터: 코드 내 /home/vlm/data/... 절대경로 그대로)
```

## 3. 경로 하드코딩 수정 (이사 후 조용히 깨지는 지점 — 반드시)

**A. Shell 5개** — `ROOT=/home/vlm/minyoung2` → **스크립트 위치 자동감지**로 교체(향후 재이동 무편집):
```bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # = minyoung4
```
대상: `resume_phase1.sh`, `phase1_status.sh`, `run_external_yucca4_nohup.sh`,
`run_task4_ablation_queue.sh` (+ 내부 `pretrain/`, `preprocessing/`, `.venv*` 참조는 `$ROOT` 기준이라 자동 해결).

**B. Python 2개 (실측 확정)** — `Path(__file__).resolve().parents[3]` (현재 Flagship/AAAI/scripts 깊이 기준) →
새 구조(minyoung4/scripts, 2단계 얕음)에선 **`parents[1]`**:
- `scripts/phase0_labelfree_screen.py:42`  `parents[3]` → `parents[1]`
- `scripts/leakage_probe.py:20`  `parents[3]` → `parents[1]`
- (`build_paper_registry.py`는 이 패턴 없음 — 수정 불필요)
- 편집 전 catch-all 확인: `grep -rn "parents\[3\]" scripts/*.py` (누락 방지)

**C. 데이터 경로** — `/home/vlm/data/FOMO300K_preprocessed`, `/home/vlm/data/AAAI_external_yucca4`:
**수정 없음**(절대경로, 데이터 안 움직임). 원하면 `DATA_ROOT` env로 파라미터화 가능(선택).

## 4. 실행 절차 (Phase 1 완료 후)

```bash
# 0) 사전: 학습 완료·watchdog 종료 확인
bash /home/vlm/minyoung2/Flagship/AAAI/scripts/phase1_status.sh   # 두 run DONE?
pkill -f "resume_phase1.sh watch"                                  # watchdog 정지

# 1) 목적지 + 본체/코드 복사
mkdir -p /home/vlm/minyoung4
cp -a /home/vlm/minyoung2/Flagship/AAAI/.            /home/vlm/minyoung4/
cp -a /home/vlm/minyoung2/pretrain \
      /home/vlm/minyoung2/preprocessing \
      /home/vlm/minyoung2/baseline-codebase          /home/vlm/minyoung4/

# 2) venv 심링크
ln -s /home/vlm/minyoung2/.venv-train  /home/vlm/minyoung4/.venv-train
ln -s /home/vlm/minyoung2/.venv        /home/vlm/minyoung4/.venv

# 3) 기존 체크포인트 심링크 (5개)
mkdir -p /home/vlm/minyoung4/experiments/phase_b
for c in pure wg0.25 wg0.5 wg0.75 full; do
  ln -s /home/vlm/minyoung2/experiments/phase_b/resenc_s3d_$c \
        /home/vlm/minyoung4/experiments/phase_b/resenc_s3d_$c
done

# 4) 경로 수정 (§3 A/B) — 편집 후

# 5) 검증 smoke (모두 통과해야 "완료")  ← 자기평가 금지, 실제 실행
cd /home/vlm/minyoung4
.venv-train/bin/python scripts/phase0_labelfree_screen.py --smoke        # 로직 PASS
.venv-train/bin/python -c "import sys;sys.path.insert(0,'pretrain');import models,eval_harness;print('import OK')"
ls /home/vlm/data/FOMO300K_preprocessed >/dev/null && echo "data OK"
bash scripts/phase1_status.sh                                            # 새 ROOT로 ckpt 읽힘?
# (선택, GPU) wg0.5 brain-age r≈0.792 재현 = 특징추출 정합 최종 확인

# 6) git 새로 시작
cd /home/vlm/minyoung4 && git init
#   .gitignore: results/**/feats/, *.npy, experiments/, .venv*, __pycache__
```

## 5. 위험 / 주의 (critical)

1. **`parents[3]→parents[1]` 미수정 = phase0가 `/home`을 repo root로 오인** → import 실패. §5 smoke가 잡음.
2. **심링크 venv 전제 = minyoung2 유지**(사용자 확정). minyoung2 삭제·이동 시 minyoung4 즉시 깨짐.
3. **기존 5 ckpt 심링크는 읽기 전용** — 새 학습은 절대 그 심링크에 쓰지 말 것(새 이름 real dir).
4. **원본 삭제 금지 (delete-before-verify 금지)** — smoke 전부 통과 확인 후에도 minyoung2/AAAI·코드 당분간 보존.
5. **데이터/`/home/vlm/data` 구조 변경 금지** — 필요 시 data-manager agent (직접 mv/rm 금지).
6. 이사 후 `docs/` 내부 경로 언급(예: STATE.md의 `/home/vlm/minyoung2/...`)은 별도 문서 최신화 대상.

## 6. 완료 정의 (Definition of Done)
- §4-5 smoke 4종 전부 PASS + (선택)GPU sanity r≈0.792
- `minyoung4`에서 `phase1_status.sh`·`phase0 --smoke`·leakage 스크립트가 무편집 재실행됨
- minyoung2 원본은 검증 완료까지 그대로 보존
