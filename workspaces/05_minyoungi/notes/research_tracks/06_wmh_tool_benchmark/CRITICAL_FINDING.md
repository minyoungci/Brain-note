# ⛔ CRITICAL FINDING — WMH→해마 연관이 뇌실(위축) 보정에 붕괴 (2026-06-16)

_critic-driven gating이 드러낸 결과. Track04 임상 논문 제출 전 반드시 처리. 자기평가 아님 — gating 테스트로 검증됨._

## 무슨 일이 일어났나
research-critic가 "SynthSeg WMH가 실제 WMH가 아니라 뇌실 경계 부분용적(위축)을 잡는 것일 수 있다"([F3])고 경고 → 직접 검증 → **확증**.

### 벤치마크 gating (`results/gate_analysis.json`)
| 코호트 | 도구 | baseline β(p) | **뇌실보정 β(p)** |
|---|---|---|---|
| OASIS A− | SynthSeg | −0.115 (.002) | **−0.018 (.62) 붕괴** |
| OASIS A− | SHIVA | −0.078 (.022) | −0.034 (.27) 붕괴 |
| A4 A+ | SynthSeg | −0.146 (.000) | −0.057 (.099) 붕괴 |
- **SHIVA(WMH-only 모델, 뇌실과 method 공유 안 함)도 붕괴** → SynthSeg 라벨 artifact 아님. WMH→해마 연관 자체가 전반적 위축과 공유.
- d2(부트스트랩): SynthSeg vs SYSU β는 CI[−0.156,−0.036] 통계적 구별됨 → 도구차는 실재(Gelman-Stern 통과).
- d3(SIMEX): SynthSeg를 SYSU 노이즈로 열화 시 β −0.115→−0.070 (SYSU 실제 −0.020). **격차 절반=측정오차, 절반=SYSU 계통편향.**

### ⭐ Track04 headline read-across (`results/track04_ventricle_readacross.json`) — AJU A− n=643
| 모델 | wmh_z β | p |
|---|---|---|
| M3 원본 (cortex 통제, 발표 headline) | **−0.123** | ≈0 ✓ |
| + FastSurfer 측뇌실 (독립 모델) | −0.036 | 0.24 ✗ |
| + SynthSeg 뇌실 (독립 분모) | −0.001 | 0.99 ✗ |
| + FS 뇌실 raw + MaskVol 별도통제 (분모 artifact 배제) | −0.011 | 0.72 ✗ |
| 뇌실 자체 → 해마 | **−0.211** | ≈0 |

→ **3개 독립 사양 전부 붕괴.** WMH-해마 상관 0.65~0.69. **뇌실이 WMH보다 해마를 훨씬 강하게 예측.**

## 정직한 해석 (양방향 — 단정 금지)
- **confounder 해석**: 노화/위축이 WMH·뇌실확장·해마위축을 동시 유발 → WMH는 해마-특이 정보 없음 → vascular SNAP thesis 약화.
- **mediator 해석**: WMH(소혈관병)→조직손상→뇌실확장 AND 해마위축. 뇌실이 mediator면 보정은 **과보정**(직접효과를 부당히 null로). 이 경우 thesis는 인과적으로 살지만 *해마-특이성*은 못 보임.
- **횡단 데이터로는 둘을 구별 불가.** Korean 종단 데이터 0(KDRC longitudinal 없음) → 이 데이터셋에서 해소 불가.
- 원본 Track04 "non-circular cortex 통제"가 생존한 이유 = cortex가 **약한** 위축 프록시. 가장 민감한 프록시(뇌실)엔 실패.

## 함의 / 결정 포인트
1. **Track04 임상 주장("A− WMH가 해마위축을 독립적으로 예측")은 현 상태로 취약** — 어느 위축 프록시를 통제하냐에 따라 뒤집힘. Reviewer가 반드시 찌를 지점.
2. 선택지: (a) 주장 약화 재프레임("WMH·해마위축이 공유 소혈관/위축 과정으로 A−에서 공발생"), (b) 뇌실 분석을 mediation 캐비엇과 함께 투명 보고, (c) 외부 종단 검증(데이터 없음).
3. **벤치마크는 오히려 강해짐**: "downstream clinical utility(M5)로 WMH 도구를 순위매기는 것 자체가 위축에 교란된다"는 meta-level 경고 = 정직한 방법론 기여.

