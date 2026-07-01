# AAAI Flagship Plan: Label-Free Objective-Balance Selection & Budget-Adaptive Transfer for Large-Scale (FOMO300K) 3D Brain MRI Foundation Models

작성일: 2026-06-29 (최종 갱신: positive-technical-first framing 확정)

이 폴더는 FOMO Challenge 제출과 **무관한** AAAI/AI conference target 연구 계획이다. 목적은 **대규모(FOMO300K → 전처리 후 226,793 volumes·36 public sources) 3D brain MRI foundation 사전학습 regime을 위한 두 positive technical method를 제안·검증**하는 것이다: **TC2(headline) 라벨-프리 effective-rank objective-balance 선택** + **TC1 budget-adaptive transfer**. 우리가 보유한 단일 dense-global 체크포인트(ResEnc, S3D dense + InfoNCE/SimPool global)가 대상이며, 스케일은 *novelty가 아니라 이 method가 필요·유효해지는 regime*이다(라벨 튜닝 불가→TC2 필수, 36-source→TC3 검증 rigor 필수).

## 기술적 기여 (Technical Contributions)

**경계(desk-reject 방지)**: 우리는 *새 backbone/loss를 발명했다고 주장하지 않는다.* dense branch(dense conv +
stage-wise re-mask)는 SparK(Tian et al., ICLR 2023)의 submanifold sparse-conv masked modeling을 **근사**한다 —
개념은 같으나 **연산은 동일하지 않고**(SparK=진짜 sparse conv; 우리=dense conv+re-mask, normalization·경계에서 비등가),
dense 변형은 ConvMAE/MCMAE 계열에 더 가깝다. 이 연산 차이는 *존재하지만* "3D 적용"만으로 novelty가 되지 않으므로
(3D masked-CNN pretraining 자체가 선행연구) **prior art backbone(SparK + ConvMAE 인용)**으로 처리한다.
기술적 novelty는 backbone이 아니라, 아래 **positive technical method 2개(TC2 headline·TC1) + 검증 rigor(TC3)**에 있다.

```text
TC1 (method+diagnostic) — Scratch-Convergence Diagnostic & Protocol-Adaptive Transfer
   문제: 3D 의료 전이에서 full fine-tuning은 random-init도 encoder를 학습시켜 scratch가 foundation을 따라잡아
        "pretraining 무용"처럼 보이는 *평가 아티팩트*를 만든다.
   기여: 진단 지표 gap(task)=Dice_scratch(full-FT) − Dice_scratch(frozen)로 *언제 pretraining이 돕는지*를
        예측하고, task별 protocol(tubular/anatomy=frozen/low-LR, lesion=full-FT)을 처방하는 알고리즘.

TC2 (HEADLINE method, UNDER CONSTRUCTION) — Label-Free Objective-Balance Selection (overcoming rank–transfer decoupling)
   FINDING(verified): dense+global 결합 SSL에선 effective rank가 transfer와 *분리* —
     rank 단조↓(14.86→12.93→11.65) vs transfer inverted-U(0.599→0.792→0.683).
     → naive rank/RankMe는 rank-max wg0(0.599)을 골라 *틀린다*(RankMe에 대한 non-obvious 경고).
   METHOD(검증중): rank가 못 잡는 up-arm까지 따라가는 라벨-프리 기준 C(α-ReQ·alignment/uniformity·cluster)로
     transfer-최적 가중치 선택 → leave-one-task-out regret로 검증. C 존재=Phase 0 GO/NO-GO, 외부검증=[PENDING].
   delta vs RankMe/α-ReQ: 그들=label-free model 순위 / 우리=objective-balance에서 rank 실패를 보이고 극복하는 C 검증.

TC3 (methodology) — Shortcut-Controlled Foundation Evaluation Protocol
   사전학습이 site/scanner를 de-confound하지 *않는*(검증됨: aug=crop+znorm, InfoNCE=crop-불변뿐) 상황에서,
   측정→A2 직교화→held-out(cross-cohort/within-cohort)로 7종 shortcut을 통제·검정하는 사전등록 프로토콜.
   외부 multi-site·대륙간(ADNI→KDRC/AJU) 검증으로 TC2를 봉인.
```

> 위치 요약: backbone=SparK-style 근사(SparK+ConvMAE 인용; 연산은 SparK와 비등가), **positive 기여=TC2(headline, 검증중) 라벨-프리 objective-balance 선택(rank↔transfer decoupling 극복) / TC1 budget·protocol-adaptive transfer / TC3 shortcut-통제 외부평가(검증 rigor).**
> "새 SSL 손실/backbone"을 주장하지 않으므로 SparK 중복 desk-reject을 피하고, 기여를 *positive technical method(TC2·TC1) + 검증 rigor(TC3)*로 명확히 한다.

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
