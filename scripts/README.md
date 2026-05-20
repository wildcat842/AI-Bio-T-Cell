# scripts/

Repository automation scripts.

## push_to_github - Initial push to GitHub

### Situation

This folder was scaffolded by Claude (Cowork). Direct push from the sandbox is blocked by the network proxy, so the user must run the first push from their own machine.

A partial `.git/` directory left over from the sandbox attempt may exist. The script automatically detects and removes it.

### Prerequisites

1. **Create an empty GitHub repo** at https://github.com/new
   - Owner: `wildcat842`
   - Repository name: `AI-Bio-T-Cell`
   - **Do NOT** check README / license / .gitignore (already included locally).
2. **Git for Windows** installed: https://git-scm.com/download/win
3. Optional: **Git LFS** for large PDFs/XLSX/h5ad: https://git-lfs.com

### Run

**Windows (PowerShell)** - English-only output, cp949-safe:
```powershell
cd "C:\2026. Claude Code\work_aibio\ai bio\AI-Bio-T-Cell"
.\scripts\push_to_github.ps1
```

If PowerShell blocks the script due to execution policy:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\push_to_github.ps1
```

**macOS / Linux / WSL**:
```bash
cd /path/to/AI-Bio-T-Cell
bash scripts/push_to_github.sh
```

### What the script does

```
[0/6] Auto-clean any corrupted .git from sandbox
[1/6] git init -b main + user config + core.autocrlf=true
[2/6] git add -A
[3/6] Initial commit (only if no commit exists yet)
[4/6] git remote add origin https://github.com/wildcat842/AI-Bio-T-Cell.git
[5/6] git lfs install + track (if git-lfs available)
[6/6] git push -u origin main
```

### Authentication options

| Method | Install | Recommendation |
| --- | --- | --- |
| Git Credential Manager (bundled with Git for Windows, OAuth) | automatic | High |
| GitHub CLI (`gh auth login`) | `winget install GitHub.cli` | High |
| Personal Access Token | https://github.com/settings/tokens | Medium |
| SSH key | `ssh-keygen -t ed25519` + add to GitHub | High |

#### Using a PAT via environment variable (PowerShell)
```powershell
$env:GH_TOKEN = "ghp_xxxxxxxxxxxxxxxxxxxxxxxx"
git remote set-url origin "https://$env:GH_TOKEN@github.com/wildcat842/AI-Bio-T-Cell.git"
.\scripts\push_to_github.ps1
```

#### Switching to SSH
```bash
git remote set-url origin git@github.com:wildcat842/AI-Bio-T-Cell.git
git push -u origin main
```

### Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `403 Permission denied` | Auth failed | `gh auth login`, or re-login via Git Credential Manager |
| `repository not found` | Empty repo not created | Create at https://github.com/new first |
| `branch main not found` | Branch name mismatch | `git branch -M main` then retry |
| `Updates were rejected` | Remote already has commits | `git pull --rebase origin main; git push -u origin main` |
| `cannot lock ref` (Windows) | Antivirus locking `.git` | Temporarily disable AV or whitelist the folder |
| `chcp` errors / mojibake | Korean cp949 console | Script forces UTF-8 (chcp 65001); if it still fails, run `chcp 65001` manually first |

### Post-push recommendations

1. **Settings -> Actions**: Enable CI (`.github/workflows/python-ci.yml`, `R-ci.yml`).
2. **Branch protection rule**: protect `main` (Settings -> Branches -> Add rule).
3. **About section** (right sidebar gear icon): add a short description and topic tags
   (`immunology`, `single-cell`, `ai-virtual-cells`, `flow-matching`, `riken`).
4. **README badges** for CI status, license, Python version.
5. **GitHub Pages** (optional): publish from `docs/`.

### Follow-up commits

Regular git workflow:
```bash
git add path/to/changed/file
git commit -m "feat: add ReapTEC enhancer overlap analysis"
git push
```

## setup_linux_remote.sh - Linux remote 서버 초기 셋업

리모트 Linux 서버에서 GitHub로부터 프로젝트를 가져오고 Python/R 환경까지 일괄 구성합니다.

### 시나리오 자동 감지

| 현재 상태 | 자동 모드 | 동작 |
| --- | --- | --- |
| 빈 디렉토리 | `clone` | `git clone` → 의존성 설치 |
| 파일은 있는데 `.git` 없음 (scp/rsync로 받은 경우) | `link` | 안전 백업 → `git init` → `remote add` → `fetch` → 사용자 확인 후 `reset --hard origin/main` |
| `.git`이 이미 있음 | `existing` | `git pull --ff-only` |

### 사용 예 (현재 `~/work/AI-Bio-T-Cell` 에 파일은 있고 `.git`이 없는 상태)

```bash
cd ~/work/AI-Bio-T-Cell
chmod +x scripts/setup_linux_remote.sh
bash scripts/setup_linux_remote.sh
```

스크립트가 자동으로:
1. 현재 파일을 `../AI-Bio-T-Cell.predl.YYYYMMDD-HHMMSS/`에 백업
2. `git init -b main` + `git remote add origin https://github.com/wildcat842/AI-Bio-T-Cell.git`
3. `git fetch origin main`
4. 사용자 `y/N` 확인 후 `git reset --hard origin/main` (원격으로 정렬)
5. Conda env 활성화 시 `pip install -e ".[dev,ml]"`, 아니면 `.venv` 생성
6. `Rscript -e 'renv::restore()'`
7. 필수 파일 무결성 점검 + `.gitkeep` 보강

### 신규 clone (다른 빈 디렉토리에서)

```bash
cd ~/work
bash AI-Bio-T-Cell/scripts/setup_linux_remote.sh --clone
# → ~/work/AI-Bio-T-Cell/ 신규 클론
```

### 옵션

```bash
bash scripts/setup_linux_remote.sh --clone           # 강제 clone 모드
bash scripts/setup_linux_remote.sh --link            # 강제 in-place 모드
bash scripts/setup_linux_remote.sh --no-python       # Python 설치 건너뜀
bash scripts/setup_linux_remote.sh --no-r            # R 설치 건너뜀
bash scripts/setup_linux_remote.sh --branch dev      # 다른 브랜치
bash scripts/setup_linux_remote.sh --repo git@github.com:wildcat842/AI-Bio-T-Cell.git  # SSH
```

## pull_from_github.sh - 일상 업데이트

GitHub의 최신 변경을 받아오고, `pyproject.toml`/`environment.yml`/`renv.lock` 변경이 감지되면 의존성을 자동으로 재설치합니다.

```bash
cd ~/work/AI-Bio-T-Cell
bash scripts/pull_from_github.sh
# 또는 다른 브랜치
bash scripts/pull_from_github.sh --branch dev
```

미커밋 변경이 있으면 안전을 위해 종료합니다. 먼저 `git stash` 또는 commit 하세요.

## Planned scripts (not yet implemented)

- `download_p0_datasets.sh` - bulk download P0 datasets (ReapTEC processed, ENCODE, GTEx, GWAS)
- `validate_structure.py` - check tree integrity and required files
