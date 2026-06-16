# Stage 2 VLM — Design (distillation framing)

## 0. 정체성 (정직하게)
G0 측정 결과: 이미지가 FastSurfer morphometry를 강하게 재현(w-corr MTL 0.78, 측뇌실 0.94), acid test G2 PASS.
단 라벨이 morphometry 파생이라 "morphometry 너머"는 측정 불가 = 천장 그대로.
→ 기여 = **"전처리 수십분 FastSurfer 파이프라인 → 3D 이미지 single forward-pass로 radiology report 생성 +
ROI-grounded·인과검증된 VLM"**. *not* "이미지가 morphometry보다 잘 본다".

## 1. 아키텍처

```
3D T1 (192³ or 96³ half) ── 3D encoder(DenseNet121, G0 가중치 warm-start)
                                 │
              ┌──────────────────┼─────────────────────┐
        (aux) │ 12 w-score head            feature map  │
              │ L_aux = MSE(ŵ, w)                        │
              ▼                                          ▼
        grounding 강제                         projector(MLP/Perceiver)
                                                    │ K visual tokens (MedGemma embed dim)
                                                    ▼
                              [visual tokens ; <bos> report tokens]  → inputs_embeds
                                                    │
                                          frozen MedGemma-27B-it
                                                    │ LM loss (visual 위치 label=-100)
                                                    ▼
                                              radiology report
```

- **Phase 1 (v1, 먼저)**: projector = global feature → K=32 tokens (MLP). ROI 마스크 불필요. grounding은 aux head로.
- **Phase 2 (v2, novelty)**: per-ROI continuous token — seg(`aparc.DKTatlas+aseg.deep`) 96라벨 → 12 ROI 마스크,
  feature map에서 mask-pool → ROI당 1~few token + morphometry signature(ŵ) 주입. ⚠️ seg(256³ conformed)를
  학습이미지(192×224×192 RAS) 공간으로 resample 필요(1회 전처리). v1의 G3 통과 시에만 투자.

## 2. 학습
- **동결**: MedGemma-27B 전부 frozen(MICCAI 2025 근거: 소데이터서 frozen>LoRA>full). encoder+projector+aux head만 학습.
- **2-stage**: ① align(encoder frozen=G0가중치, projector만) → ② joint(projector+encoder 상위, aux 병행).
- **손실**: `L = L_lm + λ·L_aux` (λ~0.5, ablation). encoder는 양 경로 공유(grounding 목적), **aux head는 별도 분기**(projector/LM 경로 미통과) — aux는 encoder를 morphometry로 grounding하되 생성헤드엔 직접 grad 안 줌. l_lm/l_aux 비율 모니터(λ 과대 시 생성표현 손상).
- **불균형**(정상46%): abnormal-MTL subject oversampling + 정상/비정상 분리 평가.
- bf16, 8×B200. batch는 메모리 보고 결정(frozen 27B + 3D encoder).

## 3. 평가 (이게 진짜 기여)
1. **content-fidelity**: 생성 report → `fidelity_gate`로 ROI 등급 추출 → GT 등급과 ordinal agreement(weighted κ) + binary-abnormal AUC (critic M1: 4-class balanced-acc는 꼬리서 가혹 → κ/AUC 병기).
2. **acid test (필수, 학습 초기)**: no-image / shuffled-image 입력 → fidelity Δ. with-image가 유의 상회해야.
3. **counterfactual grounding (critic M3)**: 입력 이미지의 특정 ROI 영역 intensity perturbation → 해당 ROI 문장이 바뀌나 (morphometry-signature 채널 OFF 상태에서 = 픽셀 grounding 증명).
4. **G3**: full VLM이 baseline("image→volume회귀(G0)→룰베이스 report") 대비 *정의된 축*에서 상회하나 — fidelity(κ) 또는 임상의 blind 자연스러움. 못 이기면 27B 제거.
5. **cross-cohort**: LOCO(consortium dummy 재적합) — 내부 holdout이 아닌 미학습 코호트.

## 4. 모니터링 (학습중 실시간)
- step별: L_lm, L_aux, lr, grad-norm → `train_log.jsonl` + stdout.
- epoch별: val L_lm, **val content-fidelity(κ)**, acid-test(no-image fidelity) → 조기 grounding 실패 감지.
- 체크포인트: best val-κ. 샘플 생성 report 5건 로깅(육안 점검).

## 5. 빌드 순서 (verified 스테이지, harness)
- **A. 데이터**: image memmap(G0 재사용) + report 토큰화(MedGemma tok) + w-score 타깃 + split. → 검증: shape/토큰 round-trip.
- **B. 모델 forward**: encoder→projector→inputs_embeds→frozen MedGemma→loss. → 검증: forward/backward smoke, grad가 projector엔 흐르고 LM엔 안 흐름 확인.
- **C. 학습루프 + 모니터링**: 위 손실 + 로깅. → 검증: 1-epoch tiny run, loss 하강.
- **D. 평가**: fidelity/acid/counterfactual. → 검증: acid가 no-image를 실제로 구분하는지.
- 각 스테이지 후 **code-auditor**(누수/수치/재현성) → 다음 단계.

## 6. go/no-go
- **G3**(C·D 후): VLM이 G0-baseline 못 이기면 → 27B 빼고 distillation 논문으로.
- **G4**(병행): R-GenIMA report-variant 선점 확인(literature-scout).
