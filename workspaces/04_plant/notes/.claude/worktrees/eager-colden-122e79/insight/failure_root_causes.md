# 실패 근본원인 통합 지도 — 4 라인 원본 검증 (4-사인)

> 2026-06-16 작성. minyoung2·minyoung4·minyoungi 3개 형제 라인 + plant(우리) 라인의 **원본 실패 기록을
> 직접 읽어**(요약본 아님) 추출한 근본원인 통합. 수많은 실패가 **4개 원인**으로 수렴하며, 2개는 구조적
> (불가피), 2개는 자초(통제가능)다. 이 문서는 상위 종합 — 상세 함정은 `methodological_traps.md`,
> dead-end 목록은 `empirical_findings.md` 참조. **새 설계는 "이 4개를 동시에 피하나?"로 점검한다.**
>
> 원본 위치: `/home/vlm/minyoung/OBSERVATORY/workspaces/{01_minyoung2,02_minyoung4,05_minyoungi}/`

---

## 핵심 한 줄

네 라인이 **독립적으로** 같은 벽에 부딪혔다. minyoung4 최종 판정:
> "de-confounding · SSL · foundation-adaptation · harmonization **네 출구가 모두 측정으로 막혔다.**"
> (`02_minyoung4/OVERVIEW.md:5`)

구조적 원인(R1·R2)이 맞물린 **늪**: bias 처리해도 부피 못 넘고(R1이 제거를 막음), 부피 못 넘으니 이미지 우회도 막힘(R2가 천장) → 원인 불명. BRIEF가 경고한 "minyoung4가 두 번 빠진 자리"가 이것.

---

## 4-사인 통합 표

| # | 근본 원인 | 성격 | 원본 증거 (file:line) |
|---|---|---|---|
| **R1** | **site == population 비가역 교란** | 🔴 구조적 | minyoung4: "site=population=severity 얽힘, **traveling-subject=0** → site 제거 = 신호 제거"(`SPEC.md:3-4,88-90`). GRL 1차 cohort AUC 0.84 floor·ΔLOCO≈0(`FAILED_DECONFOUNDING..._20260611_KO.md:27-34`), 2차 site Δ~0.02 비단조(`SPEC.md:84`). minyoungi: 한국(AJU/KDRC)↔서구 거의 disjoint, metadata로 0.84~0.99 식별(`research_notes/daily/2026-06-04.md:42-45`). plant P0: Cramér's V(site,impaired)=0.42 |
| **R2** | **morphometry 신호 천장** | 🔴 구조적 | minyoung2: deep 2.5D **5/5 LOCO 무승부**(pooled +0.018), RT-SSL≈hand-crafted ROI(AJU +0.038/KDRC −0.016/ADNI tie)(`OVERVIEW.md:82`), e01 imaging Δ+0.005 CI[−0.008,0.042]. minyoung4: morph CN/AD 0.91 못 넘음(`FAILED_FOUNDATION..._KO.md:47`). minyoungi: MixStyle **6 run 전부 Δ−0.03~−0.08**, morph LOCO 0.92 site-shift 비용 0.001~0.004(`04_loco_generalization/RESULTS.md:19,50`·`07_deep_mixstyle/RESULTS.md:24,32`). plant: image BN 0.910 ≤ morph 0.931 |
| **R3** | **평가 누수 (in-dist 거품)** | 🟡 자초 | minyoung2: transductive leak — 13K pretrain이 downstream 5.9K 포함 → 0.521→**0.471 하락**(`OVERVIEW.md:80`). minyoungi: random split site 누수; "manifest 39% 결측"이 실은 경로 `.0` 절단 **코드버그**(`findings.md:1.2`). plant: P2-③ 표현-수준 LOCO 누수(F1로 철회). → `methodological_traps.md` T1·T7 |
| **R4** | **약한/confounded target 미결정성** | 🟡 자초 | minyoung2: amyloid = **atrophy-staging confound**(CN-stratify하면 무너짐; AJU/KDRC CN n=17/21로 검증 자체 불가)(`SPEC.md:3.1`), e03 라벨구간=측정구간 "concurrent marker"(`OVERVIEW.md:94,101`). plant T3: amyloid morph 0.66·MCI 0.61. → `methodological_traps.md` T2·T3·T4 |

