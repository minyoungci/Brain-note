# MUST_KNOW — 반드시 알아야 하는 횡단 인사이트

_5개 연구를 관통하는, 잊으면 같은 실수를 반복하는 교훈. 분기마다 다시 읽어라._
_갱신: 2026-06-02. 출처: 각 워크스페이스 SCRATCHPAD/report + 서브에이전트 감사._

## 🔴 연구 방향을 좌우하는 것 (Top 3)

### 1. deep ≈ regional volumetry — 이게 현재 연구 프로그램의 중심 사실
EXP01(minyoung2)에서 deep 2.5D MIL이 **5-ROI FreeSurfer 부피 baseline**을 5/5 LOCO fold에서
못 이기고 pooled에서만 **+0.018 AUROC**[+0.011,+0.026]. → "deep이 가치를 더한다"는 주장은 현재
근거 부족. **정직한 thesis는 parsimony/cautionary.**
- 함의: **plant·minyoung3도 부피 baseline을 반드시 깔아야** 하고, 그걸 못 이기면 novelty 주장 불가.
- 주의: 이건 "deep이 쓸모없다"가 아니라 "더 어려운 task(progression) 또는 더 나은 표현(SSL)에서
  비로소 값을 할 수 있다"는 **연구 기회**의 정의이기도 하다(plant·minyoung3의 존재 이유).

### 2. LOCO transport은 seed 불안정 — 단일 run 주장은 위험
NACC/AIBL 일부 seed에서 held-out 성능 붕괴(ADNI seed2=0.522, OASIS 0.511↔0.810). 원인 후보:
in-dist val 체크포인트 → OOD gap. grad-accum·warmup·group-DRO 모두 보편 해결 실패.
- 함의: **multi-seed 필수**, 코호트별 보고 필수, 단일 fold 성공을 결과로 쓰지 마라.

### 3. 음성 결과를 출판 가능하게 설계하라
이 프로그램의 1차 기여는 SOTA가 아니라 **재사용 가능한 음성-내성 평가 프로토콜**이다(EXP01).
통제군(shuffled/nuisance/mask/volumetry)을 미리 박아 "신호 없음"이 버그가 아닌 결과가 되게 한다.

## 🟠 데이터를 만질 때 매번 (반복 사고 지점)

- **`cdr_global`은 string** → `pd.to_numeric()` 먼저. 안 하면 조용히 오정렬/TypeError.
- **single-cohort 함정**: APOE·MoCA=NACC only / MMSE=ADNI 없음 / sex NaN=A4·ADNI(→`clin_sex_raw`).
- **ROI는 fail-closed 잠정**(`roi_final_ready` 전부 False). ROI 기반 정량 결론은 "검증"이 아닌 "후보".
- **종단 시간정보는 session_id 파싱으로만** 존재. NACC 정렬 불가, KDRC 단일세션, AJU CN 없음.
- **데이터 의심을 존중하라**: "39% 결측"이 사실 경로 버그였던 전례. "정말 그게 맞아?"가 정답이었다.
  생성과 검증은 분리된 단계다(노트북이 구조가 맞아도 안 돌아갈 수 있다).

## 🟡 운영·인프라 (연구를 죽이는 비-과학적 요인)

- **RAM 1TB 절대 상한.** 초과 시 SSH 세션까지 죽는다. minyoung2가 최근 disconnect 생존(setsid 분리)
  + RAM 90% 앱레벨 캡을 넣은 건 학습이 SIGHUP/메모리로 집단사망한 흔적. 대형 run 전 `/sysmon` 확인.
- **bf16 필수, fp16 금지** (B200).
- **git 안전망 없는 워크스페이스**: minyoung3·plant에 `.git` 없음 → 대규모 삭제 비가역. init 권장.
- `/home/vlm/data`는 read-only canonical. 쓰기 금지.

## 🔵 연구 계보 (한 문장)

minyoung2(EXP01 cross-sectional 프로토콜·성숙)가 **척추**, plant(종단 확장)와 minyoung3(SSL 표현)가
그 프로토콜을 각각 시간축·표현학습으로 밀고, minyoungi가 데이터·문헌·ROI QC를 **공급**, minyoung4는 휴면.

## 미해결 의문 (서브에이전트가 남긴 [VERIFY] — 추적 필요)

- minyoung2: 3D CNN IMG-020/022 결과 미생성(run 디렉토리 빔), F10 +0.018의 pooled exchangeability 가정,
  equivalence test(TOST) 미구현 → "음성"과 "검정력 부족" 미분리.
- plant: converter 수치 불일치(A4 96 vs 98), 시간 파서 외부 검증 미수행.
- minyoung3: `Official/potato/Reset_Audits/` 부재(pre-delete inventory 위치 불명), F04-label/F05 미검증.
- minyoungi: ROI BLOCKED_PROVISIONAL, `cdrsb` 실값/placeholder 여부 미해결, experiments/ GPU 산출물과
  minyoung2/4 본진 간 역할 경계 모호.
