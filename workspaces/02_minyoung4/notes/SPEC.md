# SPEC — Foundation-model site-generalization audit (minyoung4)

> Living spec. 목적·task·데이터·목표 단일 관리. 직전 closure: `docs/context/FAILED_DECONFOUNDING_EXPLORATION_CLOSURE_20260611_KO.md`.
> 1순위 제약: **leakage(train-eval) 금지 + honest metric(morphometry BAR 대비)**.

## 0. 목적 / Thesis (2026-06-11 확정)

3D T1w MRI 파운데이션 모델(**BrainIAC** 등 공개 SSL)이 **site=population shift에서 정말 일반화하는가**를
우리 7코호트 controlled 벤치로 *엄밀·비순환*으로 측정한다.
> **주장(예상)**: 파운데이션 feature도 site를 강하게 인코딩하며, dementia 같은 morphometry-ceiling task에선
> 단순 FreeSurfer 부피(morphometry)를 넘지 못한다. 단 **brain-age처럼 헤드룸 있는 task**에선 transfer 이점이
> 있을 수 있다 — 이를 분리해 보고한다.

→ contribution: (audit) "foundation models이 multi-site에서 일반화한다"는 통념의 reality-check + (positive 후보)
brain-age transfer. 교란을 *제거*하지 않고(불가, closure 확인) *측정·통제*한다.

## 1. Task / 평가

- **(A) site-probe**: 표현 → cohort(7-way macro AUC). 파운데이션 feature가 얼마나 site-loaded인가. **전 코호트** 사용(라벨 누수 무관).
- **(B) brain-age**: 표현 → age 회귀(MAE). **leakage-clean(AJU+KDRC)**. 헤드룸-positive 후보.
- **(C) CN/AD**: 표현 → CN vs AD(+Dementia). **leakage-clean**(KDRC 내 CV + AJU↔KDRC cross). morphometry-ceiling 확인용.
- 모든 imaging 수치 = **morphometry BAR(fs_vol logistic/ridge) 대비 Δ**. BAR 못 넘으면 그게 audit 발견.

## 2. Data (확정 — `official_manifest_full_n4_real_final.csv`)

- 13,022 QC-PASS T1w / 7,231 subj / 7 코호트. fs_vol·clinical(age/sex/dx/cdr) 내장. longitudinal 2,830명(≤16세션) → **split은 subject 단위**.
- **누수 지도 (공개 파운데이션 기준)**: AJU·KDRC=**CLEAN**(한국 비공개); ADNI·OASIS·AIBL=**LIKELY 누수**; NACC=possible; A4=uncertain·CN-only.
- leakage-clean(AJU+KDRC): CN 305 / AD 487 / MCI 1219 / age 42–91 / 1,910 subj.

## 3. Goal / Win condition

- **site-probe**: 파운데이션 feature → cohort AUC를 morphometry(≈0.9)와 비교. (높으면 "여전히 site-loaded".)
- **CN/AD (clean)**: 파운데이션 frozen-probe가 morphometry BAR를 넘나? (예상: no → ceiling 확인).
- **brain-age (clean)**: 파운데이션이 morphometry MAE를 **유의하게 낮추나**? (예상: 여기엔 헤드룸 — positive 후보).
- 결론은 세 축의 *분리*로 honest하게: "site는 못 줄이고, dementia는 못 넘고, brain-age는 개선" 식.

## 4. BrainIAC 사용 게이트 (선결)
1. **누수 게이트**: BrainIAC 사전학습 데이터셋 목록 확인(논문/supp) → clean 코호트 확정(거의 AJU/KDRC). ⚠️ AMAES와 동일 원칙(closure 참조).
2. **헤드룸 게이트**: clean 코호트에서 BrainIAC frozen-probe가 morphometry BAR(아래 EXP-F0)를 넘는 기미. 없으면 dementia 베팅 비합리.
3. 전처리 매칭: BrainIAC quickstart 사양(우리 v2 192³ 아닐 수 있음).

## 5. 외부 사실 (재논쟁 금지)
- BrainIAC: SimCLR 3D, ~35 데이터셋·10질환, downstream brain-age·IDH·tumor survival. site-invariance 주장 *없음*. (Nature Neurosci 2026; AIM-KannLab/BrainIAC, CC BY-NC.)
- FOMO25 주최: "model/data scaling reliable benefit 없음" → "더 키운다" 축은 약함.
- morphometry LOCO 바 ≈ 0.90–0.92 (선행).

## 6. 실험 로그
| EXP | 내용 | 결과 |
|---|---|---|
| EXP-F0 | **morphometry BAR** (fs_vol): site-probe(7way) + brain-age MAE(clean) + CN/AD(clean) | ✅ site-probe **0.770** / brain-age **5.56yr**(clean; per-cohort 4.5–5.6) / CN-AD **0.911**(clean KDRC-CV, cross 0.87) |

**EXP-F0 인사이트**: CN/AD=ceiling(0.91, 넘기 어려움) / **brain-age=헤드룸 bar(5.56yr → BrainIAC이 이길 수 있는 positive 축)** / site-probe 0.77=reference. → audit 골격 확정: "파운데이션도 site-loaded·dementia 못 넘음, but brain-age 개선" 가설.
| EXP-F1 | BrainIAC 셋업 (가중치 7GB·monai1.3.2 env·전처리 공정성) | ✅ 로드 768-d. 전처리 공정(둘 다 brain-extracted→z-norm→96³) |
| EXP-F2 | BrainIAC frozen-probe vs BAR (3축) | ✅ site **0.842**>0.770(더 site-loaded) / brain-age **5.73**>5.56 / CN-AD **0.735**≪0.911 → **전 축 morphometry 우세** |
| EXP-F3 | few-shot (BrainIAC 주장 강점) | ✅ CN/AD·brain-age **모든 train-N에서 morphometry 우세** (N=20도). few-shot도 패배 |

## 🟢 Audit 결론 (data-confirmed, 2026-06-11)
**대규모 SSL 파운데이션(BrainIAC)이 우리 leakage-clean 코호트의 dementia·brain-age에서, frozen-probe·few-shot 전구간에 걸쳐 단순 FastSurfer morphometry(30-d)를 *못 넘고*, site는 *더* 인코딩(0.842>0.770).** = "파운데이션이 multi-site 일반화·site-invariance를 준다"는 통념의 **엄밀한 반례** (leakage-통제 7코호트). 미검증 모드=full fine-tuning(86M ViT, 소규모 한국 코호트엔 overfit 위험; frozen 열세상 escape 가능성 낮음).
→ contribution: 이 reality-check가 기술적으로 입증 가능한 핵심. 우리 데이터 규모·다코호트·누수통제가 그대로 근거.

## 7. Artifact policy
`experiments/foundation_audit/` 1디렉토리, timestamp 없음, ckpt 이름고정, 캐시 gitignore, 리포트=작은 md/csv. 매 실험 SPEC 갱신.
