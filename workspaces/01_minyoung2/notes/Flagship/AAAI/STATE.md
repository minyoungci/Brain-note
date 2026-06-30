# AAAI Flagship — STATE & RESUME (handoff)

상태: **PAUSED — 외부 raw 데이터 확보 대기.** 목표: AAAI-27 (full paper 2026-07-28), positive-technical-novelty(TC2 headline).
마지막 갱신: 2026-06-30.

## 1. 고정된 결정 (locked)
- **positive-technical-first framing**: headline = **TC2 라벨-프리 objective-balance 선택 (검증중)**.
  - FINDING(verified): dense+global 결합 SSL에선 **effective rank가 transfer와 분리**(rank 단조↓ 14.86→12.93→11.65 vs transfer inverted-U 0.599→0.792→0.683) → **naive rank/RankMe 선택은 rank-max wg0을 골라 *틀린다*** (RankMe에 대한 non-obvious 경고). ★"rank로 최적 선택"은 **주장 금지**(critic F1).
  - METHOD(미확정): rank가 못 잡는 up-arm까지 따라가는 **라벨-프리 기준 C**(후보 α-ReQ·alignment/uniformity·cluster-quality)를 찾아 **selection 절차(leave-one-task-out regret)**로 검증. **C 존재=Phase 0 후보지표 스크리닝이 GO/NO-GO**. 외부검증=[PENDING], 완료형 금지(critic M2).
  - delta vs RankMe/α-ReQ = objective-balance에서 rank가 *실패*함을 보이고 이를 극복하는 C를 selection으로 검증(존재 시).
  / **TC1** budget·protocol-adaptive transfer / **TC3** shortcut-통제 외부평가(헤드라인 아닌 *검증 rigor*). 새 backbone/loss 주장 안 함.
- backbone = SparK의 dense **근사**(dense conv + stage-wise re-mask; 연산은 SparK 진짜 sparse-conv와 **비등가**, ConvMAE/MCMAE 인용) = minor design detail, novelty 아님. anti-leakage probe = 동어반복(증거 아님).
- 코퍼스 = **FOMO300K → 전처리 후 226,793 volumes / 36 public sources**(OpenNeuro 46%·HBN·HCP·BraTS·OASIS1·2·IXI… / **ADNI 미포함** → 외부 ADNI·AIBL 등 dataset-level disjoint; subject-hash 검증은 raw 도착 시 필수). 스케일 = method가 필요·유효해지는 *regime*, novelty 자체 아님.
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
- **★TC2 Phase 0 (label-free 스크리닝) — 실행 완료(GPU2), DECISION=GO(잠정)**:
  `scripts/phase0_labelfree_screen.py` → `results/phase0_labelfree_screen.json`. sanity 통과(brain-age r 0.599/0.792/0.683 정확 재현).
  결과: rank/participation/stable_rank/silhouette=**단조**(decoupling 재확인), **alpha_req=뚜렷한 peak@wg0.5**(2.41→4.08→3.00, transfer 정점과 일치=강후보), uniformity=약한 peak.
  → **유일 강후보 = α-ReQ**(spectral shape). 단 3점이라 necessary-but-weak.
- **Phase 0.5 hardening 완료(GPU2)**: α-ReQ peak@wg0.5가 **4/4 fit-range에서 robust + 파워로 R²≈0.98–0.99** = fit 아티팩트 아님 확정. features 캐싱 `results/phase0_feats/`.
  단 **evr_top10=단조(corroborate 실패), uniformity 약함 → 후보=α-ReQ 단일**. ⚠️메커니즘 caveat: α-ReQ peak↔transfer peak은 경험적 일치이나 α-ReQ 이론으로 "왜 4.08 최적"은 미설명(spectral-smoothness 원리는 개발 대상).
- **Phase 1 진행 중(2026-06-30 launch)**: wg0.25(GPU2)·wg0.75(GPU3) 재학습 = 5-grid{0,0.25,0.5,0.75,1}. ~10–12h.
  ★재현 검증: 런치 config는 기존 `.log` 첫줄([supervisor] launch)에서 복구 — **`--global_mode infonce`(train.py 기본 dino 아님!)** 가 핵심 trap, 추측했으면 붕괴. 기존 3개와 동일 config(crop96·batch16·proj1024·steps150k·subset0·composition all·koleo0.1·lr1e-4·seed0), w_global만 변경. startup 검증: corpus 221,376 동일·w_global이 step-0 loss(0.25=1.80/0.75=3.18)에 정확 반영.
  런처: `pretrain/supervisor.py --out <dir> -- <train args>`. **resume 시 두 ckpt 완료되면**:
  → `phase0_labelfree_screen.py` **준비 완료**(DEFAULT_CKPTS에 wg0.25/0.75 추가, analyze N점 일반화 = "후보지표 argmax == transfer 정점 wg" 검정, smoke PASS). **ckpt 완료 시 그대로 재실행**(`--device cuda --max_subj 494`)하면 5점 selector 검정 → `results/tc2_labelfree_selection/phase1_5point.json`: α-ReQ argmax가 transfer argmax와 일치하면 GO(비인공물), 아니면 NO-GO→decoupling. 이후 Phase 2(leave-one-task-out regret, 외부 데이터).
  - **내성(SSH·크래시)**: 학습 tty-detached + **`scripts/resume_phase1.sh watch`** detached watchdog(pid 가동중, 10분마다 죽은 run을 checkpoint서 자동 재개, 둘 다 DONE이면 자동 종료). 서버 리부트 시만 수동 `bash scripts/resume_phase1.sh` 1회.
  - **결과 디렉토리 정리**: 활성 TC2 산출물=`results/tc2_labelfree_selection/`(README=실험로그), 전체 맵=`results/RESULTS_INDEX.md`(CANONICAL/REFERENCE/DEV/GITIGNORED 등급). 기존 참조파일(table_c2·collapse·d2_probe·leakage)은 8개 스크립트 참조라 제자리 유지.
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
