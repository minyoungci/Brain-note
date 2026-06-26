# Task2 Meningioma Segmentation

## 제출 계약

- 입력 CLI: `--flair`, `--dwi`, one of `--t2s`/`--swi`
- 출력 CLI: `--output <path>.nii.gz`
- 출력 형식: `.nii.gz` binary mask `{0,1}`

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
pretrained Dice 0.127 / NSD 0.155
scratch    Dice 0.107 / NSD 0.121
Delta small, CI overlap
```

## 구현 원칙

- 현재 가장 약한 task다.
- 단일 FLAIR만으로는 한계가 있어 멀티모달 개선이 필요하다.
- segmentation output은 반드시 원본 NIfTI 공간으로 resample-back 한다.

## 제출 전 체크리스트

- [ ] 멀티모달 strategy 확정: late fusion 또는 stem widening
- [ ] `--t2s` 케이스와 `--swi` 케이스 둘 다 처리
- [ ] Task2 seg checkpoint 확정
- [ ] sliding-window inference 구현
- [ ] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [ ] 원본 공간 resample-back 검증
- [ ] label range `{0,1}` 검증
- [ ] NSD/Dice local dry-run
- [ ] container-validator pass
- [ ] 120초/case timing pass
