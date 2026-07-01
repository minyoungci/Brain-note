# AAAI Flagship — STATE & RESUME (handoff)

상태: **ACTIVE(자율 goal 실행) — 코어 확정+audited. Phase A(TC3 fix batch) 완료, Phase B(모델비교) 완료, BrainIAC 추가 중.** 목표: AAAI-27 (full paper 2026-07-28). 모든 실험 setsid nohup(SSH-내성).
- **Phase A(TC3, audited·`external_analysis_v2.json`)**: F2(random 3seed)·F3(per-seed 1v1 paired-Δ)·M5(BCa/Holm)·M1(비선형 site probe)·M4(dx CI) 완료. code-auditor: CRITICAL 0. **결과**: post-A2 brain-age Δ — wg0(dense-only=RankMe argmax) **0.049 n.s.(=random)**, wg≥0.25 **0.23~0.29 p=0.005(생존)**. 외부 RankMe argmax=wg0(255.6). site: linear 0.84→0.25, **MLP 0.70→0.47(>0.35)→held-out-site scoping**. dx wg0≈chance vs balanced 0.72. H2 inverted-U 외부 미재현(내부한정). draft §4.4.
- **Phase B(모델비교, audited 동일 파이프라인·`model_comparison.json`)**: post-A2 우리 balanced/global(wg≥0.25 Δ0.25~0.29) **> ViT 8k baselines(vitmae/vit8mae/vitibot Δ0.16~0.26) > wg0(0.049)**. **"vit_ibot>우리" 우려=pre-A2 아티팩트로 해소**(audited post-A2선 우리가 이김). 우리 site-robust(A2 drop ≤0.02 vs ViT ~0.06). ViT=8k 파일럿(budget caveat). from-scratch=random baseline. draft §4.5.
- **BrainIAC=완료**(`brainiac_comparison.json`): MONAI 1.5.2 cross-attn 이슈였음(수정: 블록 with_cross_attention=False+strict=False, missing0/unexpected0, 타인코드 미수정). 1132 subset(A4 31·AIBL617·AJU484): **BrainIAC brain-age r0.365 > 우리 wg1 0.311/wg0.5 0.280**, dx ~비등. 정직보고: 전용 foundation·morphometry가 brain-age서 우리보다 나음, 우리 기여=rank-fails 방법론(상대,무손상). 우리 ≫ from-scratch·wg0.
- **H5 완료**(`h5_morphometry.json`): FreeSurfer morphometry r=0.474 > foundation 0.31(Δ−0.165) → **H5 기각**, 절대 brain-age 우월 주장 안 함(상대 rank-fails 무손상). draft §4.5.
- **amyloid 완료**(`amyloid.json`, negative control): A4 SUVR r≈random(0.04~0.09), AJU positivity 약함(wg0.5 0.61 vs random 0.51) → **구조 T1은 분자 amyloid 못 잡음**(multimodal-headroom 일치). 유효 task=brain-age+dx.
- **ADNI 완료(2026-07-01)**: FOMO yucca4 전처리 7159 vol(DISJOINT), 라벨 1565(CN840/MCI590/AD124), feature 추출. **H4 cross-cohort dx 성공**(`adni_downstream.json`): wg0.5 ADNI→AJU 0.706[.63,.77]·wg1 ADNI→AIBL 0.714[.65,.78](대륙간 CI>0.5), **wg0=chance→rank-fails 3번째 축 재현**. dx secondary→co-primary 승격. draft §4.4.
- **★Downstream 벤치마크 완료(2026-07-01, `downstream_benchmark.json`·`paired_vs_brainiac.json`·`finetune_benchmark.json`)**: 7 task × frozen(linear/morph_fusion/ensemble)+FT, BrainIAC 1132 subset 공정 head-to-head+paired CI. **우리>BrainIAC 유의 5/7**(MMSE p.007·CDR fusion p<.001·CN-AD fusion p.032·**sex Δ+0.159 p<.001**·amyloid p.003), brain-age tie(**FT로 0.31→0.582 역전**), CN-MCI ns(+). morph⊕우리>morph⊕BrainIAC>morph 전 reg. rank-fails 7 task 전부 재현(wg0 최악). caveat: whole-head 입력 이점(특히 sex)·FT-vs-frozen 비공정(FT-BrainIAC pending). draft §4.6.
- **남은**: FT MMSE/CDR/CN-AD 완료 / FT-BrainIAC 공정비교 / KDRC(전송중) / minyoung4 이관.
마지막 갱신: 2026-07-01.
- **승인된 실행계획**: `~/.claude/plans/twinkling-tickling-rabin.md`. Pre-req 완료(draft/03: global=InfoNCE·norm=**per-crop z-norm**(저장은[0,1], 모델입력은 z-norm=data.py/_znorm·eval load_subject 일치)·selector NO-GO 반영). **Track1 라벨 join 완료·검증**(`results/external_eval/labels/`, `scripts/build_external_labels.py`): brain-age **2093**(A4 992/AIBL 617/AJU 484), dx **CN521/MCI374/AD204**(AIBL+AJU, A4 preclinical 제외), amyloid(A4 992·AJU 484), scanner+fs_vol(26=H5 morphometry) 전수. **다음=GPU 외부 eval 스윕(5 ckpt×brain-age/dx + Δ-over-random + site A2), 사용자 승인 필요.**
- **★★Track1 외부검증 완료·CI검증(2026-07-01, GPU0, `results/external_eval/external_analysis.json`)**: 논문 정착 결과.
  - **H1/H3 brain-age(CN-fit, A2 site 직교화, n=2093)**: **scanner shortcut 거대(balacc 0.838) → A2가 제거(→0.249≈chance 0.25, H3 임계≤0.35 통과)**. balanced/global(wg≥0.25) transfer는 **A2 후에도 random과 CI-분리 생존**(post-A2 Δ 0.22~0.27) → 외부 transfer=진짜(site 아티팩트 아님). **wg0(dense-only=RankMe argmax)은 pre·post 모두 random과 CI 겹침=random 수준.**
  - **H4 dx(CN-vs-AD, age-adjusted)**: within-cohort AIBL/AJU ~0.73(balanced) vs wg0 0.49/0.58(≈chance) → **rank-fails가 dx서도 재현**(2번째 task-family). cross-cohort(AIBL↔AJU) 0.50~0.71 약함→강주장 안 함.
  - **H2 inverted-U 기각**(plateau, down-arm 없음=내부한정). **정착 주장**: "RankMe식 rank-max 선택은 pure-dense(=최악, brain-age random과 구분불가)를 고른다 — 2 task·내부+3외부코호트·scanner 직교화 후에도 성립." **rank-fails가 외부·통제·multi-task로 airtight.**
  - deviation: docs/07는 ADNI→KDRC/AJU dx 상정, 현재 A4/AIBL/AJU만 전처리→dx=AIBL↔AJU subset(명시). BCa 아닌 percentile CI(refine 대상). **해석 확정 전 research-critic 대기.**
