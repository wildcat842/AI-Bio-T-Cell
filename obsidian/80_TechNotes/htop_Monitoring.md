---
title: htop - 공용 서버 모니터링 가이드
tags: [tutorial, infrastructure, monitoring, shared-server]
status: living
created: 2026-05-21
---

# htop - 공용 서버 모니터링 가이드

> **목적**: `lucia@server179-96` 같은 공용 GPU 서버에서 본인 R/Python/학습 작업의 자원 사용을 파악하고, 다른 사용자와 충돌을 피하는 법.

## 0. 한 줄 핵심

> **`htop -u lucia`**로 시작 → **`M` (메모리 정렬)** → **`F4` 대신 `\` (필터)** → **`q`로 종료**. 이 4개면 90% 케이스 해결.

## 1. 시작과 종료

```bash
htop                       # 전체 프로세스
htop -u lucia              # 본인 프로세스만 ⭐
htop -p <PID1>,<PID2>      # 특정 PID만
htop -d 5                  # 0.5초 갱신 (기본 1.5초)
```

종료: **`q`** (대문자 F10도 가능하지만 VS Code 터미널에서는 가로채일 수 있음)

## 2. VS Code에서의 핵심 문제 — F-키 가로채기

VS Code integrated terminal에서 htop을 실행하면 **F1~F10 키를 VS Code가 가로챕니다** (F1=Command Palette, F5=Debug, etc.). htop은 다행히 모든 F-키에 **letter 단축키 대안**을 제공합니다.

| 기능 | F-키 (VS Code가 가로챔) | letter 대안 (반드시 작동) |
| --- | --- | --- |
| **메모리 정렬** | - | **`M`** (Shift+m) ⭐ |
| **CPU 정렬** | - | **`P`** (Shift+p) ⭐ |
| 시간 정렬 | - | `T` |
| 도움말 | F1 | `h` 또는 `?` |
| 설정 | F2 | `S` (대문자) |
| 검색 | F3 | `/` |
| **필터** | F4 | `\` (백슬래시) ⭐ |
| **트리뷰** | F5 | `t` (소문자) ⭐ |
| 정렬 컬럼 | F6 | `<` 또는 `>` |
| Nice 값 | F7 / F8 | `[` / `]` |
| **종료할 프로세스 선택** | F9 | `k` ⭐ |
| **htop 종료** | F10 | `q` ⭐ |
| 사용자 필터 | - | `u` |
| Thread 표시 | - | `H` (대문자) |
| 모든 프로세스 표시/숨김 토글 | - | `Space` (태그 토글) |

→ **`M`, `P`, `\`, `t`, `k`, `q`** 6개만 외우면 충분.

영구 해결책 (VS Code 설정): [[R_Manual]] §13 또는 프로젝트 `.vscode/settings.json` 참조.

## 3. 상단 게이지 읽기

```
Avg[||||||||||||||||||           59.7%]    ← CPU 평균 사용률
Mem[||||||||||||||||  177G/976G]           ← 물리 메모리 사용/전체
Swap[||||||||||||||||  16.0G/16.0G]        ← 스왑 사용/전체
Tasks: 1811, 14418 thr; 5 running          ← 프로세스/스레드/실행 중
Load average: 94.19 82.98 80.92            ← 1/5/15분 평균 로드
Uptime: 263 days(!), 16:57:47              ← 서버 가동 시간
```

### 해석 가이드

| 지표 | 좋음 | 주의 | 위험 |
| --- | --- | --- | --- |
| **Mem 사용률** | < 70% | 70~85% | > 85% (스왑 발생 위험) |
| **Swap 사용** | 0~10% | 10~50% | > 50% (RAM 부족, 성능 저하) |
| **Load average** | < CPU 코어 수 | ~ 코어 수 | > 코어 수의 2배 (오버로드) |
| **Running tasks** | 코어 수 이하 | 코어 수 정도 | 지속적으로 코어 수 초과 |

본 서버(코어 80+개 가정) 예시:
- Mem 177G/976G = 18% 사용 → **여유 800G** ✅
- Swap 16G/16G = 가득 → **이전 메모리 압박의 잔재** ⚠️ (현재는 RAM 충분)
- Load 94 ≈ CPU 코어 수 → 적당히 바쁨 ✅

## 4. 프로세스 컬럼 의미

| 컬럼 | 의미 |
| --- | --- |
| `PID` | 프로세스 ID |
| `USER` | 실행 사용자 |
| `PRI` | 우선순위 |
| `NI` | nice 값 (낮을수록 우선순위 높음) |
| `VIRT` | 가상 메모리 (덜 중요, 매핑된 전체) |
| **`RES`** | **실제 RAM 점유 (Resident Set Size)** ⭐ |
| `SHR` | 공유 메모리 |
| `S` | 상태 (R=실행, S=수면, D=대기, Z=좀비) |
| **`CPU%`** | **CPU 사용률 (단일 코어 기준 100%)** ⭐ |
| **`MEM%`** | **전체 RAM 대비 %** ⭐ |
| `TIME+` | 누적 CPU 시간 (m:ss 형식) |
| `Command` | 실행 명령 |

### 자주 보는 패턴
- **`Rscript` 또는 `python` RES가 점점 커짐**: 큰 .rds나 .h5ad 로드 중. 정상.
- **`python` CPU 100% 초과 (예: 400%)**: 멀티스레드 (numpy/torch) 사용 중. 정상.
- **`Z` 상태 (zombie)**: 정리 안 된 자식 프로세스. 부모 프로세스 종료하면 해결.
- **`D` 상태 지속 (uninterruptible sleep)**: 디스크 I/O 대기. 보통 .rds 로딩 또는 swap 사용 중.

## 5. 워크플로우 — 본인 R/Python 작업 모니터링

### 시나리오 A — 큰 Seurat .rds 로딩 중 메모리 추적

```bash
# 별도 SSH 터미널 (또는 tmux pane)
htop -u lucia

