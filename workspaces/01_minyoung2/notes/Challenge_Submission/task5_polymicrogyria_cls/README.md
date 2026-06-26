# Task5 Polymicrogyria Classification

## 제출 계약

- 입력 CLI: `--t1`
- 출력 CLI: `--output <path>.txt`
- 출력 형식: `.txt` 확률값 하나

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
pretrained AUROC 0.986 [0.952, 1.000]
scratch    AUROC 0.997 [0.983, 1.000]
Delta -0.010
```

## 해석

점수는 높지만 scratch도 천장에 가까워 site confound 또는 쉬운 split 가능성을 조심해야 한다. 제출은 가능하지만 연구적 주장에서는 강한 foundation gain으로 쓰지 않는다.

## 제출 전 체크리스트

- [ ] Task5 classifier head checkpoint 확정
- [ ] `/app/predict.py` Task5 route 구현
- [ ] Task3와 같은 `--t1` CLI를 쓰므로 route 구분 방식 확정
- [ ] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [ ] output `.txt` 숫자 하나 확인
- [ ] container-validator pass
- [ ] 120초/case timing pass
