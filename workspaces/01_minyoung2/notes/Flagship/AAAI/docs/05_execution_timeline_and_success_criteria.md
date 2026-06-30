# 05. Execution Timeline and Success Criteria

## Deadline Context

AAAI-27 official timeline (확인: 2026-06-29):

```text
2026-06-30: paper submission site opens
2026-07-21: abstracts due, 11:59 PM UTC-12
2026-07-28: full papers due, 11:59 PM UTC-12
2026-07-31: supplementary + code due
2026-11-30: notification
```

Source: `https://aaai.org/conference/aaai/aaai-27/`.

2026-06-29 기준 abstract까지 ~22일, full paper까지 ~29일. **새 대규모 사전학습은 피하고**, 이미 확보한
C1/C2 증거 + 진행 중인 외부 전처리(C3)에 집중한다.

## 현재 증거 현황 (확보 vs 잔여)

| 기여 | 증거 | 상태 |
|---|---|---|
| **TC1 protocol-adaptive** | frozen matched **+0.134**(CI-분리) + scratch-convergence diagnostic gap +0.101 | ✅ **paper-ready(GPU 재실행 불필요)** |
| **TC2 objective balance** | brain age inverted-U 0.599→**0.792**→0.683, wg0.5 정점 CI-분리 (random 0.137) | ✅ SOLID(D2, audit 검증) |
| **TC2 rank mechanism** | rankme 14.86→12.93→11.65 (단조감소) | ✅ 측정 SOLID — rank는 down-arm만(2-force) |
| TC2 polymicro/infarct | polymicro 단조(Δ-only), **infarct 컷(n21 chance)** | ⬇️ 보조/제거 |
| **TC3 external multi-site** | 6코호트 leakage-safe, pre-reg(07) LOCKED | 🟡 전처리 진행중(critical path) |
| detail: leakage probe | 동어반복 확인 → sanity only | ✅ 처리 완료(증거 아님) |

→ **TC1·TC2 모두 추가 GPU 없이 SOLID·paper-ready.** 내부 정량 증거 확보. inverted-U는 내부 1개 → **TC3 외부 재현(전처리 완료 시)이 AAAI급 봉인 레버**.

## Minimum Viable AAAI Paper

```text
1. Architecture figure (single checkpoint → dense pyramid + global vector)
2. C2: objective-balance Pareto + rank mechanism (✅)
3. C1: protocol-adaptive transfer + scratch-convergence diagnostic (✅)
4. C3: external multi-site global transfer — 최소 brain age(1+ 코호트 n≥300) + 가능시 CN/MCI/AD
5. 정직한 limitation (작은-n 내부 seg/cls, SparK 중복, dense seg modest)
```

C1·C2만으로도 honest empirical paper가 되지만, **C3가 빠지면 단일-내부-데이터 연구로 약해진다.**
C3의 brain age(외부·대륙간)가 AAAI-grade로 올리는 레버다.

## Success Criteria

### Method/empirical criteria

| Claim | Success threshold | 현재 |
|---|---|---|
| TC1 protocol-adaptive | frozen matched Δ CI-분리 + scratch-convergence diagnostic, task-adaptive 방향성 | ✅ 충족(frozen-matched, 재실행 불필요) |
| C2 balance | wg0.5가 brain age에서 wg0/wg1에 dominated 아님(정점 CI-분리) | ✅ 충족 |
| C2 rank | rank↓ 단조(측정), down-arm 설명; up-arm은 semantic 이득으로 별도 설명 | ✅ 측정 / 해석 2-force |
| C3 external | 외부 brain age Δ-over-random>0, cross-cohort/site-disjoint에서 비붕괴 | ⏳ 전처리 대기 |

### 정직한 non-goals

```text
- dense seg SOTA 주장하지 않음 (protocol-dependent·modest).
- anti-leakage를 method novelty로 주장하지 않음 (dense branch는 SparK의 sparse-conv를 dense+re-mask로 근사 — 연산은 비등가하나 기여로 주장 안 함; probe 동어반복).
- ResEnt>ViT 일반 우월 주장하지 않음 (우리 세팅 한정).
```

