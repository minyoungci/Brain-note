# plant — baseline MRI 한 장으로 미래 CDR 진행을 예측하는 전이성(transport) 반증 연구

## 한눈에

- **무엇을:** 단일 baseline T1w 뇌 MRI 한 장으로 *미래* CDR 진행(conversion)을 예측하고, 그 예측력이 deep representation에서 나오는지 — 아니면 FreeSurfer 부피측정(volumetry)+임상 공변량으로 충분한지 — 를 cross-cohort(LOCO)로 검정한다 (출처: note/SCRATCHPAD.md, docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md).
- **왜:** 선행 in-house 연구(EXP01)와 문헌(Bron 2021) 모두 "deep가 부피측정을 못 이긴다"를 시사 → novelty를 deep 우위에 걸 수 없다. 대신 **사전등록된 전이성 프로토콜 + 잘 설계된 null**을 기여로 삼는다 (출처: note/SCRATCHPAD.md §2, §4b).
- **지금 어디까지:** 2026-06-01 시작한 신생 워크스페이스. baseline-anchored 생존분석 라벨 테이블 빌드+독립검증 ✅, 사전등록 문서 ✅까지. 모델링(Cox baseline, deep arm)은 **아직 시작 전** 🟡 (출처: note/SCRATCHPAD.md §5–6).

## 배경·문제 정의

이 워크스페이스는 주변 두 선행 프로젝트의 결론 위에 서 있고, 그 결론이 연구 방향의 제약조건이 된다.

- **EXP01 (minyoung2) — 부정적으로 수정된 결론 (2026-06-01).** "deep T1 표현이 nuisance(site/provenance/tracer/volume) 대비 증분 신호를 운반한다"는 주장은, nuisance baseline을 5-ROI 위축 부피(F9)로 업그레이드하자 LOCO **fold 5/5에서 동률**, pooled에서만 **+0.018 AUROC [+0.011, +0.026]** (n=4966)로 축소됐다. 정직한 결론은 "deep가 해석가능한 부피 baseline을 거의 못 이긴다"이며, 제거 불가능한 제약이다 (출처: note/SCRATCHPAD.md §2).
- **문헌 positioning (literature-scout, 2026-06-01) — 결정적.** Bron et al. 2021 (*NeuroImage:Clinical*)은 MCI→AD conversion에서 deep CNN이 conventional structural feature를 못 이긴다고 보고(SVM 0.756 vs CNN 0.742 internal, p<0.01; external 동률) → "deep가 progression에서 volumetry를 이긴다"는 이미 ~반증됨. Image-only baseline-T1 conversion AUROC는 정직하게 ≈0.70–0.78이며 >0.85는 leakage/multimodal 신호로 본다 [VERIFY DOI 10.1016/j.nicl.2021.102712] (출처: note/SCRATCHPAD.md §4b).

따라서 이 연구는 deep 우위를 **가정하지 않고 검정**한다. 핵심 질문 두 개 (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §1):
- **Q1 (시간축 복제):** 학습된 baseline-scan 표현이 baseline FreeSurfer volumetry + 임상 공변량(age, sex, baseline CDR-SB) 대비 미래 CDR 진행을 **증분(incremental) 예측**하는가?
- **Q2 (전이):** 증분이 있다면 held-out cohort(LOCO)로 **전이되는가?**

진짜 gap = progression에 대한 **체계적 LOCO 증분-가치-over-volumetry 전이 검정**이며, 검정력을 갖춘 사전등록 null도 유효한 1차 결과로 본다 (출처: note/SCRATCHPAD.md §4b, docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §1–2).

## 데이터

- **원천:** `/home/vlm/data/preprocessed_official/official_manifest_full.parquet` — 13,022 세션 × 75 컬럼, 1행/세션, 7개 컨소시엄, read-only canonical (출처: note/SCRATCHPAD.md §1).
- **데이터의 진짜 강점 = 7개 컨소시엄.** 대부분의 논문이 ADNI 단독인 데 비해 cross-cohort transportability가 차별점 (출처: note/daily/2026-06-01.md).
- **함정들 (⚠️):** `cdr_global`/`cdrsb`는 **string 타입** → `pd.to_numeric()` 강제 변환 필수(미변환 시 silent TypeError/오정렬). **시간 간격 컬럼 부재** → session_id 파싱으로만 복원: ADNI/AIBL=날짜(YYYYMMDD), A4=VISCODE 개월, OASIS=일수. NACC=이미지ID(시간 정보 없음, 정렬 불가), AJU=V1/V2, KDRC=단일세션 (출처: note/SCRATCHPAD.md §0·§4, scripts/build_longitudinal_cases.py:75–104).
- **clin_dx_label은 subject-level 상수** → conversion을 인코딩 불가. endpoint는 **session-level cdr_global/cdrsb만** 사용 (출처: note/SCRATCHPAD.md §4, scripts/build_longitudinal_cases.py:9–11).

