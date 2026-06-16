# I12 — "예측-법칙(ceiling-law)" 메타토픽은 Schulz/Bzdok·Bron에 대부분 선점됨; 생존 각도는 좁은 a priori 스크리닝 규칙뿐

## 무엇을 시도했나
11실패+자산 실측 후, 지도예측 공간 고갈을 인정하고 메타토픽으로 전환 시도: **"학습 3D-T1 표현이 engineered morphometry를 언제·왜 못 이기는가"를 (S=saturation × M=modality-encoding) 2좌표 예측법칙으로 정식화, 11타깃×7축×4코호트×2인종 검증.** 확정 전 literature-scout로 신규성 검증(약속된 필수 단계).

## 어디서/왜 (선행연구가 경험적 칸을 전부 선점)
- **Schulz & Bzdok, Nat Commun 2020** (UKB 뇌영상, 선형=딥러닝 ~1만 샘플까지): "승리 사분면이 비었다"는 경험적 코어를 이미 확립. *단 진단 방식은 post-hoc sample-complexity/scaling curve(두 모델 다 학습 필요), S×M 2좌표나 a priori 예측은 없음.*
- **Schulz & Bzdok, Cell Reports 2024 ("Performance reserves")**: 멀티모달 추가 ≈ 샘플 2배. **우리의 "탈출=modality 추가(M↑)"를 이미 정량 증명.**
- **Bron 2021 NeuroImage:Clinical**: CNN≈SVM, AD 진단·교차코호트 → saturated-dx 칸 선점.
- **Chattopadhyay 2024**: amyloid는 T1에 약하게 인코딩 → T1-blind 칸 선점.
- **기억-집행 dissociation·DTI→executive·WMH→executive = 교과서 신경학** (우리 I11 발견 아님).
- **판정(literature-scout): 표의 모든 경험적 칸이 개별 출판됨. Schulz를 아는 reviewer는 핵심주장을 "새 코호트 재진술"로 읽고 kill.** NeuroImage/MedIA/TMI엔 부족, MIDL/MICCAI라도 *좁힌 형태*라야.

## 재사용 가능한 인사이트
1. **메타토픽("우리가 천장을 특성화했다")조차 이미 점유된 땅이다.** deep-vs-engineered가 안 되는 건 우리만의 발견이 아니라 brain-imaging ML의 *공인된 사실*(Schulz/Bron/Wen). negative 특성화 논문의 신규성 바가 생각보다 높음.
2. **유일 생존 각도 = "딥모델 *학습 전에* S·M을 싸게 계산해 deep-vs-engineered 결과를 예측하는 a priori 스크리닝 *규칙/도구*"** (관찰이 아니라 method). Schulz는 post-hoc scaling으로 진단 → cheap a priori 사전검사는 미점유. 단 (a) M을 딥모델 학습 없이 싸게 측정(frozen 사전학습 인코더 프로브 등) 가능해야, (b) Schulz scaling이 공짜로 주는 것 이상이라야 성립. 실행위험·중간 신규성, MIDL tier.
3. **데이터의 진짜 미점유 자산은 ML-벤치마크 축이 아니라 *심층표현형 한국 VCI 코호트*(SNSB도메인+DTI+actigraphy+혈관+종단인지)** — Schulz/UKB/ADNI에 없는 조합. 차별화는 ML-방법이 아니라 *임상-신경과학 finding* 쪽에 있을 수 있음(단 구조→인지 신호 약함 R²~0.09).
4. **교훈: 토픽 확정 전 literature-scout는 필수.** 내부 실험이 아무리 깔끔해도 외부 선점이 토픽을 죽인다. (자기평가 편향 방지의 외부판)

## 증거/포인터
- literature-scout 보고(이 세션): Schulz Nat Commun 2020 / Cell Reports 2024 / Bron NeuroImage:Clinical 2021 / Chattopadhyay Front Neurosci 2024.
- 연결: [[I11_snsb_domain_dissociation_and_decline]](S×M의 경험 근거), [[I02_amyloid_null_and_morphometry_oracle]](taxonomy 원형), [[I09_multimodal_alignment_transfer]](modality 추가=transfer).
