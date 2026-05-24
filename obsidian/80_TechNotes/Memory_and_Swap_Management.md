---
title: Memory & Swap 관리 - 공용 서버 실전
tags: [technote, infrastructure, memory, swap, troubleshooting]
status: living
created: 2026-05-25
---

# Memory & Swap 관리 - 공용 서버 실전

> 본 프로젝트의 22 GB Seurat .rds 같은 큰 객체를 로딩할 때, 또는 다른 사용자가 무거운 학습을 돌릴 때, **메모리·스왑 상황을 정확히 진단하고 본인 작업을 안전하게 보호**하는 법.

## 0. 핵심 한 줄

> **"Swap 16G/16G"가 떠도 정상일 때가 많다.** 진짜 위험은 **"swap이 활발히 입출력 중(`si/so` 값이 큰)"** 상태. 진단은 `vmstat 2` 한 줄.

## 1. 개념 — RAM vs Swap vs OOM

### RAM (물리 메모리)
- 실제 DRAM 칩에 있는 공간 — 빠름 (ns 단위)
- L40S 서버: 976 GB

### Swap (페이지 파일)
- 디스크에 만든 "가짜 RAM" 확장 공간
- RAM이 부족할 때 비활성 페이지를 디스크로 옮기는 안전망
- 본 서버: 16 GB

### OOM (Out Of Memory)
- RAM + Swap도 다 차서 더 못 줄 때 → Linux OOM killer 발동
- 가장 RAM 많이 쓰는 프로세스 강제 종료
- 본인 R/Python 프로세스가 갑자기 사라졌다면 OOM 의심

## 2. "Swap 16G/16G full" 시나리오 — 진짜 위험한가?

이게 보였을 때 묻고 답해야 할 핵심 3가지:

### Q1. 지금도 활발히 swap 입출력 중인가?

```bash
vmstat 2 5     # 2초 간격 5번
```

출력:
```
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0 16777216 8e+08  6e+05 1e+08    0    0    23    45  ...  ... ...
```

| 컬럼 | 의미 | 위험 기준 |
| --- | --- | --- |
| `swpd` | swap 사용량 (KB) | **그저 사용된 양 — 0이 아니어도 OK** |
| **`si`** | swap-in 속도 (KB/s, 디스크→RAM) | **> 100 KB/s가 지속이면 thrashing 시작** |
| **`so`** | swap-out 속도 (KB/s, RAM→디스크) | **> 100 KB/s가 지속이면 RAM 부족** |
| `wa` (CPU) | I/O wait % | **> 30%가 지속이면 swap 병목** |

**`si` 와 `so` 가 둘 다 0이면 swap이 가득 차 있어도 그저 "이전에 사용했던 흔적"일 뿐.** 현재 시스템은 RAM으로 잘 돌고 있고 swap은 그저 점유된 상태로 남아있을 뿐입니다.

### Q2. 누가 swap을 점유하고 있나?

```bash
# 본인 프로세스의 swap 사용량
for pid in $(pgrep -u lucia); do
  swap_kb=$(awk '/VmSwap:/ {print $2}' /proc/$pid/status 2>/dev/null)
  if [[ -n "$swap_kb" && "$swap_kb" != "0" ]]; then
    echo "PID $pid: ${swap_kb} KB - $(cat /proc/$pid/comm 2>/dev/null)"
  fi
done

# 전체 시스템에서 swap 사용 top 10
sudo smem -t -k -s swap -c "pid user command swap" -r 2>/dev/null | head -15
# (sudo 없으면) /proc 직접 파싱:
for pid in $(ls /proc | grep -E '^[0-9]+$'); do
  swap_kb=$(awk '/VmSwap:/ {print $2}' /proc/$pid/status 2>/dev/null)
  cmd=$(cat /proc/$pid/comm 2>/dev/null)
  user=$(stat -c '%U' /proc/$pid 2>/dev/null)
  [[ -n "$swap_kb" && "$swap_kb" != "0" ]] && echo "$swap_kb $user $pid $cmd"
done 2>/dev/null | sort -rn | head -10
```

### Q3. RAM이 충분히 여유로운가?

```bash
free -h
# 출력 예:
#               total        used        free      shared  buff/cache   available
# Mem:           976G        177G          5G        2.1G        794G        800G
# Swap:           16G         16G          0B
```

