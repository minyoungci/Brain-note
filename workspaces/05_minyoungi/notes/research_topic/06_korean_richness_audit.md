# 06 · Korean richness 실측 감사 + "CN 23" 함정 정정 (2026-06-15)

> **목적**: "Korean 데이터가 신호 풍부 → richness를 주역으로 발견을 뽑을 수 있나"를 *말이 아니라 manifest 카운트*로 결판.
> 부산물로 dossier 전반에 박혀있던 **"AJU CN 23" 수치가 라벨-컬럼 함정 아티팩트**임을 발견·정정.
> **소스**: `Clinical/consortiums/Korean/korean_multimodal_manifest.parquet` (2,196×89) + `korean_clinical_subject_level.parquet` (1,898×51). 모든 수치 `notna()` 직접 카운트(생성/검증 분리).

---

## 1. ⭐ "AJU CN 23" 정정 — 함정 컬럼 아티팩트

AJU 진단이 manifest에 **3개 컬럼**으로 들어있고 값이 서로 다르다:

| 컬럼 | AJU CN | 정체 | 비고 |
|---|---|---|---|
| `clin_dx_label` | **23** | ⚠️ **함정 컬럼** | MCI 980·AD 238·CN 23 — CN/OtherDem을 MCI로 collapse한 열화 라벨. 메모리 `korean-cohort-enrichment-v3`가 경고한 그것 |
| `aju_dx3` = `dx_session` | **144** | ✅ **권위(session-aware)** | MCI 801·AD 239·CN 144·OtherDem 94. `03_spec §4` authoritative 규칙 |
| `dx_3class` (subject-level) | 206 | baseline 4-class | MCI 754·AD 252·CN 206·OtherDem 110 (분양 1,322 기준) |

**결론**: `04 §2`·`02 D-5`·`01 D2`·메모리 2곳이 인용한 **"AJU CN 23"은 틀린 숫자**(열화 라벨 컬럼). 
- 권위 AJU CN = **144 세션** (영상-가용), subject-level = **206**.
- 권위 라벨(dx_session) 기준 **pooled Korean CN = AJU 144 + KDRC 282 = 426** (≠ 23+282).

**파급**: `02 D-5`("AJU CN n=23 → held-out CN/AD 구조적 불가")의 死因이 **6배 과소집계에 근거**. CN 144 / AD 239이면 AJU held-out CN-vs-AD 테스트가 modest하나 *구조적 불가는 아님* → D-5 사망확인서는 **재검토 대상으로 강등**(부활 선언 아님 — 0.91 morphometry 바·MCI 편중은 잔존).

---

## 2. Joinable richness — "통합 1개"가 아니라 "부분겹침 2개" (실측)

session-level 동시-가용(intersection) 카운트:

| 축 | AJU (1,287) | KDRC (909) | pool 가능? |
|---|---|---|---|
| **amyloid SUVR (연속)** | **0** | **481** | ❌ KDRC 단독 자산 |
| amyloid any (binary) | 1,286 | 534 | ✅ |
| APOE | 1,286 | 534 | ✅ |
| 인지(mmse+cdr session) | 1,287 | 477 | ✅ |
| **T1+APOE+인지+amyloid** | 1,285 | 477 | ✅ → **1,762** |
| **+멀티모달영상(FLAIR+PET)** | 962 | 454 | ✅ → **1,416** |
| FULL +혈관+대사labs | 1,256 (WMH-visual) | 247 (Fazekas) | ❌ 척도 비호환 |
| **rich subset 내 CN(dx_session)** | **144** | **29** | — |

**판독**
- **AJU = 大 but amyloid=visual(이진)뿐, SUVR 0.** 혈관=WMH-visual.
- **KDRC = 연속 SUVR(481)이 유일 강점, 단 작고 biomarker-rich subset이 impaired 편중**(rich 477 중 CN 29뿐 — amyloid를 환자에게만 측정한 base-rate 교란).
- **합칠 수 있는 한계선 = binary amyloid + 멀티모달(1,416).** 연속 SUVR·혈관(WMH vs Fazekas)·우울(SGDS vs GDS)은 척도 비호환 → **코호트 내부 분석만**. → `03_spec §7 #5·#9` "직접 비교 금지"가 숫자로 확증됨.

---

## 3. 판정 — richness는 audit의 *부품*으로 최강, 독립 발견으로는 modest

| 질문 | 실측 답 |
|---|---|
| richness를 주역으로 한 발견 가능? | 가능하나 modest. (a) KDRC 연속-SUVR×멀티모달 N≈227–481, CN 부족 / (b) pooled binary-amyloid 멀티모달 N≈1,416 |
| 그게 audit을 대체하나? | **아니오.** "한국≠서구" 주장 순간 traveling=0 벽; 한국-내부 단독(혈관-amyloid)은 N 작고·impaired 편중·서구서 well-trodden |
| audit 플래그십 유지? | **유지.** richness(측정 amyloid·APOE·인지·멀티모달 1,416)는 transportability/비식별성 audit의 **confound 통제·비순환 probe 부품으로 load-bearing** |

**한 줄**: richness는 내가 우려한 것보다 크지만(멀티모달+biomarker 1,416, AJU CN도 144), 독립 임상발견으로는 companion 한 편이 한계. **플래그십은 `04`+`05`(amyloid=covariate transportability 비대칭)로 불변**, richness는 그 substrate.

---

## 4. 전파 정정 (이 문서 기준 진실)

- `04 §2`·`§4`, `02 D-5`, `01 D2`: "AJU CN 23" → **144(session)/206(subject)**, "23은 clin_dx_label 함정" 주석.
- 메모리 `sci-clinical-pivot`·`scanner-site-bias-axes`: 동일 정정.
- `03_spec §3`(CN 206)·`§7 #1`(AJU 206)은 **subject-level이라 정확** — 수정 불요, session=144 cross-ref만.

## 5. 재현
```bash
uv run python - <<'PY'
import pandas as pd
s=pd.read_parquet('Clinical/consortiums/Korean/korean_multimodal_manifest.parquet')
aju=s[s.consortium=='AJU']
print({c:(aju[c]=='CN').sum() for c in ['clin_dx_label','aju_dx3','dx_session']})  # 23,144,144
PY
```

## 6. 연결
- 전략: [`04_sci_clinical_pivot.md`](04_sci_clinical_pivot.md) · [`05_flagship_reframe.md`](05_flagship_reframe.md) · 사망확인서 [`02_trajectory_ranking.md`](02_trajectory_ranking.md)(D-5 재검토)
- 데이터 정본: [`03_processed_data_spec.md`](03_processed_data_spec.md)(§4 dx 권위 규칙, §7 척도 비호환)
- 메모리: `[[sci-clinical-pivot]]` `[[korean-cohort-enrichment-v3]]`(clin_dx_label 트랩 경고 원본) `[[scanner-site-bias-axes]]`
