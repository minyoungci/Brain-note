# MIN-WMH — 실행 상태 / 핸드오프 (2026-06-16 갱신)

_세션 끊겨도 이 문서로 재개. 장기작업 = nohup(detached) CPU, 세션-독립._

> ⛔ **먼저 읽을 것: `CRITICAL_FINDING.md`** — critic-driven gating 결과 WMH→해마 연관(벤치마크 M5 + Track04 headline 공통)이 **뇌실(위축) 보정에 붕괴**. 벤치마크 결론·Track04 제출 모두 영향. 아래 "최종 결과"는 그 교란 발견 *이전*의 baseline.

## 🔴 GT-Dice 벤치마크 진행 중 (MICCAI 2017 WMH Challenge, 사용자 승인)
공개 GT(수동 마스크) = killer 실험: **Dice 정확도 순위 vs downstream 임상검출 vs 위축누출**.
- 데이터: `~/.cache/kagglehub/.../wmh-dataset/versions/1/wmh_data` (training~41+test~63, 3사이트, subject별 pre/FLAIR+pre/T1 정합 + wmh.nii 마스크 0/1). archive 삭제됨.
- 도구 5종(멀티모달 포함 — 정합본이라 작동): ANTsPyNet SYSU·SHIVA·HyperMapp3r·wmhseg(`run_gt_dice_antspynet.py`, pid `gt_dice_antspynet.pid`, CPU 느림~수시간) + WMH-SynthSeg(`gt_synthseg/`, pid `synthseg_gt.pid`, GPU3 ~10분).
- 스모크 검증: SYSU Dice 0.746, HyperMapp3r 0.495(1 subject).
- 완료 후 자동: `gt_dice_synthseg.py`(공간 리샘플 Dice) → `gt_dice_summary.py`(5도구 종합 → `gt_dice_summary.json`). 부분결과 peek: `gt_dice_antspynet.csv`.
- 가설: **Dice 1등(SYSU, 홈그라운드) ≠ 임상검출 1등(SynthSeg)** → "정확도≠임상유용성, 임상검출은 위축누출 추적".

## 🔴 종단 구제 진행 중 (AJU V2, GPU3 nohup)
사용자 승인 후 진행. FastSurfer는 Docker/deps 부재 → **WMH-SynthSeg를 V1+V2 T1에 실행**(동일도구 내부일관, ~15분).
- 변환 완료: A− **195명** V1 T1+V2 T1+V2 FLAIR (`results/longitudinal/nifti/`, manifest.csv). 간격 측정가능 42명 중앙 **~4년**(범위1-8y, 나머지 날짜 stripped).
- WMH-SynthSeg T1: pid `results/longitudinal/wmhsynthseg_t1.pid`, 로그 `wmhsynthseg_t1.log`, 출력 `t1_vols.csv`. 재실행: `CUDA_VISIBLE_DEVICES=3 WMH_MODEL_DIR=$PWD/tools/wmh_synthseg/models uv run python tools/wmh_synthseg/repo/WMHSynthSeg/inference.py --i .../t1_inputs --o .../t1_segs --csv_vols .../t1_vols.csv --device cuda --crop --threads 4`
- 완료 후 자동: `longitudinal_analysis.py` → **GATE(WMH-SynthSeg hippo vs FastSurfer hippo r>0.8)** 통과 시 `dHippo ~ baseline_WMH + baseline_hippo + dVentricle + cov`. 결과 `longitudinal_result.json`.
- 해석: baseline WMH가 *이후* 해마위축 예측하면=시간선행(뇌실교란 못깨는 증거). PV-지배라 dVentricle 통제가 핵심.