핵심:
- **`available`이 100 GB 이상**이면 RAM 여유 충분 → swap은 그저 cosmetic
- `free`는 작아 보여도 `buff/cache`는 즉시 회수 가능한 메모리 (커널 페이지 캐시)
- **`available`이 RAM의 10% 이하**가 되면 위험 신호 → swap-out 시작 임박

## 3. 본 서버(977 GB RAM) 케이스 — 거의 항상 cosmetic

본 프로젝트 서버는 RAM 977 GB / Swap 16 GB. 비율 60:1.
- swap 가득 차도 RAM에 800 GB 여유 → **본인 작업에 영향 0**
- 누군가 메모리 한계까지 짜낸 후 swap에 잔여물이 남은 것
- 정상 동작 중

→ "Swap 16G/16G"는 **놀라지 말고 vmstat의 si/so가 0인지만 확인하면 됨**.

## 4. 진짜 위험 시그널 — Thrashing

Thrashing = 시스템이 RAM ↔ Swap 사이를 미친 듯이 왔다갔다하느라 진짜 작업이 안 되는 상태:

```bash
vmstat 2

# 위험 출력 예:
# procs -----memory------ ---swap-- -----io---- ------cpu-----
#  r  b   swpd   free ...   si   so    bi    bo  us sy id wa
#  2  5 16777216  100M ... 5000 8000  9000 12000   5  3  2 90  ← wa 90%!
```

증상:
- `si` `so` > 1000 KB/s 지속
- `wa` (I/O wait) > 50%
- 시스템 전체가 느려짐, ssh도 지연
- 본인 작업 응답성 급격히 저하

대응:
1. **즉시 본인 큰 프로세스 종료** (다른 사람도 시스템 회복에 감사할 것)
   ```bash
   kill -TERM <PID>
   # 또는 더 강력하게
   kill -9 <PID>
   ```
2. R 작업 중이면 R 콘솔에서 `q()` (저장은 'n'로 빠르게)
3. Python 작업이면 `Ctrl+C` (저장 안 됨 주의)

## 5. swap 가득 차 있을 때 — 본인 R/Python 작업은 안전한가?

**대부분의 경우 안전합니다.** 다만 주의할 점:

### 안전한 경우
- swpd 16G full + si/so 0 → 그저 점유 흔적, RAM은 충분
- `free -h`의 available > 100 GB

### 주의할 경우
- 본인 큰 .rds 로딩 직전 → 로딩 시 RAM 부족하면 swap이 더 못 받아주므로 즉시 OOM 가능
- 본인 PyTorch가 데이터 prefetch 많이 할 때

### 대비
```bash
# 큰 작업 시작 전 한 줄
free -h | awk '/^Mem:/ {print "Available:", $7}'

# Available이 작업에 필요한 만큼의 1.5배 이상인지 확인
# (예: 30GB Seurat 로드 → Available > 45GB 권장)
```

## 6. 본인이 메모리를 너무 먹고 있을 때 — 사용량 줄이기

본 프로젝트에서 자주 마주칠 상황과 대응:

### Seurat .rds (R) - 메모리 큼
```r
# 1) 작업 끝난 객체는 명시적으로 제거
rm(big_seurat); gc()

# 2) 큰 .rds는 backed mode 불가, 대신 subset으로 분할 로드
obj <- readRDS("big.rds")
cd8 <- subset(obj, subset = celltype == "CD8 T cell")
rm(obj); gc()  # 원본 즉시 해제

# 3) 메모리 사용량 확인
sort(sapply(ls(), function(x) object.size(get(x))), decreasing=TRUE)
gc()  # garbage collect + 사용량 출력
```

### AnnData (Python) - backed mode 사용
```python
import anndata as ad
# 일반 로드: 전체 RAM 로드
adata = ad.read_h5ad("big.h5ad")

# Backed mode: 디스크에서 lazy 읽기 (메모리 절약)
adata = ad.read_h5ad("big.h5ad", backed="r")
# .X 접근 시에만 디스크 read

# 작업 후 닫기 필수
adata.file.close()
```

### PyTorch - 명시적 cuda 메모리 회수
```python
import torch, gc
del model, optimizer, batch
gc.collect()
torch.cuda.empty_cache()
```

## 7. 진단 cheat-sheet

