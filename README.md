# 🚀 Ultimate Windows Terminal Setup Guide

A comprehensive guide to setting up a beautiful, informative, and productive terminal environment on Windows.

![Terminal Preview](https://raw.githubusercontent.com/starship/starship/master/media/demo.gif)

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Step 1: Install Development Languages](#step-1-install-development-languages)
  - [Node.js](#nodejs)
  - [Rust](#rust)
  - [Go (Golang)](#go-golang)
- [Step 2: Install CLI Tools](#step-2-install-cli-tools)
- [Step 3: Install PowerShell Modules](#step-3-install-powershell-modules)
- [Step 4: Configure PowerShell Profile](#step-4-configure-powershell-profile)
- [Step 5: Configure Starship Prompt](#step-5-configure-starship-prompt)
- [Step 6: Install Nerd Fonts](#step-6-install-nerd-fonts)
- [Step 7: Configure Windows Terminal](#step-7-configure-windows-terminal)
- [Step 8: Configure VS Code](#step-8-configure-vs-code)
- [Quick Reference](#quick-reference)
- [Troubleshooting](#troubleshooting)

---

## Overview

This setup transforms your Windows terminal into a powerful development environment with:

| Feature | Tool | Description |
|---------|------|-------------|
| 🎨 Beautiful Prompt | Starship | Fast, customizable, cross-shell prompt |
| 📁 Enhanced Directory Listing | eza | Modern `ls` replacement with icons & colors |
| 🔍 Syntax Highlighted Files | bat | `cat` clone with syntax highlighting |
| ⚡ Ultra-fast Search | ripgrep | Blazingly fast text search |
| 🔎 Fuzzy Finder | fzf | Interactive fuzzy search for files/history |
| 📍 Smart Navigation | zoxide | Intelligent `cd` that learns your habits |
| 🔀 Beautiful Git Diffs | delta | Syntax-highlighted git diffs |
| 🎯 File Icons | Terminal-Icons | Icons in directory listings |

---

## Prerequisites

- Windows 10/11
- PowerShell 7+ (recommended) or Windows PowerShell 5.1
- Windows Terminal (recommended)
- Administrator access (for some installations)

### Install PowerShell 7 (if not installed)

```powershell
winget install Microsoft.PowerShell
```

### Install Windows Terminal (if not installed)

```powershell
winget install Microsoft.WindowsTerminal
```

---

## Step 1: Install Development Languages

### Node.js

**Option A: Using winget (Recommended)**
```powershell
winget install OpenJS.NodeJS.LTS
```

**Option B: Using Chocolatey**
```powershell
choco install nodejs-lts -y
```

**Option C: Manual Download**
Download from [nodejs.org](https://nodejs.org/) and run the installer.

**Verify Installation:**
```powershell
node --version
npm --version
```

---

### Rust

Rust is installed via `rustup` which doesn't require admin privileges.

```powershell
# Download and run rustup installer
Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "$env:TEMP\rustup-init.exe"
& "$env:TEMP\rustup-init.exe" -y
```

**Add to PATH (current session):**
```powershell
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
```

**Verify Installation:**
```powershell
rustc --version
cargo --version
```

---

### Go (Golang)

**Option A: Using winget**
```powershell
winget install GoLang.Go
```

**Option B: Manual Installation (No Admin Required)**

```powershell
# Download Go
$goVersion = "1.22.0"
$goUrl = "https://go.dev/dl/go$goVersion.windows-amd64.zip"
$goZip = "$env:TEMP\go.zip"
$goInstallPath = "$env:USERPROFILE\go-sdk"

# Download and extract
Invoke-WebRequest -Uri $goUrl -OutFile $goZip
Expand-Archive -Path $goZip -DestinationPath $goInstallPath -Force

# Add to user PATH permanently
$goBin = "$goInstallPath\go\bin"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$goBin*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$goBin", "User")
}

# Add to current session
$env:PATH = "$env:PATH;$goBin"
```

**Verify Installation:**
```powershell
go version
```

---

## Step 2: Install CLI Tools

All tools are installed via Cargo (Rust's package manager), which doesn't require admin privileges.

### Ensure Cargo is in PATH

```powershell
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
```

### Install All Tools at Once

```powershell
cargo install starship zoxide eza bat ripgrep git-delta
```

### Or Install Individually

```powershell
# Starship - Beautiful, fast prompt
cargo install starship

# zoxide - Smart directory jumping
cargo install zoxide

# eza - Modern ls replacement
cargo install eza

# bat - Cat with syntax highlighting
cargo install bat

# ripgrep - Ultra-fast grep
cargo install ripgrep

# delta - Beautiful git diffs
cargo install git-delta
```

### Install fzf (Fuzzy Finder)

```powershell
# Create local bin directory
$fzfDir = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Force -Path $fzfDir | Out-Null

# Download and extract fzf
$fzfUrl = "https://github.com/junegunn/fzf/releases/download/v0.55.0/fzf-0.55.0-windows_amd64.zip"
Invoke-WebRequest -Uri $fzfUrl -OutFile "$env:TEMP\fzf.zip"
Expand-Archive -Path "$env:TEMP\fzf.zip" -DestinationPath $fzfDir -Force
```

### Verify All Tools

```powershell
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:USERPROFILE\.local\bin;$env:PATH"

@("starship", "zoxide", "eza", "bat", "rg", "fzf", "delta") | ForEach-Object {
    $v = & $_ --version 2>$null | Select-Object -First 1
    Write-Host "$_ : $v"
}
```

---

## Step 3: Install PowerShell Modules

```powershell
# Terminal-Icons - File icons in directory listings
Install-Module -Name Terminal-Icons -Scope CurrentUser -Force

# PSFzf - fzf integration for PowerShell
Install-Module -Name PSFzf -Scope CurrentUser -Force

# posh-git - Git status in prompt (optional, starship handles this)
Install-Module -Name posh-git -Scope CurrentUser -Force
```

---

## Step 4: Configure PowerShell Profile

### Locate Your Profile

```powershell
$PROFILE
# Usually: C:\Users\<username>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

### Create/Edit Profile

```powershell
# Create profile directory if it doesn't exist
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

# Open profile in VS Code (or notepad)
code $PROFILE
```

### Complete PowerShell Profile

Copy this entire configuration into your profile:

```powershell
<# 
Terminal Enhancement Profile
============================
Features:
- Smart PATH management
- Module loading with error handling
- PSReadLine configuration (history, predictions)
- fzf integration
- zoxide (smart cd)
- eza aliases (better ls)
- bat aliases (better cat)
- Git shortcuts
- Utility functions
- Starship prompt
#>

$ErrorActionPreference = "Continue"

# ==================== PATH Setup ====================
$pathsToAdd = @(
    "$env:USERPROFILE\.cargo\bin",
    "$env:USERPROFILE\go-sdk\go\bin",
    "$env:USERPROFILE\.local\bin"
)
foreach ($p in $pathsToAdd) {
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) {
        $env:PATH = "$p;$env:PATH"
    }
}

# ==================== Modules ====================
Import-Module PSReadLine -ErrorAction SilentlyContinue
Import-Module posh-git -ErrorAction SilentlyContinue
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module PSFzf -ErrorAction SilentlyContinue

# ==================== PSFzf Configuration ====================
if (Get-Module PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSFzfOption -EnableAliasFuzzyEdit
    Set-PSFzfOption -EnableAliasFuzzySetLocation
}

# ==================== PSReadLine Configuration ====================
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView

    # Arrow keys search history based on current input
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Ctrl+r for fzf history search (fallback if PSFzf not loaded)
    if (-not (Get-Module PSFzf) -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
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

# ==================== zoxide (Smart cd) ====================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    try {
        (& zoxide init powershell) -join "`n" | Invoke-Expression
    } catch {
        Write-Warning "zoxide init failed: $($_.Exception.Message)"
    }
}

# ==================== eza Aliases (Better ls) ====================
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function l { eza --icons --group-directories-first }
    function la { eza -a --icons --group-directories-first }
    function ls { eza --icons --group-directories-first }
    function ll { eza -la --icons --group-directories-first --git }
    function lt { eza --tree --icons --level=2 }
    function lta { eza --tree --icons -a --level=2 }
} else {
    function ll { Get-ChildItem -Force }
    function la { Get-ChildItem -Force }
}

# ==================== bat Aliases (Better cat) ====================
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat --style=auto $args }
    function catp { bat --plain $args }
}

# ==================== ripgrep Alias ====================
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep {
        param(
            [Parameter(Mandatory)] [string]$Pattern,
            [string]$Path = "."
        )
        rg $Pattern $Path
    }
}

# ==================== Git Shortcuts ====================
function gst { git status }
function gco { param([string]$Branch) git checkout $Branch }
function gl { git pull }
function gp { git push }
function ga { git add $args }
function gaa { git add --all }
function gc { git commit -m $args }
function gca { git commit --amend }
function gd { git diff $args }
function gds { git diff --staged }
function gb { git branch $args }
function glog { git log --oneline --graph --decorate -20 }

# Use delta for git diffs if available
if (Get-Command delta -ErrorAction SilentlyContinue) {
    $env:GIT_PAGER = "delta"
}

# ==================== Utility Functions ====================
function which { param([string]$Name) Get-Command $Name -All | Select-Object -ExpandProperty Source }
function reload { . $PROFILE; Write-Host "Profile reloaded." -ForegroundColor Green }
function touch { param([string]$Path) if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date } else { New-Item -ItemType File -Path $Path } }
function mkcd { param([string]$Path) New-Item -ItemType Directory -Path $Path -Force; Set-Location $Path }

# Directory navigation shortcuts
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Fuzzy finders
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    function ff { Get-ChildItem -Recurse -File | ForEach-Object { $_.FullName } | fzf | ForEach-Object { code $_ } }
    function fd { Get-ChildItem -Recurse -Directory | ForEach-Object { $_.FullName } | fzf | ForEach-Object { Set-Location $_ } }
}

# ==================== Starship Prompt ====================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    try {
        (& starship init powershell) -join "`n" | Invoke-Expression
    } catch {
        Write-Warning "starship init failed: $($_.Exception.Message)"
    }
}
```

### Apply Profile

```powershell
. $PROFILE
```

---

## Step 5: Configure Starship Prompt

### Create Configuration Directory

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config" | Out-Null
```

### Create Starship Configuration

Create file at `~/.config/starship.toml`:

```powershell
code "$env:USERPROFILE\.config\starship.toml"
```

### Complete Starship Configuration

```toml
# Starship Configuration - Beautiful & Informative Prompt

# Inserts a blank line between shell prompts
add_newline = true

# Timeout for commands executed by starship (in milliseconds)
command_timeout = 1000

# Format of the prompt
format = """
$username$hostname$directory$git_branch$git_status$git_state\
$nodejs$rust$golang$python$java$docker_context\
$cmd_duration$line_break$character"""

# Right side of prompt
right_format = """$time"""

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"

[username]
style_user = "bold cyan"
style_root = "bold red"
format = "[$user]($style) "
disabled = false
show_always = false

[hostname]
ssh_only = true
format = "on [$hostname](bold purple) "

[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold blue"
format = "[$path]($style)[$read_only]($read_only_style) "
read_only = " 🔒"

[git_branch]
symbol = " "
style = "bold purple"
format = "on [$symbol$branch]($style) "

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "bold yellow"
conflicted = "🔥"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "📦"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"

[git_state]
format = '[\($state( $progress_current of $progress_total)\)]($style) '
cherry_pick = "[🍒 PICKING](bold red)"
rebase = "[📐 REBASING](bold yellow)"
merge = "[🔀 MERGING](bold purple)"

[nodejs]
symbol = " "
style = "bold green"
format = "[$symbol($version)]($style) "
detect_files = ["package.json", ".node-version"]
detect_folders = ["node_modules"]

[rust]
symbol = " "
style = "bold red"
format = "[$symbol($version)]($style) "

[golang]
symbol = " "
style = "bold cyan"
format = "[$symbol($version)]($style) "

[python]
symbol = " "
style = "bold yellow"
format = "[$symbol($version)]($style) "
detect_files = ["requirements.txt", "pyproject.toml", "Pipfile", "setup.py"]

[java]
symbol = " "
style = "bold red"
format = "[$symbol($version)]($style) "

[docker_context]
symbol = " "
style = "bold blue"
format = "[$symbol$context]($style) "
only_with_files = true

[cmd_duration]
min_time = 2000
format = "took [$duration](bold yellow) "
show_milliseconds = false

[time]
disabled = false
format = "[$time]($style)"
style = "bold dimmed white"
time_format = "%H:%M"

[package]
disabled = true
```

---

## Step 6: Install Nerd Fonts

Nerd Fonts include icons required for the terminal tools to display properly.

### Download CaskaydiaCove Nerd Font

```powershell
# Download font
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip"
$fontZip = "$env:TEMP\CascadiaCode.zip"
$fontDir = "$env:TEMP\CascadiaCode"

Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
```

### Install Fonts (User-level, No Admin Required)

```powershell
$userFonts = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $userFonts)) {
    New-Item -ItemType Directory -Path $userFonts -Force | Out-Null
}

# Copy font files
Get-ChildItem "$fontDir" -Filter "CaskaydiaCoveNerdFont*.ttf" | ForEach-Object {
    Copy-Item $_.FullName -Destination $userFonts -Force
    Write-Host "Installed: $($_.Name)"
}
```

### Install Fonts (System-wide, Requires Admin)

```powershell
# Run PowerShell as Administrator
$shell = New-Object -ComObject Shell.Application
$fonts = $shell.Namespace(0x14)

Get-ChildItem "$fontDir" -Filter "*.ttf" | ForEach-Object {
    $fonts.CopyHere($_.FullName)
    Write-Host "Installed: $($_.Name)"
}
```

---

## Step 7: Configure Windows Terminal

### Open Settings

Press `Ctrl+,` in Windows Terminal, or open the settings JSON directly:

```powershell
code "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
```

### Add Font Configuration

Add the following to the `profiles.defaults` section:

```json
{
    "profiles": {
        "defaults": {
            "font": {
                "face": "CaskaydiaCove Nerd Font",
                "size": 12
            },
            "opacity": 95,
            "useAcrylic": true,
            "colorScheme": "One Half Dark"
        }
    }
}
```

### Recommended Color Schemes

Add to the `schemes` array:

```json
{
    "name": "Tokyo Night",
    "background": "#1A1B26",
    "foreground": "#C0CAF5",
    "black": "#15161E",
    "red": "#F7768E",
    "green": "#9ECE6A",
    "yellow": "#E0AF68",
    "blue": "#7AA2F7",
    "purple": "#BB9AF7",
    "cyan": "#7DCFFF",
    "white": "#A9B1D6",
    "brightBlack": "#414868",
    "brightRed": "#F7768E",
    "brightGreen": "#9ECE6A",
    "brightYellow": "#E0AF68",
    "brightBlue": "#7AA2F7",
    "brightPurple": "#BB9AF7",
    "brightCyan": "#7DCFFF",
    "brightWhite": "#C0CAF5",
    "cursorColor": "#C0CAF5",
    "selectionBackground": "#33467C"
}
```

---

## Step 8: Configure VS Code

### Open Settings JSON

Press `Ctrl+Shift+P` → "Preferences: Open User Settings (JSON)"

### Add Terminal Font Configuration

```json
{
    "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font",
    "terminal.integrated.fontSize": 14,
    "terminal.integrated.defaultProfile.windows": "PowerShell"
}
```

### Quick Command

```powershell
$settings = "$env:APPDATA\Code\User\settings.json"
$json = Get-Content $settings -Raw | ConvertFrom-Json
$json | Add-Member -NotePropertyName "terminal.integrated.fontFamily" -NotePropertyValue "CaskaydiaCove Nerd Font" -Force
$json | ConvertTo-Json -Depth 100 | Set-Content $settings -Encoding UTF8
```

---

## Quick Reference

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files |
| `↑ / ↓` | Search history (type prefix first) |
| `Tab` | Auto-complete with predictions |

### Command Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls`, `l` | `eza --icons` | List with icons |
| `la` | `eza -a --icons` | List all (including hidden) |
| `ll` | `eza -la --icons --git` | Long list with git status |
| `lt` | `eza --tree` | Tree view |
| `cat` | `bat` | Syntax highlighted file view |
| `grep` | `rg` | Fast text search |
| `z <dir>` | `zoxide` | Jump to directory |

### Git Shortcuts

| Alias | Command |
|-------|---------|
| `gst` | `git status` |
| `gco <branch>` | `git checkout` |
| `gl` | `git pull` |
| `gp` | `git push` |
| `ga <file>` | `git add` |
| `gaa` | `git add --all` |
| `gc "message"` | `git commit -m` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `glog` | `git log --oneline --graph` |

### Utility Functions

| Function | Description |
|----------|-------------|
| `reload` | Reload PowerShell profile |
| `which <cmd>` | Find command location |
| `mkcd <dir>` | Create and enter directory |
| `touch <file>` | Create empty file |
| `..` / `...` / `....` | Go up directories |
| `ff` | Fuzzy find file → open in VS Code |
| `fd` | Fuzzy find directory → cd into it |

---

## Troubleshooting

### Icons Not Displaying

1. Ensure Nerd Font is installed
2. Restart terminal completely
3. Verify font is selected in terminal settings

### Tools Not Found

```powershell
# Add to PATH manually
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:USERPROFILE\.local\bin;$env:PATH"
```

### Starship Not Loading

```powershell
# Check if starship is installed
starship --version

# Reinitialize
(& starship init powershell) -join "`n" | Invoke-Expression
```

### zoxide Not Working

```powershell
# Check installation
zoxide --version

# Reinitialize
(& zoxide init powershell) -join "`n" | Invoke-Expression

# Build history by navigating directories
z --help
```

### Profile Loading Slow

1. Remove unused module imports
2. Use `-ErrorAction SilentlyContinue` for optional modules
3. Consider lazy loading for heavy modules

---

## One-Click Setup Script

Save this as `setup-terminal.ps1` and run in PowerShell:

```powershell
# Full Terminal Setup Script
# Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Then: .\setup-terminal.ps1

Write-Host "🚀 Starting Terminal Setup..." -ForegroundColor Cyan

# 1. Install Rust
if (-not (Get-Command rustc -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Rust..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "$env:TEMP\rustup-init.exe"
    & "$env:TEMP\rustup-init.exe" -y
    $env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
}

# 2. Install CLI tools
Write-Host "Installing CLI tools..." -ForegroundColor Yellow
cargo install starship zoxide eza bat ripgrep git-delta

# 3. Install fzf
Write-Host "Installing fzf..." -ForegroundColor Yellow
$fzfDir = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Force -Path $fzfDir | Out-Null
Invoke-WebRequest -Uri "https://github.com/junegunn/fzf/releases/download/v0.55.0/fzf-0.55.0-windows_amd64.zip" -OutFile "$env:TEMP\fzf.zip"
Expand-Archive -Path "$env:TEMP\fzf.zip" -DestinationPath $fzfDir -Force

# 4. Install PowerShell modules
Write-Host "Installing PowerShell modules..." -ForegroundColor Yellow
Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name PSFzf -Scope CurrentUser -Force -SkipPublisherCheck

# 5. Install Nerd Font
Write-Host "Installing Nerd Font..." -ForegroundColor Yellow
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip"
Invoke-WebRequest -Uri $fontUrl -OutFile "$env:TEMP\CascadiaCode.zip"
Expand-Archive -Path "$env:TEMP\CascadiaCode.zip" -DestinationPath "$env:TEMP\CascadiaCode" -Force
$userFonts = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
New-Item -ItemType Directory -Force -Path $userFonts | Out-Null
Copy-Item "$env:TEMP\CascadiaCode\CaskaydiaCoveNerdFont-Regular.ttf" -Destination $userFonts -Force
Copy-Item "$env:TEMP\CascadiaCode\CaskaydiaCoveNerdFontMono-Regular.ttf" -Destination $userFonts -Force

Write-Host "✅ Setup complete! Please:" -ForegroundColor Green
Write-Host "   1. Copy the PowerShell profile from README to: $PROFILE" -ForegroundColor White
Write-Host "   2. Copy starship.toml to: ~/.config/starship.toml" -ForegroundColor White
Write-Host "   3. Set font to 'CaskaydiaCove Nerd Font' in terminal settings" -ForegroundColor White
Write-Host "   4. Restart your terminal" -ForegroundColor White
```

---

## Credits

- [Starship](https://starship.rs/) - Cross-shell prompt
- [eza](https://github.com/eza-community/eza) - Modern ls
- [bat](https://github.com/sharkdp/bat) - Better cat
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast search
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smart cd
- [delta](https://github.com/dandavison/delta) - Git diff viewer
- [Nerd Fonts](https://www.nerdfonts.com/) - Patched fonts with icons

---

**Happy Coding! 🎉**
