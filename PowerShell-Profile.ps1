<# 
#Plan
1) Load useful modules safely
2) Configure PSReadLine: history search, prediction, fzf history
3) Improve directory navigation with zoxide
4) Improve listing with eza + Terminal-Icons
5) Setup a modern prompt (starship)
6) Add quality-of-life functions and aliases
#>

# Keep profile resilient: don't let one optional tool break the whole shell
$ErrorActionPreference = "Continue"

# Detect if running inside PowerShell Editor Services (VS Code extension host)
$_isEditorServices = ($host.Name -eq 'Visual Studio Code Host') -or
                     ($null -ne $env:TERM_PROGRAM -and $env:TERM_PROGRAM -eq 'vscode' -and $host.Name -eq 'ConsoleHost' -and $null -ne $psEditor) -or
                     ($host.Name -match 'PowerShell Editor Services')

# ---------- PATH Setup ----------
# Ensure cargo, go, local bin, and winget packages are in PATH
$pathsToAdd = @(
    "$env:USERPROFILE\.cargo\bin",
    "$env:USERPROFILE\go-sdk\go\bin",
    "$env:USERPROFILE\.local\bin"
)
# Auto-discover winget-installed CLI tools
$wingetPkgs = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
if (Test-Path $wingetPkgs) {
    Get-ChildItem $wingetPkgs -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $exeDir = Get-ChildItem $_.FullName -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($exeDir) { $pathsToAdd += $exeDir.DirectoryName }
    }
}
foreach ($p in $pathsToAdd) {
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) {
        $env:PATH = "$p;$env:PATH"
    }
}

# ---------- Modules ----------
Import-Module PSReadLine -ErrorAction SilentlyContinue
Import-Module posh-git   -ErrorAction SilentlyContinue
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module PSFzf -ErrorAction SilentlyContinue

# ---------- PSFzf Configuration ----------
if ((Get-Module PSFzf) -and -not $_isEditorServices) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSFzfOption -EnableAliasFuzzyEdit
    Set-PSFzfOption -EnableAliasFuzzySetLocation
}

# ---------- PSReadLine (history + editing) ----------
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView

    # Prefix history search: type "dotnet" then Up Arrow to search matching commands
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Better history search with Ctrl+r using fzf (if installed)
    if ((Get-Command fzf -ErrorAction SilentlyContinue) -and -not $_isEditorServices) {
        Set-PSReadLineKeyHandler -Chord "Ctrl+r" -ScriptBlock {
            $histPath = (Get-PSReadLineOption).HistorySavePath
            if (-not (Test-Path $histPath)) { return }

            $line = Get-Content $histPath -ErrorAction SilentlyContinue |
                Where-Object { $_ -and $_.Trim() -ne "" } |
                Select-Object -Unique |
                fzf --tac --height 40% --reverse

            if ($line) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($line) }
        }
    }
}

# ---------- zoxide (smart cd) ----------
if (-not $_isEditorServices) {
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        try {
            (& zoxide init powershell) -join "`n" | Invoke-Expression
        } catch {
            Write-Warning "zoxide init failed: $($_.Exception.Message)"
        }
    } elseif (Get-Module z -ListAvailable) {
        Import-Module z -ErrorAction SilentlyContinue
    }
}

# ---------- Better ls ----------
function ll { Get-ChildItem -Force }
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function l  { eza --icons --group-directories-first }
    function la { eza -a --icons --group-directories-first }
    function ls { eza --icons --group-directories-first }
    function lt { eza --tree --icons --level=2 }
    function lta { eza --tree --icons -a --level=2 }
    function ll { eza -la --icons --group-directories-first --git }
} else {
    # Fallback so 'la' exists even without eza
    function la { Get-ChildItem -Force }
}

# ---------- Better cat with bat ----------
# Use 'bcat' instead of overriding 'cat' to avoid breaking PowerShell Editor Services
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function bcat { bat --style=auto $args }
    function catp { bat --plain $args }
}

# ---------- Fast search helpers ----------
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep {
        param(
            [Parameter(Mandatory)] [string]$Pattern,
            [string]$Path="."
        )
        rg $Pattern $Path
    }
}

# ---------- Git helpers ----------
function gst { git status }
function gco { param([string]$Branch) git checkout $Branch }
function gpl  { git pull }
function gpsh  { git push }
function ga  { git add $args }
function gaa { git add --all }
function gcmt  { git commit -m $args }
function gca { git commit --amend }
function gd  { git diff $args }
function gds { git diff --staged }
function gb  { git branch $args }
function glog { git log --oneline --graph --decorate -20 }

# Use delta for better diffs if available
if (Get-Command delta -ErrorAction SilentlyContinue) {
    $env:GIT_PAGER = "delta"
}

# ---------- Utilities ----------
function which { param([string]$Name) Get-Command $Name -All | Select-Object -ExpandProperty Source }
function reload { . $PROFILE; Write-Host "Profile reloaded." -ForegroundColor Green }
function touch { param([string]$Path) if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date } else { New-Item -ItemType File -Path $Path } }
function mkcd { param([string]$Path) New-Item -ItemType Directory -Path $Path -Force; Set-Location $Path }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Fuzzy file finder with fzf
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    function ff { Get-ChildItem -Recurse -File | ForEach-Object { $_.FullName } | fzf | ForEach-Object { code $_ } }
    function fd { Get-ChildItem -Recurse -Directory | ForEach-Object { $_.FullName } | fzf | ForEach-Object { Set-Location $_ } }
}

# ---------- Prompt (starship) ----------
if (-not $_isEditorServices) {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        try {
            (& starship init powershell) -join "`n" | Invoke-Expression
        } catch {
            Write-Warning "starship init failed: $($_.Exception.Message)"
        }
    }
}

# Graphviz for pprof
$env:Path += ';C:\Program Files\Graphviz\bin'
