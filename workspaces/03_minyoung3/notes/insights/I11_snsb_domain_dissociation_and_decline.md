# I11 — morphometry는 1차원 전반-중증도 센서: 도메인-특이(집행) 변량에 blind, 종단 저하 예측 불가

## 무엇을 시도했나 (새 자산 발굴 + 두 가설 검정)
이전 9실패+I10은 전부 **거친 타깃(dx/age/amyloid = morphometry-saturated)** 이었다. 한 번도 안 쓴 자산을 발굴:
`/home/vlm/data/raw/AJU/metadata/임상역학정보 분양_all.xlsx`(코드북 동봉) = **다site 한국 만성뇌혈관(cerebrovascular) 코호트**, baseline 1322 + **follow-up(TFU) 295**, 876변수 = SNSB-II **도메인별 신경심리 z점수**(기억 SVLT/RCFT, 집행 Stroop/COWAT/Digit-back, 언어 BNT, 시공간 RCFT-copy, 전반 MMSE/CDR-SB) + 혈관위험인자. z점수는 한국 규준(연령·교육 보정). MRI morphometry와 겹침 **976명(횡단)·292명(종단)**.
- 가설A(횡단 dissociation): morphometry(AD-signature ROI)는 위축→치매라 기억·dx엔 천장이지만, **혈관코호트의 집행기능은 백질/소혈관 주도**라 GM-부피엔 안 잡힌다 → 집행이 학습표현/DTI가 채울 빈자리.
- 가설B(종단): baseline morphometry가 미래 도메인 저하를 예측한다.
- CPU 게이트(GPU/DTI 0): `scripts/cognition_dissociation_gate.py`, `scripts/longitudinal_decline_gate.py`. Ridge, multi-seed×5fold OOF R², subject-bootstrap CI.

## 어디서/왜 (결과 — 가설A는 *부분* 생존, 내 프레이밍은 틀림 / 가설B는 사망)
**횡단 (N=976), morphometry→도메인 z, raw R²:** 기억0.090 / 집행0.097 / 언어0.073 / 시공간0.059 / MMSE0.061 → **전 도메인 거의 동일·약함.** "집행이 특별히 어렵다"는 프레이밍 거짓; morphometry는 **모든 도메인에 똑같이 약하게 붙는 1차원 전반-중증도 축**.
**도메인-특이변량(나머지 도메인+MMSE 잔차화) morphometry R²:** 기억 **+0.030**(양수) / 집행 **−0.035** / 언어 −0.019 / 시공간 −0.028. → morphometry는 **기억-특이 신호만 보유, 집행/언어/시공간-특이는 0% 설명.** 집행 하위검사 내적일관성 α≈0.70 → **집행-특이 변량은 신뢰할 신호(노이즈 아님)인데 morphometry+crude WMH 둘 다 못 채움.**
**종단 (N=292, 평균 2.39년), baseline morphometry→연율 Δ도메인:** 전 도메인 **R²<0**(기억 −0.107, 집행 −0.059) = 평균보다 나쁨. 저하를 예측하는 유일 변수는 기저인지(RTM, base_only 기억 +0.106); morphometry는 그 위 증분 0. → **structure는 미래 저하를 예측 못 함.**

## 재사용 가능한 인사이트
1. **morphometry-oracle의 정체 = "1차원 전반-중증도 센서".** 도메인 전반에 동일·약하게 붙고, 유일한 도메인-특이 신호는 기억(+0.030). dx가 잘 맞은 건 dx가 그 전반축의 단조함수라서. (taxonomy I02 보강: saturated의 메커니즘 = 1D severity proxy)
2. **유일하게 남은 positive 모양의 균열:** morphometry가 **R²=0**으로 못 보는 **reliable executive-specific 변량**(α≈0.70). 여기만 "0에서 출발하므로 morphometry를 이기기 쉬운" 타깃. 단 crude WMH도 0 → DTI 미세구조만이 미검정 후보, EV 중간·null 위험 실재.
3. **종단 인지저하는 이 N(292/2시점)에선 structure로 예측 불가** → 종단-예측 방향 사망. 2시점·중간 N·noisy Δ의 한계(I06 종단 경고와 동형).
4. **자산 교훈:** 큐레이션된 manifest(dx/age/apoe만)는 raw 코호트의 0.5%만 노출했다. raw `임상역학정보` xlsx에 SNSB 도메인·종단·혈관인자가 통째로 있었음 → **새 방향은 새 데이터가 아니라 *덜 들여다본 기존 데이터*에서 나온다.** (한글 파일명 NFC/NFD 매칭 함정 주의)
5. **dissociation 방향 자체는 "negative 특성화 논문"으로 확정 가능**(morphometry=1D severity, 도메인-blind, 저하-blind). win-보고 문헌과 차별. 횡단 절대 R²가 작아 positive 흥분도는 낮음.

