# push_to_github.ps1
# AI-Bio-T-Cell -> GitHub initial push automation (Windows PowerShell)
#
# Usage:
#   cd "C:\2026. Claude Code\work_aibio\ai bio\AI-Bio-T-Cell"
#   .\scripts\push_to_github.ps1
#
# Prerequisites:
#   - Install Git for Windows (https://git-scm.com/download/win)
#   - Authenticate your GitHub account (Git Credential Manager / PAT / SSH)
#   - Create an empty repository at github.com/wildcat842/AI-Bio-T-Cell in advance

$ErrorActionPreference = "Stop"
$Repo = "https://github.com/wildcat842/AI-Bio-T-Cell.git"
$Branch = "main"

Write-Host "=== AI-Bio-T-Cell -> GitHub initial push ===" -ForegroundColor Cyan
Write-Host "Repo  : $Repo"
Write-Host "Branch: $Branch"
Write-Host ""

# [0/6] Automatically clean broken .git directory
# (sandbox-generated leftovers may exist)
if (Test-Path ".git") {
    try {
        git rev-parse --is-inside-work-tree | Out-Null
        Write-Host "[0/6] Existing .git repository detected - reusing it" -ForegroundColor Yellow
        $skipInit = $true
    } catch {
        Write-Host "[0/6] Corrupted .git detected - removing..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force ".git"
        $skipInit = $false
    }
} else {
    $skipInit = $false
}

# [1/6] git init
if (-not $skipInit) {
    Write-Host "[1/6] git init -b $Branch" -ForegroundColor Cyan
    git init -b $Branch
    git config user.email "sojung.kim.nca@gmail.com"
    git config user.name "Sojung Kim"
}
Write-Host ""

# [2/6] git add
Write-Host "[2/6] git add -A" -ForegroundColor Cyan
git add -A
$cached = (git diff --cached --numstat | Measure-Object).Count
Write-Host "  Staged: $cached files"
Write-Host ""

# [3/6] Initial commit (only if no commit exists)
$hasCommit = $true
try { git rev-parse HEAD 2>$null | Out-Null } catch { $hasCommit = $false }

if (-not $hasCommit -and $cached -gt 0) {
    Write-Host "[3/6] Initial commit" -ForegroundColor Cyan

    $msg = @"
Initial commit - AI-Bio-T-Cell project scaffold

- Project structure for AI Virtual Cells x RIKEN ReapTEC T-Cell research
- 19 dataset catalogs (datasets/) with READMEs and download scripts
- Python (aibio package) and R (Seurat/Signac helpers) source code
- Obsidian vault for shared research notes (4 topics, concepts, ADR)
- GitHub Actions CI for Python (ruff + pytest) and R (testthat)
- Evaluation reports, data catalog, and summary slides under reports/deliverables/
"@

    git commit -m $msg

} elseif ($cached -gt 0) {

    Write-Host "[3/6] Commiting changes" -ForegroundColor Cyan
    git commit -m "Update project files"

} else {

    Write-Host "[3/6] No changes detected - skipping commit" -ForegroundColor Yellow
}

Write-Host ""

# [4/6] Configure remote
Write-Host "[4/6] Configuring remote origin" -ForegroundColor Cyan

try {

    $existing = git remote get-url origin 2>$null

    if ($existing -ne $Repo) {

        git remote set-url origin $Repo
        Write-Host "  Updated origin: $Repo"

    } else {

        Write-Host "  Origin already configured: $existing"
    }

} catch {

    git remote add origin $Repo
    Write-Host "  Added origin: $Repo"
}

Write-Host ""

# [5/6] Git LFS (optional)
Write-Host "[5/6] Initializing Git LFS (optional)" -ForegroundColor Cyan

if (Get-Command git-lfs -ErrorAction SilentlyContinue) {

    git lfs install

    git lfs track "*.pdf" "*.xlsx" "*.docx" "*.pptx" "*.png" "*.h5" "*.h5ad" "*.rds" 2>$null

    Write-Host "  LFS tracking configured (.gitattributes updated)"

} else {

    Write-Host "  WARN: git-lfs is not installed. Installing Git LFS is recommended for large PDF/XLSX files: https://git-lfs.com"
}

Write-Host ""

# [6/6] Push
Write-Host "[6/6] git push -u origin $Branch" -ForegroundColor Cyan

git push -u origin $Branch

Write-Host ""
Write-Host "[OK] Done." -ForegroundColor Green
Write-Host "Repo: $Repo"