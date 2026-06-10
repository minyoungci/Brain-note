# CRON_SETUP — daily note 자동화 구성

> ⚠️ **폐기됨 (2026-06-10).** 이 OS cron 방식은 컨테이너 재시작(2026-06-09) 때 패키지·데몬·crontab이
> 전부 소멸해 6/9 노트가 누락됐다. 현재 방식은 **`SCHEDULER_SETUP.md`**(userland, 재시작 생존형)를 보라.
> 아래는 이력 보존용 기록이다.

> **목적:** `daily_note.sh`를 매일 23:50 KST 자동 실행하는 스케줄러 구성과 복구 절차  ·  **갱신:** 2026-06-03

이 서버는 **s6-overlay 컨테이너**(PID1 = `s6-svscan`)다. systemd·기본 cron이 없어 일반적인
`crontab` 설치가 바로 안 된다. 아래는 실제로 구성한 방식과, 컨테이너 재시작 시 점검 절차다.

## 구성 요약

| 항목 | 값 |
|---|---|
| 스케줄 | `50 14 * * *` (UTC) = **23:50 KST** 매일 |
| 실행 사용자 | `dbssus123` (crontab owner, SSH 키 보유) |
| 잡 | `DO_PUSH=1 tools/daily_note.sh >> .cron.log 2>&1` |
| cron 패키지 | `cron 3.0pl1-137ubuntu3` (jammy, archive.ubuntu.com에서 .deb 수동 설치) |
| 데몬 영속 | `/etc/services.d/cron/run` (s6-overlay legacy v2 서비스) |
| 로그 | `OBSERVATORY/.cron.log` (gitignore) |

## 왜 이렇게 했나 (환경 제약)

- **systemd 불가**: PID1이 `s6-svscan`. `systemctl`·user timer 모두 사용 불가(DBUS 없음).
- **apt 메인 미러 깨짐**: 한국 미러(`ftp.daum.net`)가 Release 파일을 안 줘서 `apt-get install cron` 실패
  (`Candidate: (none)`). → archive.ubuntu.com pool에서 jammy `.deb`를 직접 받아 `dpkg -i`.
- **cron은 root 필요**: 타 사용자 spool 읽기·setuid 때문. 컨테이너는 `dbssus123`로 돌지만 `sudo` 무암호 가능.

## 설치 절차 (재현용)

```bash
# 1) cron .deb 설치 (jammy)
cd /tmp
wget http://archive.ubuntu.com/ubuntu/pool/main/c/cron/cron_3.0pl1-137ubuntu3_amd64.deb
sudo dpkg -i cron_3.0pl1-137ubuntu3_amd64.deb

# 2) crontab 등록 (사용자 dbssus123)
crontab -l   # 아래 라인이 있어야 함
# 50 14 * * * DO_PUSH=1 /home/vlm/minyoung/OBSERVATORY/tools/daily_note.sh >> /home/vlm/minyoung/OBSERVATORY/.cron.log 2>&1

# 3) cron 데몬 기동 (root, daemonize → PID1로 reparent)
sudo /usr/sbin/cron
pgrep -a cron   # /usr/sbin/cron 떠 있어야 함
```

## 영속성 — 컨테이너 재시작 대응 ⚠️ 중요

`sudo /usr/sbin/cron`으로 띄운 데몬은 **현재 컨테이너 한정**이다. 재시작하면 사라진다.
재시작 자동 복구를 위해 s6-overlay legacy 서비스를 심어 뒀다:

- `/etc/services.d/cron/run` → 부팅 시 s6-overlay가 `cron -f`를 supervise.

**단, 이 서비스가 부팅 시 root로 실행되는지는 컨테이너 정책에 의존한다(미검증, `[VERIFY]`).**
s6 트리가 jovyan 권한으로 돌면 `cron -f`가 root 권한을 못 얻어 실패할 수 있다.
→ 재시작 후 반드시 아래 헬스체크를 돌려라.

### 재시작 후 헬스체크

```bash
pgrep -a cron || echo "cron 데몬 죽음 → sudo /usr/sbin/cron 재기동 필요"
crontab -l | grep daily_note || echo "crontab 비었음 → 아래 재등록"
```

cron이 안 떠 있으면:
```bash
sudo /usr/sbin/cron        # 즉시 복구
```
crontab이 비었으면(spool 손실 시):
```bash
( crontab -l 2>/dev/null | grep -v daily_note.sh
  echo '# OBSERVATORY daily note — 23:50 KST (14:50 UTC) 생성·commit·push'
  echo '50 14 * * * DO_PUSH=1 /home/vlm/minyoung/OBSERVATORY/tools/daily_note.sh >> /home/vlm/minyoung/OBSERVATORY/.cron.log 2>&1'
) | crontab -
```

## 검증 기록 (2026-06-03)

- ✅ cron 1분 테스트 잡 발사 확인 (`00:15:01 UTC` 실행).
- ✅ `daily_note.sh`를 cron 최소환경(`env -i HOME=… PATH=/usr/bin:/bin`)으로 실행 → 생성·commit·**push** 성공.
- ⚠️ `[VERIFY]` 컨테이너 재시작 후 `/etc/services.d/cron`이 root로 자동 기동되는지 미확인 — 첫 재시작 때 헬스체크로 확인.

## 수동 실행 (cron 없이)

```bash
tools/daily_note.sh                  # 오늘(KST) 노트 생성·commit
DATE=2026-06-01 tools/daily_note.sh  # 특정일 재생성(멱등)
DO_PUSH=1 tools/daily_note.sh        # commit 후 push
```
