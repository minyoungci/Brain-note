# 단일 Transform Chain — 보조 모달리티를 T1w 격자에 정렬하는 계약

> 핵심: FLAIR/T2/PET가 T1w final tensor와 **voxel-for-voxel 대응**하려면, T1w를 만든
> 것과 **동일한 crop/pad centroid**를 써야 한다. 이 문서는 그 계약을 정의한다.

## 왜 final cropped tensor를 등록 기준으로 쓰면 안 되나

official note §7.2: T1w final tensor는 crop/pad 후 **affine이 identity일 수 있다**. 이걸
registration `-ref`로 쓰면 real anatomy 좌표를 잃는다. 따라서 등록 기준은 **anatomy 좌표가
살아있는 1mm-RAS T1w (pre-crop)** 여야 한다.

## 체인 (보간은 단 한 번)

```
moving raw (FLAIR/T2/PET)
  ├─ [AJU] dcm2niix → NIfTI
  ├─ N4 bias correction        (구조 모달리티만; PET 제외)
  ▼
rigid register (FLIRT 6-DOF, normmi) → ref = 1mm-RAS T1w reference grid
  │   ⇒ 등록 결과가 곧 model grid(pre-crop)에 안착 = 보간 1회
  ▼
crop/pad  (T1w brain mask의 bbox+centroid 사용; 순수 array slice, 보간 0)
  ▼
normalize
  ├─ 구조(FLAIR/T2): brain-mask robust z-score  (T1w와 통일)
  └─ PET: SUVR (whole cerebellum) → clip → [0,1]
  ▼
final tensor [192,224,192]  +  spatial QC (registration dice/centroid)
```

## 1mm-RAS T1w reference 재구성 (결정적)

v2 출력이 pre-crop 중간물을 저장하지 않을 수 있으므로, **native HD-BET brain+mask에서
결정적으로 재구성**한다 (T1w가 만들어진 방식 그대로):

```python
ref = transform_chain.reconstruct_t1w_reference(native_brain, native_mask, voxel_mm=1.0)
#   brain: RAS → 1mm resample(order=1)
#   mask : RAS → 1mm resample(order=0)  ← binary 유지
```

같은 native 격자를 같은 voxel로 resample → 같은 shape·같은 centroid → **T1w final tensor와
동일 grid**. 이 mask centroid로 `crop_or_pad_with_reference`를 호출하면 모든 모달리티가
정확히 같은 자리에 놓인다 (`tests/test_transform_chain.py`가 이 불변식을 검증).

## 왜 moving 자신의 mask가 아니라 T1w mask로 crop 하나

각 모달리티가 자기 brain mask centroid로 crop하면 모달리티마다 crop 중심이 미세하게
달라져 **채널 간 voxel 대응이 깨진다**. T1w mask 하나로 모두 crop해야 정렬이 보장된다.
(official crop_pad.py 주석: "Use the same crop metadata for T1w/PET alignment contracts.")

## QC (intensity-only 금지)

- `registration_qc`: 등록된 모달리티 support vs T1w brain mask의 **dice + centroid 거리**.
- `tensor_qc`: shape/finite/nonzero.
- PET 추가: SUVR reference voxel 수, cortical mean SUVR plausibility band.
