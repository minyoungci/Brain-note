# 전처리 — 실행 노트

> 상세·근거(파이프라인 4단계·안전장치·manifest·코퍼스 실측·DWI 큐레이션·무결성)는 **[[../docs/02_data]]** 단일 출처.

전처리는 **완료**(학습 코퍼스 226,793 / 3.2TB, `/home/vlm/data/FOMO300K_preprocessed`). 재실행/추가 시:
```bash
# 점검(처리 없이 대기 수)
PYTHONPATH=baseline-codebase/src .venv/bin/python preprocessing/preprocess_fomo300k.py --dry-run
# 실행(공식 Yucca 4단계 + float16 + DWI b800~1200 큐레이션, 자동 resume)
PYTHONPATH=baseline-codebase/src .venv/bin/python preprocessing/preprocess_fomo300k.py --modalities --num-workers 32
```
- `preprocess_fomo300k.py` — 프로덕션 드라이버(스트리밍·안전장치 11·manifest CSV). `--dwi-bval-min/max`(기본 800~1200), `--categories`(기본 anat,dwi).
- `analyze_corpus.py` — 코퍼스 실측 분석(`.venv-train`).
- `extract_arrange.py` — 파일럿 추출 전용(프로덕션은 드라이버로 대체).
- 전처리 env = `.venv`(yucca2.2.6/torch2.2). 학습은 `.venv-train`.
