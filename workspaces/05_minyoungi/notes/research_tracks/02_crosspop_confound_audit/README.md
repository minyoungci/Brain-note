# Track 02 — Cross-population Confound Audit

## 목표
"site == population (한국 AJU/KDRC vs 서구) + traveling subject 0 regime에서
image-text/멀티모달 contrastive 정렬은 질병이 아니라 **코호트를 정렬한다**"는 것을
**식별성(identifiability) + dual-probe로 정량 측정**. 음성/경계 결과도 논문.

## 왜 이게 살아있나 (dossier 정합)
`../../research_topic/{00,README}` — ⭐1순위 "cross-population shortcut-audit". ADLIP/CLIP-medical
누구도 한국-confounded + traveling-subject-0에서 "contrastive가 무엇을 정렬하나"를 식별성으로
분해 안 함. **정확도 경쟁이 아니라 "무엇이 결정 가능한가" 측정**.

## 이미 수집된 증거 (CPU, 2026-06-10)
- 텍스트→코호트 AUC **0.999** (스모킹건: education 구절 유무 = AJU 961/0·KDRC 0/446).
- de-leak(교육·결측 제거) 후도 **0.887**, 순수 생물값도 **0.678** → 값=population=cohort.
- 영상(fs_vol)→코호트 **0.747**.
- 구조 ROI ΔAUC: amyloid +0.008/+0.018 (무용), 치매 +0.133/+0.053 (강함).

## 측정 프로토콜 (TODO)
- [ ] **정렬 전/후 코호트 probe**: 텍스트-only, 영상-only, joint embedding 셋. 정렬 후 코호트가 더 분리되면 "contrastive가 site 흡수" 정량증거.
- [ ] **ΔAUC 분해**: APOE/MMSE 통제 후 영상 잔차 기여 ≈ 0이면 "정렬은 생물학 아닌 코호트".
- [ ] **dual-probe**(site↓ + biology보존 + null) — 단 site==population이라 한계 명시.
- [ ] **식별성 논증**: traveling subject 0 → 코호트효과/인구효과 분리 *원리적 불가* 형식화.
- [ ] cross-population 확장: 한국↔서구(ADNI/OASIS, paths.py에 PET 추가됨).

## 관계
Track 01(VLM)의 산출물(정렬 후 임베딩·probe)이 이 track의 핵심 데이터. 01을 audit 렌즈로 분석.

상태: 증거 일부 수집. 01 진행과 병행해 측정 프로토콜 구체화.
