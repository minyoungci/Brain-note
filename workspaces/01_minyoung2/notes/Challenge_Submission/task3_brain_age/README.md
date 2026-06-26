# Task3 Brain Age Regression

## 제출 계약

- 입력 CLI: `--t1`
- 출력 CLI: `--output <path>.txt`
- 출력 형식: `.txt` 숫자 하나
- 의미: predicted age
- 예: `35`

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
pretrained Pearson 0.947 [0.937, 0.955]
scratch    Pearson 0.910 [0.891, 0.927]
Delta +0.037
```

## 구현 원칙

- Task1/5와 같은 cls/reg inference route를 재사용한다.
- 출력 text에는 나이 값 하나만 쓴다.

## 제출 전 체크리스트

- [ ] Task3 regression head checkpoint 확정
- [ ] `/app/predict.py` Task3 route 구현
- [ ] Task5와 같은 `--t1` CLI를 쓰므로 route 구분 방식 확정
- [ ] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [ ] output `.txt` 숫자 하나 확인
- [ ] container-validator pass
- [ ] 120초/case timing pass
