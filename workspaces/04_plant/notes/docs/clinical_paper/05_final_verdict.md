# 최종 판정 — incremental-value/longitudinal 라인 (2026-06-24)

> goal: (A)(B) 확인 후 잡을 수 있는 연구 주제 finding 존재 여부.
> 결론: **novel-headline은 없음. 그러나 commit 가능한 중위 임상 SCI 주제는 있음(아래 §commit).**

## 3-게이트 (종단 amyloid 예후 후보)
- **G1 interval — PASS.** `aju_session_labels.csv` edate로 V1→V2 295명(median 1.94yr) 복원. amyloid 예후 증분 interval 보정 후 유지: ΔMMSE +0.058 [.040,.077], conversion AUROC +0.031 [.012,.047].
- **G3 robustness — PASS.** GBM +0.092 [.050,.130](Ridge보다 큼=비선형). Ridge·GBM·두 outcome 동의, amyloid 유일 예후 모달리티(FLAIR·혈액·구조 null).
- **G2 점유 — FAIL(대부분 점유).** lit-scout(peer-reviewed):
  - base claim 포화: Younes 2025(Alz&Dem NACC 실세계)·Neurology(amyloid+ decline). 효과크기 +0.058 = PMC8233225 "small" 범위 = novelty 아님.
  - (a) Asian amyloid 종단 예후 점유: **Lee 2016 Neurology**(삼성, 한국, amyloid PET 3yr, 혈관 위 독립) = 킬러. SR 2018(Korean aMCI)도.
  - (b) full-stack modality-specific = 좁은 공백, ART 2026(WMH+amyloid+plasma 독립기여, 본문 [VERIFY])에 위협 + 결과의존적.
  - (c) K-ROAD 종단공백 = 확정이나 *데이터* 기여, 만료성.

## 판정
**경험적으로 단단(G1·G3) but novelty 점유(G2).** 조건부 중위 임상 SCI((b)+(c) 결합, JAD/JCN, 데이터/프로토콜 기여 포지셔닝)는 가능하나 — ① ART2026 본문이 full-stack 안 했음 확인 + ② 결과가 "amyloid만"으로 나옴 의 *두 미확정 조건* 동시 의존. **= 확실한 주제 아님.**

## 메타 결론 (이 데이터)
cross-sectional 전 각도(etiology·alignment·서양비교·parsimony) + 종단 탈출구까지 끝까지 검증 → 전부 점유/null/만료. **이 데이터는 honest rigor 아래 data/replication 기여만 내고 novel headline 미달.** (memory [[kroad-occupancy-threat]]·[[p2-novelty-positioning]]·[[novelty-landscape-verdict]]와 최종 일치.)

## 정직한 권고 (우선순위)
1. **AJU의 정직한 최선 역할 = external validation / data descriptor** (headline novelty 아님). 종단 295명 2년은 자산이나 단독 페이퍼 미달.
2. **질문을 데이터우위∩novel신호가 겹치는 곳으로 이동** — 단 amyloid 예후는 ADNI/NACC도 포화(Younes 2025). 이 *질문 자체*가 saturated.
3. **확실한 주제는 다른 질문/데이터 필요.** 이 데이터 N+1 변형은 experiment-economy 위반(VOI≈0).

## §commit — 잡을 수 있는 주제 (2026-06-24, amyloid-층화로 완결)
amyloid-음성 검정(06): amyloid+ ΔMMSE −1.80(decliner 43%, 예측가능) vs amyloid− −0.22(decliner 19%, **어떤 모달리티로도 예측불가**). → 예후 신호가 amyloid-구동임을 *완성*.

**Commit 주제(중위 임상 SCI):** "실세계 Asian memory clinic의 modality-specific × amyloid-층화 종단 예후 지도 — full-stack(구조·WMH·혈액22종) 통제 하 baseline amyloid-PET만이 인지쇠퇴 예후 모달리티이고, amyloid−(실세계 다수)는 안정·예측불가. amyloid-enriched 연구코호트·cross-sectional K-ROAD가 못 보는 종단 구조."
- 체급: JAD/JCN(안전) ~ ART(도전). top 아님.
- delta=(b)full-stack modality-specific + amyloid-층화 + (c)K-ROAD 종단공백 + 실세계 Asian. *데이터/프로토콜 기여*.
- **남은 단일 게이트: ART2026 본문**(full-stack 했나) → 안 했으면 ART 도전, 했으면 JAD.

## 재현 코드
`experiments/incremental_value/{00..06}.py` — assemble·incremental(TOST)·GBM·nonlinearity·longitudinal·interval-adjusted·amyloid-층화.