---

## R1의 정확한 메커니즘 — minyoungi가 밝힌 미묘한 진실

confounded regime에서 **harmonization은 신호를 "드러내는(unmask)" 게 아니라 가짜 신호를 "꺼뜨린다(deflate)".**
- 표준 가정(Saponaro ASD): site가 약한 *진짜* 신호를 가림 → 제거 시 0.58→0.67 ↑
- **우리 데이터**: site가 confounded *가짜* 라벨을 부풀림(AJU=MCI 다수) → 제거 시 CN/MCI raw 0.674 → pooled **0.591 하락**(`08_cn_mci_harmonization/RESULTS.md:10-31`)

→ "harmonization으로 정확도 향상"은 우리 regime에서 **원리적으로 불가능**. site-probe↓이 biology-preserved인지 biology-erased인지 단일 probe로 **판정 불가(undecidable)** — biology-preserving 비순환 probe가 유일 판정자.

추가 정량(minyoungi): site는 **픽셀보다 metadata에 박힘**(metadata 0.761 > image-appearance 0.556 > chance 0.143). ComBat은 fs_vol site 0.238→0.175 달성해도 **image shortcut 0.565는 못 건드림**(별개 레이어)(`02_combat_fsvol/RESULTS.md:31`). N4는 appearance 0.556→0.517만(절반), WhiteStripe/Nyúl/blur 전부 악화 또는 무효.

---

## 설계 점검 체크리스트 — "이 4개를 동시에 피하나?"

새 실험/설계는 아래 4개를 *모두* 회피해야 산다. 하나라도 걸리면 과거 무덤 재방문.

- [ ] **R1 회피:** cross-site bias를 *풀려고* 하지 않는다(4라인이 불가 증명). 회피책 = **단일 코호트로 bracket** 또는 bias를 *측정·특성화*(제거 아님).
- [ ] **R3 방어:** 단일 코호트라도 **subject-level held-out + validation-lock** 필수. pretrain이 downstream subject를 보면 누수(nested). random split 금지.
- [ ] **R2 회피:** target이 **morph-약한 regime**(MCI/progression)이어야 천장 우회. morph-강(AD/CN)이면 단일 코호트 안에서도 천장.
- [ ] **R4 회피:** target이 confounded/약하면 안 됨(amyloid=atrophy-staging confound, concurrent-marker 금지). 비교 bar 명시.

### LOCO 방법론 규율 (`learn/knowledge/01_loco_transport.md`)
- nuisance control battery: shuffled→chance(누수 점검) / nuisance-only / mask-only / **image-full이 +regional volumetry bar까지 이겨야** 신호 주장.
- incremental value: `nuisance+image > nuisance`의 **부트스트랩 CI 하한 > 0**(점추정 금지).
- **multi-seed 필수 · 코호트별 보고**(pooled 평균이 불균형/회귀 은폐 — minyoungi NACC 회귀, AJU CN n=23 제외가 그 예).

---

## 반복된 메타 함정 (4라인 공통)

1. **confound 과소진단** — amyloid atrophy-confound(minyoung2), site=population(minyoung4/i)을 설계 초기에 놓침.
2. **참조 baseline 자기기만** — e01이 reference에 이미 morphometry 포함(minyoung2 `OVERVIEW.md:99`). 계층적 bar(covariate→morph→learned) 명시 필수.
3. **pooled 평균이 회귀 은폐** — minyoungi NACC −0.0442 회귀가 primary 평균에 가려짐.
4. **"데이터 결측"의 1차 용의자는 코드** — minyoungi 39% 결측이 실은 경로버그(datadict stale도 동류 — manifest는 parquet 직접 조회).
5. **검정력 부족 ≠ 동등** — Δ<0.03 detect 불가인데 "deep≈morph" 주장. TOST 필수.
</content>
