---
title: "2026-05-26 minyoung3 pre-delete inventory and reset note"
date: 2026-05-26
tags:
  - reset
  - pre-delete-inventory
  - brain-image-ai
  - pet-amyloid
workspace_to_reset: "/home/vlm/minyoung3"
---

# 2026-05-26 — `/home/vlm/minyoung3` 삭제 전 inventory / reset note

Min이 다른 방법 제안을 위해 데이터 구성을 다시 해보자고 했고, `/home/vlm/minyoung3`의 이전 실험 내용을 삭제 요청했다.

삭제 전 확인한 상태:

- Target: `/home/vlm/minyoung3`
- Exists: yes
- Directory: yes
- Active processes referencing target: none observed
- Git branch shown from target: `master`
- Important caveat: `git rev-parse --show-toplevel` returned `/home/vlm`, so `/home/vlm/minyoung3` is not an isolated nested git repo; it is a subdirectory under the broader `/home/vlm` git tree.
- Remote visible from that tree: `https://github.com/HeeKuk99/missing-modality-brain-tumor-seg.git`
- `git status --short -- /home/vlm/minyoung3`: clean before deletion.

Top-level inventory and approximate sizes:

```text
512B  .gitignore
512B  README.md
512B  results
512B  runs
1.0K  configs
2.0K  tests
4.0K  docs
18K   reports
81K   scripts
3.1M  manifests
```

Top-level entries:

```text
.gitignore
README.md
configs/
docs/
manifests/
reports/
results/
runs/
scripts/
tests/
```

Files observed:

```text
tests/test_training_readiness_import.py
tests/test_linkage_smoke_script_import.py
tests/test_audit_script_import.py
scripts/audit_pet_amyloid_training_readiness.py
scripts/audit_pet_amyloid_t1w_linkage_smoke.py
scripts/audit_pet_amyloid_source_contract.py
reports/PET_AMYLOID_TRAINING_READINESS_AUDIT.md
reports/PET_AMYLOID_T1W_LINKAGE_SMOKE.md
reports/PET_AMYLOID_SOURCE_CONTRACT_AUDIT.md
configs/source_contract.yaml
docs/context/VALIDATION_LOG.md
docs/context/OPEN_QUESTIONS.md
docs/context/WORKSPACE_STATE.md
docs/PATH_CONVENTIONS.md
docs/TARGET_CONTRACT.md
docs/PROJECT_PLAN.md
README.md
manifests/audits/pet_amyloid_training_readiness_audit.json
manifests/audits/pet_amyloid_t1w_linkage_smoke_manifest.csv
manifests/audits/pet_amyloid_t1w_linkage_smoke.json
manifests/audits/pet_amyloid_source_contract_audit.json
```

Raw/shared data safety:

- No top-level symlink was observed.
- Some files mention `/home/vlm/data/raw` and `/home/vlm/data/preprocessed_official`, but these appear as referenced paths in configs/scripts/audit JSONs, not as files to delete inside `minyoung3`.
- Deletion must not touch `/home/vlm/data/raw` or `/home/vlm/data/preprocessed_official`.

Recommended deletion scope:

1. Conservative reset: delete experiment artifacts only: `manifests/`, `reports/`, `runs/`, `results/`.
2. Strong reset: delete all previous experiment scaffold contents inside `/home/vlm/minyoung3`, including `configs/`, `docs/`, `scripts/`, `tests/`, `manifests/`, `reports/`, `runs/`, `results/`, `README.md`, `.gitignore`, while preserving the directory `/home/vlm/minyoung3` itself.
3. Archive-first reset: move/copy the current contents to an archive outside the target, then delete.

Because Min said “이전 실험 내용은 모두 삭제”, the likely intended scope is option 2, but destructive deletion should be confirmed after this inventory.
