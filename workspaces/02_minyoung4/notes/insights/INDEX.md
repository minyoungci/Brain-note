# INSIGHTS — 실패 실험·실패 지점·이관 가능한 교훈 (단일 진입점)

> **목적**: 같은 부검을 반복하지 않기 위한 dead-end 지도 + 측정값 보존 + 추후 연구에 재사용할 insight.
> **규칙(항상)**: 실패한 실험/방향, 실패 지점, 거기서 얻은 insight는 *항상 이 폴더*(`insights/`)에 저장한다.
> **사용법**: 새 방향을 시작하기 전에 이 INDEX를 먼저 grep하라. 이미 측정으로 죽은 길이면 GPU/시간을 쓰지 않는다.

상세 파일:
- `META_INSIGHTS_transferable_KO.md` — **데이터 불문 이관 가능한 교훈**(다른 연구에도 적용). 가장 재사용 가치 높음.
- `2026-06-14_korean_multimodal_AD_programme_KO.md` — 한국 멀티모달 AD 프로그램(Phase1-3 + subtyping + atlas) 전체 기록.
- 기존 상세 closure(이전 세션, 이동 안 함·여기서 참조):
  - `../docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md`
  - `../docs/context/FAILED_FOUNDATION_AUDIT_CLOSURE_20260611_KO.md`
  - `../docs/context/FAILED_DECONFOUNDING_EXPLORATION_CLOSURE_20260611_KO.md`
  - `../docs/context/FOMO_SSL_PRETRAINING_PLAN_20260608_KO.md`
  - `../experiments/CLOSED_negatives/` (scanner_pop_decomp E1-E4 코드+리포트, separability_diagnostic, RETROSPECTIVE.md)

---

## 마스터 카탈로그 — 죽은 방향 전부 (측정으로 확정)

| # | 방향 | 상태 | 핵심 측정 (왜 죽었나) | 이관 insight | 증거 |
|--:|---|---|---|---|---|
| 1 | 3D raw-voxel CN/AD 표현학습 | ☠️ dead | **intensity(원영상) 0.88 < morphometry 0.91**; morpho 위 residual disease ΔAUC **+0.0001** | 원영상에 ROI 넘는 AD 신호 *부재*(정보부재≠ROI손실) | FAILED_3D_CNAD_… |
| 2 | Foundation/SSL (BrainIAC frozen) | ☠️ dead | **BrainIAC 0.735 vs morpho 0.911**; few-shot 전구간 패배; site-probe 0.842(*더* site-loaded) | 2 order 큰 데이터로 학습한 foundation조차 morpho 못 넘음 → 2000으로 자체 SSL 무망 | FAILED_FOUNDATION_… |
| 3 | De-confounding / harmonization (ComBat) | ☠️ dead | ComBat이 CN/MCI unmask 못 함(0.620→0.618); pooled는 *하락*(0.674→0.591) | "site 지름길 제거 = deflate, not unmask" | FAILED_DECONFOUNDING_… |
| 4 | Scanner=population decomposition (E1-E4) | ☠️ dead **+ 통념 반증** | **E2 disease-matched: cross-ancestry deflation +0.05→−0.001 (p=0.79)**; E4 site benign(gap +0.024) | ⚠️ **"site=population irreducible"은 *artifact*로 기각됨**(우리 통념이 틀렸음) | CLOSED_negatives/20260613_scanner_pop_decomp |
| 5 | Separability diagnostic (예측메트릭) | ☠️ dead | metric이 downstream 손실 예측 못 함 | 사전 separability→사후 손실 연결 미성립 | CLOSED_negatives/separability_diagnostic |
| 6 | 멀티모달 영상 method-win (GATE) | ☠️ dead | 영상 ΔAUC ~0.03 over clinical+APOE; MCI선 CI∋0(=0) | 예측신호가 APOE/임상 지배 → 영상 headroom 없음 | 03_pet_value/GATE_baseline.md |
| 7 | 멀티모달 discrete subtyping (Phase2) | ☠️ dead(negative-as-measurement) | ordinal-WMH 축hijack; ARI 0.75±0.43(불안정); amyloid+atrophy=AT(N) positivity(기존) | co-pathology는 *연속 gradient*지 discrete subtype 아님 | 02_subtyping/SUMMARY.md |
| 8 | PP(맥압)→amyloid "needle" | ☠️ scooped | A4/LEARN N=1690(2025): PP→Aβ β=0.078 p=0.001 +APOE moderation 이미 보고 | 🥈→confirmatory 강등. needle 사망 | research-advisor 2026-06-14 |
| 9 | MCI amyloid-without-PET을 novel로 | ☠️ scooped + 뒤처짐 | 한국 출판 **AUC 0.856/0.835**(memory+MTA+APOE+age) > 우리 **0.76** | 우리 수치가 published Korean SOTA보다 아래 | research-advisor 2026-06-14 |
| 10 | PET-절약 triage를 headline로 | ⚠️ 점령+필드이동 | MCI amyloid-PET 이미 "not cost-effective"; 필드는 plasma **pTau217 AUC 0.935**로 이동 | MRI+APOE triage(0.76)는 혈액(0.93)이 점령한 자리 | research-advisor 2026-06-14 |
| 11 | 멀티모달 fusion *방법론* | ☠️ dead(no headroom) | MCI 영상/혈관/대사 블록 ΔAUC CI∋0=0; CN/AD 영상 총여지 ~0.04(morpho가 흡수) | fusion은 *이길 metric*이 있어야 — 우리 데이터엔 headroom 0 | 본 세션 Phase3/3b |
| 12 | **Atlas / voxel-attention / SSL 학습** | ☠️ dead(측정+선점+scale) | #1·#2가 이미 측정; learnable atlas는 Dalca NeurIPS19/AtlasMorph MedIA25 선점; Korean template 존재(KOR152); 2-site는 site-invariance 불가(traveling 0) | "atlas 학습"은 #1/#2 실패의 우회로 못 됨 — 같은 3벽 | literature-scout 2026-06-14 |
| 13 | **연속 amyloid-burden 회귀 (label-type 전환)** | ☠️ dead(confound; enrich 재오픈→scanner 통제로 재폐쇄) | 서구 CN-heavy(OASIS+NACC)=NULL(ΔR² 0.012/−0.010). KDRC wide-dx(n=731)서 raw ΔR² 0.073 출현했으나 **단조 erosion**: +stage 0.044→**+scanner-covariate 0.030 CI[0.002,0.057](취약)→within-Ingenia(n=508) 0.025 CI[−0.015,0.059]=NULL**. scanner↔amyloid 상관 p<1e-4(스캐너=sub-site proxy, GE site AD-heavy). 가장 깨끗한 단일-스캐너 통제서 소멸 | ~0.04는 stage+scanner/sub-site 교란. 연속 라벨도 morphometry genuine headroom 없음. **META #10 확장: wide-dx+multi-scanner 단일코호트 "morph→biomarker"는 stage·sub-site 둘다 통제(covariate+within-scanner) 전 신뢰금지** | 20260614_suvr_headroom_gate/CLOSURE.md (2 auditor + stage·scanner 통제) |

