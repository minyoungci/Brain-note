# Task7 Fairness

## 제출 계약

- 입력 CLI: `--input`
- 출력 CLI: `--output <path>.npy`
- 출력 형식: `.npy` 1D fixed-length embedding
- finetune: 금지

## 현재 상태

로컬에는 그룹/인구통계 메타가 없어 fairness metric을 내부에서 계산할 수 없다. 챌린지 서버가 Task6과 같은 embedding을 받아 그룹별 OvR AUROC/F1을 평가한다.

## 구현 원칙

- Task6 embedding route와 동일하게 유지한다.
- task-specific supervised adaptation을 넣지 않는다.
- embedding preprocessing은 Task6과 동일해야 한다.

## 제출 전 체크리스트

- [ ] Task6/7 common embedding route 확정
- [ ] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [ ] `.npy` 1D fixed-length output 검증
- [ ] no-finetune 위반 여부 코드 리뷰
- [ ] container-validator pass
- [ ] 120초/case timing pass
