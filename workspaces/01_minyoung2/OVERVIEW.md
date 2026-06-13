# minyoung2 — 구조 MRI ROI-token SSL과 종단 prognosis 검증

## 한눈에
- 구조 T1 MRI에서 **95개 FreeSurfer DKT+aseg ROI를 "토큰"으로 하는 region-token transformer를 masked-region SSL로 pretrain**하는 연구. 구조 MRI 최초의 ROI-as-unit SSL을 표방하며 downstream은 amyloid가 아니라 CDR-SB 인지 severity로 확정됐다 (출처: SPEC.md §0).
- 이름과 달리 VLM이 아니라 **self-supervised representation learning** 연구다. 핵심 증거는 성능 자랑이 아니라 "ROI-token vs whole-volume" ablation(인과 분리)이다 (출처: SPEC.md §0).
- RT-SSL 본편은 R0–R8 게이트를 통과해 논문 초안(v1)까지 작성됐고 `archive/rtssl_v1/`에 보존됐다. 정직한 결론은 🟡 **"학습 SSL baseline은 능가하나 hand-crafted morphometry와는 comparable(압도 아님)"** (출처: archive/rtssl_v1/paper/RESULTS.md).
- 현재 프론티어는 그 다음 질문 — **종단(longitudinal/change) 축에서 구조-MRI 표현이 classical을 넘는가** — 를 묻는 prognosis 실험(e01–e06)이다. e05에서 morphometry는 baseline 임상중증도 위에 미래 진행을 3/3 유의하게 추가했으나, learned 표현(RT-SSL)은 morphometry를 못 넘는다 (출처: results/RESULTS.md).
- 병행해 amyloid PET/FLAIR 멀티모달 데이터 엔지니어링(manifest·SUVR·tracer 검증) 자산이 구축돼 있다 (출처: reports/).

## 배경·문제 정의
이 워크스페이스는 이전 탐색 phase의 두 가지 교훈 위에 서 있다 (출처: SPEC.md §1):

1. **cross-cohort 전이는 site≈severity confound로 구조적으로 막힘** → within-cohort로 전환.
2. **amyloid-from-T1은 천장이 낮음**(외부검증 ~0.62–0.70, covariate age+APOE4가 매칭).

가장 이른 프레이밍(2026-06-08~09)은 amyloid 분류 + "Shortcut-Suppressed Privileged Distillation(SSPD)"이었다. 당시 scout 검증으로 **task novelty=0**(amyloid-from-T1은 다수 published), 단독 component novelty도 전부 약함을 인정하고 "결합의 필연성(H)"으로만 승부하려 했다 (출처: docs/archive/2026-06-09-accv-novelty-and-experiment-plan.md). 이 방향은 이후 폐기됐다.

핵심 전환은 **task 자체의 교체**다. amyloid는 atrophy-staging confound다 — CN-stratified로 정직하게 나누면 imaging이 covariate에 진다 (출처: SPEC.md §3.1). 반면 **CDR-SB 인지 severity는 위축이 직접적·정당한 인과**이므로 confound가 없다는 것이 새 task 선택의 근거다 (출처: SPEC.md §0, §3.2).

## 데이터
| 자산 | 규모 | 출처 |
|---|---|---|
| T1 192³ SSL pretrain | 7코호트 **13,022** | SPEC.md §2 |
| DKT+aseg parcellation(95 ROI) | 13,022 전부(100%) | SPEC.md §2 |
| amyloid 라벨 + covariate(age/APOE4/sex/mmse) | 4코호트 **3,180** | SPEC.md §2, reports/rematch_report.md |
| downstream(amyloid 100%) | AJU 1,000 / KDRC 534 | SPEC.md §2 |

amyloid 멀티모달 자산은 별도 데이터 엔지니어링으로 정제됐다:
- **T1→amyloid 최근접 재매칭**: 3,291 → **3,180**(drop 111), 전 코호트 gap≤365d 100%, 경로 실재 3180/3180 검증 (출처: reports/rematch_report.md).
- **PET tracer 검증**: ADNI=AV45, OASIS=PiB/AV45 혼재, AJU=FBB 주도(FMM 1건 혼재, n=30 샘플 기준), **KDRC는 이미지 헤더에 tracer 미기재 → 정량 PET 보류, visual read만 사용**. tracer가 코호트마다 달라 SUVR의 cross-tracer 정량 비교는 불가, Centiloid harmonization 별도 필요라고 명시 (출처: reports/tracer_verification.md).
- PET→T1 정합 SUVR(192×224×192)과 FLAIR 전처리 파이프라인 일부가 `data/preprocessed_mm/`에 산출됨 (출처: preprocessing/resolve_pet.py, prep_pet.py, prep_flair.py).

