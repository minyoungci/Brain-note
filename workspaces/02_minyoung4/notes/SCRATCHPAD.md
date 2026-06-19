# SCRATCHPAD — Decision Log (handoff only)

> 새 세션 인계용 decision log. 긴 연구 노트 아님. 상세는 링크 문서 참조.
> Updated: 2026-06-19

## 현재 결정 (locked)
- 목표 수준: **ACCV-tier CV / medical-vision method paper** (IDH 예측 응용 논문 아님).
- 메인 방법 후보: **CTEC** = lesion-grounded behavioral regularization. **NOT LOCKED.**
  - draft: `docs/context/ctec_method_claim_draft.md`
  - exp02 ceiling probe가 **positive일 때만** `experiments/exp03_ctec_tumor_evidence_consistency/`로 승격.
- Fork: **A (image-only CTEC) = main method**, **B (image+clinical) = main-table comparator/upper-bound** (appendix 아님).
- brain-age disentanglement(C2)는 novelty 아님 → age-independent / clinical-adjusted **평가축으로만** 사용.
- 제외: C4 IRM/V-REx. 보류: C3 confound-balanced contrastive.

## exp02 ceiling probe 결과 (locked)
- **B2 Res3DNet proxy ceiling = NO-GO** (2026-06-19).
  - spec: `experiments/exp02_res3dnet_proxy_baseline/CEILING_PROBE_SPEC.md`
  - full nested OOF: `experiments/exp02_res3dnet_proxy_baseline/runs/B2_res3dnet_proxy/ceiling_probe_full_nested_v1/image_oof_long.csv`
  - report: `experiments/exp02_res3dnet_proxy_baseline/runs/B2_res3dnet_proxy/ceiling_probe_full_nested_v1/ceiling_probe/report.md`
  - OOF validation: 5776 rows = 1444 outer test + 4332 nested train; fold/role/score UID duplicates 0; missing image scores 0.
  - primary result over age_sex: dAUC -0.0405 CI95 (-0.0505, -0.0310), dAUPRC -0.0749 CI95 (-0.1064, -0.0447), dBrier +0.0277 CI95 (+0.0174, +0.0380).
  - strata: 40_59 dAUC -0.1575; 60_69 dAUC -0.1792; 70_plus discrimination undefined (0 mutants).
  - diagnostics: no strong brain-age shortcut signature by tau=0.85 (corr image_logit, age = -0.452).
  - verdict: **do not promote CTEC to exp03 from this B2 evidence**. Pivot or build a materially stronger image baseline before any CTEC performance claim.

- **B3 lesion-ROI/mask-input oracle proxy ceiling = NO-GO** (2026-06-19).
  - purpose: stronger tumor-localized image signal probe after B2 NO-GO. This is **not** the final mask-free method; it uses tumor segmentation at inference as an oracle-style lesion ROI/mask input.
  - full nested OOF: `experiments/exp02_res3dnet_proxy_baseline/runs/B3_lesion_roi_resnet_proxy/ceiling_probe_roi96_nested_v1/image_oof_long.csv`
  - report: `experiments/exp02_res3dnet_proxy_baseline/runs/B3_lesion_roi_resnet_proxy/ceiling_probe_roi96_nested_v1/ceiling_probe/report.md`
  - cohort: clinical subset from image UID set, 1421/1444 subjects (23 dropped for validated segmentation availability).
  - OOF validation: 5684 rows = 1421 outer test + 4263 nested train; fold-internal train/test UID overlap 0; fold/role/score UID duplicates 0; missing image scores 0.
  - primary result over age_sex: dAUC -0.0370 CI95 (-0.0497, -0.0248), dAUPRC -0.0663 CI95 (-0.1092, -0.0260), dBrier +0.0251 CI95 (+0.0137, +0.0363).
  - strata: 40_59 dAUC -0.1185; 60_69 dAUC -0.0723; 70_plus discrimination undefined (0 mutants).
  - diagnostics: no strong brain-age shortcut signature by tau=0.85 (corr image_logit, age = -0.412).
  - verdict: **do not promote CTEC/lesion-grounded IDH performance claim from B3 evidence**. Even an oracle lesion-ROI/mask proxy failed to add clinical-adjusted value over age_sex.

## exp02 implementation notes
  - harness: `scripts/run_ceiling_probe.py` (analysis-only, synthetic self-test 3/3 통과, GPU 없음).
    `p_age_only` LOCO OOF 필수. test-only image OOF는 GO 차단.
  - image runner: `scripts/run_image_baseline.py` (smoke/diagnostic). `draft_first_lexical` full run은 코드가 거부.
    `earliest_numeric` policy, geometry check, bf16 autocast path, deterministic worker seed, full audit CSV 추가됨.
    GPU diagnostic 완료: B2/bf16/96x128x128/augment path 통과. Full-fold raw NIfTI on-the-fly run은 CPU I/O 병목으로 중단;
    `--cache-volumes` run-local tensor cache 추가 및 small GPU cache smoke 통과.
    Full outer-fold B2/96x128x128/bf16/cache jobs 완료:
    UCSD `b2_loco_ucsd_full_96_bf16_cache_v1`, UPENN `b2_loco_upenn_full_96_bf16_cache_v1`,
    UTSW `b2_loco_utsw_full_96_bf16_cache_v1`, MU `b2_loco_mu_full_96_bf16_cache_v1`.
    monitor: `experiments/exp02_res3dnet_proxy_baseline/scripts/monitor_nohup_image_training.sh`.
    outer OOF collector: `scripts/collect_outer_oof.py` (test-only; ceiling GO에는 nested train OOF 필요).
    auto orchestrator log: `runs/B2_res3dnet_proxy/auto_orchestrator_v1/`; outer 4개 완료 후 nested OOF 12개를
    GPU2-5에 자동 launch했고, 완료 시 `build_ceiling_image_oof.py` + `run_ceiling_probe.py`까지 실행 완료.
    Outer 4 folds completed and collected: `runs/B2_res3dnet_proxy/outer_oof_test_only_v1/outer_oof_test_only.csv`
    (test-only, not ceiling-valid). Fold AUC: UCSD 0.591, UPENN 0.844, UTSW 0.732, MU 0.772.
    Nested OOF 12/12 completed. Cohort for this run is conflict-excluded N=1444. Shortcut tau used by report: 0.85.

## 하드 제약
- GPU 실행·장시간 작업은 `nvidia-smi`/cwd/git 상태/command preview 후 Min 승인 필요.
- shared/raw data write/delete/move/rename 금지.
- glioma 데이터는 `docs/context/` 소스 경유 (AD manifest와 별개; CLAUDE.md의 두 manifest는 AD용).

## 검증된 사실 (재확인 불필요)
- `age_only` LOCO AUC `0.890952` — brain-age confound.
- tumor seg coverage **1439/1457 (98.8%)**, 4 consortia 전부.
- age reference frame 사이트별 상이(MU=diagnosis, UPENN=scan, UTSW=imaging, UCSD=fixed). **HARD BLOCKER (미해소)**: MU 진단-스캔 offset max 3.647y 등 사이트 offset이 40/60 경계와 상호작용 → future confirmatory analysis 전 반드시 해소. ("age-bin 보정으로 견고"라고 단정 금지.)
- 활성 agent config home = `/home/jovyan/.claude` (5 agents). `professor`/`pipeline-validator`는 `/home/vlm/.claude`(비활성)라 미등록.
