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

## Planned scripts (not yet implemented)

- `setup_dev_env.sh` - install conda env + renv automatically
- `download_p0_datasets.sh` - bulk download P0 datasets (ReapTEC processed, ENCODE, GTEx, GWAS)
- `validate_structure.py` - check tree integrity and required files