- Track2(dense-seg, docs/10): seg 정합 gate(provisional/BLOCKED)→multiclass probe→H-A off-center→H-B LOTO. 정합 gate 통과 시에만 GPU.
- **Phase 1 결과 (검증됨, `results/tc2_labelfree_selection/phase1_5point.json`)**: 5점 wg[0,.25,.5,.75,1] transfer r=[0.599,0.774,**0.792**,0.768,0.683] inverted-U 정점 wg0.5. sanity(3점 재현) 통과.
  - **DECISION=NO-GO**: 사전등록 후보(α-ReQ/evr_top10/silhouette) 어느 것도 argmax@wg0.5 못 맞힘. **α-ReQ argmax@wg0.25** — 3점 "peak@0.5"는 coarse-grid 아티팩트로 판명(Phase 1이 정확히 이걸 잡음).
  - **regret 관점(critic 판정 대기)**: α-ReQ regret 0.019(wg0.25 택, near-optimal) vs rank류 regret 0.194(wg0 택, 파국). uniformity regret 0이나 **비후보→체리피킹 금지**. argmax→regret 리프레임 HARKing 여부 = research-critic 투입.
- 외부: `/home/vlm/data/AAAI_external_yucca4/{A4 7131, AIBL 1295, AJU 610}` (1mm-iso RAS [0,1], 학습코퍼스와 intensity 정합). leakage=**DISJOINT**(`results/external_eval/`). 남은 것: NACC/KDRC(+원하면 ADNI) 전처리 + eval_harness 배선.

