# I04 — 엔지니어링 함정 (조용히 결과를 망치는 버그 패턴)

## P1 — cache/index 정렬 오류 (filter 후 위치 vs 원본 row)
- **증상**: npy를 `cache_index=arange(n)`로 만들고, 다운스트림에서 `man[ok]`로 필터 후 보조
  테이블(tab)을 **필터된 위치 0..k-1**로 인덱싱하면, 캐싱 실패가 1개라도 있을 때 npy-row와
  필터-위치가 어긋나 **이미지와 잘못된 레이블/타깃이 매칭**된다. 전체 캐싱 성공 시엔 숨겨져
  smoke를 통과하고 실제 run에서만 조용히 깨진다. (run_fusion_ssl.py에서 code-auditor가 C1로 적발)
- **교훈**: 보조 테이블은 **npy-row(원본 인덱스)로 일관 인덱싱**하라. `assert len(tab)==len(images)`,
  `assert cache_index==arange(n)`, 그리고 "랜덤 5샘플의 (이미지 row ↔ 레이블 row) 일치"를 출력 검증.

## P2 — 출력 tag 충돌 (서로 다른 실험이 같은 폴더 덮어씀)
- **증상**: pretrained 인코더 출처(brain-age vs ROI-volume)를 tag에 안 넣어 `_ptft` 동일 tag로
  brain-age seed-613 run을 ROI run이 덮어씀 → 집계가 두 arm을 섞음.
- **교훈**: tag에 **모든 구분 변수**(init 출처, width, pretext, seed)를 인코딩하고, summary.json에
  `config=vars(args)` 전체를 기록. 기존 출력 dir 침묵 덮어쓰기 금지.

## P3 — 소표본 AUC 인플레이션
- **증상**: longitudinal morphometry-change n=354 → 0.85, n=1,714 → 0.73–0.78. 작은 n + subject-CV는
  위로 편향.
- **교훈**: 헤드라인 수치는 **충분한 n + subject-level + bootstrap CI**에서. 소표본 셀은 "참고"로만.

## P4 — pgrep/pkill self-match (무한루프 + self-kill)
- **증상 A (대기 무한루프)**: `pgrep -f pretrain_brainage.py`가 **자기 명령줄**(그 문자열 포함)을
  매칭 → while 루프가 영원히 안 끝남.
- **증상 B (self-kill)**: `pkill -f build_X.py; ...; uv run python build_X_parallel.py` 를 한 줄에
  넣으면, pkill 패턴 "build_X.py"가 **이 명령 자신의 command line**(pkill 인자 + parallel 스크립트명에
  모두 포함)을 매칭해 **자기 bash를 SIGTERM(exit 144)** → 뒤의 launch가 실행조차 안 됨. 캐시 0.
- **교훈**: (1) 대기는 **파일 존재/개수**로. (2) pkill은 **launch와 분리된 별도 명령**에서, 패턴은
  죽일 대상에만 매칭되게 구체적으로(예: `pkill -f "build_X.py$"` 또는 `--parallel`을 패턴에 포함하지 말 것).
  같은 줄에서 "kill old + launch new"를 하지 말 것.

## P5 — 컬럼 충돌(merge suffix), 희소 필드
- longitudinal manifest의 `age/cdrsb`가 main manifest와 merge 시 `_x/_y` 충돌 → 침묵 NaN.
  종단 manifest의 `age`는 sparse(대부분 NaN)였다. **merge 후 dtype/non-null을 즉시 검증.**

## 재사용 체크리스트 (실험 전)
- [ ] 이미지↔레이블 정렬 랜덤샘플 출력 검증  [ ] tag에 모든 구분자 + config 전체 기록
- [ ] subject-level split 교집합 0 assert  [ ] permutation-null로 leakage 확인
- [ ] determinism flags(bf16, cudnn.deterministic)  [ ] 헤드라인은 큰 n + bootstrap

## P6 — 쉘 sweep의 빈 인자 파싱 (control이 조용히 실패)
- **증상**: `--aux  --tag F_x` 처럼 빈 값을 의도한 인자가, bash에서 공백이 collapse되어
  argparse가 `--aux="--tag"`로 먹고 `--tag`가 사라져 usage 에러 → **image-only/no-fusion control이
  전부 실패**. 정작 비-빈 fusion arm만 성공해 집계표에 baseline이 통째로 누락.
- **교훈**: 빈 값은 **반드시 따옴표**로 `--aux ""`. sweep 후 "기대한 run 수 == 실제 summary 수"를
  assert. control/baseline 누락은 결론을 통째로 무효화하므로 집계 시 baseline 존재를 먼저 확인.

## P7 — 미구현 pretext가 zero-loss backward crash (control 무효)
- **증상**: `--pretext recon`을 옵션으로 받았으나 forward에 recon loss 미구현 → `loss=tensor(0.0)`이
  leaf(grad_fn 없음) → `loss.backward()`가 "element 0 ... does not require grad" 크래시. recon
  control이 통째로 실패해 "longitudinal vs generic SSL" 비교가 빠짐.
- **교훈**: 옵션으로 노출한 모든 분기는 **실제 loss를 생성하는지** assert(`assert loss.requires_grad`).
  또는 미구현 분기는 argparse choices에서 제외. control이 실패하면 핵심 비교가 사라진다.
