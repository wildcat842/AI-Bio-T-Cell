# scripts/

레포 운영 자동화 스크립트.

## push_to_github - GitHub로 초기 push

### 상황 설명

본 폴더는 Claude(Cowork)가 생성한 프로젝트 스캐폴드입니다. **샌드박스에서 GitHub로 직접 push가 차단되어** (네트워크 프록시 403), 사용자가 본인 머신에서 첫 push를 수행해야 합니다.

샌드박스에서 시도한 `.git/` 잔여물이 폴더에 일부 남아있을 수 있는데, 스크립트가 자동으로 감지·정리하므로 신경 쓰지 마세요.

### 사전 준비

1. **GitHub에 빈 레포 생성**: https://github.com/new
   - Owner: `wildcat842`
   - Repository name: `AI-Bio-T-Cell`
   - README/license/gitignore **체크하지 말 것** (이미 본 폴더에 포함)
2. **Git for Windows** 설치 (https://git-scm.com/download/win)
3. (선택) **Git LFS** 설치 (https://git-lfs.com) - 대용량 PDF/XLSX/h5ad 푸시용

### 실행

**Windows (PowerShell)**:
```powershell
cd "C:\2026. Claude Code\work_aibio\ai bio\AI-Bio-T-Cell"
.\scripts\push_to_github.ps1
```

**macOS / Linux / WSL**:
```bash
cd /path/to/AI-Bio-T-Cell
bash scripts/push_to_github.sh
```

스크립트는 다음을 순차 수행합니다.

```
[0/6] 깨진 .git 잔여물 자동 정리
[1/6] git init -b main
[2/6] git add -A
[3/6] 초기 커밋
[4/6] git remote add origin https://github.com/wildcat842/AI-Bio-T-Cell.git
[5/6] git lfs install + track (있을 때만)
[6/6] git push -u origin main
```

### 인증 옵션

| 방법 | 설치 | 권장도 |
| --- | --- | --- |
| Git Credential Manager (Git for Windows 기본 포함, OAuth) | 자동 | ★★★ |
| GitHub CLI (`gh auth login`) | `winget install GitHub.cli` | ★★★ |
| Personal Access Token | https://github.com/settings/tokens | ★★ |
| SSH 키 | `ssh-keygen -t ed25519` + GitHub 등록 | ★★★ |

#### PAT를 환경변수로 사용 (PowerShell)
```powershell
$env:GH_TOKEN = "ghp_xxxxxxxxxxxxxxxxxxxxxxxx"
git remote set-url origin "https://$env:GH_TOKEN@github.com/wildcat842/AI-Bio-T-Cell.git"
.\scripts\push_to_github.ps1
```

#### SSH로 전환
```bash
git remote set-url origin git@github.com:wildcat842/AI-Bio-T-Cell.git
git push -u origin main
```

### 트러블슈팅

| 증상 | 원인 | 해결 |
| --- | --- | --- |
| `403 Permission denied` | 인증 실패 | GCM 재로그인 또는 `gh auth login` |
| `repository not found` | GitHub 레포가 없음 | https://github.com/new 에서 빈 레포 먼저 생성 |
| `branch main not found` | 브랜치 이름 불일치 | `git branch -M main` 후 재시도 |
| `Updates were rejected` | 원격에 이미 커밋 존재 | `git pull --rebase origin main && git push -u origin main` |
| `cannot lock ref` (Windows) | 안티바이러스가 .git 접근 차단 | 일시 비활성화 또는 예외 경로 등록 |

### push 성공 후 권장 작업

1. **Repo Settings → Actions**: CI 활성화 (`.github/workflows/python-ci.yml`, `R-ci.yml`)
2. **Branch protection rule**: main 보호 (Settings → Branches → Add rule)
3. **About 섹션** (오른쪽 사이드바 톱니바퀴): 짧은 설명 + 토픽 태그 (`immunology`, `single-cell`, `ai-virtual-cells`, `flow-matching`, `riken`)
4. **README badge** 추가 (CI 상태, license 등)
5. **GitHub Pages** (선택): `docs/` 폴더 publish

### 후속 커밋

이후 작업은 일반 git 흐름:
```bash
git add path/to/changed/file
git commit -m "feat: add ReapTEC enhancer overlap analysis"
git push
```

## (향후) 추가 스크립트 예정

- `setup_dev_env.sh` - conda env + renv 자동 설치
- `download_p0_datasets.sh` - P0 데이터셋(ReapTEC processed, ENCODE, GTEx, GWAS) 일괄 다운로드
- `validate_structure.py` - 폴더 트리·필수 파일 무결성 자동 검증
