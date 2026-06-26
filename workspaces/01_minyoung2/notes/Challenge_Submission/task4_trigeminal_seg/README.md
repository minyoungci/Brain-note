# Task4 Trigeminal Segmentation

## 제출 계약

- 입력 CLI: `--t2`
- 출력 CLI: `--output <path>.nii.gz`
- 출력 형식: `.nii.gz` multiclass mask `{0,1,2}`

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
pretrained Dice 0.413 / NSD 0.786
scratch    Dice 0.164 / NSD 0.344
Delta Dice +0.249, NSD +0.442
```

## 구현 원칙

- Task1과 함께 우선 제출 준비 대상이다.
- 리더보드 가중치가 큰 voxel-level task다.
- multiclass 출력 `{0,1,2}`와 원본 공간 resample-back이 핵심 검증 포인트다.

## 제출 전 체크리스트

- [ ] Task4 seg checkpoint 확정
- [ ] sliding-window inference 구현
- [ ] multiclass argmax 출력 구현
- [ ] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [ ] 원본 공간 resample-back 검증
- [ ] label range `{0,1,2}` 검증
- [ ] container-validator pass
- [ ] 120초/case timing pass