**설계상 코호트 제한 — 시간 정렬 가능한 4개만.** NACC(정렬 불가), AJU(CN baseline 없는 memory-clinic 군), KDRC(단일세션)는 설계로 제외 (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §4, scripts/build_longitudinal_cases.py:56–58).

| cohort | longit. subj | CN-baseline | converters | follow-up median(y) | LOCO held-out? |
|---|---:|---:|---:|---:|:--:|
| ADNI | 849 | 464 | 130 | 5.72 | **yes** |
| A4 | 769 | 560 | 98 | 1.50 | **yes** |
| OASIS | 363 | 317 | 30 | 5.01 | train-pool (양성 30, 부족) |
| AIBL | 178 | 126 | 14 | 3.11 | train-pool (양성 14, 부족) |
| TOTAL | 2159 | 1467 | 272 | — | |

(출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §4; data/derived/longitudinal_progression/longitudinal_summary.json 직접 확인). A4 follow-up이 짧고(median 1.5y) 검열(censoring)이 많아 ⚠️ 약한 fold다 (출처: note/SCRATCHPAD.md §5 Key numbers).

## 접근·방법

EXP01의 control-battery 프로토콜을 생존분석으로 시간축 확장. 모델링 전에 endpoint와 성공 기준을 **사전 잠금**(pre-registration) (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md).

- **1차 endpoint — 생존(time-to-event).** baseline CN(cdr_global==0) 대상. `event_conversion` = 이후 어느 세션이든 cdr_global≥0.5 관측 시 1, `time_to_event_years` = 첫 conversion 시각(이벤트) 또는 마지막 follow-up(우측 검열). 지표 = **Harrell's c-index**. 생존 프레이밍은 가변 follow-up·검열을 다루므로 **필수**(binary fixed-horizon은 follow-up 기간을 교란) (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §3, scripts/build_longitudinal_cases.py:144–163).
- **2차 — CDR-SB 악화.** Δcdrsb≥0.5. AIBL 제외(CDR-SB 없음). **민감도 — fixed-horizon binary** 24m/36m(간격 코호트 한정), conversion-AUROC 문헌과 연결용·비주력 (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §3).
- **5-arm control battery** (동일 fold·동일 생존 head):
  1. **clinical+volumetry baseline ("the bar")** — age/sex/baseline CDR-SB + FreeSurfer ROI 부피(hippocampus, entorhinal, ventricle, inf-lat-vent, amygdala, parahippocampal L/R; head-size=fs_MaskVol). Penalized Cox. **deep가 이겨야 할 기준선.**
  2. **image-full** — deep baseline-scan 표현(+증분 검정용 동일 임상 공변량).
  3. **mask-only** — brain-geometry 통제(T1 intensity 없음).
  4. **shuffled-label** — leakage probe(c-index≈0.5여야 정상).
  5. **volumetry+image** — 증분 검정: image가 volumetry 위에 더하는가? (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §5, scripts/build_longitudinal_cases.py:60–71)
- **사전등록 판정 기준 (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §7):**
  - **H-증분 ACCEPT** ⇔ (volumetry+image)−(volumetry)의 paired-bootstrap Δc-index **CI 하한 > 0 — ADNI·A4 양쪽 held-out 모두에서**.
  - **H-증분 REJECT(null)** ⇔ ≥1 held-out fold에서 CI가 0 포함. 이 경우 CI 폭 + **power/MDE 분석**과 함께 1차 결과로 보고. pooled-only 유의성만으로는 어떤 주장도 하지 않음.
- **필수 confound 통제:** follow-up 기간(생존 프레이밍이 native 처리 + <1y 제외 민감도), cohort-as-shortcut(cohort-ID-only baseline은 LOCO에서 c≈0.5여야), leakage audit(subject-level split 분리, baseline에 미래 visit 정보 없음, shuffled≈chance), A4 regime shift(preclinical, 별도 보고) (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §6).

## 현재 상태와 결과

| 항목 | 상태 | 근거 |
|---|:--:|---|
| baseline-anchored 생존 라벨 테이블 빌드 | ✅ | `scripts/build_longitudinal_cases.py` |
| 독립 검증(불변식 + 재유도) | ✅ | `tests/test_build_longitudinal_cases.py` PASS |
| 사전등록 문서(endpoint·기준 잠금) | ✅ | `docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md` |
| LOCO 생존 split + leakage audit | 🟡 미착수 | SCRATCHPAD §6 #1 |
| Volumetry+clinical Cox baseline("the bar") | 🟡 미착수 | SCRATCHPAD §6 #2 |
| deep image arm (GPU) | 🟡 미착수(사전승인 대기) | SCRATCHPAD §6 #4 |