## ✅ ANTsPyNet 완료 (A4 250 + AJU 96, 에러 0·값 정상 검증됨)
runner resumable(done체크, 빈 CSV 내성, 절대경로 필수). 재실행:
```
cd research_tracks/06_wmh_tool_benchmark; VPY=$PWD/.venv_bench/bin/python
nohup $VPY run_antspynet.py $PWD/results/<c>_benchmark_cohort.parquet <flair_col> $PWD/results/<c>/antspynet_vols.csv > $PWD/results/<c>/antspynet.log 2>&1 &
```
flair_col: A4=`raw_flair_path`, AJU=`flair_nifti`. 평가: `uv run python eval_tool_dependence.py`.

## ⭐ 최종 결과 — 3-tool tool-dependence (`results/tool_dependence.json`, 검증됨)

| 코호트 | 인구 | amyloid | n | SynthSeg β(p) | SYSU β(p) | SHIVA β(p) | inter-tool CCC (ss~sysu/ss~shiva/sysu~shiva) |
|---|---|---|---|---|---|---|---|
| **OASIS** | 미국 | A− | 242 | **−0.115 (.002)✓** | −0.020 (.56)✗ | **−0.076 (.026)✓** | 0.685 / 0.065 / 0.069 |
| **A4** | 미국 | A+ | 250 | **−0.146 (.000)✓** | −0.032 (.33)✗ | −0.063 (.059)~ | 0.28 / 0.089 / 0.054 |
| **AJU** | 한국 | A− native | 96 | +0.034 (.64)✗ | +0.073 (.32)✗ | +0.097 (.18)✗ | 0.12 / 0.094 / 0.074 |

- **출력 sanity**: 3코호트 모두 err=0, NaN=0. SYSU 과분할(median 6.5–18k mm³) vs SHIVA 보수적(median 0.4–1k mm³). z-score log 회귀라 스케일 무관.
- **headline (M5)**: 동일 FLAIR에서 **도구 선택이 임상 결론을 바꾼다**. WMH-SynthSeg는 일관 검출(OASIS·A4), **SYSU-media는 일관 놓침(3코호트 전부)**, SHIVA 중간(OASIS 검출/A4 경계). US 2코호트(A−·A+)에서 패턴 복제.
- **M6 disagreement**: SYSU가 부피는 10–20배 크지만 임상신호는 놓침 → **부피 크기 ≠ 임상 타당도**. synthseg~shiva CCC≈0.07(거의 무상관)인데도 둘 다 OASIS에서 검출 → 분할 *내용*이 관건.

## ⚠️ 정직한 한계 (단정 금지)
- **AJU native n=96 = 3도구 전부 null**. → **tool 효과 아님**(도구 합의). 원래 Track04 AJU(registered 1mm, n=643)=β−0.123이 재현 안 됨. **주의**: OASIS도 native 5mm인데 검출됨(n=242) → "native 5mm가 신호를 죽인다" 단정 불가. 가장 방어적 해석=**AJU 96 subset 저검정력/비재현**. ⇒ tool-dependence 근거는 **US 코호트(OASIS clean + A4 패턴복제)**가 carry. Korean 기여는 Track04(registered n=643)에 남음.
- **properly-powered Korean 대안**: AJU `flair_final_path`(registered, A− n=656) 존재 → 3도구 재실행 가능. 단 z-score 전처리본 의심(ANTsPyNet은 raw 강도 기대) → 입력 타당성 확인 필요(research-critic 판단 대기).
- KDRC: native FLAIR 5/20 → 보류, limitation.

## 코호트 (FLAIR 보유 = 4개 전부)
AJU·KDRC(한국, Track04) / OASIS·A4(미국). **ADNI 제외**(다운로드=T1전용, FLAIR 1건). AIBL·NACC=FLAIR無.

## 정직한 위치
- 벤치마크(MIN-WMH) = moderate novelty(GT-free clinical-validity framework) + **tool-dependence-of-inference** finding이 진짜 기여.
- ⭐ **부산물이 더 큼**: OASIS가 Track04의 cross-population 외부검증을 줌(β−0.088 p=0.021, make-or-break 통과). → Track04 매뉴스크립트에 통합 권고(우선).
