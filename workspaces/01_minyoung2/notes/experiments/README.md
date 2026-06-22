# experiments/ — 학습·실험 산출물 (registry)

모든 학습/실험 run을 실험별 서브디렉토리로 보관. 설계는 [[../docs/03_architecture_method]], 위험/모니터는 [[../docs/06_risk_register]], 현재 상태는 [[../SCRATCHPAD]].

## 구조 규약
```
experiments/<experiment>/
  README.md                  # 가설·방법·runs 표·결론
  run<NN>_<설명>_<날짜>/
    config.json              # 하이퍼파라미터 + code commit (커밋)
    summary.md               # 결과·해석·판정 (커밋)
    cos_series.csv 등        # compact 결과 (커밋)
    metrics.jsonl·run.log    # raw (gitignore — 대용량/재생성 가능)
  figures/                   # 출력 figure
```
- run 디렉토리 = 1 run. config+summary+compact만 커밋, raw/checkpoint는 gitignore(`.gitignore` 참조).
- 실험 게이트마다 SCRATCHPAD 갱신 + 커밋([[../SCRATCHPAD]]).

## 실험 목록
| 실험 | 목적 | 상태 |
|---|---|---|
| [conflict_pilot](conflict_pilot/README.md) | (구 thesis GATE) dense-global gradient 충돌? | 완료 — cosine 기각, magnitude robust(run01~03). cosine/decoder-transfer 탈락 → thesis=II+III |
| [eval_harness](eval_harness/README.md) | 내부 평가(seg·cls·reg 동시 Pareto, Tier 0) | run01 완료 — random baseline이 confound 노출(seg 위치 shortcut·cls site). Δ-over-random 필수 |