- ✅ **라벨 테이블이 feasibility 추정과 교차검증됨.** 빌드 산출 converter 수 ADNI 130 / A4 98 / OASIS 30 / AIBL 14 (총 272, CN-baseline 1467)가 사전 feasibility 추정치와 일치. 생존 필드(event/time_to_event/censoring) 추가·검증 완료 (출처: note/SCRATCHPAD.md §5; data/derived/longitudinal_progression/longitudinal_summary.json 직접 확인).
- ✅ **독립 재유도 검증.** 테스트가 스크립트의 grouping 경로를 재사용하지 않고 raw manifest에서 코호트별 최대 40명(총 ≤160명)을 독립 시간키로 재정렬해 라벨 일치 확인 + 불변식(1행/subject, baseline=최초 세션, follow-up>0, CN만 conversion 라벨, 검열시각=최대 follow-up 등) 전수 검사 (출처: tests/test_build_longitudinal_cases.py:24–86, scripts/build_longitudinal_cases.py:206–270).
- 🟡 **모델 성능 수치는 아직 없다.** 현재 산출물은 "순수 기술(description)"이며 model·performance·생물학적 주장 없음을 코드가 명시 (출처: scripts/build_longitudinal_cases.py:39). c-index 등 결과 보고는 the bar(Cox) 이후 단계.

⚠️ **검정력이 지배적 위협.** held-out converter ADNI 130 / A4 98 → CI가 넓어 **+0.02 Δc-index가 탐지 불가능할 수 있음**. MDE(최소탐지효과) 분석은 후순위가 아니라 deliverable의 일부 (출처: note/SCRATCHPAD.md §5–6, docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §8).

## 폐기·전환된 시도

- ❌ **EXP01 계열 반증(재제안 금지):** amyloid line(OASIS 전용, 라벨 81.9% 결측), discrete tokenizer(증분 신호 없음), "brain-pretrain이 transport를 안정화"(거짓 — ConvNeXt 연관이지 pretrain 아님), "group-DRO가 transport 해결"(코호트 의존, AIBL 붕괴) (출처: note/SCRATCHPAD.md §2).
- ❌ **deep-research(웹검색) workflow 실패.** StructuredOutput 미호출로 전체 실패, 104 에이전트 / ~1.36M 토큰 낭비. **재시도 안 함**, literature-scout 단일 에이전트로 대체 (출처: note/SCRATCHPAD.md §4, note/daily/2026-06-01.md).
- 🟡→설계전환 **NACC/AJU/KDRC 제외.** longitudinal 작업을 시간 정렬 가능한 ADNI/AIBL/A4/OASIS로 한정. NACC(이미지ID, 정렬 불가), AJU(CN baseline 없음), KDRC(단일세션) (출처: docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §4).
- 🟡→설계전환 **F04 consecutive-visit 쌍 폐기.** 기존 F04 longitudinal 쌍은 연속 방문 쌍이라 baseline-anchored가 아니므로, baseline 기준으로 **재빌드** (출처: note/SCRATCHPAD.md §4, scripts/build_longitudinal_cases.py:9–11).

## 남은 과제·다음 단계

사전등록 §7 기준에 대한 greenlight 대기 중. 빌드 순서(각 단계는 독립 검증으로 게이트) (출처: note/SCRATCHPAD.md §6, docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md §9):

1. **LOCO 생존 split + leakage audit** (CPU).
2. **Volumetry+clinical Cox baseline("the bar")** — fold별 c-index + bootstrap CI. **deep 전에, CPU에서.**
3. cohort-ID + shuffled-label 통제.
4. **deep image arm** (GPU — 사전승인 필요) + delta에 대한 증분 검정.
5. **power/MDE 분석** + synthesis.

⚠️ 핵심 기억 수치: A4 follow-up median 1.5y, ADNI 5.7y, OASIS 5.0y; AIBL는 cdrsb 없음 → cdrsb endpoint에서 제외 (출처: note/SCRATCHPAD.md §5).

## 출처 맵

| 경로 | 내용 |
|---|---|
| note/SCRATCHPAD.md | 데이터 인벤토리, 선행연구 frontier, 방향 결정, feasibility 제약, 진행/다음 단계 |
| docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md | 사전등록: framing·endpoint·코호트/split·5-arm·confound·판정기준·위협 |
| scripts/build_longitudinal_cases.py | baseline-anchored 생존 라벨 빌드(시간 파싱·endpoint 정의·불변식 검사) |
| tests/test_build_longitudinal_cases.py | raw manifest 기반 독립 재유도 + 불변식 검증(PASS) |
| note/daily/2026-06-01.md | 시작일 회고: 선행연구 매핑, 방향 결정, deep-research 실패 |
| CLAUDE.md | 운영 원칙(bf16, read-only 데이터, 생성/검증 분리, 사전승인 게이트) |
| .gitignore | 대용량 산출물 제외 정책(코드·문서·실험 텍스트만 추적) |

※ `/home/vlm/data/preprocessed_official/official_manifest_full.parquet`(13,022×75)는 read-only 원본으로 직접 열지 않았으며, 수치는 SCRATCHPAD/prereg/코드의 기재값을 근거로 한다. `data/derived/longitudinal_progression/longitudinal_summary.json`은 직접 확인해 모든 converter 수·follow-up median을 교차검증했다.

---
> 자동 생성: LLM 에이전트가 `plant` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-10.