종단 라벨은 `v4_longitudinal_manifest.csv` + `visit_level_cdr_v7.csv`, 변화(delta) feature는 minyoung3의 `aeb_longitudinal_pair_table.csv`(10,562 pairs, baseline+delta ROI 16)를 참조한다 (출처: results/RESULTS.md).

## 접근·방법
**RT-SSL(Region-Token SSL)** 설계 (출처: SPEC.md §4, archive/rtssl_v1/paper/PAPER.md):
- 공유 3D CNN이 T1 볼륨을 feature map으로 인코딩 → 95개 DKT+aseg 영역으로 pooling해 **region token 95개** 생성.
- transformer가 **masked-region modeling**(마스킹된 ROI의 morphometry=부피·intensity를 나머지 ROI 맥락으로 복원) 목적으로 학습. positional encoding = ROI 해부 위치.
- downstream: pretrained encoder를 frozen → embedding 위에 Ridge/linear-probe로 CDR-SB 회귀.

검증 원칙은 일관되게 엄격하다: **생성·검증 분리, 자기평가로 완료/novelty 판정 금지, 모든 게이트는 독립 산출물로 판정**(SPEC.md §0). leakage 차단은 fold 내부 scaler/imputer fit, subject-level GroupKFold, bootstrap CI로 강제됐다 (출처: results/RESULTS.md).

**Must-beat baseline** 우선순위: ① covariate LR(age+APOE4+sex) — 못 이기면 중단, ② FreeSurfer-ROI-volume XGBoost, ③ 일반 SSL(Models Genesis / Swin-UNETR SSL) + DAMT(ACCV2024) (출처: SPEC.md §6).

## 현재 상태와 결과

### RT-SSL 본편 — R0~R8 게이트 통과, 논문 초안 v1
모든 수치는 code-auditor 독립 감사 + **inductive(subject-disjoint)** + multi-seed CV 기준 (출처: archive/rtssl_v1/paper/PAPER.md).

✅ **Task feasibility(CDR-SB)**: 전 코호트서 imaging이 covariate(age+sex)를 압도 (출처: SPEC.md §3.2):

| cohort | covariate corr | ROI imaging corr | imaging 기여 |
|---|--:|--:|--:|
| AJU | 0.045 | 0.433 | +0.39 |
| KDRC | 0.005 | 0.394 | +0.39 |
| ADNI | 0.194 | 0.482 | +0.29 |
| OASIS | 0.081 | 0.284 | +0.20 |

✅ **Main result(CDR-SB, inductive, frozen-probe, 5-seed)** (출처: archive/rtssl_v1/paper/PAPER.md Table 2):

| 표현 | AJU | KDRC | ADNI |
|---|--:|--:|--:|
| **RT-SSL (ours)** | **0.471±0.018** | **0.378±0.012** | **0.492±0.001** |
| whole-volume anatomy SSL(matched head, ablation) | 0.390±0.003 | 0.305±0.009 | 0.424±0.005 |
| Models-Genesis(generic) | 0.417±0.007 | 0.359±0.014 | 0.440±0.008 |
| Swin-UNETR SSL(transformer) | 0.366±0.017 | 0.248±0.008 | 0.417±0.007 |
| hand-crafted ROI | 0.433 | 0.394 | 0.482 |
| covariate(age+sex) | 0.045 | 0.005 | 0.194 |

✅ **핵심 ablation 유지(inductive)**: ROI-token > whole-volume(matched head) 전 코호트 +0.07~0.08(유의). 두 whole-vol SSL(anatomy/generic)은 서로 비슷하고, 더 강한 Swin-UNETR transformer도 CNN+region-token에 뒤짐 → **tokenization이 차이의 원인**(인과 분리) (출처: SPEC.md §5 R8, archive/rtssl_v1/paper/PAPER.md §5.2).

✅ **Positional(해부 정체성) — 코호트 의존적 효과**: inductive 프로토콜 동일 5-seed 기준. ADNI(−0.053)·KDRC(−0.037)에서 유의, AJU는 효과 없음(+0.010). SSL recon L1은 0.467→0.705로 저하. 효과가 전 코호트 일률적이지 않음을 논문에 명시 (출처: archive/rtssl_v1/paper/PAPER.md Table 3):

