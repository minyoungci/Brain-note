# I03 — 데이터 현실 점검: manifest headline의 함정

## 무엇을 시도했나
longitudinal 방향 feasibility 판단. "longitudinal_voxel_manifest 18,868 세션 / 8,260 subj"이
headline.

## 어디서/왜 함정이었나 (실패 지점)
- **headline 행수는 사용 가능 데이터가 아니다.** ROI(FreeSurfer)-처리된 종단 세션은 main
  manifest(13,022)로 제한; 다중-ROI subject 중 대부분은 **같은 시점 rescan**이라 ≥6개월 종단
  pair는 처음 354명뿐으로 보였다.
- **scan_day는 OASIS만 100%**, 나머지 6개 코호트 0% → 시간 순서/변화율 계산 불가로 보였다.
- 그러나 **session_id가 날짜를 인코딩**(ADNI/AIBL YYYYMMDD, OASIS dNNNN, A4 VISCODE, AJU V#)
  → 복원 시 dated ≥1yr 종단 **2,706명, 4코호트**로 확장. multi-tensor 3,601명(date-agnostic SSL).
- **소표본 AUC 인플레이션**: longitudinal morphometry-change가 n=354에서 0.85였으나 확장된
  n=1,714에서 0.73–0.78. 작은 n의 화려한 수치는 과적합/행운.

## 재사용 가능한 인사이트
1. **manifest 컬럼/행수를 믿지 말고, 실제 사용 가능한 (이미지+레이블+간격) 교집합을 직접 세라.**
   "X개 세션"이 아니라 "조건 만족 subject 수"를.
2. **날짜/메타가 비어 보여도 다른 필드(session_id, 파일명)에 인코딩됐을 수 있다** — 복원 시도가
   feasibility를 뒤집는다(404 OASIS-only → 2,706 multi-cohort).
3. **수치는 항상 큰 n에서 재확인하라.** 소표본 CV-AUC는 위로 편향된다.
4. base-rate가 코호트마다 다르면(amyloid 0.31–0.68) site가 레이블을 예측 → LOCO가 보수적이고
   site-shift가 천장을 낮춘다(morpho로 cohort 예측 AUC 0.79–0.87 확인).

## 증거/포인터
- `reports/CONSORTIUM_INVENTORY.md`, `results/longitudinal/BARS.md`,
  `scripts/build_consortium_inventory.py`, `scripts/build_longitudinal_dataset.py`.