```bash
# A. 한 번에 전체 상황 보기
free -h && echo "---" && vmstat 2 3

# B. 본인 프로세스의 RES + Swap
ps -u lucia -o pid,rss,comm --no-headers | sort -k2 -nr | head -10
for pid in $(pgrep -u lucia); do
  swap=$(awk '/VmSwap:/ {print $2}' /proc/$pid/status 2>/dev/null || echo 0)
  rss=$(awk '/VmRSS:/ {print $2}' /proc/$pid/status 2>/dev/null || echo 0)
  cmd=$(cat /proc/$pid/comm)
  printf "PID %6d  RSS %8d KB  Swap %6d KB  %s\n" "$pid" "$rss" "$swap" "$cmd"
done | sort -k4 -nr | head -10

# C. OOM killer가 작동했는지 확인 (최근)
dmesg | grep -i "killed process\|out of memory" | tail -10
# 또는
journalctl -k --since "1 hour ago" | grep -i oom

# D. 가장 메모리 많이 쓰는 프로세스 한 줄
ps aux --sort=-%mem | awk 'NR<=10'

# E. 캐시 메모리 강제 해제 (sudo 필요 - 공용서버에선 안 됨)
# sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"  ← 시스템 관리자 영역
```

## 8. 본 프로젝트 권장 모니터링 워크플로우

```bash
# 별도 SSH 터미널 1: 큰 작업 (R/Python)
Rscript big_analysis.R

# 별도 SSH 터미널 2: 모니터링
watch -n 3 'free -h; echo; vmstat 1 2 | tail -3; echo; ps -u lucia -o rss,pcpu,comm --sort=-rss --no-headers | head -5'
```

이 한 줄이 RAM/Swap/본인 프로세스 메모리를 동시에 보여줍니다.

## 9. 자주 묻는 질문 (FAQ)

| Q | A |
| --- | --- |
| Swap이 가득 차 있는데 위험한가? | si/so가 0이면 cosmetic. vmstat 2로 확인. |
| 내 R 프로세스가 갑자기 죽었다 | OOM killer 가능성. `dmesg | grep -i killed` 확인. RAM 부족 시점 추적. |
| R에서 `vector memory exhausted` 에러 | RAM 부족. subset으로 분할 또는 다른 노드 사용. `gc()`로 회수. |
| free 명령의 'free'와 'available' 차이? | free = 즉시 사용 가능. available = free + 회수 가능한 cache. **available 보세요.** |
| swap을 비우려면? | `sudo swapoff -a && sudo swapon -a` (sudo 필요 - 일반 사용자는 불가). 본인은 메모리 회수만 가능. |
| Python에서 큰 numpy 배열로 swap 사용 줄이려면? | `np.memmap`으로 disk-backed 배열, 또는 `dask.array`로 lazy. |
| GPU 메모리 부족 (CUDA OOM)은 다른 문제인가? | 네. CPU RAM과 별개. `nvidia-smi`로 GPU 메모리 확인, `torch.cuda.empty_cache()` 사용. |

## 10. 공용 서버 매너 — 메모리 측면

- **큰 작업 시작 전** `free -h` 확인 (available > 작업 필요량의 1.5배)
- **메모리 큰 데이터는 작업 후 즉시 `rm()` + `gc()`** (R) 또는 `del` + `gc.collect()` (Python)
- **swap thrashing 발견 시** 본인 큰 프로세스도 의심 → 자발적으로 종료/축소
- **공용 캐시 메모리** (`/dev/shm`, `/tmp`)에 큰 임시 파일 두지 말기
- **백그라운드 작업** 끝나면 즉시 `kill`, zombie 프로세스 정리

## 11. 관련 노트

- [[htop_Monitoring]] — 인터랙티브 모니터링 (M으로 메모리 정렬, F2 nice 조정)
- [[R_Manual]] §10 (R 자주 막히는 점) — vector memory exhausted 등
- [[R_Package_Management]] — 패키지 의존성 관리

## 한 줄

> **"Swap 16G/16G full"은 보통 cosmetic.** 진짜 위험은 `vmstat 2`의 **si/so가 0이 아닌 상태가 지속**될 때. 본 서버(977 GB RAM)에서는 거의 항상 RAM 충분하므로 swap 표시는 안심하고 무시 — 다만 본인 작업 시작 전 `free -h`의 **available**이 작업 필요량의 1.5배 이상인지만 확인하세요.
