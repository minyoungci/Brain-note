# Flagship Research Workspace

이 폴더는 challenge 제출물과 분리된 foundation-model 연구 공간이다. 이제 작업 축을 명확히 둘로 나눈다.

## Directory Split

Current active work:

```text
ACTIVE: Flagship/v1_evidence/ decoder replacement only
PARKED: Flagship/v2_jepa/ Brain-JEPA experiments, until explicitly resumed
```

| Path | Scope | Do not mix with |
|---|---|---|
| `Flagship/v1_evidence/` | 현재 학습된 `ResEnc + S3D-style dense + InfoNCE-global` foundation의 증거, figure/table, decoder 교체 실험 | 새 JEPA foundation pretraining |
| `Flagship/v2_jepa/` | Brain-JEPA 3D multimodal foundation v2 후보. 현재는 보류 상태이며 실험 실행하지 않음 | 기존 foundation decoder 교체 실험 |

## v1_evidence

`v1_evidence`는 기존 foundation model을 버리지 않는다. 핵심 작업은 다음이다.

- 기존 foundation novelty evidence 정리
- S3D anti-leakage dense branch / InfoNCE global branch 분석
- Task2 실패에서 얻은 인사이트를 반영한 decoder replacement 실험
- `S3D-VistaAdapter`: current foundation encoder + new prompt-conditioned segmentation decoder

Main entry:

```text
Flagship/v1_evidence/README.md
Flagship/v1_evidence/code/s3d_vista_adapter/
Flagship/v1_evidence/plans/Plan_F_S3D_VistaAdapter.md
```

## v2_jepa

`v2_jepa`는 기존 model의 decoder만 바꾸는 실험이 아니다. 완전히 별도의 next foundation candidate다.
현재 지시 기준으로는 실행하지 않고 보관만 한다.

- Brain-JEPA 3D multimodal SSL objective
- context encoder / EMA target encoder
- latent prediction and collapse diagnostics

Main entry:

```text
Flagship/v2_jepa/README.md
Flagship/v2_jepa/code/brain_jepa/
Flagship/v2_jepa/plans/Plan_D_Brain_JEPA_3D_Multimodal.md
```

## Rule

새 실험을 만들 때 먼저 질문한다.

```text
기존 foundation을 증명하거나 decoder만 바꾸는가? -> v1_evidence
새 foundation pretraining objective/model을 만드는가? -> v2_jepa
```

현재 실행 규칙:

```text
JEPA 실험은 명시적으로 재개 지시가 있을 때만 실행한다.
그 전까지 모든 실행/검증/후속 구현은 v1_evidence decoder replacement에 한정한다.
```
