# P2 PLAN — 학습된 표현이 morphometry를 넘는가 (GPU)

> 설계서(코드 전 합의). **kill-criteria 숫자 명시**(CLAUDE.md: NO-GO 없으면 시작 안 함). 작성 2026-06-11.
> 근거: `RESEARCH_PROPOSAL.md` + P0 audit + 5각도 수렴 + CPU texture/biomarker 검정. 모든 CPU 단축경로는 음성 → 남은 건 학습 표현.

## 0. 목표 (단일 질문)
**native-space T1w에서 학습된 3D 표현이, morphometry가 *약한* regime(amyloid·MCI)에서 morphometry baseline을 LOCO로 넘어 transport하는가?**
- 넘으면 → (a) 부피 너머 micro 신호 존재. 못 넘으면 → 강한 (b) 천장(통제된 조건에서도 이미지가 못 더함). **어느 쪽이든 1차 결과.**

## 1. Target / Bar (morph-weak만; AD/CN 0.93 천장은 제외)
| target | 코호트 | morphometry LOCO 바(측정됨) | n |
|---|---|---|---|
| **amyloid +/-** (1차) | AJU·KDRC·NACC·OASIS | ~0.71~0.73 | ~3,383 (CN-poor 무관) |
| **MCI vs CN** (2차) | 7코호트 | ~0.61 | — |
> AD/CN(0.93)은 control/sanity로만. 혈액·멀티모달은 P0서 음성(control).

## 2. 입력·native space 처리 (★중요)
- 입력 = **이미지 텐서만**(192×224×192, native, z-score, brain-masked). +최소 메타(age) 허용. **ROI값·scanner·CDR·morphometry 입력 금지**(target/audit 전용).
- **native space = 미정규화** → 피험자마다 위치/크기/방향 상이. CNN은 pose에 강건해야 함 → **augmentation 필수**(random flip, ±10° rotation, ±10% scale/translation). bf16(fp16 금지).
- 1차는 **2mm 다운샘플(≈96×112×96)** 로 속도 확보 → 통과 시 full-res.

## 3. Split / 평가 (validation-lock + LOCO + multi-seed)
- **subject-level LOCO**(leave-one-consortium-out). held-out 코호트 체크포인트 선택 금지.
- validation-lock: in-dist val로 best 고르지 않음 → **last-k 평균 / EMA**. (minyoung2 W2 교훈)
- **multi-seed ≥3(통과 시 5)**. per-cohort AUROC + balanced-acc + prevalence + bootstrap CI.
- **G1 모니터:** 학습된 embedding → consortium 분류(site-probe). disease 보존 동시 확인.

## 4. 실험 순서 (arm)
- **Stage 0 (smoke):** 1 held-out, 2mm, 1 seed, ~5 epoch. 파이프라인·RAM·augmentation·누수 단위테스트 통과. **성능 주장 아님.**
- **Stage 1 (signal gate) ← 결정 run:** supervised 3D CNN(ResNet) end-to-end, full LOCO(amyloid 4 fold), multi-seed, 2mm. vs morphometry 바. *왜 supervised 먼저:* 가장 싸고 직접적. full supervision도 morph를 못 넘으면 비싼 SSL은 무의미(minyoung2 S1 신호게이트 논리).
- **Stage 2 (Stage1 통과 시만):** Arm A(label-free SSL/MAE) · Arm B(+site-invariance, scanner-family 누수 모니터) · Arm C(IGUANe harmonization 대조) · Arm D(plain control). full-res.
- **Stage 3:** dual-gate 판정 + transport + (a)/(b) 결정.

## 5. KILL-CRITERIA (숫자 — 위반 시 즉시 중단·ledger)
- **NO-GO 1 (천장):** Stage1 supervised LOCO amyloid AUROC가 morphometry 바 대비 **CI 하한이 0 이하**(즉 유의 초과 못 함)가 **≥3/4 held-out 코호트 ∧ ≥3 seed** → 이미지가 supervision으로도 morph 못 넘음 → 강한 (b) → 딥표현 arm 중단, (b) 결과 작성.
- **NO-GO 2 (불안정):** validation-locked per-cohort AUROC가 **≥2 코호트에서 <0.55**(near-chance 붕괴) ∧ seed sd>0.08 → 불안정(minyoung2 W1). 하이퍼파라미터 맹목 튜닝 금지, 원인(데이터/아키/누수) 진단 먼저.
- **NO-GO 3 (누수):** embedding site-probe bAcc가 morphometry site-leak(0.27)보다 **크고** AUROC가 높으면 → site shortcut 의심 → G1 fail. Arm B(invariance) 없이 성능 주장 금지.
- **NO-GO 4 (반복):** 같은 arm 하이퍼파라미터만 바꿔 3회 연속 NO-GO → 폐기, 상위 결정점 복귀.

## 6. Compute / RAM 규율
- B200, **bf16**, 1차 2mm라 메모리 여유. CUDA_VISIBLE_DEVICES로 **빈 GPU 지정**(현재 GPU5/4 여유).
- **setsid 분리**(minyoung2 W4: SIGHUP로 job 전멸 이력) + app-level RAM cap + `/sysmon` 확인. RAM 1TB 상한.
- 산출물: `results/P2/`, 체크포인트 `.gitignore`. 코드 `experiments/P2/` + `src/microbrain/`.

## 7. 진입 전 체크포인트
- Stage 1(비싼 결정 run) 전 **git commit**(되돌아갈 지점). Stage 0 smoke는 즉시 가능(저비용).

## 8. 첫 행동
1. `src/microbrain/`에 native-space loader(augment) + 3D CNN + LOCO train/eval.
2. split/leakage 단위테스트(subject disjoint, 입력에 morph/scanner 없음) → 통과.
3. **Stage 0 smoke**(1 fold·1 seed·2mm) 실행 → 보고. 통과 후 Stage 1(결정 run)은 체크포인트+확인 후.
