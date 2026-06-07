# minyoung4 — full_n4 nuisance-aware 3D 표현학습 → ROI-intensity LOCO 게이트 감시 카드

> **목적:** full_n4 manifest 기반 shortcut-aware 3D 표현학습의 현황 요약(2회 피벗·현재 BLOCKED)  ·  **출처:** `/home/vlm/minyoung4/docs/context/full_n4_experiment_redesign_20260603/`  ·  **갱신:** 2026-06-07 (HEAD `6f0754d`, 2026-05-29 — 이후 전부 미커밋)

## ⚠️ 최우선 사실 — 6/3~6/7 작업 전부 미커밋

git HEAD = `6f0754d`("chore: retired ROI-token 정리", **2026-05-29**). 재가동 산출물
(`docs/context/full_n4_experiment_redesign_20260603/` — stage 스크립트 227개·md 596개·전 결과)은 **untracked**
(`git ls-files` 0건). 6/3 `git fetch` 1회(`.git/FETCH_HEAD` 06-03 09:50)·6/7 09:25 `.git` mtime은 commit이 아니라 status/index 읽기.
이전 카드의 `[VERIFY]`(커밋 여부 불명)는 이제 확정: **아무것도 커밋되지 않았다.** 4일치 작업이 디스크에만 존재.

## 주제 (2회 피벗 후 현황)

핵심 질문은 minyoung2 EXP01의 "deep ≈ volumetry, shortcut 의심"에 대한 표현학습 차원의 응답:
**scanner/source/consortium shortcut을 GRL+decorrelation으로 벗긴 3D T1w 표현이 단순 ROI 부피 baseline을 넘는가.**

궤적이 두 번 피벗했다(둘 다 데이터로 기각됨):
1. (학습된 3D 표현) → scanner-family 누수·morphometry 미초과로 ❌
2. (calibration-only) → 비-risk 그룹 악화로 ❌
3. (현재) **pre-registered ROI-intensity-feature LOCO 평가 게이트**(Stage 219~232) — **G0 feature coverage 미통과로 BLOCKED**.

## 데이터 정책 (full_n4)

base = `/home/vlm/data/preprocessed_official/official_manifest_full_n4.csv` (13,022 rows / 7,231 subj, `final_tensor_n4_path`/`final_mask_n4_path`).

| 역할 | 코호트 | 수 |
|---|---|---|
| supervised CN/AD | ADNI(75AD/832CN)·AIBL(51/422)·KDRC(130/255) | **1,765 subj** |
| CN-only domain control | NACC(935CN, held 제외)·OASIS(7AD, low-cell sensitivity-only) | — |

## 방법 (코드 검증됨)

- **domain-adversarial(GRL)**: `stage8h_…_adversarial_audit.py`의 `grad_reverse()`(line 97), `--grl-lambda` 기본 1.0. loss = recon + source·CE(GRL(emb), acq_scanner_source) + scanner·CE(GRL(emb), scanner_family). Stage 8K/8M/8N/8O는 content/nuisance 분해(content adv + nuisance sup + decorrelation + ROI-ratio penalty).
- **shortcut-aware ROI-text contrastive**: `stage8c_…_roi_text_gpu_smoke.py`(InfoNCE ROI-identity + hard-neg margin + ratio decorr). GPU 실행되나 **n=18 subj / 90 ROI pair / 3 epoch smoke** — 성능 claim 아님.

## 결과 진행 (전부 ❌/🟡 부정적, 출처 병기)

| 단계 | 규모 | 결과 | 판정 |
|---|---|---|---|
| 8N cond005 | n=55 bounded | ROI-ratio R² 0.268→0.161·held AUC 0.713→0.796 개선, **scanner-family bAcc 0.328→0.356 악화** | 🟡 clear win 아님 |
| 8N cond010(강) | n=55 | scanner-family bAcc 0.611 | ❌ 사용 금지 |
| **8M full-cohort** | n=1,765 | bounded **일반화 실패**: scanner-family 0.328→**0.660**·held AUC 0.713→**0.669**. ROI-volume-only baseline AUC ≈ **0.933** | ❌ 표현 분해 불충분 |
| 8O/8Q/8R | n=1,765 | content embedding 추가 시 **음의 delta**(−0.008~−0.037). ROI-volume residualize → embedding AUC 0.529(chance) | ❌ 독립 잔여 MRI 신호 없음 |
| 8218 calibration | — | KDRC 비-risk 그룹 Δlog-loss +0.383/499 subj | ❌ calibration-only 중단 |

morphometry comparator(Stage212/219, `morph_sqrt_label_env_C0.03`): KDRC AUC 0.9122·AIBL 0.9177~0.9203·ADNI 0.8742~0.8818.

## 현재 상태 — BLOCKED (Stage 219~232)

- `stage221_…`: `gate_pass: False`, 기대 **3,622 subj** 중 complete **1,765**, missing **1,857**. 모델 미학습.
- 6/7 세션(stage 222~232, 07:50~09:24)은 전부 **resumable feature-extraction 파이프라인 구축·단위테스트**(timing·resume-safety·contract). **실제 추출 미실행**(`stage226_…` 출력 dir `exists: False`).

## 다음 게이트

`stage222_resumable_stage8x_feature_generator.py`를 **1,857 subj × 5 ROI mask(9,285 mask, ~9.4GB I/O)**에 실행 → G0 통과.
**장시간 전처리이므로 Min 승인 필요(Confirmation Gate).** G0 통과 후에만 Stage221 LOCO 모델링·Stage224 shortcut audit 진행.

## 한 줄 리스크

⚠️ **전부 미커밋**(4일치 작업 안전망 0) · scanner-family 누수가 미해결 핵심(bounded 개선→full-scale 악화 0.328→0.660) ·
bounded smoke n=55가 n=1,765로 일반화 실패(contrastive smoke n=18) · raw morphometry 지배(residualize 시 chance) ·
사전등록 guard가 test 관측 후 도출돼 fresh held cohort 재검증 필요. 현 과학적 결론은 **부정**(이미지 표현 ≯ ROI morphometry).
