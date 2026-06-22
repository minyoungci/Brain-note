# FOMO26 공식 규칙 (주최측 발신) + 우리 설계 함의

> 출처: FOMO26 challenge 규칙 페이지 + FAQ (주최측 발신, 2026-06). 위반 시 실격, 애매하면 fomo26@di.ku.dk 사례별 확인.

## ⚠️ 실격 규칙 (하나라도 위반 시 disqualification)
1. **단일 사전학습 체크포인트** — 모든 downstream task에 *동일한* 사전학습 체크포인트 사용. task별 다른 체크포인트 제출 금지.
2. **Finetuning 추가 데이터 금지** — 두 트랙 모두 finetuning에 추가 데이터 불가 (few-shot generalization 평가가 핵심).
3. **트랙별 데이터 제약**:
   - **Methods Track**: 사전학습에 *FOMO300K 외 데이터 금지*. 외부 데이터/외부데이터로 학습된 모델로 supervision 보강 금지(예: pretrained 모델로 seg 라벨 생성), 수동 주석(manual annotation) 금지.
   - **Open Track**: 사전학습에 모든 데이터(비공개 포함) 허용. 단 사용 데이터 *전부 명시·인용*.
4. **검증 시도 제한** — validation leaderboard에서 *task당·트랙당 최대 3회* 유효 시도.
5. **런타임 제약** — *H100 80GB VRAM 1대 + 32 CPU, 케이스당 120초* 추론 제한.
6. **참가 자격** — 조직자와 활발한 업무관계자 참가 불가(리더보드 미등재). 조직자 소속기관 구성원은 참가 가능하나 수상 제외.

## 도구/전처리 규칙 (FAQ)
- **Asparagus 프레임워크 = 권장(baseline), 강제 아님.**
- **전처리(Methods) 자유**: skull-strip(SynthStrip·HD-BET·ROBEX·BET) / bias 보정(N4) / 정합(ANTs·FLIRT·NiftyReg·Elastix·SynthMorph·MNI152) / 재배향·리샘플링·강도정규화 — 전부 명시 허용. *단 추가데이터 supervision·수동주석 금지(규칙 2·3).*
- **코드 공개 = 권장(의무 아님).** 단 후속 논문 포함되려면 재현 가능한 방법론 세부 제출 필수.
- 모델은 챌린지 목적만 사용 후 삭제, 필요 시 NDA.

## 과제 (7 downstream tasks)
| Task | 내용 | 유형 | 지표 | finetune |
|---|---|---|---|---|
| 1 | Infarct 분류 | Classification (few-shot) | AUROC | O |
| 2 | Meningioma 분할 | Segmentation (few-shot) | DSC + NSD | O |
| 3 | Brain Age 추정 | Regression | MAE + 상관계수 | O |
| 4 | Trigeminal Neuralgia 분할 (신규) | Segmentation (multiclass) | DSC + NSD | O |
| 5 | Polymicrogyria 분류 (신규) | Classification (few-shot) | AUROC | O |
| 6 | Linear Probing (신규) | 표현 품질 | OvR AUROC + F1 | **X (금지)** |
| 7 | Bias·Fairness (신규) | 공정성 (Task6 설정) | 그룹별 OvR AUROC + F1 | **X (금지)** |

- Task 6·7은 finetuning 없이 *입력당 embedding 내는 컨테이너만* 제출.

## 평가 가중 (⭐ 전략 핵심)
- 케이스 동일가중, 지표=케이스 평균. task순위=지표순위 평균. 통합순위=task순위 *가중평균*.
- **가중치**: image-level(1,3,5,6,7) 각 **10%** / **voxel-level(2,4) 각 25%**.
- → **segmentation(2,4)이 통합순위의 50%.** 미제출 task = 해당 task 최악순위.

## 상금·출판·일정
- 상금: 트랙당 $1000 (1위 $500 / 2위 $300 / 3위 $200).
- 출판: Nature Methods / **Medical Image Analysis** / npj Digital Medicine / **IEEE TMI** 목표. 전 task 실질제출 팀 공저초청(팀당 ≤5인, trivial 제출 제외).
- 일정: **5/15 sanity-check** · **6/15 validation+최종 제출 파이프라인** · **8/21 마감** · **10/1 MICCAI 발표**.

---

## ⭐ 우리 설계 함의 (규칙→설계, [[03_architecture_method]]·[[04_strategy_plan]] 반영)
1. **단일 체크포인트 강제** → "단일 백본이 7 task 전부" thesis를 *규칙이 강제*. task별 사전학습 불가 → 우리 **local-global balancing의 정당성을 규칙이 뒷받침**.
2. **seg 50% 가중** → **dense/seg 경로가 리더보드를 지배.** balancing이 seg를 *절대 희생 못함*(local-global tension의 무게가 seg 쪽). **voxel task 2·4 인프라(sliding-window/NSD) 최우선.**
3. **120초/case 추론** → 모델 *efficiency가 제약*. 큰 ViT 추론속도 검증 필수(작은 모델 findings와 정합). **Phase A에서 추론시간 측정.**
4. **validation 3회** → 리더보드 튜닝 불가 → **모든 선택을 내부 subject-disjoint val + 3시드+CI로**. 리더보드는 최종 확인용.
5. **공저 게이트 = 7 task 비-trivial 제출**(미수정 baseline=trivial) → 안전판. **first-author = ①balancing/③fairness 도전.**
