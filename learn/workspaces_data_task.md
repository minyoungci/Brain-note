# 워크스페이스 데이터·Task 매트릭스

> 5개 연구 디렉토리의 *실험 내용*을 데이터·task별로 한 표에 정리. · 기준: 2026-06-11
> 출처: 각 워크스페이스 카드(`workspaces/<NN>/`) + manifest 실측 + `plant/RESEARCH_BRIEF.md`.
> ⚠️ `DASHBOARD.md`의 04_plant 행은 stale(옛 longitudinal). **plant는 microbrain으로 재정의됨** — 이 표가 최신.

## 공유 데이터 토대

| 자산 | 내용 |
|---|---|
| `official_manifest_full_n4_real_final.parquet` | **THE canonical** (최신). 13,022 세션 / 7 코호트 / 122컬럼. `.datadict.csv` 동봉. |
| `official_manifest_full_n4.csv` | N4 프로그램판(6/3). minyoung2·3·4가 공유. |
| `official_manifest_full.parquet` | base(13,022×75). |
| 입력 텐서 | `final_tensor_path` = 192×224×192, 1mm RAS, z-score, brain-masked, 동일 격자. N4판 `final_tensor_n4_path`. |
| 7 코호트(N 세션) | ADNI 4742 · NACC 1866 · A4 1811 · OASIS 1420 · AJU 1287 · AIBL 987 · KDRC 909 |
| 공통 타깃 | `cdr_global`(0:7080/0.5:4931/1:831/2:161/3:19, severe 희소) · morphometry bar `fs_vol_*` |
| 공유 함정 | `roi_final_ready=False`(전수, 사람 sign-off 전) · site 누수(LOCO 미적용 시 AUC 거품) |

경로: `/home/vlm/data/preprocessed_official/`

## 디렉토리별 매트릭스

| 디렉토리 | Task (연구 질문) | 데이터 (코호트·N·매니페스트) | 입력·방법 | 상태 / 핵심 결과 |
|---|---|---|---|---|
| **minyoung2** (EXP01) | nuisance shortcut(site·tracer·timing·뇌용적) 통제 후 T1w가 **transportable CDR 신호를 incremental**하게 담는가. + EXP04 N4 transport | 7-cohort T1w+CDR · 2.5D coronal slice-bag manifest · 5-ROI FreeSurfer 부피 baseline · EXP04=`..._n4` | 2.5D MIL, **7-cohort LOCO + control battery**, paired bootstrap incremental value. 3D CNN(IMG-020/022) 실행 중 | 🟡 **deep ≈ regional volumetry** (5/5 fold 동률, pooled만 +0.018). 3D CNN 결과 미생성 |
| **minyoung4** | scanner/source/consortium shortcut을 **GRL+decorrelation**으로 벗긴 3D T1w 표현이 **ROI 부피 baseline을 넘는가** | `..._n4.csv`(13,022/7,231 subj). sup CN/AD = ADNI(75/832)·AIBL(51/422)·KDRC(130/255)=**1,765 subj**. CN-only ctrl = NACC(935)·OASIS(7) | domain-adversarial(GRL), **Stage219~232 ROI-intensity LOCO 게이트** | ⚠️ **BLOCKED** — 2회 피벗 기각(scanner-family 누수·morphometry 미초과), G0 coverage 미통과, 6/3~6/7 미커밋 |
| **minyoung3** (F04) | **image-only 3D ROI-grounded 해부학 VQA** (three-zone: far-neg/near-cut/far-pos). 진단분류 아닌 **task/eval 기여**, 3D>고정 2.5D | ROI-evidence dataset **18,815 sess/56,445 slab** · matched 3D VQA **19,236 QA / 9,278 sess / 5,601 subj** | 3D global64³+MTL64³ fusion tri-view, **raw-visible 라벨**, validation-locked LOCO. **입력=이미지+question ID만** | 🟢 manuscript asset 생성. 외부 morphometry bar 0.910. git 부재 |
| **plant** ⟶ **microbrain** 🆕 | **site/scanner bias 내성 micro-level T1w 표현**. 1순위 = 표현 부진 원인이 **(a) bias 오염** vs **(b) 부피 너머 미세신호 천장**인지 분리·판정 | `..._n4_real_final`(13,022/7코호트). voxel 풀 `voxelwise_qc_candidate=True` **12,978**. bias축 consortium·acq_scanner·acq_field_strength. bar `fs_vol_*` | **입력=이미지만**. P0 audit→P1 baseline→P2 multi-arm(SSL/site-invariance/harmonization/대조)→P3 (a)/(b)판정. 게이트 G1(site→chance)+G2(morphometry 초과·transport) | 🆕 설계 lock 전, **P0 착수 대기**. (옛 longitudinal 라인 폐기) |
| **minyoungi** | 지원 — ① 문헌 triage ② clinical 데이터 이해(교육 ipynb) ③ **ROI QC (Gate05b)** | `roi_volumes_full.parquet`(전수 13,022 ROI vol, provisional) · ROI auto-QC 13,022(**12,932 PASS/46 FLAG**) · 7컨소시엄 EDA | notebooks 00~06, ROI numeric+visual QC, CDR Global 공통타깃, ComBat harmonization, b1 global ROI-cos | 🟡 Gate05b: b1이 ADNI/KDRC 개선하나 **NACC 회귀**. `roi_final_ready` 전수 False |

## 횡단 연결

```
minyoungi (데이터·문헌·ROI QC 공급)
   │
minyoung2 EXP01 (cross-sectional 프로토콜·척추) ── deep≈volumetry 결론
   ├ minyoung4 : 표현학습 축 (GRL shortcut 제거, BLOCKED)
   ├ minyoung3 : 데이터 생성 축 (ROI-evidence → 해부 VQA)
   └ plant/microbrain : bias 내성 micro 표현 축 (audit→multi-arm, P0 대기)
minyoung2·3·4는 official_manifest_full_n4 공유(N4 프로그램)
```