## 1. 고정된 결정 (locked)
- **positive-technical-first framing**: headline = **TC2 라벨-프리 objective-balance 선택 (검증중)**.
  - FINDING(verified): dense+global 결합 SSL에선 **effective rank가 transfer와 분리**(rank 단조↓ 14.86→12.93→11.65 vs transfer inverted-U 0.599→0.792→0.683) → **naive rank/RankMe 선택은 rank-max wg0을 골라 *틀린다*** (RankMe에 대한 non-obvious 경고). ★"rank로 최적 선택"은 **주장 금지**(critic F1).
  - METHOD(미확정): rank가 못 잡는 up-arm까지 따라가는 **라벨-프리 기준 C**(후보 α-ReQ·alignment/uniformity·cluster-quality)를 찾아 **selection 절차(leave-one-task-out regret)**로 검증. **C 존재=Phase 0 후보지표 스크리닝이 GO/NO-GO**. 외부검증=[PENDING], 완료형 금지(critic M2).
  - delta vs RankMe/α-ReQ = objective-balance에서 rank가 *실패*함을 보이고 이를 극복하는 C를 selection으로 검증(존재 시).
  / **TC1** budget·protocol-adaptive transfer / **TC3** shortcut-통제 외부평가(헤드라인 아닌 *검증 rigor*). 새 backbone/loss 주장 안 함.
- backbone = SparK의 dense **근사**(dense conv + stage-wise re-mask; 연산은 SparK 진짜 sparse-conv와 **비등가**, ConvMAE/MCMAE 인용) = minor design detail, novelty 아님. anti-leakage probe = 동어반복(증거 아님).
- 코퍼스 = **FOMO300K → 전처리 후 226,793 volumes / 36 public sources**(OpenNeuro 46%·HBN·HCP·BraTS·OASIS1·2·IXI… / **ADNI 미포함** → 외부 ADNI·AIBL 등 dataset-level disjoint; **subject-hash 검증 완료(2026-07-01): A4/AIBL/AJU vs 226,793 4-level DISJOINT**, `results/external_eval/`). 스케일 = method가 필요·유효해지는 *regime*, novelty 자체 아님.
- **Foundation 재학습 불필요** — 기존 150k 체크포인트 `resenc_s3d_{pure,wg0.5,full}` 사용.
- 모든 transfer claim은 `docs/08` shortcut 통제(측정→A2→B) + Δ-over-random + CI 필수. (CLAUDE.md 필수선행 7번)

