# scripts/

레포 운영 자동화 스크립트.

## push_to_github

GitHub 원격(`https://github.com/wildcat842/AI-Bio-T-Cell`)으로 첫 push를 수행합니다.

**현재 상태**: 본 폴더의 `.git/`에 초기 커밋(`76e274f Initial commit`)이 이미 들어있습니다. 다음 단계는 사용자 본인의 머신에서 push만 수행하면 됩니다.

### Windows (PowerShell)
```powershell
cd "C:\2026. Claude Code\work_aibio\ai bio\AI-Bio-T-Cell"
.\scripts\push_to_github.ps1
```

### macOS / Linux / WSL
```bash
cd /path/to/AI-Bio-T-Cell
bash scripts/push_to_github.sh
```

### 인증 옵션

| 방법 | 권장도 |
| --- | --- |
| Git Credential Manager (Git for Windows 기본) | ★★★ |
| Personal Access Token (PAT) | ★★ |
| GitHub CLI (`gh auth login`) | ★★★ |
| SSH 키 + `git remote set-url origin git@github.com:wildcat842/AI-Bio-T-Cell.git` | ★★★ |

### PAT 사용 예 (PowerShell)
```powershell
$env:GH_TOKEN = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
git remote set-url origin "https://$env:GH_TOKEN@github.com/wildcat842/AI-Bio-T-Cell.git"
git push -u origin main
```

### push 실패 시

- `403 Permission denied` → 인증 문제. `gh auth login` 또는 GCM에서 다시 로그인.
- `repository not found` → GitHub 웹에서 `wildcat842/AI-Bio-T-Cell` 빈 레포가 먼저 생성되어 있어야 합니다.
- `branch main not found` → `git branch -M main` 후 재시도.

### 후속 작업

push 성공 후:
1. Repo Settings → Actions에서 CI 활성화 (`.github/workflows/python-ci.yml`, `R-ci.yml`)
2. Branch protection rule 설정 (main 보호)
3. About 섹션에 짧은 설명/토픽 태그(immunology, single-cell, ai-virtual-cells) 추가
