# AAAI Flagship Plan: Single-Checkpoint Dense-Global 3D Brain MRI Foundation — What Transfers, and How to Deploy It

작성일: 2026-06-29 (최종 갱신: hybrid framing 확정)

이 폴더는 FOMO Challenge 제출과 **무관한** AAAI/AI conference target 연구 계획이다. 목적은 우리가 보유한 단일 dense-global 3D brain MRI SSL 체크포인트(ResEnc, S3D dense + InfoNCE/SimPool global)를 대상으로, **무엇이 전이되고 어떻게 배포해야 하는지를 통제된 실험으로 규명**하고 그 결과를 conference paper 수준의 기여로 정리하는 것이다.

## 기술적 기여 (Technical Contributions)

**경계(desk-reject 방지)**: 우리는 *새 backbone/loss를 발명했다고 주장하지 않는다.* dense branch(stage-wise
re-mask submanifold masked conv)는 SparK(Tian et al., ICLR 2023)와 동치이며 **인용된 prior art backbone**으로 처리한다.
기술적 novelty는 backbone이 아니라, 아래 **3개의 method/diagnostic/framework 기여**에 있다.

```text
TC1 (method+diagnostic) — Scratch-Convergence Diagnostic & Protocol-Adaptive Transfer
   문제: 3D 의료 전이에서 full fine-tuning은 random-init도 encoder를 학습시켜 scratch가 foundation을 따라잡아
        "pretraining 무용"처럼 보이는 *평가 아티팩트*를 만든다.
   기여: 진단 지표 gap(task)=Dice_scratch(full-FT) − Dice_scratch(frozen)로 *언제 pretraining이 돕는지*를
        예측하고, task별 protocol(tubular/anatomy=frozen/low-LR, lesion=full-FT)을 처방하는 알고리즘.

TC2 (method+analysis) — Objective-Balance Trade-off & Rank-based Checkpoint Selection
   단일 dense-global 체크포인트에서 global 가중치는 semantic 정보 주입과 effective-rank를 trade off 한다(2-force).
   balanced(wg0.5)가 global 전이 inverted-U 정점(정점 CI-분리, n=494). rank 곡선이 down-arm을 설명 →
   레이블 없이 balance를 고르는 진단 근거.

TC3 (methodology) — Shortcut-Controlled Foundation Evaluation Protocol
   사전학습이 site/scanner를 de-confound하지 *않는*(검증됨: aug=crop+znorm, InfoNCE=crop-불변뿐) 상황에서,
   측정→A2 직교화→held-out(cross-cohort/within-cohort)로 7종 shortcut을 통제·검정하는 사전등록 프로토콜.
   외부 multi-site·대륙간(ADNI→KDRC/AJU) 검증으로 TC2를 봉인.
```

> 위치 요약: backbone=SparK(인용), **기여=TC1 진단·처방 method / TC2 balance·rank 선택기준 / TC3 shortcut-통제 평가 framework.**
> "새 SSL 손실"을 주장하지 않으므로 SparK 중복 desk-reject을 피하고, 기여를 *technical method/diagnostic/methodology*로 명확히 한다.

## 검증된 핵심 증거 (이 계획의 토대)

이 framing은 추측이 아니라 다음 실측에 기반한다(상세: `05`, `06`).

- **C2 (provenance-clean global probe, recipe=resenc_s3d, matched random baseline):**
  brain age Pearson r — random 0.137 → pure(wg0) 0.599 → **wg0.5 0.792** → full(wg1) 0.683.
  rankme(tail) — wg0 14.86 → wg0.5 12.93 → wg1 11.65 (단조감소). → wg0.5가 inverted-U 정점.
- **TC1 (trigeminal Task4, n=40) — paper-ready(재실행 불필요):**
  frozen matched **Δ+0.134** (0.442[0.408,0.474] vs frozen-scratch 0.308[0.275,0.340], CI-분리) +
  scratch-convergence diagnostic gap=0.409−0.308=**+0.101**. frozen-foundation ≈ full-FT-scratch 0.409(CI 겹침) →
  "값싼 frozen probe가 full-FT-scratch 수준 회복". men은 방향성만.
- **C3 (외부 데이터, 준비중):** ADNI/NACC/A4/AIBL/AJU/KDRC 6코호트가 FOMO300K 사전학습
  filelist와 0건 중복(구조적 leakage-safe). brain age 합 ~6,300, CN/MCI/AD(ADNI/KDRC/NACC),
  대륙간(ADNI→KDRC/AJU). OASIS-3는 leakage-indeterminate로 제외.

## 문서 구성

| 문서 | 목적 |
|---|---|
| `01_problem_and_positioning.md` | 문제 정의, hybrid 기여(C1/C2/C3) framing, SparK 정직한 positioning |
| `02_ablation_study_plan.md` | C1/C2를 증명하는 ablation matrix (objective sweep·protocol sweep 중심) |
| `03_experiment_and_data_plan.md` | 외부 코호트(실측 인벤토리)·전처리·leakage-safe split 설계 |
| `04_augmentation_plan.md` | augmentation = robustness 분석 (main novelty 아님) |
| `05_execution_timeline_and_success_criteria.md` | AAAI 일정 역산, 증거 현황, success/fail 기준 |
| `06_ablation_execution_runbook.md` | 실행 runbook — 완료/잔여 작업 추적 |

## Challenge와의 경계

이 계획은 FOMO Challenge submission이 아니다.

- Challenge-specific task score 최적화는 별도(`Challenge_Submission/`)로 둔다.
- AAAI plan은 우리가 보유한 추가 컨소시엄 데이터(외부 검증)를 사용한다. 단 pretraining/downstream
  leakage 방지를 위해 subject/site/dataset split을 엄격히 관리한다(코호트 disjoint 구조로 충족).
- 전처리는 pretraining과 외부 downstream 모두 **동일 Yucca 4-step**(HD-BET/N4/skull-strip 없음)을
  적용해 전처리-유발 domain shift를 제거한다.

## 정직성 원칙 (모든 문서에 적용)

```text
- 과대주장 금지: S3D/L_dense는 새 손실이 아니며 anti-leakage probe는 동어반복이다.
- 모든 transfer 수치는 Δ-over-random/scratch + CI로 보고한다(작은 n 주의).
- dense seg는 SOTA를 주장하지 않는다. protocol-dependent·modest 전이로 정직하게 보고한다.
- 중심 증거는 C1/C2/C3 ablation과 외부검증이며, Task2 meningioma 저성능은 limitation으로만 쓴다.
```
