# FLAIR 전용 파이프라인

**우선순위 1 추가 모달리티** (WMH/혈관성; 양 코호트 커버리지 ~940–1000, 둘 다 WMH visual read 보유 → 검증 가능).

- 체인: `[AJU dcm2niix]` → N4 → rigid(6-DOF, normmi) → 1mm-RAS T1w reference → crop/pad(T1w centroid) → robust z-score → registration QC → tensor QC. 2D면 native copy도 emit.
- mask는 T1w에서 전파(재추출 안 함).
- config: `configs/flair.yaml` · 근거: `docs/PRIOR_RESEARCH.md §1`

```bash
uv run python -m preprocessing.modalities.flair.pipeline AJU ABD-AJ-0001 V1            # plan(dry-run)
uv run python -m preprocessing.modalities.flair.pipeline KDRC 24009249 ses-1 --execute # smoke(승인 후)
```
