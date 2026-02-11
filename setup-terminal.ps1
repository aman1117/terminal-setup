# ============================================================
# 🚀 One-Click Terminal Setup Script for Windows
# ============================================================
# 
# This script sets up a beautiful, productive terminal with:
# - Starship prompt
# - eza, bat, ripgrep, fzf, zoxide, delta
# - Nerd Fonts
# - PowerShell profile
#
# Usage:
#   1. Open PowerShell as regular user
#   2. Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#   3. Run: .\setup-terminal.ps1
#
# ============================================================

param(
    [switch]$SkipRust,
    [switch]$SkipFonts,
    [switch]$SkipProfile
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✅ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  ℹ️  $Message" -ForegroundColor Yellow
}

# ============================================================
# Banner
# ============================================================
Write-Host @"

  ╔═══════════════════════════════════════════════════════╗
  ║                                                       ║
  ║   🚀 Ultimate Terminal Setup for Windows              ║
  ║                                                       ║
  ║   Installing: Starship, eza, bat, ripgrep,            ║
  ║               fzf, zoxide, delta, Nerd Fonts          ║
  ║                                                       ║
  ╚═══════════════════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# ============================================================
# Step 1: Install Rust (required for cargo install)
# ============================================================
if (-not $SkipRust) {
    Write-Step "Step 1/6: Installing Rust"
    
    if (Get-Command rustc -ErrorAction SilentlyContinue) {
        $rustVersion = rustc --version
        Write-Success "Rust already installed: $rustVersion"
    } else {
        Write-Info "Downloading rustup installer..."
        Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "$env:TEMP\rustup-init.exe"
        
        Write-Info "Running rustup installer..."
        & "$env:TEMP\rustup-init.exe" -y
        
        # Add to current session PATH
        $env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
        
        Write-Success "Rust installed successfully!"
    }
} else {
    Write-Step "Step 1/6: Skipping Rust installation"
}

# Ensure cargo is in PATH
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"

# ============================================================
# Step 2: Install CLI Tools via Cargo
# ============================================================
Write-Step "Step 2/6: Installing CLI Tools"

$tools = @(
    @{ Name = "starship"; Cmd = "starship"; Desc = "Beautiful prompt" },
    @{ Name = "zoxide"; Cmd = "zoxide"; Desc = "Smart directory jumping" },
    @{ Name = "eza"; Cmd = "eza"; Desc = "Modern ls replacement" },
    @{ Name = "bat"; Cmd = "bat"; Desc = "Cat with syntax highlighting" },
    @{ Name = "ripgrep"; Cmd = "rg"; Desc = "Ultra-fast grep" },
    @{ Name = "git-delta"; Cmd = "delta"; Desc = "Beautiful git diffs" }
)

foreach ($tool in $tools) {
    if (Get-Command $tool.Cmd -ErrorAction SilentlyContinue) {
        Write-Success "$($tool.Name) already installed"
    } else {
        Write-Info "Installing $($tool.Name) ($($tool.Desc))..."
        cargo install $tool.Name
        Write-Success "$($tool.Name) installed!"
    }
}

# ============================================================
# Step 3: Install fzf
# ============================================================
Write-Step "Step 3/6: Installing fzf"

$fzfDir = "$env:USERPROFILE\.local\bin"
$fzfExe = "$fzfDir\fzf.exe"

if (Test-Path $fzfExe) {
    Write-Success "fzf already installed"
} else {
    Write-Info "Creating local bin directory..."
    New-Item -ItemType Directory -Force -Path $fzfDir | Out-Null
    
    Write-Info "Downloading fzf..."
    $fzfUrl = "https://github.com/junegunn/fzf/releases/download/v0.55.0/fzf-0.55.0-windows_amd64.zip"
    Invoke-WebRequest -Uri $fzfUrl -OutFile "$env:TEMP\fzf.zip"
    
    Write-Info "Extracting fzf..."
    Expand-Archive -Path "$env:TEMP\fzf.zip" -DestinationPath $fzfDir -Force
    
    Write-Success "fzf installed!"
}

# Add to PATH
$env:PATH = "$fzfDir;$env:PATH"

# ============================================================
# Step 4: Install PowerShell Modules
# ============================================================
Write-Step "Step 4/6: Installing PowerShell Modules"

$modules = @("Terminal-Icons", "PSFzf")

foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Write-Success "$module already installed"
    } else {
        Write-Info "Installing $module..."
        Install-Module -Name $module -Scope CurrentUser -Force -SkipPublisherCheck
        Write-Success "$module installed!"
    }
}

