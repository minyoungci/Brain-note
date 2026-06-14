# I01 — FreeSurfer-percentile VQA의 2단계 circularity

## 무엇을 시도했나
image-only 3D MRI ROI-grounded VQA. 정답 레이블 = train-only-CN 정규기준 ROI 잔차 percentile
cutoff. Q-ROUTE(질문 라우팅), grounding(attention localization), reliability/uncertainty,
score-meta, adjusted-target 등 수개월·974 run·255 스크립트.

## 어디서/왜 실패했나 (실패 지점)
- **천장 고정**: 정답 = threshold(FreeSurfer_morphometry(image)) → morphometry가 완벽 oracle
  (AUC→1.0). 이미지 모델이 할 수 있는 최선은 FreeSurfer 모사 → 새 신호 없음.
- **바닥 고정**: grounding GT = FreeSurfer mask + brain-extraction/conform 후 심부구조가 수 mm로
  co-locate → **상수 prior가 모든 해상도에서 grounding을 이김**(학습 attention은 prior의 복사본,
  cos 0.95–0.97). circularity control로 독립 재현됨.
- 모든 "특수 메커니즘"이 차례로 deflate: routing≈attention(+0.005), 큰 백본은 이득 소멸,
  Gumbel collapse, localization/relational은 single-view 미달, score-meta는 bootstrap 미통과.

## 재사용 가능한 인사이트
1. **레이블이 입력에서 도구로 유도되면(label = tool(image)) 그 도구가 oracle이 되어 vision
   headroom이 원리적으로 사라진다.** 새 task를 잡기 전 "레이블이 입력 이미지에서 유도됐는가?"를
   먼저 물어라. 유도됐다면 circular.
2. **정합/conform된 뇌에서 grounding 지표(mass-in-ROI/pointing)는 상수 prior가 near-ceiling**
   이다. grounding 주장 시 반드시 static-prior baseline을 보고하라.
3. 작은 held-out cohort 점추정은 변동이 크다 → bootstrap이 거의 모든 "win"을 걷어낸다.
4. novelty는 **non-circular 레이블**(독립 modality로 측정된 것: PET/유전/임상결과)이 필요.

## 증거/포인터
- `FAILURE_AND_NOVELTY_ANALYSIS.md` (전체 카탈로그, 검증), `Archive/` (구 산출물),
  `Archive/scripts/old_freesurfer_vqa/control_circularity.py` (재현된 negative).
