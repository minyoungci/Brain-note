# AAAI Flagship — STATE & RESUME (handoff)

상태: **PAUSED — 외부 raw 데이터 확보 대기.** 목표: AAAI-27 (full paper 2026-07-28), 기술적-novelty(TC1/TC2/TC3).
마지막 갱신: 2026-06-29.

## 1. 고정된 결정 (locked)
- 기여 = **technical contributions TC1/TC2/TC3** (새 backbone/loss 주장 안 함). anti-leakage = **SparK-cited detail**(동어반복, 증거 아님).
- **Foundation 재학습 불필요** — 기존 150k 체크포인트 `resenc_s3d_{pure,wg0.5,full}` 사용.
- 모든 transfer claim은 `docs/08` shortcut 통제(측정→A2→B) + Δ-over-random + CI 필수. (CLAUDE.md 필수선행 7번)

## 2. 증거 현황 (audit-검증)
| 기여 | 상태 | 핵심 수치 |
|---|---|---|
| **TC1** protocol-adaptive + scratch-convergence diagnostic | ✅ paper-ready(내부, GPU 불필요) | frozen matched **+0.134**[CI 0.408–0.474 vs 0.275–0.340], diagnostic gap **+0.101** |
| **TC2** objective balance + rank | ✅ paper-ready(내부 SOLID) | brain-age inverted-U 0.599→**0.792**[0.762,0.819]→0.683(정점 CI-분리), rankme 14.86→12.93→11.65(2-force, down-arm만) |
| **TC3** shortcut-controlled external | 🟡 pre-reg v2 **LOCKED**, **미실행** | `[EXTERNAL-PENDING]` — 외부 데이터 대기 |
| (컷/강등) infarct=chance / polymicro=Δ-only / leakage probe=동어반복 | ⬇️ | — |

## 3. 산출물 (artifact 위치)
- 계획 docs: `Flagship/AAAI/docs/README, 01–07`; **`docs/08`(shortcut 필수, CLAUDE.md #7)**.
- pre-registration(LOCKED): `Flagship/AAAI/docs/07_c3_external_preregistration.md` (F1/F2/M1–M7 반영, 임계값 동결).
- 원고 초안: `Flagship/AAAI/draft/00_outline.md, 03_method.md, 04_2_tc2_objective_balance.md`.
- TC2 표+스크립트: `results/table_c2_objective_balance.csv`, `scripts/build_c2_table.py`(source 추출, CI-분리 자동검정).
- TC2 probe 원천: `results/d2_probe/{s3d_random,resenc_s3d_pure,resenc_s3d_wg0.5,resenc_s3d_full}/eval_results.json`.
- 메모리: `fomo-preprocessing-pipeline`, `aaai-novelty-reality`, `shortcut-confound-control`, `code-review-mandatory`(확장).

## 4. 단일 의존성 = 외부 전처리 (CPU, 사용자 진행 중)
- leakage-safe 6코호트: ADNI/NACC/A4/AIBL/AJU/KDRC (FOMO300K filelist와 0건). **OASIS-3 제외**(disjoint 증명 불가).
- raw → **FOMO Yucca 4-step**(crop_to_nonzero/znorm/1mm-RAS, **HD-BET/N4 없음**) → npy.
- 현재 디스크: ADNI/A4 일부, NACC/AIBL/KDRC/AJU 미생성.

## 5. RESUME STEPS (외부 데이터 준비되면, doc 07 §7)
```text
1. 코호트별 Yucca 산출물 + label table + filelist 0-overlap 재확인.
2. [unblinding 전] code-auditor가 patient-GroupKFold·CN-fit·nested CV·A2 train-only를 코드에서 확인.
3. eval_harness 외부 task 배선: brainage_ext(CN-fit), cnmciad_cls (cross-cohort 모드).
4. TC3 실행:
   - shortcut audit: 측정(site probe) → A2 직교화(train-only) → held-out(cross/within-cohort) + 공변량.
   - baselines: matched random ×≥3 seed, FreeSurfer fs_* morphometry, wg0/0.5/1, (ref) scratch.
   - falsification(Holm): H1(primary pooled cross-cohort brain-age Δ)·H2(inverted-U 양성기준)·H3(post-A2 site-acc≤chance+0.10)·H4(age-adj dx)·H5(vs morphometry).
5. 독립 검증(code-auditor 통계/provenance + research-critic 해석) 후 확정.
6. → TC3 §4.4 결과 → Abstract/Conclusion framing 분기(H1/H3/H5 결과 따라).
```

## 6. 외부 없이 진행 가능한 것 (선택, 대기 중 본문 진척)
- 본문 초안: TC1 §4.3, Related Work §2(SparK/ConvMAE/SimMIM·brain-age·shortcut), Exp setup §4.1, Intro §1 골격.
- Method `[VERIFY]` 확정(코드): 정확 crop/arch, s3d global objective(DINO/Sinkhorn), 코퍼스 226,793.
- 그림: method diagram, Pareto+rank, protocol curve.
- (GPU 선택) TC2 seed-robustness 짧은 sweep — inverted-U의 pretraining-seed 견고성 방어.

## 7. ⚠️ 살아있는 리스크 (resume 시 명심)
- **H5 morphometry**: foundation brain-age < FreeSurfer면 절대성능 주장 빠짐 → TC2 *상대* inverted-U만 생존(valid). 메모리 `t1-morphometry-saturation`.
- **H3 shortcut**: 선형 A2가 비선형 scanner 코드 못 막으면 claim "held-out 전이"로 축소.
- TC1·TC2는 *내부*. AAAI 기술적 무게는 TC3 외부 재현이 실어줌.

## 8. 표준 작업 원칙 (상시)
생성/검증 분리 — 모든 결과/claim은 독립 에이전트(code-auditor+research-critic) 검증 후 확정. abstract/conclusion은 TC3 전 잠그지 않음.
