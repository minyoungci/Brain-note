# Checkpoint Staging

이 폴더는 제출 컨테이너에 포함할 checkpoint를 확정하는 staging 위치다.

## 공통 foundation checkpoint

현재 단일 foundation checkpoint:

```text
experiments/phase_b/resenc_s3d_wg0.5/latest.pt
```

최종 컨테이너에는 다음 경로로 들어가는 것을 목표로 한다.

```text
/app/checkpoints/foundation_latest.pt
```

## Task별 checkpoint

아직 제출 패키징용 checkpoint 파일명은 확정 전이다. 확정 후 아래 이름으로 staging한다.

```text
task1_head.pt
task2_seg.pt
task3_head.pt
task4_seg.pt
task5_head.pt
embedding_config.json
```

주의: 실제 `.pt` 파일은 대용량 산출물이므로 git에 넣지 않는다.
