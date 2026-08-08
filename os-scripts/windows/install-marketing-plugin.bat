@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..\..") do set "project_directory=%%~fI"
set "source_plugin=%project_directory%\plugins\marketing"
set "source_manifest=%source_plugin%\.codex-plugin\plugin.json"

if not exist "%source_plugin%\" (
    echo Error: marketing plugin source not found: "%source_plugin%".
    pause
    exit /b 1
)

if not exist "%source_manifest%" (
    echo Error: marketing plugin manifest not found: "%source_manifest%".
    pause
    exit /b 1
)

where powershell >nul 2>&1
if errorlevel 1 (
    echo Error: PowerShell is required to manage plugin metadata.
    pause
    exit /b 1
)

:prompt_scope
echo Install scope:
echo   1. Personal
echo   2. Project
set "install_scope="
set /p "install_scope=Select the install scope: "

if "!install_scope!"=="1" goto personal_scope
if "!install_scope!"=="2" goto project_scope
echo Invalid selection. Please try again.
goto prompt_scope

:personal_scope
set "scope_name=personal"
set "target_plugin=%USERPROFILE%\.codex\plugins\marketing"
set "marketplace_file=%USERPROFILE%\.agents\plugins\marketplace.json"
set "marketplace_name=personal"
set "marketplace_display_name=Personal"
set "marketplace_source_path=./.codex/plugins/marketing"
goto inspect_marketplace

:project_scope
set "scope_name=project"

:prompt_project_directory
set "target_directory="
set /p "target_directory=Enter the project root directory: "
set "target_directory=!target_directory:"=!"

if not defined target_directory (
    echo The directory cannot be empty. Please try again.
    goto prompt_project_directory
)

if not exist "!target_directory!\" goto confirm_create
goto resolve_project_directory

:confirm_create
choice /c YN /n /m "The directory does not exist. Create it? [Y/N] "
if errorlevel 2 goto cancelled
mkdir "!target_directory!"
if errorlevel 1 goto failed_create

