# POST_V2_DATA_ALIGNMENT_NOTE

Updated: 2026-05-20
Workspace: `/home/vlm/minyoung4`

## Current state

현재 `/home/vlm/minyoung4`에는 최종 VLM-ready 데이터 symlink, final manifest, split file, experiments/vlm 단계 디렉토리가 없다.

단, OASIS 완료 전 신중한 조기 점검용으로 **partial non-OASIS manifest v0**를 생성했다.

```text
/home/vlm/minyoung4/manifests/v2_partial/vlm_ready_manifest_v2_partial_non_oasis_v0.csv
/home/vlm/minyoung4/manifests/v2_partial/vlm_ready_manifest_v2_partial_non_oasis_v0_report.md
```

이 파일은 final training manifest가 아니다. OASIS, biomarker join, caption policy, split이 모두 빠져 있다.

## Rule

v2 preprocessing이 끝난 뒤에만 다음을 진행한다.

```text
1. v2 preprocessing output inventory
2. subject-session-scan 기준 VLM-ready manifest alignment
3. path/key/diagnosis/class/missingness/biomarker/longitudinal audit
4. caption allowed/forbidden field policy
5. subject-disjoint and cohort-held-out split files
6. shortcut baselines
7. 그 다음 VLM common-core training
```

## Do not do yet

v2 preprocessing 완료 전에는 아래를 만들거나 확정하지 않는다.

- final data symlink tree
- `experiments/vlm/` 실험 구조
- final `vlm_ready_manifest_*.csv`
- subject split files
- caption files that imply a final target
- training configs

## First action after v2 completion

```text
현재 v2 output root와 canonical metadata manifest를 확인하고, read-only inventory report부터 생성한다.
```
