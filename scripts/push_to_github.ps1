# push_to_github.ps1
# AI-Bio-T-Cell -> GitHub initial push (Windows PowerShell, ASCII-only)
#
# Usage:
#   cd "C:\2026. Claude Code\work_aibio\ai bio\AI-Bio-T-Cell"
#   .\scripts\push_to_github.ps1
#
# Prerequisites:
#   - Git for Windows installed (https://git-scm.com/download/win)
#   - GitHub authenticated (Git Credential Manager / PAT / SSH / gh CLI)
#   - The empty GitHub repo must already exist:
#     https://github.com/wildcat842/AI-Bio-T-Cell  (create without README/license/.gitignore)

$ErrorActionPreference = "Stop"

# Force UTF-8 console to avoid cp949 issues on Korean Windows
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
    chcp 65001 > $null
} catch {}

$Repo   = "https://github.com/wildcat842/AI-Bio-T-Cell.git"
$Branch = "main"

Write-Host "=== AI-Bio-T-Cell -> GitHub initial push ==="
Write-Host "Repo  : $Repo"
Write-Host "Branch: $Branch"
Write-Host ""

# Verify we are at the repo root
if (-not (Test-Path "pyproject.toml") -or -not (Test-Path "datasets")) {
    Write-Host "ERROR: Run this script from the AI-Bio-T-Cell repo root."
    Write-Host "       Current directory: $(Get-Location)"
    exit 1
}

# [0/6] Auto-clean leftover .git from sandbox attempts
$skipInit = $false
if (Test-Path ".git") {
    $isRepo = $false
    try {
        git rev-parse --is-inside-work-tree 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) { $isRepo = $true }
    } catch {}

    if ($isRepo) {
        Write-Host "[0/6] Found existing git repository - reusing"
        $skipInit = $true
    } else {
        Write-Host "[0/6] Found corrupted .git directory - removing"
        # Use Remove-Item with -Recurse -Force; some files may need attrib reset
        Get-ChildItem -Path ".git" -Recurse -Force -ErrorAction SilentlyContinue |
            ForEach-Object {
                try { $_.Attributes = "Normal" } catch {}
            }
        Remove-Item -Recurse -Force ".git" -ErrorAction SilentlyContinue
        if (Test-Path ".git") {
            Write-Host "ERROR: Could not remove .git directory. Delete it manually and retry."
            Write-Host "       In Explorer: enable hidden files, delete .git folder, try again."
            exit 1
        }
    }
}
Write-Host ""

# [1/6] git init
if (-not $skipInit) {
    Write-Host "[1/6] git init -b $Branch"
    git init -b $Branch
    if ($LASTEXITCODE -ne 0) { exit 1 }
    git config user.email "sojung.kim.nca@gmail.com"
    git config user.name  "Sojung Kim"
    # Normalize line endings on Windows (auto = convert to LF in repo, CRLF on checkout)
    git config core.autocrlf true
    # Avoid filemode noise on Windows
    git config core.filemode false
} else {
    Write-Host "[1/6] Skipping init - existing repo"
}
Write-Host ""

# [2/6] git add
Write-Host "[2/6] git add -A"
git add -A
if ($LASTEXITCODE -ne 0) { exit 1 }
$cached = (git diff --cached --numstat | Measure-Object).Count
Write-Host ("       Staged: {0} files" -f $cached)
Write-Host ""

# [3/6] Commit if needed
$hasCommit = $true
try { git rev-parse HEAD 2>$null | Out-Null; if ($LASTEXITCODE -ne 0) { $hasCommit = $false } }
catch { $hasCommit = $false }

if (-not $hasCommit -and $cached -gt 0) {
    Write-Host "[3/6] Creating initial commit"
    $msg = "Initial commit - AI-Bio-T-Cell project scaffold`n`n" +
           "- Project structure for AI Virtual Cells x RIKEN ReapTEC T-Cell research`n" +
           "- 19 dataset catalog (datasets/) with READMEs and download scripts`n" +
           "- Python (aibio package) and R (Seurat/Signac helpers) source code`n" +
           "- Obsidian vault for shared research notes (4 topics, concepts, ADR)`n" +
           "- GitHub Actions CI for Python (ruff+pytest) and R (testthat)`n" +
           "- Evaluation report, data catalog, summary slides under reports/deliverables/"
    git commit -m $msg
} elseif ($cached -gt 0) {
    Write-Host "[3/6] Committing staged changes"
    git commit -m "Update project files"
} else {
    Write-Host "[3/6] No changes to commit"
}
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host ""

# [4/6] Remote origin
Write-Host "[4/6] Setting remote origin"
$hasOrigin = $false
try { git remote get-url origin 2>$null | Out-Null; if ($LASTEXITCODE -eq 0) { $hasOrigin = $true } } catch {}

if ($hasOrigin) {
    $existing = git remote get-url origin
    if ($existing -ne $Repo) {
        git remote set-url origin $Repo
        Write-Host "       origin updated -> $Repo"
    } else {
        Write-Host "       origin already set: $existing"
    }
} else {
    git remote add origin $Repo
    Write-Host "       origin added -> $Repo"
}
Write-Host ""

# [5/6] LFS (optional)
Write-Host "[5/6] Git LFS init (optional)"
$hasLfs = $null -ne (Get-Command git-lfs -ErrorAction SilentlyContinue)
if ($hasLfs) {
    git lfs install | Out-Null
    git lfs track "*.pdf" "*.xlsx" "*.docx" "*.pptx" "*.png" "*.h5" "*.h5ad" "*.rds" 2>$null | Out-Null
    Write-Host "       LFS tracking enabled (see .gitattributes)"
} else {
    Write-Host "       WARN: git-lfs not installed. For large PDF/XLSX, install from https://git-lfs.com"
}
Write-Host ""

# [6/6] Push
Write-Host "[6/6] git push -u origin $Branch"
git push -u origin $Branch
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Push failed. Common fixes:"
    Write-Host "  - Authenticate:    gh auth login    (or use PAT / SSH)"
    Write-Host "  - Repo missing:    https://github.com/new  (create wildcat842/AI-Bio-T-Cell empty)"
    Write-Host "  - Diverged:        git pull --rebase origin main; .\scripts\push_to_github.ps1"
    exit 1
}
Write-Host ""
Write-Host "[OK] Done."
Write-Host "Repo: $Repo"
