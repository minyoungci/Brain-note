# MIN-WMH — SSH-resilient 핸드오프 (8도구 × 4코호트 최종 런)

_모든 잡 nohup+disown(PPID=1) → SSH 끊겨도 지속. 이 문서로 재개._

## 🔴 진행 중 (전부 detached)
| 잡 | pid 파일 | 출력 | GPU |
|---|---|---|---|
| AJU reg SYSU+SHIVA (6청크) | `results/ajureg/chunks/pids.txt` | `chunks/out_*.csv` | 2/3/5 |
| AJU reg HyperMapp3r (6청크) | `results/ajureg/hm_chunks/pids.txt` | `hm_chunks/out_*.csv` | 2/3/5 |
| AJU reg wmhseg (3청크) | `results/ajureg/wmhseg_chunks/pids.txt` | `wmhseg_chunks/out_*.csv` | 4 |
| AJU reg LST-AI (3청크) | `results/ajureg/lstai_chunks/pids.txt` | `lstai_chunks/out_*.csv` | 4 |
| **wmhseg GT-Dice** (MICCAI 1mm) | pid 534785 | `results/gt_dice_wmhseg.csv` | 4 |
| **LST-AI GT-Dice** (MICCAI) | pid 534787 | `results/gt_dice_lstai.csv` | 4 |
| **최종 모니터** (20잡 대기→병합→분석) | **pid 637160** | `results/ajureg/FINAL_COMPLETE.txt` | — |

## ✅ 완료된 것
- 3코호트 dissociation: OASIS(A−, 완벽분리)·A4(A+, 기전복제)·AJU native (`results/dissociation_multicohort.json`)
- AJU reg: naive/Otsu(643) ✅ + SynthSeg(583, Track04 재사용) ✅
- GPU 활성화(venv_bench TF + CUDA libs + LD_LIBRARY_PATH), rescaling 검증(ρ=0.782), manifest 검증

## 진행 확인 / 최종 결과
```
tail research_tracks/06_wmh_tool_benchmark/results/ajureg/FINAL_progress.log   # 진행도(3분마다)
cat research_tracks/06_wmh_tool_benchmark/results/ajureg/FINAL_COMPLETE.txt    # 최종 8도구×4코호트 (ALL_DONE 후)
```
**최종 모니터(637160)가 20잡 전부 끝나면 자동으로**: 코호트 vols 병합 → `dissociation_multicohort.py` 실행 → `FINAL_COMPLETE.txt`.

## 재개 (모니터/잡 죽었을 시)
- 컴퓨트 러너 전부 resumable(done 체크). 죽은 청크는 동일 명령 재실행(GPU: `LD_LIBRARY_PATH=<nvidia libs>` + `CUDA_VISIBLE_DEVICES=<gpu>` + `TF_FORCE_GPU_ALLOW_GROWTH=true`).
- nvidia lib 경로: `.venv_bench/bin/python -c "import os,nvidia;b=os.path.dirname(nvidia.__file__);print(':'.join([os.path.join(b,d,'lib') for d in os.listdir(b) if os.path.isdir(os.path.join(b,d,'lib'))]))"`
- 최종 분석만 재실행: `uv run python research_tracks/06_wmh_tool_benchmark/dissociation_multicohort.py`

## ⚠️ ETA / 율속
wmhseg·LST-AI ~6분/subject(GPU서도 patch/greedy 느림) = 율속. full 643은 9-20h라 검출은 partial(capped)로 충분(n≥150 powered). GT-Dice는 ~100 MICCAI. **전체 ~3-5h.**

## 8도구 × 4코호트 (목표)
도구: SYSU·SHIVA·SynthSeg·HyperMapp3r·**wmhseg·LST-AI**(6 DL) + naive·Otsu(2 classical)
코호트: OASIS(A−)·A4(A+)·AJU native(A−)·**AJU registered(A− n643, 깨끗한 복제)**
→ 완성 시 핵심 산점도(Dice vs 검출)가 8점으로 닫히고 깨끗한 A− 복제 확보.