| 14 | **멀티모달 fusion: FLAIR/PET 추가 (proxy→raw-3D regional)** | ☠️ dead(측정, #11 강화) | KDRC tri-modal(n=751)서 LOMO ΔAUC(제거 시 변화): proxy(Fazekas2+SUVR1) dx PET+0.008/FLAIR+0.001≈0 → **raw-3D 38-ROI regional씩(T1 30보다 rich)** 줘도 dx **PET −0.017/FLAIR −0.013**, amyloid **FLAIR −0.015**(음수=빼면 이득=노이즈). full AUC 0.728<parsimonious 0.789(영상feature 과적합) | FLAIR/PET는 T1+tab 위로 비중복 신호 0·노이즈 → multimodal fusion·missing-modality robustness "robust to nothing". Stage2 GPU deep prior≈0(미실행). **VQA/VLM은 T1-중심 resource 벤치로만, fusion novelty 닫힘** | 20260614_suvr_headroom_gate/CLOSURE.md ADDENDUM |

| 15 | **conditional 3D brain diffusion (clinical/volume-conditioned 생성)** | ⚠️ scooped+scale 열위 (lit-gate 2026-06-14) | global-volume cond.=BrainLDM(Pinaya'22, 31.7k UKB) 완전점령; counterfactual aging/atrophy-edit=레드오션(Sun MICCAI'25 7-lobar, Peng'24-25, Puglisi BrLP'25); 30-region cond.은 incremental gap; **amyloid-cond.은 구조신호 부재로 fidelity 검증불가**; 증강 +2%p marginal·유의성無 | 우리 13k T1-only·서양 base 부재로 스케일 승부 불리. 한국 코호트는 *데이터* delta지 *방법론* delta 아님 → top-tier 약함. GPU ROI 낮음 | literature-scout 2026-06-14 (Pinaya'22/Sun'25/Peng'24/Puglisi'25/Dhinagar'25) |

상태 범례: ☠️ dead(측정으로 확정) / ⚠️ 점령(선행연구) / scooped(우리보다 앞선 출판 존재).

---

## 무엇이 *살아남았나* (정직한 positive — `experiments/⭐_20260613_korean_AD_multimodal/`)
- Phase 1 결정인자(🥉 confirmatory, **AJU-only 한계**): amyloid←APOE, WMH←HTN, atrophy←APOE. Kang2023 선점.
- Phase 2 **continuous co-pathology**(negative가 positive measurement인 드문 케이스; Prosser2024 unsubtyped과 동방향).
- Phase 3 **PET redundant for syndromic CN/AD**(ΔAUC +0.003 [−0.001,+0.006], de-overclaimed). amyloid status는 비-PET 0.76 부분회복(APOE 주도).
- → 종합 천장: **mid-tier 임상(NeuroImage:Clinical/JAD)**, A&D는 stretch. 일부 mid-tier 방조차 선점(#8-10).

## 천장 돌파 레버 (분석 아니라 데이터)
- 🟢 **plasma pTau217**(AJU 잔여혈액 assay 가능시) — 유일하게 덜 닫힌 질문(영상 vs 혈액 vs 둘다 증분). [VERIFY 가능여부]
- 🔴 longitudinal/tau-PET: 우리 데이터 영구 불가(V2 PET=0, tau 없음). 새 코호트(K-ROAD 등) 필요.

## 검색 한계 (정직)
- 위 scooping 판정은 영어 peer-reviewed 기반. **한국어 학회지 미검색** — #8·#9가 한국어로 이미 있을 수도(더 나쁨), 정확 프레임이 비어있을 수도. [VERIFY]