| | with-pos | no-pos | Δ |
|---|--:|--:|--:|
| AJU | 0.471±0.018 | 0.481±0.004 | +0.010 |
| KDRC | 0.378±0.012 | 0.341±0.017 | −0.037 |
| ADNI | 0.492±0.001 | 0.439±0.009 | −0.053 |

❌→🟡 **transductive 착시 정정(R8/C1)**: 감사 전 transductive 수치(AJU 0.521/KDRC 0.400/ADNI 0.525)는 downstream subject가 pretrain에 포함된 누수였다. downstream subject 전 시점 제외 재pretrain(13K→5,956)하니 **0.471/0.378/0.492로 하락** (출처: SPEC.md §5 R8).

🟡 **정직한 한계(논문 명시)** (출처: archive/rtssl_v1/paper/RESULTS.md §5, ABSTRACT.md):
- **vs hand-crafted morphometry = comparable**(AJU +0.038, ADNI tie, KDRC −0.016) — 압도 아님. "beats all baselines"라 쓰지 말 것이 명시 규칙.
- KDRC 약함(n=534), frozen linear-probe가 fine-tune보다 강함, 실제 DAMT Swin 미재현(matched-backbone로 대체).
- **Swin-UNETR SSL 수치는 PAPER.md Table 2에 수록(0.366/0.248/0.417)됐으나 ABSTRACT.md는 미동기화 상태로 [PENDING] 표기 잔류.**

### Prognosis 전환 — 현재 프론티어
cross-sectional에서 RT-SSL이 hand-crafted와 comparable이었으므로, 질문을 **종단/변화 축**으로 옮겼다 (출처: results/RESULTS.md).

| exp | 질문 | 결과 | 판정 |
|---|---|---|---|
| e01 | baseline imaging이 morphometry+공변량 위에 미래전환을 더하나 | MCI→AD: 공변량만 0.815, +imaging Δ+0.005 CI[−0.008,0.042] | **tie** |
| e02 | preclinical(CN)에서 imaging이 demographics 위에 더하나 | CN→전환: DEMO 0.667, imaging 추가 0(morpho 0.599<DEMO) | **tie** |
| e03 | imaging *변화*(delta)가 단면 baseline 위에 더하나 | 3/4 타깃 유의(+0.017~0.026) **단 concurrent(라벨구간=delta구간)** | **concurrent only** |
| e04 | 초기 변화[t0→t1]가 *그 이후*(비중첩) 진행을 단면 위에 예측하나 | 미래 진단악화 +0.036 CI[0.002,0.071] 유의(marginal); 미래 CDR 비유의 | **marginal prognostic** |
| e05 | (교정) baseline morphometry가 baseline 임상중증도 위에 미래진행 더하나 | 3/3 유의(+0.025~0.087 CI>0) | **morphometry prognostic** |

🟡 **정직한 결론** (출처: results/RESULTS.md §핵심 결론):
1. **(교정됨) morphometry(baseline imaging)는 prognostic하게 유용하다** — e05(시점정렬): baseline morphometry가 baseline 임상중증도 위에 미래 진단악화/AD전환/CDR진행을 3/3 유의하게 추가. 이전 e01의 "saturated"는 부정확 — e01은 reference에 morphometry가 이미 포함된 상태여서 "learned 표현이 morphometry 위에"를 본 것이지 "morphometry가 clinical 위에"가 아니었음.
2. **그러나 *learned* 표현(RT-SSL embed)은 morphometry를 못 넘는다** — e01(RT≈HC_COV), cross-sectional 인지/amyloid 모두 consistent. 프로젝트 전체의 robust한 negative.
3. **변화(change) 축**: e03(delta over baseline)은 concurrent(라벨구간=delta구간, critic 확인)으로 staging marker이지 예측 아님. e04(disjoint)에서 초기 atrophy-rate가 미래 진단악화를 단면 위에 marginal 추가(+0.036, CI[0.002,0.071], ADNI 중심).
4. **단 age/sex 미가용 → demographics 통제 불가(e05 한계)** (출처: experiments/prognosis/e05_prognosis_aligned.py).