## 2. 증거 현황 (audit-검증)
| 기여 | 상태 | 핵심 수치 |
|---|---|---|
| **TC1** protocol-adaptive + scratch-convergence diagnostic | ✅ paper-ready(내부, GPU 불필요) | frozen matched **+0.134**[CI 0.408–0.474 vs 0.275–0.340], diagnostic gap **+0.101** |
| **TC2** objective balance + rank (FINDING) | ✅ paper-ready(내부 SOLID) | brain-age inverted-U 0.599→**0.792**[0.762,0.819]→0.683(정점 CI-분리), rank류 monotonic→wg0 선택=regret 0.194 |
| **TC2** label-free selector (METHOD) | 🔴 **argmax NO-GO** (5점 검정) | 사전등록 후보 전부 정점 못맞힘. α-ReQ regret 0.019(near-opt) but argmax@wg0.25. **regret-headline 정당성=critic 판정 대기**. uniformity 승격 금지(비후보) |
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
- raw → **FOMO Yucca 4-step**(crop_to_nonzero/[0,1]-norm/1mm-RAS, **HD-BET/N4 없음**) → npy. (norm=min-max[0,1], znorm 아님 — 학습코퍼스와 실측 일치 확인)
- 현재 디스크: **A4/AIBL/AJU 완료(leakage DISJOINT)**. NACC/KDRC(+선택 ADNI) 미생성. AJU는 344건 skip(비-T1, 정상).

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
- **★TC2 Phase 0→0.5→1 전부 완료(2026-07-01). 결과 = argmax NO-GO** (`results/tc2_labelfree_selection/phase1_5point.json`, README 로그):
  - 5점 transfer r=[0.599,0.774,**0.792**,0.768,0.683] 정점 wg0.5(interior). sanity 통과.
  - **사전등록 후보(α-ReQ/evr_top10/silhouette) 모두 argmax@wg0.5 실패.** α-ReQ argmax@wg0.25(3점 peak@0.5는 coarse-grid 아티팩트로 falsify) — Phase 1이 이 거짓양성을 잡음.
  - **research-critic 판정(2026-07-01, 반영 필수)**: positive selector headline **불가**. 이유 3종:
    (F1) 최적 wg0.5 = **grid 정확한 중점** → "중점 찍기" trivial heuristic regret **0.000 < α-ReQ 0.019** → selector가 무비용 default보다 나쁨.
    (F2) 내부 3점{0.25,0.5,0.75}={0.774,0.792,0.768} **통계적 tie**(Δr≈0.4 SE) → α-ReQ near-opt는 노이즈. 견고한 건 오직 **rank류 wg0 선택 실패(regret 0.194, ~4SE, CI-분리)**.
    (F3) argmax NO-GO 후 regret 앞당겨 headline = HARKing(held-out unlabeled·multi-task LOTO·baseline격파 전엔 exploratory만).
  - **살아남는 것 = cautionary FINDING만**: RankMe식 rank-max 선택이 최악(wg0) 고름. 단 **내부 interior-optimum task가 brain-age n=1**(critic 최대 약점) + inverted-U 외부 재현 실패 시 경고 자체 붕괴(H2 의존).
  - **금지**: uniformity(비후보, regret 0) 승격=체리피킹. α-ReQ 0.019 headline.
  - 학습·watchdog 자기종료, GPU2/3 반환. 5 ckpt DONE(pure/wg0.25/wg0.5/wg0.75/full).
  - **결과 디렉토리 정리**: 활성 TC2 산출물=`results/tc2_labelfree_selection/`(README=실험로그), 전체 맵=`results/RESULTS_INDEX.md`(CANONICAL/REFERENCE/DEV/GITIGNORED 등급). 기존 참조파일(table_c2·collapse·d2_probe·leakage)은 8개 스크립트 참조라 제자리 유지.
- 본문 초안: TC1 §4.3, Related Work §2(SparK/ConvMAE/SimMIM·brain-age·shortcut), Exp setup §4.1, Intro §1 골격.
- Method `[VERIFY]` 확정(코드): 정확 crop/arch, s3d global objective(DINO/Sinkhorn), 코퍼스 226,793.
- 그림: method diagram, Pareto+rank, protocol curve.
- (GPU 선택) TC2 seed-robustness 짧은 sweep — inverted-U의 pretraining-seed 견고성 방어.

## 7. ⚠️ 살아있는 리스크 (resume 시 명심)
- **★TC2 headline 붕괴(critic 2026-07-01)**: label-free selector positive claim 불가(F1 중점-triviality/F2 노이즈/F3 HARKing). 살아남는 건 rank-max mis-selection 경고뿐. 최소수선: (a) TC2를 selector→cautionary/open-problem 재프레이밍, (b) interior-optimum 2번째 task 확보(FastSurfer dense-seg가 off-center 최적점 후보→중점-triviality 격파 가능), (c) regret은 Phase 2 조건(held-out unlabeled·LOTO·external·baseline격파) 충족 전 headline 금지, (d) draft §4.2 3점표→5점(정점→plateau, 새 이웃 wg0.25/0.75는 wg0.5 CI 내), (e) doc/07에 regret 미등록.
- **load-bearing 의존성**: "rank fails" 경고는 **inverted-U 존재를 전제**. C3 외부서 inverted-U 미재현(H2 기각)이면 transfer 단조→rank 안 틀림→경고 자체 붕괴. TC2 negative의 생사도 C3에 달림.
- **H5 morphometry**: foundation brain-age < FreeSurfer면 절대성능 주장 빠짐 → TC2 *상대* inverted-U만 생존(valid). 메모리 `t1-morphometry-saturation`.
- **H3 shortcut**: 선형 A2가 비선형 scanner 코드 못 막으면 claim "held-out 전이"로 축소.
- TC1·TC2는 *내부*. AAAI 기술적 무게는 TC3 외부 재현이 실어줌.

## 8. 표준 작업 원칙 (상시)
생성/검증 분리 — 모든 결과/claim은 독립 에이전트(code-auditor+research-critic) 검증 후 확정. abstract/conclusion은 TC3 전 잠그지 않음.
