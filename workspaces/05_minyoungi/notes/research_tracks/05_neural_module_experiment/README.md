# Track 05 — Neural Module Experiment (별도·격리)

_생성 2026-06-16. **목적**: 임상 논문(Track 04)은 그대로 두고, *정당하게 이름 붙일 수 있는* 작은 신경망 모듈을 탐색._
_Track 04 manuscript/results 절대 미수정. 이건 분리된 탐색._

## ⚠️ 실험 Contract — 모듈이 "이름을 버는" 조건 (lock)

named module은 **존재**가 아니라 **측정 가능한 개선**으로 정당화된다. 아래를 만족 못 하면 이름 안 붙인다(reviewer-bait 회피).

```
모듈은 다음을 모두 만족해야 named 기여로 인정:
1. 명확한 baseline(off-the-shelf)이 있다.
2. 측정 가능한 metric을 baseline 대비 *유의하게* 개선한다 (우연/노이즈 아님, 독립검증).
3. 개선이 ablation으로 그 모듈에 귀속된다 (모듈 제거 시 개선 사라짐).
4. dead wall을 재시도하지 않는다 (image>morphometry 분류·multimodal fusion accuracy = 금지).
```

## 후보 task (실재 문제 기반)

### ⭐ C1. Cross-resolution WMH harmonization head (1순위)
- **실재 gap (Track 04 Stage E)**: WMH-SynthSeg가 native 5mm vs registered 1mm FLAIR서 WMH 부피 **2× 불일치**(CCC 0.47, rank ρ 0.83). 같은 환자·다른 acquisition → 다른 값 = 임상 reproducibility 문제.
- **모듈**: WMH-SynthSeg 출력(부피/확률맵) + 해상도/슬라이스두께 메타 → 해상도-불변 WMH 추정 경량 head.
- **baseline**: raw WMH-SynthSeg 출력.
- **GO 기준**: paired native+registered(Stage E ~100쌍)서 **CCC 0.47 → 유의 ↑** AND visual-grade 상관 보존 AND WMH→해마 β 안정. ablation 통과.
- **이름 정당 시**: "resolution-harmonization module for clinical WMH quantification". Track 04와 직결.
- **데이터**: 이미 보유(stageE native + stageB/C registered, 시각등급). 추가 GT 불요(self-consistency가 metric).

### C2. (대안) WMH partial-volume refinement — thick-slice 5mm서 PV 보정 (GT 필요 → 약함)
### C3. (대안) 사용자 지정 — Min이 medical-AI 전공자로서 특정 모듈 구상 있으면 우선

## Dead walls (금지)
- image→CN/AD/amyloid 분류로 morphometry(0.91) 넘기 (track01·voxelwise·MixStyle 死)
- multimodal fusion accuracy SOTA (fusion_synergy +0.016 死)
- 새 분할기로 WMH-SynthSeg 이기기 (GT 없음 + 강한 baseline)

## 상태
셋업. **task 미확정** — C1(권장) vs Min 구상(C3) 결정 후 설계.
GPU 학습 = 사전승인 + 하네스. 이번 단계 = 설계·contract만.