### 멀티모달 데이터 엔지니어링(병행)
✅ **Phase1 이중 covariate baseline LOCO**(seed=42, n_boot=1000): a-dem mean 0.743, **a-clin mean 0.775**. AJU(+0.060)·KDRC(+0.045)에서 clinical gap이 커 clinical-stage 교란 실재. fold간 spread가 커 pooled 금지가 정당화됨. n_cohort=4 → subject-level bootstrap CI가 cohort-level 불확실성 과소추정(방향·일관성으로만 해석) (출처: reports/phase1_covariate_baseline.md).

## 폐기·전환된 시도
- ❌ **amyloid downstream task**: atrophy-staging confound(CN-stratified서 imaging<covariate). AJU/KDRC CN n=17/21로 검증조차 불가 → 폐기, honest-secondary로만 잔류 (출처: SPEC.md §3.1).
- ❌ **SSPD(Shortcut-Suppressed Privileged Distillation) + amyloid 분류 프레이밍**: task novelty=0, 단독 component novelty 전부 약함으로 판정 → docs/archive로 보존 (출처: docs/archive/2026-06-09-accv-novelty-and-experiment-plan.md).
- ❌ **cross-cohort 전이**: site≈severity confound로 구조적 차단 → within-cohort 전환(이전 phase, git tag `exploratory-v1`에 보존) (출처: SPEC.md §1).
- 🟡 **transductive 평가 수치 전체**: 누수로 무효 → inductive 재측정으로 대체 (출처: SPEC.md §5 R8).

## 남은 과제·다음 단계
SPEC가 명시한 잔여 작업 (출처: SPEC.md §5 "남은 것"):
1. Models-Genesis baseline도 inductive 재측정
2. masked / contrastive 항 ablation 분리
3. AD/age 보조 task로 de-risk
4. KDRC 보강(n=534, marginal)
5. (optional) 실제 DAMT Swin 재현
6. 논문 작성(ABSTRACT.md Swin-UNETR 행 동기화 필요)

프론티어 쪽에서는 **e06**(learned 표현의 *change*가 classical delta-ROI를 보완하는가)가 핵심 미해결 질문이다(코드: `experiments/prognosis/e06_learned_delta.py`). 단, 지금까지의 종단 신호가 marginal(e04 CI 하한 0.002)이라 **이 노선이 강한 contribution으로 성립할지 자체가 미정 리스크**다 (출처: results/RESULTS.md).

가장 큰 정직한 리스크: RT-SSL이 hand-crafted morphometry를 못 넘으므로 headline은 "method(region-token formulation)가 학습 SSL paradigm을 이긴다 + 인과 ablation"으로 좁혀야 하며, 성능 우위 주장은 금지돼 있다 (출처: SPEC.md §7, archive/rtssl_v1/paper/ABSTRACT.md).

## 출처 맵
- `SPEC.md` — SSOT. RT-SSL 설계·데이터·R0~R8 게이트·task 전환·리스크
- `results/RESULTS.md` — prognosis 실험 인덱스(e01–e05, e06 진행), 현재 프론티어 결론
- `archive/rtssl_v1/paper/ABSTRACT.md` · `RESULTS.md` · `PAPER.md` — RT-SSL 논문 초안 v1, 최종(inductive) 수치; PAPER.md Table 2–3이 권위 소스(RESULTS.md보다 updated)
- `docs/archive/2026-06-09-accv-novelty-and-experiment-plan.md` · `2026-06-08-amyloid-classification-task-and-data-spec.md` — 폐기된 amyloid/SSPD 프레이밍
- `reports/phase1_covariate_baseline.md` — 이중 covariate LOCO baseline
- `reports/rematch_report.md` — T1→amyloid 재매칭(3291→3180)
- `reports/tracer_verification.md` — PET tracer 검증, KDRC 정량 보류
- `experiments/roitoken.py` — RT-SSL 모델/SSL(`--exclude_ds` inductive, `--no_pos` ablation)
- `experiments/prognosis/e05_prognosis_aligned.py` · `e06_learned_delta.py` — 시점정렬 prognosis 교정 실험 및 현재 frontier
- `experiments/{baselines,swin_ssl,aux_tasks,data_roi,cache_img,cache_img13k}.py` — baseline·보조 task·캐시
- `preprocessing/{resolve_pet,prep_pet,prep_flair,verify_tracers}.py` — 멀티모달 전처리

---
> 자동 생성: LLM 에이전트가 `minyoung2` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-13.