## 추가 검증 (2026-06-16): radiomics SHAPE도 executive-specific 못 채움 → DTI만 남고 EV 하락
무료 게이트(`scripts/shape_executive_gate.py`): 안 쓰던 **radiomics shape 196개**를 도메인-특이 인지에 투입 → 전부 **강한 음수**(executive-specific: volume −0.026 / **shape −0.229** / vol+shape −0.274; memory/lang/visuo도 동일). shape는 신호 없이 과적합만 추가. **결론: 현재 가진 어떤 engineered 구조 feature(volume·shape·crude WMH)도 executive-specific을 R²>0으로 못 잡음.** → (1) I11 크랙은 DTI 미세구조 단독 미검정으로 확정, shape로 싸게 못 엶. (2) **경고: vol=0·shape<0·WMH=0의 누적은 "executive-specific이 WM에 있어 DTI가 본다"보다 "구조 MRI에 아예 없다(I02 amyloid식 signal-starved)"로 기울어 DTI 도박 EV 하락.**

## 추가 검증 b (2026-06-16): WMH 시각등급도 executive-specific 못 채움 (크랙 사실상 닫힘)
`scripts/fazekas_executive_gate.py` (AJU only, KDRC 제외; AJU는 fazekas_pv/deep 없고 **wmh_grade_visual N=975**만, 1/2/3=613/307/55). executive-specific: **WMH 단독 R²=+0.005**, morph+WMH(−0.033)=morph(−0.036) → 증분 0. partial Spearman(WMH, exec-specific) rho=−0.094 p=0.008 = 유의하나 크기 무의미(~0.8%). WMH는 오히려 memory-specific에 약간 붙음(morph+WMH 0.033→0.051). **→ volume·shape·crude-WMH·WMH시각등급 = 가진 모든 구조 WM 측정이 executive-specific에 전부 0.** "executive-specific은 구조 MRI에 없음(I02식 signal-starved)" 거의 확정. 유일 미검정=연속 tract-DTI(단 WMH 3단계 coarse라 DTI 여지 잔존, EV 추가 하락).

## 부수 발견: conditional generative는 *데이터-ready*하나 천장은 못 넘음
`korean_multimodal_manifest.csv` 실측: AJU 이미지 **1001명 전부 디스크 실재**(`preprocessed_official/v2`, 192×224×192 1mm RAS z-score brain-extracted = 모델 준비완료), 조건변수 거의 완전(age/sex/dx/MMSE/CDR/APOE/혈관/GDS/혈액검사/WMH/교육 ~1000). conditional gen p(image|clinical)은 **buildable**(N=1001+자체 다코호트 사전학습+latent diffusion)이나 (1) 3D 생성엔 N=1001 빈약(memorization 위험), (2) **정보 천장 동일**(같은 p 모델링, escape 아님), (3) payoff 물렁/crowded(counterfactual·normative·disentangle) — 단 "generation-as-measurement(T1이 phenotype의 무엇을 인코딩하나=M좌표 추정)"로 재프레임 시 toy-modest. CN-poor(AJU 29)라 normative modeling도 약함.

## 증거/포인터
- `scripts/cognition_dissociation_gate.py` → `results/cognition_dissociation/RESULTS.md`, `results.json`
- `scripts/shape_executive_gate.py` → `results/cognition_dissociation/RESULTS_shape.md` (shape null)
- `scripts/fazekas_executive_gate.py` → `results/cognition_dissociation/RESULTS_fazekas.md` (WMH-visual null)
- `scripts/longitudinal_decline_gate.py` → `results/cognition_dissociation/RESULTS_longitudinal.md`
- 원천: `/home/vlm/data/raw/AJU/metadata/임상역학정보 분양_all.xlsx`(BL 1322 / TFU 295 / 코드북 3시트)
- 연결: [[I02_amyloid_null_and_morphometry_oracle]](천장 taxonomy 메커니즘), [[I10_actigraphy_no_increment_over_morphometry]](6번째 천장축), [[I06_longitudinal_contrastive_harmful]](종단 noise 규율), [[I07_whattofuse_amyloid_clinical_dominant]](engineered가 image에 redundant 동형)