# htop 안에서:
M               # 메모리 정렬 → 본인 R 프로세스가 가장 위로
# RES 컬럼이 점점 커지는 것을 관찰
# 30 GB까지 가면 정상 (Seurat 5 layered object)
# 100 GB 넘으면 OOM 위험, 다른 .rds로 시도
```

### 시나리오 B — PyTorch 학습 시작 후 GPU/CPU 확인

```bash
# 터미널 1
python train.py

# 터미널 2 (별창)
htop -u lucia
P               # CPU 정렬 → DataLoader worker들 보임

# 터미널 3 (GPU)
watch -n 2 'nvidia-smi --query-gpu=index,memory.used,utilization.gpu --format=csv,noheader'
```

### 시나리오 C — 공용 서버에서 GPU 비어있는지 확인 (학습 시작 전)

```bash
nvidia-smi --query-gpu=index,name,memory.used,memory.total --format=csv,noheader
# 0번 GPU의 memory.used가 < 1 GB면 비어있음
# 그 GPU 사용
CUDA_VISIBLE_DEVICES=0 python train.py
```

### 시나리오 D — 다른 사용자가 RAM 잡고 있는지

```bash
htop
M               # 메모리 정렬
u               # 사용자 필터 → all users (q 빠져나오기)
# 상위 5개 보고 어떤 사용자가 메모리 점유 중인지 파악
```

## 6. htop 대신/추가로 쓸만한 도구

### conda env에 이미 깔린 것
- `nvtop` (없으면 `mamba install -c conda-forge nvtop`) — GPU의 htop
- `glances` (없으면 `mamba install -c conda-forge glances`) — 한 화면에 CPU/Mem/Net/Disk/GPU 다
- `btop` (`mamba install -c conda-forge btop`) — 최신 UI, 마우스 잘 작동

### 한 줄 명령
```bash
# 본인 메모리 사용 top 10
ps -u lucia -o pid,rss,pcpu,cmd --sort=-rss --no-headers | head -10 | \
  awk '{printf "%6d  %6.2f GB  %5.1f%%  %s\n", $1, $2/1048576, $3, substr($0, index($0,$4))}'

# 본인 총 메모리 사용량
ps -u lucia -o rss --no-headers | awk '{s+=$1} END {printf "Total: %.2f GB\n", s/1048576}'

# 현재 시스템 한 줄 요약
echo "Load: $(uptime | awk -F'load average:' '{print $2}'); RAM free: $(free -h | awk '/^Mem:/ {print $4}')"

# 5초마다 본인 프로세스 목록 갱신
watch -n 5 'ps -u lucia -o pid,rss,pcpu,etime,cmd --sort=-rss | head -10'
```

## 7. tmux와 결합 — SSH 끊겨도 모니터링 유지

```bash
# 최초 1회만 (서버에서)
tmux new -s monitor
# tmux 안에서
htop -u lucia

# 화면에서 벗어날 때 (htop은 계속 실행됨)
# Ctrl+B 누른 후 D (detach)

# 다시 보고 싶을 때 (다음 SSH 접속 후)
tmux attach -t monitor

# 영구 종료
# tmux 안에서 Ctrl+B 누른 후 :kill-session
```

## 8. 트러블슈팅

| 증상 | 원인 | 해결 |
| --- | --- | --- |
| `htop: command not found` | conda env에 없음 | `mamba install -c conda-forge htop` |
| F-키가 작동 안 함 | VS Code 가로채기 | §2의 letter 대안 사용 |
| 글자 깨짐 | locale 미설정 | `export LANG=ko_KR.UTF-8` 또는 `LANG=C.UTF-8` |
| 본인 프로세스가 안 보임 | 다른 사용자 필터 활성 | `u` → All users |
| 트리뷰가 너무 복잡 | thread 표시 켜짐 | `H` 눌러 thread 숨김 |
| 메모리 표시가 K/M/G가 아닌 숫자 | 단위 설정 | `S` (설정) → Meters → Show CPU/Mem in normalized 켜기 |

## 9. 보안 / 매너 — 공용 서버 에티켓

| 행동 | 권장 |
| --- | --- |
| GPU 점유 전 다른 사용자 확인 | `nvidia-smi` 먼저 |
| 메모리 큰 작업 전 RAM 확인 | `free -h`, 다른 user의 RES |
| 오래 걸리는 작업 | `nice -n 10`으로 우선순위 낮추기 |
| 작업 끝나면 conda env deactivate | `conda deactivate` |
| 임시 파일 정리 | `~/tmp/`, `/tmp/lucia_*` 등 |
| 다른 사용자 프로세스 kill 금지 | `htop`에서 `k` 누를 때 본인 PID인지 확인 ⚠️ |

## 10. 관련 노트

- [[R_Manual]] §13 — VS Code F-키 가로채기 우회 (VS Code 설정으로 영구 해결)
- [[R_Python_Bridge]] — R↔Python 동시 작업 시 메모리 모니터링 중요
- 평가 보고서 §5 — 하드웨어 권장 사양

## 한 줄

> 공용 서버 R/Python 작업의 90%는 **`htop -u lucia` → `M`(메모리 정렬) → 본인 RES가 100G 안 넘는지 확인** 한 줄로 끝납니다. VS Code 터미널에서는 F-키 대신 letter 단축키(`M`, `P`, `\`, `t`, `k`, `q`)를 쓰세요. GPU는 `nvidia-smi` 또는 `nvtop`으로 별도 확인.
