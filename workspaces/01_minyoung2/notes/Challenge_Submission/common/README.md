# Common Submission Assets

이 폴더는 7개 task가 공유하는 제출 자산을 둔다.

## 역할

- `container/`: 공통 `Apptainer.def`, `/app/predict.py`, 패키징 스크립트.
- `checkpoints/`: foundation checkpoint와 task별 finetuned head/adapter checkpoint 포인터.
- `validator/`: container-validator 로그와 결과.
- `logs/`: 빌드, dry-run, timing 로그.

## 공통 제출 원칙

최종 제출물은 `.sif` 하나이며, 현재 해석상 7개 task에 같은 `.sif`를 사용한다. `predict.py`는 입력 파일 조합 또는 validator가 제공하는 task 정보로 task route를 선택해야 한다.

## 필수 checkpoint

Foundation:

```text
experiments/phase_b/resenc_s3d_wg0.5/latest.pt
```

Task별 head/adapter는 아직 제출 패키징용으로 고정되지 않았다. 각 task 폴더의 `README.md`와 `checkpoints/`에서 확정한다.