## Deep-WMH 분해 (critic Q3a, 사전확정 10mm, `results/deep_wmh_decomposition.json`) — 구제 실패
AJU A− n=583. **WMH 97.7%가 periventricular**(deep=2.3%, median 0.003%ICV). 신호 전부 PV 분획:
| 모델 | β(p) |
|---|---|
| TOTAL (cortex) | −0.134 (≈0) ✓ |
| DEEP (cortex) | +0.008 (0.74) ✗ |
| DEEP + 뇌실 (KEY) | −0.0003 (0.99) ✗ |
| PV (cortex) | −0.142 (≈0) ✓ |
| PV + 뇌실 | −0.058 (0.073) ✗ |
→ **deep WMH(부분용적/위축경계 오염 불가 분획)는 뇌실보정 전에도 신호 0.** PV(위축결합)가 전 신호를 carry. 횡단 독립-혈관-driver 주장 닫힘. caveat: deep 2.3%로 극소→deep-null에 검정력부족 일부 기여(단 지배결론 견고).

## 종단 구제 시도 결과 (`results/longitudinal/longitudinal_result.json`) — 공정하게 실패
AJU V2, A− **n=173**(195 변환, 간격~4년, 4년간 77.5% 위축). hippo+ventricle=WMH-SynthSeg V1+V2 T1(동일도구). **GATE 통과**: WMH-SynthSeg hippo vs FastSurfer hippo **r=0.863**(대리 outcome 신뢰).
| 모델 | baseWMH β(p) |
|---|---|
| M1 baseline만 (시간선행) | −0.047 (**0.047**) 유의 |
| M3 +baseline 뇌실(SynthSeg, 올바른 교란) | −0.019 (0.51) ✗ |
| M4 +baseline 뇌실(FastSurfer 독립) | −0.020 (0.49) ✗ |
| Δ뇌실 자체→Δhippo | −0.082 (0.0002) |
→ **시간선행 신호(M1, p0.047)는 약하게 존재하나 baseline 뇌실(노출과 동시점=올바른 교란) 보정에 사망.** 독립 FastSurfer 프록시로도 동일. baseWMH는 baseline 위축상태(뇌실)가 예측하는 것 이상으로 미래 위축을 예측 못 함. **횡단+종단 모두에서 독립-혈관-driver 주장 closed.** (Δ뇌실 M2는 동시변화=over-control이라 참고만.)

## 최종 verdict / 두 산출물
- **임상 논문**: "WMH 독립 driver" 주장 closed → critic floor로 재프레임 = "정량 WMH는 A−에서 전반적 위축과 co-localize하는 민감 마커, 해마-특이/독립 혈관 driver 아님; 종단에서도 baseline 뇌실 이상의 예후정보 없음". visual→quantitative 측정-업그레이드 발견은 독립 생존. (DADM급)
- **벤치마크(MIN-WMH)**: "downstream clinical-utility 순위는 위축에 교란" = 더 강한 방법론 기여. `RESULTS.md` 백본 완성.

## (구) 남은 단 하나의 혈관 구제 경로 = 종단 — 위에서 시도·종결됨
AJU V2: **A− 196명이 V2 FLAIR+T1 보유**(raw 디스크 확인). baseline-WMH→Δhippo(baseline hippo·뇌실 보정) = 시간선행 논증(Fiford식). 뇌실-교란이 못 깨는 유일 설계. ⚠️ GPU 전처리(196 scan: FLAIR→WMH-SynthSeg, T1→FastSurfer) = **사전승인 대상**. PV-지배(98%)라 종단도 "PV WMH·뇌실 co-progress" 해석여지 남음 → baseline+Δ뇌실 동시보정 필요.

## 재현
`uv run python research_tracks/06_wmh_tool_benchmark/gate_analysis.py`
`uv run python research_tracks/06_wmh_tool_benchmark/track04_ventricle_readacross.py`
`uv run python research_tracks/06_wmh_tool_benchmark/deep_wmh_decomposition.py`