:resolve_project_directory
for %%I in ("!target_directory!") do (
    set "target_directory=%%~fI"
    set "project_name=%%~nxI"
)
set "CODEX_INSTALL_PROJECT_NAME=!project_name!"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$name=$env:CODEX_INSTALL_PROJECT_NAME.ToLowerInvariant() -replace '[^a-z0-9]+','-'; $name.Trim('-')"`) do set "marketplace_name=%%I"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$name=$env:CODEX_INSTALL_PROJECT_NAME -replace '[-_]+',' '; (Get-Culture).TextInfo.ToTitleCase($name.ToLowerInvariant())"`) do set "marketplace_display_name=%%I"

if not defined marketplace_name (
    echo Error: the project directory name cannot be converted to a marketplace name.
    pause
    exit /b 1
)

set "target_plugin=!target_directory!\plugins\marketing"
set "marketplace_file=!target_directory!\.agents\plugins\marketplace.json"
set "marketplace_source_path=./plugins/marketing"

:inspect_marketplace
set "existing_entry=0"
if not exist "!marketplace_file!" goto confirm_existing

set "CODEX_INSTALL_MARKETPLACE_PATH=!marketplace_file!"
for /f "tokens=1,2 delims=|" %%A in ('powershell -NoProfile -Command "try { $data=Get-Content -Raw -LiteralPath $env:CODEX_INSTALL_MARKETPLACE_PATH ^| ConvertFrom-Json; if ([string]::IsNullOrWhiteSpace([string]$data.name)) { throw 'Marketplace name is missing.' }; $found=@($data.plugins ^| Where-Object { $_.name -eq 'marketing' }).Count -gt 0; Write-Output ([string]$data.name + '^|' + [int]$found) } catch { Write-Error $_; exit 1 }"') do (
    set "marketplace_name=%%A"
    set "existing_entry=%%B"
)
if errorlevel 1 goto failed_marketplace_read

:confirm_existing
if exist "!target_plugin!" goto confirm_overwrite
if "!existing_entry!"=="1" goto confirm_overwrite
goto copy_plugin

:confirm_overwrite
choice /c YN /n /m "The marketing plugin or marketplace entry already exists. Merge and overwrite matching content? [Y/N] "
if errorlevel 2 goto cancelled

:copy_plugin
for %%I in ("!target_plugin!\..") do set "target_plugin_parent=%%~fI"
if not exist "!target_plugin_parent!\" mkdir "!target_plugin_parent!"
if errorlevel 1 goto failed_plugin_directory
xcopy "%source_plugin%\*" "!target_plugin!\" /E /I /H /Y /Q >nul
if errorlevel 1 goto failed_plugin_copy

set "CODEX_INSTALL_MANIFEST_PATH=!target_plugin!\.codex-plugin\plugin.json"
powershell -NoProfile -Command "try { $path=$env:CODEX_INSTALL_MANIFEST_PATH; $manifest=Get-Content -Raw -LiteralPath $path ^| ConvertFrom-Json; if ([string]::IsNullOrWhiteSpace([string]$manifest.version)) { throw 'Plugin version is missing.' }; $base=([string]$manifest.version).Split('+')[0]; $manifest.version=$base + '+codex.local-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'); $manifest ^| ConvertTo-Json -Depth 20 ^| Set-Content -LiteralPath $path -Encoding UTF8 } catch { Write-Error $_; exit 1 }"
if errorlevel 1 goto failed_cachebuster

for %%I in ("!marketplace_file!\..") do set "marketplace_directory=%%~fI"
if not exist "!marketplace_directory!\" mkdir "!marketplace_directory!"
if errorlevel 1 goto failed_marketplace_directory

set "CODEX_INSTALL_MARKETPLACE_PATH=!marketplace_file!"
set "CODEX_INSTALL_MARKETPLACE_NAME=!marketplace_name!"
set "CODEX_INSTALL_MARKETPLACE_DISPLAY_NAME=!marketplace_display_name!"
set "CODEX_INSTALL_PLUGIN_SOURCE_PATH=!marketplace_source_path!"
powershell -NoProfile -Command "try { $entry=[ordered]@{ name='marketing'; source=[ordered]@{ source='local'; path=$env:CODEX_INSTALL_PLUGIN_SOURCE_PATH }; policy=[ordered]@{ installation='AVAILABLE'; authentication='ON_INSTALL' }; category='Productivity' }; $path=$env:CODEX_INSTALL_MARKETPLACE_PATH; if (Test-Path -LiteralPath $path) { $data=Get-Content -Raw -LiteralPath $path ^| ConvertFrom-Json; if ([string]::IsNullOrWhiteSpace([string]$data.name)) { throw 'Marketplace name is missing.' }; $plugins=@($data.plugins); $replaced=$false; for ($index=0; $index -lt $plugins.Count; $index++) { if ($plugins[$index].name -eq 'marketing') { $plugins[$index]=[pscustomobject]$entry; $replaced=$true; break } }; if (-not $replaced) { $plugins += [pscustomobject]$entry }; $data.plugins=$plugins } else { $data=[ordered]@{ name=$env:CODEX_INSTALL_MARKETPLACE_NAME; interface=[ordered]@{ displayName=$env:CODEX_INSTALL_MARKETPLACE_DISPLAY_NAME }; plugins=@([pscustomobject]$entry) } }; $data ^| ConvertTo-Json -Depth 20 ^| Set-Content -LiteralPath $path -Encoding UTF8 } catch { Write-Error $_; exit 1 }"
if errorlevel 1 goto failed_marketplace_write

echo The marketing plugin and marketplace entry were prepared.
echo Plugin: "!target_plugin!"
echo Marketplace: "!marketplace_file!"

choice /c YN /n /m "Install or reinstall the marketing plugin now? [Y/N] "
if errorlevel 2 goto skipped_install

where codex >nul 2>&1
if errorlevel 1 goto failed_codex_missing

if /i "!scope_name!"=="project" (
    codex plugin marketplace add "!target_directory!"
    if errorlevel 1 goto failed_marketplace_registration
)

codex plugin add "marketing@!marketplace_name!"
if errorlevel 1 goto failed_plugin_install

echo The marketing plugin was installed. Start a new conversation to use the updated plugin.
pause
exit /b 0

:skipped_install
echo Plugin installation was skipped. Install it later from the Plugins Directory or Codex CLI.
pause
exit /b 0

:failed_create
echo Error: failed to create the directory "!target_directory!".
pause
exit /b 1

:failed_marketplace_read
echo Error: failed to read the marketplace file "!marketplace_file!".
pause
exit /b 1

:failed_plugin_directory
echo Error: failed to create the plugin directory.
pause
exit /b 1

:failed_plugin_copy
echo Error: failed to copy the marketing plugin.
pause
exit /b 1

:failed_cachebuster
echo Error: failed to update the plugin cachebuster.
pause
exit /b 1

:failed_marketplace_directory
echo Error: failed to create the marketplace directory.
pause
exit /b 1

:failed_marketplace_write
echo Error: failed to create or update the marketplace file.
pause
exit /b 1

:failed_codex_missing
echo Error: Codex CLI was not found. Files were prepared, but the plugin was not installed.
pause
exit /b 1

:failed_marketplace_registration
echo Error: failed to register the project marketplace. Files were prepared.
pause
exit /b 1

:failed_plugin_install
echo Error: failed to install the marketing plugin. Files were prepared.
pause
exit /b 1

:cancelled
echo Operation cancelled.
pause
exit /b 0
