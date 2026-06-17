# MIN-WMH — Experiment Plan (tool expansion + GT anchor)

_목표: "downstream clinical utility는 WMH 도구의 교란된 벤치마크"를 (1) 도구 수를 최대로 늘리고
(2) 진짜 GT-Dice 앵커를 붙여 bulletproof로. 2026-06-16 작성._

## GT 결정 (확정)
- **우리 코호트 ≠ Dice-GT** (수동 voxel 마스크 없음). visual 등급(Fazekas/AJU grade)은 **concurrent validity**용(상관), Dice 아님.
- 진짜 Dice-GT = **외부 공개 MICCAI 2017 WMH Challenge**(manual mask 60 train + 110 test). 다운로드 필요.
- ⚠️ **SYSU = 그 챌린지 우승자(해당 데이터 학습)** → SYSU 유리. 프레이밍: "홈그라운드 Dice 1등 도구가 downstream 꼴찌" = 정확도≠유용성 증명. test split만 사용 + bias 명시.

## 도구 풀 (최대화)
| 도구 | 패러다임 | 비용 | 상태 |
|---|---|---|---|
| WMH-SynthSeg | domain-randomization (3D U-Net) | 보유 | ✅ |
| ANTsPyNet SYSU-media | supervised 2D (MICCAI 우승) | 보유 | ✅ |
| ANTsPyNet SHIVA | supervised 3D | 보유 | ✅ |
| **ANTsPyNet HyperMapp3r** | supervised 3D | **무설치**(같은 venv) | 🆕 E1 |
| **ANTsPyNet wmh_segmentation** | supervised | **무설치** | 🆕 E1 |
| **ANTsPyNet white_matter_hyperintensity** | supervised | **무설치** | 🆕 E1 |
| LST-AI | DL (MS+WMH 학습) | pip+torch venv (승인) | 🔜 E2 |
→ **최대 7도구, 4+ 패러다임.** (PVS/arterial 함수는 WMH 아님 → 제외)

## Phase 계획
### E1 — 무설치 도구 추가 (CPU nohup, 승인 불요)
1. `run_antspynet.py` 확장: hypermapp3r + wmh_segmentation + white_matter_hyperintensity 추가.
2. **스모크 먼저**(각 1장, 출력 sane? 비현실 부피 아닌지) → 통과 도구만 채택.
3. OASIS·A4·AJU 전수 재추론 (nohup, resumable).
4. `gate_analysis.py` 재실행 → 6도구로 tool-dependence·CCC·뇌실붕괴·SIMEX 갱신.
**성공조건**: 각 도구 err<5%, 부피 생리적 범위, 6도구 결과표 재생성.

### E2 — LST-AI 추가 (설치+GPU, 승인 대상)
1. 별도 venv에 `lst-ai` 설치(torch) + 스모크.
2. 전 코호트 추론 → 7도구.
**게이트**: pyproject/env 변경·GPU = 사전승인.

### E3 — 검증 앵커 (대부분 무설치)
- **M1 concurrent validity** (무설치): 도구별 WMH vs visual 등급(AJU `wmh_grade_visual`)·Fazekas(KDRC) 상관.
- **M2 cross-resolution** (무설치): native 5mm↔registered 1mm paired CCC(Stage E ~94) 도구별.
- **M4 vascular construct** (무설치): HTN/DM→도구별 WMH (AJU RF 100%).
- **GT-Dice** (외부 다운로드+승인): MICCAI WMH test split에 전 도구 → Dice. **Dice 순위 vs downstream 순위 vs 위축누출** 3자 비교 = 킬러.

### E4 — 종합
7도구 × multi-metric 프로파일 + headline("downstream-utility 순위는 위축에 교란")을 다도구로 일반화.

## 산출물 매핑
- 무설치(E1+E3 일부) → cautionary methods 논문 즉시 강화 (도구 6, multi-metric).
- +E2+GT-Dice → 정식 멀티도구 벤치마크 (Dice≠clinical≠truth 루프 완성).

## 정직한 리스크
- ANTsPyNet 신규 3함수 적용성 [VERIFY](스모크 전 미확정). 일부 가중치 미배포/입력요건 다를 수 있음.
- MICCAI GT 다운로드 접근성 미확인 + SYSU 학습편향(disclose).
- LST-AI는 MS-lesion 특화 → WMH 일반인구 적용성 [VERIFY].
- 도구 늘려도 headline(위축누출)은 이미 성립 — 추가는 *일반화/강건성* 보강이지 결론 변경 아님.
