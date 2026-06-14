# eTIV 배치 산출 — 설계안 (00_etiv_batch)
> 목적: head-size 정규화용 **atrophy-불변 eTIV**를 전 subject에 산출 → 작업 manifest에 `eTIV` 컬럼 추가.
> RESEARCH_PLAN §6(normative threshold)의 **선행 prerequisite (P1)**. 13k bulk 배치 → **실행 전 사용자 승인 필요**.

## 0. 가용성 (검증됨 2026-06-14)
- FSL flirt: `/home/jovyan/fsl/share/fsl/bin/flirt` ✓
- MNI152 full-head 템플릿: `/home/jovyan/fsl/data/standard/MNI152_T1_1mm.nii.gz` ✓ (두개골 포함)
- 입력 `orig.mgz`(FastSurfer 256³ conformed full-head): **7코호트 전수 존재** ✓
- 대안 도구: ANTs(antspyx 0.6.3), SimpleITK 2.2.1

## 1. 방법 (Buckner 2004 / FreeSurfer eTIV 원리)
- **왜 orig.mgz**: brain-extracted(native_hdbet)는 affine 스케일이 *brain 크기*를 따라가 위축에 교란됨.
  `orig.mgz`는 **두개골 포함(full-head)** → 등록 스케일이 *두개강 크기* 기준 = **atrophy-불변**.
- 등록: `orig.mgz` → `MNI152_T1_1mm` **12-dof affine**(FLIRT, cost=corratio). 출력 = affine 행렬 M(subj→MNI).
- **eTIV = ICV_MNI152 / det(M의 3×3 linear part)**.
  - ICV_MNI152 = 상수. (norming이 비율기반이면 상수 cancel — 상대 norming엔 det만 필요; 절대 eTIV 보고 시에만 상수 fix.)
  - det 방향/부호는 §4 QC로 검증(작은 머리→작은 eTIV 나와야).

## 2. 파이프라인 (per subject)
1. `orig.mgz` → nii 변환 (nibabel; FLIRT가 .mgz 직접 불가 시).
2. `flirt -in orig.nii -ref MNI152_T1_1mm -dof 12 -omat M.mat -cost corratio` (이미지 출력 불필요, 행렬만).
3. `det = np.linalg.det(M[:3,:3])`.
4. `eTIV = ICV_MNI / det`.
5. QC: flirt cost, det 범위 → flag.

## 3. 출력 (이 서브디렉토리)
- `00_etiv_batch/etiv_table.csv`: `tag, subject_id, session_id, consortium, eTIV, det, flirt_cost, qc_flag`
- → 작업용 manifest에 `eTIV` 컬럼 **merge(별도 파일, 원 manifest 불변)**.
- 로그: `00_etiv_batch/run.log`, 실패목록 `failures.csv`.

## 4. 검증 / QC (자기기만 방지 — 전량 전에 파일럿)
- **파일럿 200 subject 먼저** → 아래 통과 후 전량.
- eTIV 분포 **~1.2–1.8 L**(성인 정상). 범위 밖 = 등록 실패 의심 → flag.
- **남>여**(성별차 알려짐) 재현.
- eTIV vs `fs_BrainSegVol` 상관 ~0.7–0.9 (높되 <1).
- **결정적**: **AD군 eTIV ≈ CN군 eTIV**(atrophy-불변) vs `fs_BrainSegVol`은 AD<CN.
  이 대조가 "eTIV가 제대로 atrophy-불변"이라는 증거. (KDRC dx 라벨로 확인.)
- 등록 실패(cost 이상/det 음수·극단) → 재시도(다른 cost/도구) 또는 제외 기록.

## 5. 컴퓨트
- FLIRT 12-dof ~10–40s/subject(CPU). 13,022 → 다코어 병렬 **수 시간**. GPU 불필요(affine=CPU).
- I/O: orig.mgz 읽기(256³). 동시성 제한으로 디스크 부하 관리(RAM 보호: sysmon).

## 6. 리스크
- FastSurfer conformed-space eTIV ≠ FreeSurfer talairach eTIV(미세 차이) → **전 subject 동일 방법으로 내부 일관** 산출(상대 norming엔 충분).
- 등록 실패(병리/아티팩트) → QC flag.
- multi-scanner: eTIV는 두개강(해부)이라 scanner 영향 작으나 FLIRT 강건성은 영상품질 의존 → cost QC.
- ICV_MNI 상수: 상대 norming이면 무관.

## 7. 실행 순서 (승인 후)
1. 파일럿 200(코호트 균형) → §4 QC 통과 확인.
2. 전량 13k 배치(병렬) → `etiv_table.csv`.
3. manifest merge + 분포 리포트.
→ 그 다음 RESEARCH_PLAN §6: CN군 norming(eTIV residual + age/sex w-score/centile) → Stage1 report 규칙.

## 상태
- [ ] 사용자 승인 (bulk 배치)
- [ ] 파일럿 200
- [ ] 전량 + merge
