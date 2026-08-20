# HuaweiCloud DevKit → ClawHub Publisher
# 从 npm 拉取指定版本，发布到 ClawHub
#
# 用法:
#   .\publish.ps1 -Version 1.0.2-next.16          # 正式发布
#   .\publish.ps1 -Version 1.0.2-next.16 -DryRun   # 预览
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [switch]$DryRun,
    [string]$Owner = "huaweiclouddev",
    [string]$Name = "huaweicloud-devkit",
    [string]$DisplayName = "HuaweiCloud DevKit"
)

$ErrorActionPreference = "Stop"
$WorkDir = Join-Path $PSScriptRoot "tmp"

# -- 1. 清理 ----------------------------------------------------------------
Write-Host "[1/4] 清理临时目录..." -ForegroundColor Cyan
if (Test-Path $WorkDir) { Remove-Item -Recurse -Force $WorkDir }
New-Item -ItemType Directory -Path (Join-Path $WorkDir "node_modules") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $WorkDir "node_modules" "huaweicloud-devkit" "plugins" "huaweicloud-core") -Force | Out-Null

# -- 2. 下载 npm 包 ----------------------------------------------------------
Write-Host "[2/4] npm install huaweicloud-devkit@$Version ..." -ForegroundColor Cyan
Push-Location $WorkDir
npm init -y --silent 2>$null | Out-Null
npm install "huaweicloud-devkit@$Version" --no-save 2>&1
if ($LASTEXITCODE -ne 0) { Pop-Location; throw "npm install 失败" }
Pop-Location

$Extracted = Get-ChildItem -Path (Join-Path $WorkDir "node_modules") -Directory | Where-Object { $_.Name -eq "huaweicloud-devkit" } | Select-Object -First 1
$PluginDir = Join-Path $Extracted.FullName "plugins" "huaweicloud-core"
if (-not (Test-Path $PluginDir)) { throw "未找到 plugins/huaweicloud-core，npm 包结构可能已变更" }

# 补 openclaw.plugin.json（npm 包中可能没有）
$Ocj = Join-Path $PluginDir "openclaw.plugin.json"
if (-not (Test-Path $Ocj)) {
    Copy-Item (Join-Path $PSScriptRoot "openclaw.plugin.json") $PluginDir -Force
}

Write-Host "  插件: $PluginDir" -ForegroundColor Green

# -- 3. 发布到 ClawHub -------------------------------------------------------
Write-Host "[3/4] clawhub package publish..." -ForegroundColor Cyan
$args = @(
    "package", "publish", $PluginDir,
    "--family", "bundle-plugin",
    "--name", $Name,
    "--display-name", $DisplayName,
    "--version", $Version,
    "--bundle-format", "codex",
    "--owner", $Owner
)
if ($DryRun) { $args += "--dry-run" }

& clawhub @args --json 2>&1 | ForEach-Object { Write-Host "  $_" }

# -- 4. 清理 -----------------------------------------------------------------
Write-Host "[4/4] 清理..." -ForegroundColor Cyan
Remove-Item -Recurse -Force $WorkDir
Write-Host "✓ 完成. 用户安装: openclaw plugins install clawhub:$Name" -ForegroundColor Green