## Go / No-Go Rules

### Go for AAAI (hybrid)
```text
TC1 frozen-matched Δ+0.134 CI-분리 + diagnostic (✅, 재실행 불필요)
AND TC2 brain-age inverted-U 정점 CI-분리 (✅)
AND TC3 외부 brain age ≥1 코호트(n≥300) Δ>0, cross-cohort/site-defensible (전처리 완료 후)
```

### Redirect (medical venue)
```text
C1/C2 깨끗하나 C3 외부검증이 데드라인 내 불가
```

### Hold
```text
C3 외부 split이 leakage-safe로 방어 안 됨 (현재는 disjoint 검증되어 해당 없음)
OR 외부 brain age가 random과 분리 안 됨
```

## Execution Plan

### Phase 1. C1/C2 증거 고정 + 문서/그림 (지금, GPU 불필요)
- D1(protocol)·D2(objective probe)·collapse diagnostics 통합 → Table 1/2 + Figure 2/3
- 문서 hybrid framing 반영(완료) + SparK/ConvMAE/SimMIM 인용
- (선택) boundary-bleed leakage probe 재설계 — detail 섹션

산출:
```text
Table_Objective_Balance.csv, Table_Protocol_Transfer.csv
Figure_Pareto_Rank.png, Figure_Protocol_Curve.png
```

### Phase 2. 외부 데이터 전처리 (진행중, CPU, 사용자)
- Yucca 4-step을 6코호트에 적용. n≥300 첫 코호트 우선(brain age anchor 선행).
- split manifest(subject/site/cross-continent) + filelist disjoint 재확인.

산출:
```text
external_manifest.csv, split_manifest.json, preprocessing_report.md
```

### Phase 3. C3 외부 평가 (전처리 완료 후, GPU 경량)
- eval_harness에 외부 task 배선(brainage_ext, cnmciad_cls) → frozen probe + Δ-over-random + CI
- site-disjoint(ADNI/NACC) + cross-continent(ADNI→KDRC/AJU)

산출:
```text
Table_External_Transfer.csv, Figure_Site_Disjoint.png
```

### Phase 4. Manuscript
- method-as-study(C1/C2) 먼저, experiments(C3) 다음, limitation 정직하게.
- supplementary: data split 검증, leakage-safe 증명, 전처리 동일성.

## Immediate Next Actions

1. (완료) 문서 hybrid framing 반영.
2. C1/C2 paper-ready 표/그림 생성(기존 자산).
3. 외부 전처리 코호트 순서·ETA 확정(사용자) → n≥300 anchor 먼저.
4. 외부 코호트 eval_harness 배선(전처리 산출물 포맷 확인 후).
5. SparK/ConvMAE/SimMIM 및 brain-age SSL 선행연구 인용 정리.

## Important Writing Guidance

과대주장 금지:
```text
S3D/L_dense/anti-leakage는 novelty가 아니다 (dense+re-mask는 SparK sparse-conv의 근사 — 연산은 비등가하나 기여로 주장 안 함; ConvMAE 인용; probe 동어반복).
```
주장하는 것 (positive technical method, headline=TC2, 검증중):
```text
대규모(FOMO300K, 226,793 volumes·36-source) 3D brain MRI foundation에서
(TC2, headline) FINDING: objective balancing 시 effective rank가 transfer와 *분리*(rank 단조↓ vs inverted-U)
   → naive rank/RankMe 선택 실패. METHOD: 이를 극복하는 라벨-프리 기준 C로 transfer-최적 가중치 선택을
   leave-one-task-out regret로 검증(C 존재=Phase 0 GO/NO-GO). ★"rank로 최적 선택" 주장 금지.
(TC1) scratch-convergence 진단 기반 budget/protocol-adaptive transfer.
(TC3 = shortcut-통제 외부평가 = 검증 rigor). 외부검증=[PENDING], 완료형 금지.
delta vs RankMe/α-ReQ = model 순위가 아니라, objective-balance에서 rank 실패를 보이고 극복하는 C를 selection으로 검증.
```
Task2는 central proof가 아니라 few-shot lesion + task-adaptive protocol 필요성의 사례로만.
