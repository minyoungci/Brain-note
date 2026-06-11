# SPEC — Adaptation of 3D brain-MRI foundation models under site shift (minyoung4, Direction 2)

> Living spec. 이전 closure들: `docs/context/FAILED_*_CLOSURE_20260611_KO.md`.
> 1순위 제약: leakage(train-eval) 금지 + honest eval. **morphometry는 yardstick 아님 — 여러 baseline 중 하나.**

## 0. 목적 / Thesis (2026-06-11 확정, 사용자 선택 = "adaptation 방법론 연구")
사전학습된 3D 뇌-MRI foundation(BrainIAC 등)을 **어떻게 적응(adapt)시켜야 site-shift에 강건한가**를
우리 7코호트 leakage-통제 벤치로 체계적으로 측정한다.
> **질문**: frozen이 (이미 측정상) 단순 baseline에 지고 site를 더 싣는다. **fine-tuning regime이 이를 escape하는가?
> 어떤 적응 전략(linear / LoRA / partial / full FT)이 transfer↑·site-loading↓를 best로 주는가?**

## 1. Task / 평가 (morphometry-yardstick 아님)
- **adaptation ladder**: ① frozen-probe ② linear-probe ③ LoRA/partial-FT ④ full-FT. (+ baseline: from-scratch 동일 backbone)
- **endpoint**: (A) CN/AD 분류 (B) brain-age 회귀. 둘 다 **leakage-clean**(AJU+KDRC) + 가능시 다코호트.
- **평가 축**:
  1. **LOCO transfer** (미관측 cohort 일반화) — 핵심.
  2. **site-loading** (표현→cohort AUC, 적응이 줄이나).
  3. baseline 대비(from-scratch·frozen·morphometry는 *참조*, 천장 아님).
- 모든 수치 다seed mean±std. ΔAUC/Δsite over from-scratch & frozen.

## 2. Data
- `official_manifest_full_n4_real_final.csv` 7코호트. leakage-map: AJU·KDRC=CLEAN(공개 foundation 미포함), ADNI/OASIS/AIBL=likely 누수, NACC/A4 uncertain.
- foundation transfer 평가의 task-probe(B,C)는 **clean(AJU+KDRC)**; site-probe(A)는 전 코호트.
- 입력: v2 T1w final_tensor_n4 → 96³ resize + normalize (BrainIAC transform 매칭).

## 3. Win / 판정
- **(positive)** 어떤 적응 전략이 frozen·from-scratch 대비 LOCO transfer를 유의 개선 AND/OR site-loading 감소 → "foundation 적응이 site-shift에 도움" 입증.
- **(negative-but-real)** full-FT조차 from-scratch와 동등·site 안 줄면 → "이 regime에선 대규모 pretrain이 이점 없다"는 강한 audit 결론(우리 BrainIAC frozen audit의 fine-tune 확장).

## 4. 선결 (setup gate)
1. **모델 재취득**: BrainIAC(GitHub AIM-KannLab, CC-BY-NC, ViT 7GB) 또는 brain2vec(HF, Apache-2.0, VAE). 직전 리셋서 삭제 → 재다운로드.
2. env: monai 호환(이전 monai-1.3.2 격리 env). 입력 전처리 공정성 재확인.
3. frozen baseline 재현(이전 audit: site 0.842 / brain-age 5.73 / CN-AD 0.735)으로 setup 검증.

## 5. 실험 로그
| EXP | 내용 | 결과 |
|---|---|---|
| (이전 audit, archived) | BrainIAC **frozen** vs morphometry | site 0.842>0.770 / brain-age 5.73>5.56 / CN-AD 0.735≪0.911 (frozen 열세) |
| K0/K1 (archived→closure) | KDRC 멀티모달 WMH headroom | morphometry ceiling (Δ≈0) |
| D2-S0 | BrainIAC 재취득(repo+가중치+monai1.3.2 env) + frozen 재현 | ✅ site **0.842**/brain-age **5.73**/CN-AD **0.735** = 이전 audit 완전 일치 (셋업 검증) |
| D2-S1 | adaptation ladder (frozen/partial/full/scratch), brain-age, **held-out=KDRC** LOCO | _running GPU1/2/4/6_ — trainable 0/28.3/88.3/88.3M. 측정: held-out MAE(transfer) + site-loading |

판정(D2-S1): full/partial이 frozen·scratch 대비 held-out MAE↓ AND site-loading↓이면 "foundation 적응이 site-shift에 도움" 입증. 

## 6. Artifact policy
`experiments/foundation_adapt/` 1디렉토리, 가중치·캐시 gitignore, 리포트 작은 md/csv. 매 실험 SPEC 갱신.
