# push_to_github.ps1
# 사용자의 Windows 머신에서 AI-Bio-T-Cell 폴더에 진입한 후 실행:
#   cd "C:\2026. Claude Code\work_aibio\ai bio\AI-Bio-T-Cell"
#   .\scripts\push_to_github.ps1
#
# 사전 조건:
#   1. Git for Windows 설치 (https://git-scm.com/download/win)
#   2. GitHub 인증: 다음 중 하나
#      - Git Credential Manager (Git for Windows 기본 포함, 자동 OAuth)
#      - Personal Access Token: $env:GH_TOKEN 환경변수에 설정
#      - GitHub CLI: gh auth login

$ErrorActionPreference = "Stop"
$Repo = "https://github.com/wildcat842/AI-Bio-T-Cell.git"

Write-Host "[1/5] git status" -ForegroundColor Cyan
git status --short | Select-Object -First 10
Write-Host ""

Write-Host "[2/5] git log" -ForegroundColor Cyan
git log --oneline -5
Write-Host ""

Write-Host "[3/5] remote 설정" -ForegroundColor Cyan
$existing = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    git remote add origin $Repo
    Write-Host "  origin added: $Repo"
} elseif ($existing -ne $Repo) {
    git remote set-url origin $Repo
    Write-Host "  origin updated: $Repo"
} else {
    Write-Host "  origin already set: $existing"
}
Write-Host ""

Write-Host "[4/5] LFS 초기화 (선택, 대용량 PDF/XLSX 있을 때)" -ForegroundColor Cyan
$lfsAvailable = (Get-Command git-lfs -ErrorAction SilentlyContinue) -ne $null
if ($lfsAvailable) {
    git lfs install
    git lfs track "*.pdf" "*.xlsx" "*.docx" "*.pptx" "*.png" "*.h5" "*.h5ad" "*.rds" 2>$null
    Write-Host "  LFS tracking 설정됨 (.gitattributes 참조)"
} else {
    Write-Host "  WARN: git-lfs 미설치. https://git-lfs.com 에서 설치 권장."
}
Write-Host ""

Write-Host "[5/5] push to GitHub" -ForegroundColor Cyan
git push -u origin main
Write-Host ""
Write-Host "[OK] Done." -ForegroundColor Green
Write-Host "Repo: $Repo"
