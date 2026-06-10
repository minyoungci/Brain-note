# 04 — Leave-One-Consortium-Out (LOCO) CN/AD 일반화 (결과)

_생성: 2026-06-04. fs_vol morphometry, subject-first(1인 1세션). 스크립트 `loco_generalization.py`._
_코호트 = ADNI/AIBL/KDRC(strict CN/AD 둘 다 보유). 전처리 3종 전부 LOCO 누설 안전. RandomForest, ROC-AUC._

## 데이터 (subject-first)
| consortium | AD | CN |
|---|---:|---:|
| ADNI | 126 | 849 |
| AIBL | 70 | 452 |
| KDRC | 249 | 282 |

## 결과 — held-consortium CN/AD AUC

| 전처리 | held ADNI | held AIBL | held KDRC | **mean** | random-split 상한 | site-shift 비용 |
|---|---:|---:|---:|---:|---:|---:|
| raw | 0.910 | 0.918 | 0.919 | **0.916** | 0.920 | **0.004** |
| **icv** (÷MaskVol) | 0.904 | 0.943 | 0.922 | **0.923** | 0.924 | **0.001** |
| train_z | 0.910 | 0.918 | 0.919 | 0.916 | 0.920 | 0.004 |

(site-shift 비용 = random-split 상한 − LOCO. 0에 가까울수록 site shift가 일반화를 안 깬다.)

## 핵심 결론 (성공가능성 판단의 근거)
1. **morphometry(fs_vol)의 CN/AD 신호는 held-out 컨소시엄으로 거의 완벽히 일반화된다** (LOCO mean 0.916~0.923).
2. **site-shift 비용이 사실상 0** (0.001~0.004): held-cohort AUC ≈ 같은 코호트 내 random-split AUC. → site/scanner/모집단이 달라도 **disease 신호 전이가 깨지지 않는다.**
3. 따라서 **CN/AD에 한해 morphometry는 이미 site-robust** — harmonization이 "일반화 향상"을 위해 추가로 필요하지 않다. minyoung4 stage8M의 ROI-volume baseline(held-AUC 0.933)을 독립 재확인.
4. **ICV 정규화가 미세하게 도움**(0.916→0.923, 특히 AIBL 0.918→0.943) — head-size는 작은 site/모집단 요인.

## 함의
- 01(site는 metadata/appearance에 강하게 박힘)과 04(morphometry는 site-robust)를 합치면:
  **"site bias는 raw image/metadata에 존재하지만, disease-relevant morphometry로 내려가면 거의 사라진다."**
- 이미지 표현학습의 0.556 shortcut은 "raw 이미지에서 학습할 때"의 문제이지, downstream 부피 신호의 문제가 아니다.
- → 이미지-레벨 harmonization으로 "CN/AD 일반화 향상"을 노리는 연구는 **headroom이 거의 없다**(이미 0.92, 비용 ~0). 06_feasibility 문서 참조.

## 주의
- 단면(subject-first) 설정. AJU는 CN이 23명뿐이라 제외. NACC/OASIS/A4는 strict AD 부재로 LOCO 대상 아님(CN-only domain control).
- AUC는 session이 아닌 subject 단위(중복 제거)라 낙관 편향 최소화.

## 산출물
- `out/loco_results.json`, `out/fig_loco_auc.png`
