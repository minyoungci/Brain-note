# notebook/ — 데이터-문제 증거 + 진행 가능 방향

> 데이터를 직접 열어 수치+그림으로 입증하는 설득형 시리즈. 종합 narrative는 `docs/blog/the-data-ceiling.md`,
> 기술 분석은 `docs/analysis/`. 데이터: QC-pass 작업셋(`data/derived/manifest_qc_pass/`).

| 노트북 | 문제 | 핵심 증거 |
|---|---|---|
| `01_class_and_site_confound.ipynb` | 클래스 분포 × site=population | Cramér's V 0.421 · morph→site 2.6×(AJU 0.905) · within-site disease 0.775 |
| `02_label_quality_and_leakage.ipynb` | 라벨 정적·결측=site신호·누수 | dx_label 변화 0 · 결측 히트맵 · dup md5 |
| `03_modality_label_disjointness.ipynb` | 구조적 저주 modality⊥label | ADNI raw multimodal=0 · DWI/PET은 KDRC/OASIS |
| `04_morphometry_ceiling.ipynb` | morphometry 천장 | morph 증분 over DEMO+BASE CI 0 포함(전환·회귀) |
| `05_longitudinal_limits.ipynb` | 종단 한계 | 전환 검정력부족 · 변화율 ΔR² CI 전부 음수 |
| `06_feasible_directions.ipynb` | **진행 가능 방향** | Lane B/A/O3 데이터 feasibility + kill-test + GATE-3 |

## 재현
```bash
uv run python notebook/_build.py            # 생성
uv run jupyter nbconvert --to notebook --execute --inplace \
  --ExecutePreprocessor.kernel_name=mb-uv --ExecutePreprocessor.timeout=900 notebook/0*.ipynb
```

## 규약
- 절대경로 자립 실행(cwd 무관). 그림은 `figures/`(gitignore=png, 재생성). 블로그용 사본은 `docs/blog/figures/`(추적).
- 새 분석은 `NN_<topic>.ipynb`로 추가 + `_build.py`·이 표에 반영. 비슷한 주제는 신규 대신 기존 갱신.
