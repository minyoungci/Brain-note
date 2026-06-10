# 08 — CN/MCI weak-baseline harmonization 결과

_생성: 2026-06-04. 원본 READ-ONLY(manifest sha256 `5ae141a4…` 전후 동일). 스크립트 `exp_cn_mci.py`, 검증 `verify_cn_mci.py`._
_질문: 04/07이 "CN/AD(강함)는 harmonization 불필요"를 보였으니 — **약한 task(CN/MCI)에선 harmonization이 도움이 되나(Saponaro 2022 unmask 패턴)?**_
_데이터: complete-case n=12,579. CN vs MCI (n_MCI=4,031 / n_CN=7,580). 대조군 CN/AD 동시 계산._

## Part A — unmask 검정 (pooled + within-ADNI), CN/MCI vs CN/AD 대조

| 지표 (RF / LogReg) | raw | ComBat(dx보존) | ComBat(dx미보존) |
|---|---|---|---|
| **CN/MCI pooled** | 0.674 / 0.673 | 0.661 / 0.646 | **0.591 / 0.568** |
| **CN/MCI within-ADNI**(비순환) | 0.620 / 0.578 | 0.625 / 0.585 | **0.618 / 0.577** |
| CN/AD pooled (대조) | 0.893 / 0.895 | 0.896 / 0.895 | 0.852 / 0.843 |
| CN/AD within-ADNI (대조) | 0.884 / 0.893 | 0.885 / 0.898 | 0.885 / 0.892 |
| site7 ba (chance 0.143) | 0.238 | 0.175 | 0.164 |

(within-ADNI LogReg std ≈ 0.027. site-probe·null은 02와 동일: shuffled≈0.143, fake≈0.50 — 통과.)

## Part B — LOCO 일반화 headroom (subject-first)

| task | held별 icv AUC (ADNI/NACC/AIBL/OASIS/KDRC) | icv LOCO mean | random 상한 | **site-shift 비용** |
|---|---|---|---|---|
| **CN/MCI** | 0.641 / 0.651 / 0.715 / 0.768 / 0.672 | **0.689** | 0.733 | **0.044** |
| CN/AD (대조) | 0.893 / 0.862 / 0.953 / 0.985 / 0.927 | 0.924 | 0.907 | −0.017 (≈0) |

## 결론 (RF+LogReg 양쪽 검증)

1. **CN/MCI는 진짜 약한 baseline.** within-ADNI(단일 site, 비순환) AUC 0.58~0.62 (CN/AD 0.88 대비). headroom은 존재.
2. **그러나 ComBat이 CN/MCI를 unmask하지 못한다.** within-ADNI가 ComBat 후에도 **flat**(RF 0.620→0.618, LogReg 0.578→0.577, std 내). 즉 weak 신호는 **site에 가려진 게 아니라 원래 약한 것** — 제거할 mask가 없음.
3. **pooled는 오히려 하락**(RF 0.674→0.591, LogReg 0.673→0.568). 이유: site==population에서 site는 MCI 라벨의 **양성 지름길**(AJU=MCI 980/CN 23). ComBat이 그 지름길을 제거 → pooled가 진짜 within-site 약신호(0.62) 쪽으로 내려옴. **올바른 동작이지 unmask 아님.**
4. **Saponaro 패턴 비재현 + 메커니즘 차별화(핵심 novelty).** Saponaro의 ASD(0.58→0.67)는 site가 약신호를 *masking* → 제거 시 unmask. **우리 site==population에서는 site가 confounded 라벨을 *inflating*(가짜 상향)** → 제거 시 pooled 하락. **mask와 inflation은 반대 방향.** harmonization의 unmask 이득은 "site가 nuisance로 masking할 때"만 성립하며, "site가 라벨과 confounded될 때"는 성립하지 않는다.
5. **LOCO headroom은 작고 미활용.** CN/MCI site-shift 비용 0.044 (CN/AD ~0보다 큼 → CN/MCI가 더 site-민감)이나, feature-level ComBat은 이 0.044를 메우지 못함(within-site 신호 불변). 즉 headroom이 있어도 ComBat이 못 채움.

→ **경계 완성**: CN/AD(강함, 비용~0) — harmonization 불필요 / CN/MCI(약함, 비용 0.044) — harmonization 역시 **안 도움**(unmask 실패, pooled는 site-inflation 제거로 하락). **site==population 교란 regime에서 harmonization은 강한 task도 약한 task도 살리지 못한다.**

## 함의 (전체 연구 verdict)
- 우리 데이터로 **positive harmonization 성과는 CN/MCI에서도 안 나온다** — "약 baseline이면 도움"이라는 마지막 희망 경로가 닫힘.
- 단 이건 **더 강한 audit 결과**: harmonization 실패가 "CN/AD에 headroom이 없어서"가 아니라, **confounded regime의 구조(site=inflation≠mask)** 때문임을 weak/strong 대조로 입증. Souza 2024 대비 "site==population에선 inflation이라 unmask가 원리적으로 불가"가 정량 차별점.
- positive를 원하면 (06 Part 3): site가 *masking*하는 비-confounded 설정(traveling subject / overlap cohort)이 전제로 필요 — 현 데이터엔 없음.

## 한계 (정직성)
- ComBat은 pooled full-fit(LOCO에 적용 불가) → Part A는 within-distribution 검정. LOCO에서 harmonization-적용형(domain adaptation)이 0.044를 메울 여지는 별도 미검증.
- MCI 정의는 컨소시엄별 이질(ADNI MCI vs NACC ImpairedNotMCI 등) — dx3 매핑으로 통일했으나 라벨 잡음 존재.
- CN_preclinical(A4 1811)을 CN으로 매핑 — A4는 MCI 0이라 LOCO held-target 아님(pooled CN에만 기여).

## 산출물
- `out/cn_mci_results.json` (Part A/B 전체 수치, CN/MCI + CN/AD 대조)
