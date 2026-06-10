# FOMO Official Preprocessing Scaffold — 2026-06-08 (byte-verified vs 공식 코드)

## 상태

이 scaffold는 **공식 코드와 byte 단위로 대조**되었다(이전: 문서/논문 정렬 → 현재: 실제 yucca/baseline 코드 확인).
- 대조 대상:
  - `fomo25/baseline-codebase` → `src/data/fomo-60k/preprocess.py` (pretraining 전처리 진입점)
  - `Sllambias/yucca` → `yucca/functional/preprocessing.py` (`preprocess_case_for_training_without_label`) + `yucca/functional/array_operations/normalization.py` (`volume_wise_znorm`)
- 여전히 Yucca를 import하는 *공식 코드 자체*는 아니다 — **공식 로직을 nibabel로 재현한 정렬 scaffold**이며, 핵심 파라미터·연산순서는 byte-대조로 일치시켰다.

## 공식 코드 원문 (인용)

**fomo25 baseline `preprocess.py`**:
```python
preprocess_config = {
    "normalization_operation": ["volume_wise_znorm"],
    "crop_to_nonzero": True,
    "target_orientation": "RAS",
    "target_spacing": [1.0, 1.0, 1.0],
    "keep_aspect_ratio_when_using_target_size": False,
    "transpose": [0, 1, 2],
}
# 입력은 이미 "co-registered, RAS, defaced/skull-stripped" (README) → 그 위에 추가 전처리
# 저장: np.save(.npy) + save_pickle(.pkl)
```
**yucca 연산 순서** (`preprocess_case_for_training_without_label`):
```text
reorient(RAS) → crop_to_nonzero(bg=0) → transpose → resample(skimage resize, order=3) → resample_and_normalize → (volume_wise_znorm)
```
**yucca `volume_wise_znorm`** (`array_operations/normalization.py`):
```python
mask = array != empty_val          # foreground(=nonzero)
array = clamp(array, mask=mask)     # clamp: upper-clip to 99th pct of FOREGROUND (q=0.99)
array = znormalize(array, mask=mask)  # FOREGROUND mean/std로 z-norm
```

## byte-대조 결과

| 항목 | 공식(yucca/baseline) | 이 scaffold | 판정 |
|---|---|---|---|
| reorient | RAS | RAS (`as_closest_canonical`) | ✅ |
| 연산 순서 | crop → resample → znorm | crop → resample → znorm (재정렬 완료) | ✅ (수정함) |
| crop | `crop_to_nonzero`(bg=0), resample 前 | nonzero bbox, resample 前 | ✅ |
| resample spacing | 1mm iso | 1mm iso | ✅ |
| resample interpolation | **order=3 (cubic)** | **order=3** (수정함, 이전 order=1) | ✅ (수정함) |
| 99th upper clip | volume_wise_znorm 내부 clamp(q=0.99, foreground) | clip_upper=99 on nonzero mask | ✅ |
| z-norm | foreground mean/std | foreground mean/std | ✅ |
| N4 | 없음 | 없음 | ✅ |
| skull-strip | upstream(입력 pre-stripped) | 안 함(경고만) | ✅(설계 일치) |

### 정정 (이전 주장 오류)
- ❌ 이전: "FOMO25 config엔 clip이 없다(=AMAES-specific)." → ✅ **정정: 99th upper clip은 `volume_wise_znorm` 내부 `clamp(q=0.99)`로 존재**(foreground 기준). scaffold의 clip_upper=99가 맞다.

## 남은 차이 (문서화, 버그 아님)
1. **resample 엔진**: scaffold=nibabel `resample_to_output(order=3, affine-aware)` vs 공식=skimage `resize(order=3, shape-from-spacing)`. **order·target spacing 동일**, 가장자리 수치만 미세 차이.
2. **출력 포맷**: scaffold=`.nii.gz`+json sidecar(검수 친화) vs 공식=`.npy`+`.pkl(image_props)`(학습 파이프라인용). 학습에 바로 먹이려면 .npy 저장으로 바꿔야 함.

## ⚠️ 우리 데이터 적용 핵심 (정직)
- **공식 입력은 skull-stripped** → nonzero==brain. **FOMO300K는 RAW/whole-head 배포**(샘플 검증). 공식 매치하려면 **HD-BET/SynthStrip을 upstream 실행** 필요. scaffold는 strip 안 하고 `skull_strip_warning`을 sidecar에 기록(실측: whole-head FOMO에 정상 발화).
- skull-strip 채택은 우리 whole-head/site-bias 선호와 충돌 → **모델링 결정**(공식 매치 vs whole-head).
- `/home/vlm/data/raw/`는 읽기 입력만(write/delete/move 금지). OASIS 제외·subject 중복·cohort path adapter는 manifest audit에서 별도.

## 검증 (실측)
- 문법 OK / `contract` 출력 = byte-verified contract.
- 실제 FOMO 볼륨(FLAIR 1.25mm)에 `preprocess-one` 완주: → RAS·**1mm iso**·crop·foreground-clamp99·foreground-znorm, status=completed, skull_strip_warning 발화 ✓.

## 제공 기능
```bash
python fomo_preprocess_scaffold.py contract
python fomo_preprocess_scaffold.py audit-manifest --manifest IN.csv --path-column raw_path --out-csv audit.csv --exclude-consortium OASIS
python fomo_preprocess_scaffold.py preprocess-one --input raw.nii.gz --output out.nii.gz --sidecar out.json [--dry-run]
```

## 남은 작업
1. ✅ 공식 코드 byte-대조 (완료, 본 문서).
2. ☐ **skull-strip 결정**(공식 strip vs whole-head) + 결정 시 HD-BET/SynthStrip upstream 연결.
3. ☐ (학습 직결 시) 출력 .npy+.pkl로 전환 + image_props 호환.
4. ☐ FOMO raw 3-5개 + 우리 raw cohort별 path adapter audit → bounded smoke → manifest dry-run.
5. ☐ Min 승인 후 bounded → 대량 preprocessing(별도 command preview+승인).