# ============================================================
# Step 5: Install Nerd Font
# ============================================================
if (-not $SkipFonts) {
    Write-Step "Step 5/6: Installing Nerd Font (CaskaydiaCove)"
    
    $userFonts = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $fontCheck = "$userFonts\CaskaydiaCoveNerdFont-Regular.ttf"
    
    if (Test-Path $fontCheck) {
        Write-Success "Nerd Font already installed"
    } else {
        Write-Info "Downloading CaskaydiaCove Nerd Font..."
        $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip"
        Invoke-WebRequest -Uri $fontUrl -OutFile "$env:TEMP\CascadiaCode.zip"
        
        Write-Info "Extracting fonts..."
        Expand-Archive -Path "$env:TEMP\CascadiaCode.zip" -DestinationPath "$env:TEMP\CascadiaCode" -Force
        
        Write-Info "Installing fonts to user profile..."
        New-Item -ItemType Directory -Force -Path $userFonts | Out-Null
        
        Get-ChildItem "$env:TEMP\CascadiaCode" -Filter "CaskaydiaCoveNerdFont*.ttf" | ForEach-Object {
            Copy-Item $_.FullName -Destination $userFonts -Force
        }
        
        Write-Success "Nerd Font installed!"
    }
} else {
    Write-Step "Step 5/6: Skipping font installation"
}

# ============================================================
# Step 6: Create Configuration Files
# ============================================================
if (-not $SkipProfile) {
    Write-Step "Step 6/6: Creating Configuration Files"
    
    # Create starship config
    $starshipConfig = "$env:USERPROFILE\.config\starship.toml"
    if (-not (Test-Path $starshipConfig)) {
        Write-Info "Creating starship configuration..."
        New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config" | Out-Null
        
        @'
add_newline = true
command_timeout = 1000

format = """$username$hostname$directory$git_branch$git_status$git_state\
$nodejs$rust$golang$python$docker_context\
$cmd_duration$line_break$character"""

right_format = """$time"""

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[directory]
truncation_length = 3
style = "bold blue"

[git_branch]
symbol = " "
style = "bold purple"

[git_status]
style = "bold yellow"

[nodejs]
symbol = " "
format = "[$symbol($version)]($style) "

[rust]
symbol = " "
format = "[$symbol($version)]($style) "

[golang]
symbol = " "
format = "[$symbol($version)]($style) "

[python]
symbol = " "
format = "[$symbol($version)]($style) "

[cmd_duration]
min_time = 2000
format = "took [$duration](bold yellow) "

[time]
disabled = false
format = "[$time]($style)"
style = "dimmed white"
'@ | Set-Content $starshipConfig -Encoding UTF8
        
        Write-Success "Starship config created at: $starshipConfig"
    } else {
        Write-Success "Starship config already exists"
    }
    
    # Check PowerShell profile
    if (-not (Test-Path $PROFILE)) {
        Write-Info "PowerShell profile not found"
        Write-Info "Please copy the profile from README.md to: $PROFILE"
    } else {
        Write-Success "PowerShell profile exists at: $PROFILE"
    }
} else {
    Write-Step "Step 6/6: Skipping configuration files"
}

# ============================================================
# Summary
# ============================================================
Write-Host @"

  ╔═══════════════════════════════════════════════════════╗
  ║                                                       ║
  ║   ✅ Setup Complete!                                  ║
  ║                                                       ║
  ╚═══════════════════════════════════════════════════════╝

"@ -ForegroundColor Green

Write-Host "  📋 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Set terminal font to 'CaskaydiaCove Nerd Font'" -ForegroundColor White
Write-Host "     - Windows Terminal: Settings → Profiles → Defaults → Font" -ForegroundColor DarkGray
Write-Host "     - VS Code: Settings → Terminal Font Family" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  2. Copy PowerShell profile from README.md to:" -ForegroundColor White
Write-Host "     $PROFILE" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  3. Restart your terminal" -ForegroundColor White
Write-Host ""
Write-Host "  📖 Full documentation: README.md" -ForegroundColor Cyan
Write-Host ""

# Verify installations
Write-Host "  🔍 Installed Tools:" -ForegroundColor Yellow
@("starship", "zoxide", "eza", "bat", "rg", "fzf", "delta") | ForEach-Object {
    $cmd = $_
    $version = try { & $cmd --version 2>$null | Select-Object -First 1 } catch { "not found" }
    if ($version -and $version -ne "not found") {
        Write-Host "     ✅ $cmd" -ForegroundColor Green
    } else {
        Write-Host "     ❌ $cmd" -ForegroundColor Red
    }
}
Write-Host ""
