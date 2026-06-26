# Task6 Linear Probe

## 제출 계약

- 입력 CLI: `--input`
- 출력 CLI: `--output <path>.npy`
- 출력 형식: `.npy` 1D fixed-length embedding
- finetune: 금지

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
Task1 data frozen probe AUROC 0.817
```

## 구현 원칙

- supervised head를 넣지 않는다.
- frozen foundation encoder/global vector만 사용한다.
- embedding dimension은 고정되어야 한다.
- Task7과 같은 embedding route를 공유한다.

## 제출 전 체크리스트

- [ ] embedding dimension 확정
- [ ] frozen-only route 검증
- [ ] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [ ] `.npy` 1D float output 검증
- [ ] container-validator pass
- [ ] 120초/case timing pass
