# notebook/ — 분석 노트북 (micro 분석)

> 실행 가능한 개별 분석. 종합 narrative·향후 제안은 `docs/PRIOR_FAILURE_AND_GOFORWARD.md`.
> 데이터: QC-pass 작업셋(`data/derived/manifest_qc_pass/`, read-only canonical에서 빌드).

| 노트북 | 내용 | 핵심 출력 |
|---|---|---|
| `01_prior_failure_analysis.ipynb` | 이전 실패 4-사인(R1–R4)·dead-ends·ceiling | site×impaired Cramér's V=0.421 |
| `02_data_qc_integrity.ipynb` | base-텐서 전수 QC + QC-pass 빌드 검증 | 0 flagged · 12,978 작업셋 |
| `03_cohort_class_bias.ipynb` | 코호트×진단 confound(R1 실증) | `figures/03_cohort_class.png` |
| `04_longitudinal_feasibility.ipynb` | ADNI 종단·전환 검정력·회귀 N·라벨 함정 | 전환 ~26–50 / 회귀 N=849 |
| `05_baseline_bar.ipynb` | ⭐ 계층적 baseline bar + 부트스트랩 CI(critic 반영) | morph 신호 실재하나 baseline 인지와 중복 → 임상 위 여유 미확립 |
| `06_cohort_bias_audit.ipynb` | ⭐ 7코호트 bias 프로파일 + site식별/disease분리 | site 2.6×chance(AJU 0.905) but within-site disease 0.775=decidable |

## 재현
```bash
# 1) 생성
uv run python notebook/_build.py
# 2) 실행 (mb-uv 커널 = uv 환경)
uv run jupyter nbconvert --to notebook --execute --inplace \
  --ExecutePreprocessor.kernel_name=mb-uv --ExecutePreprocessor.timeout=600 \
  notebook/0*.ipynb
```

## 규약
- 노트북은 절대경로로 자립 실행(실행 cwd 무관).
- 그림은 `figures/`(gitignore=png). 무거운 산출물 금지 — 수치는 노트북 출력/리포트에.
- 새 micro 분석은 `NN_<topic>.ipynb`로 추가하고 이 표·`_build.py`에 반영.
