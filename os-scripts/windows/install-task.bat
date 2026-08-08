@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..\..") do set "project_directory=%%~fI"
set "source_skill=%project_directory%\skills\task"
set "source_work=%project_directory%\work\task"
set "source_general=%source_work%\general\AGENTS.md"

if not exist "%source_skill%\" (
    echo Error: skill source directory not found: "%source_skill%".
    pause
    exit /b 1
)

if not exist "%source_general%" (
    echo Error: general work rule not found: "%source_general%".
    pause
    exit /b 1
)

set /a option_count=0
for /f "delims=" %%F in ('dir /b /s /a-d "%source_work%\AGENTS.md" 2^>nul ^| sort') do (
    set "relative_file=%%~fF"
    set "relative_file=!relative_file:%source_work%\=!"
    if /i not "!relative_file!"=="general\AGENTS.md" (
        set "rule_path=!relative_file:\AGENTS.md=!"
        set /a option_count+=1
        set "option_!option_count!=!rule_path!"
    )
)

if !option_count! equ 0 goto no_optional_rules

echo Optional task work rules:
for /l %%I in (1,1,!option_count!) do echo   %%I. !option_%%I!
goto prompt_selection

:no_optional_rules
echo No optional task work rules were found. General will be installed.
goto prompt_directory

:prompt_selection
set "selection="
set /p "selection=Select rule numbers separated by spaces, enter "all", or press Enter for general only: "

if not defined selection goto prompt_directory
if /i "!selection!"=="all" (
    for /l %%I in (1,1,!option_count!) do set "selected_%%I=1"
    goto collect_selected_rules
)

for /f "delims=0123456789 " %%A in ("!selection!") do goto invalid_selection

for %%N in (!selection!) do (
    if %%N lss 1 goto invalid_selection
    if %%N gtr !option_count! goto invalid_selection
    set "selected_%%N=1"
)
goto collect_selected_rules

:invalid_selection
echo Invalid selection. Please try again.
for /l %%I in (1,1,!option_count!) do set "selected_%%I="
goto prompt_selection

:collect_selected_rules
set /a copy_rule_count=0
for /l %%I in (1,1,!option_count!) do (
    if defined selected_%%I call :add_rule_with_parents "!option_%%I!"
)

:prompt_directory
set "target_directory="
set /p "target_directory=Enter the target directory: "
set "target_directory=!target_directory:"=!"

if not defined target_directory (
    echo The directory cannot be empty. Please try again.
    goto prompt_directory
)

if not exist "!target_directory!\" goto confirm_create
goto check_existing

:confirm_create
choice /c YN /n /m "The directory does not exist. Create it? [Y/N] "
if errorlevel 2 goto cancelled
mkdir "!target_directory!"
if errorlevel 1 goto failed_create

:check_existing
if exist "!target_directory!\skills\task\" goto confirm_overwrite
if exist "!target_directory!\work\task\" goto confirm_overwrite
goto copy_files

:confirm_overwrite
choice /c YN /n /m "Task skill or work rules already exist. Merge and overwrite matching files? [Y/N] "
if errorlevel 2 goto cancelled

:copy_files
if not exist "!target_directory!\skills\" mkdir "!target_directory!\skills"
if errorlevel 1 goto failed_skills_directory
xcopy "%source_skill%\*" "!target_directory!\skills\task\" /E /I /Y /Q >nul
if errorlevel 1 goto failed_skill_copy

if not exist "!target_directory!\work\task\general\" mkdir "!target_directory!\work\task\general"
if errorlevel 1 goto failed_work_directory
copy /Y "%source_general%" "!target_directory!\work\task\general\AGENTS.md" >nul
if errorlevel 1 goto failed_general_copy

for /l %%I in (1,1,!copy_rule_count!) do (
    set "rule_path=!copy_rule_%%I!"
    if not exist "!target_directory!\work\task\!rule_path!\" mkdir "!target_directory!\work\task\!rule_path!"
    if errorlevel 1 goto failed_work_directory
    copy /Y "%source_work%\!rule_path!\AGENTS.md" "!target_directory!\work\task\!rule_path!\AGENTS.md" >nul
    if errorlevel 1 goto failed_rule_copy
)

echo The task skill and general work rule were installed in "!target_directory!".
if !copy_rule_count! gtr 0 (
    echo Optional work rules installed:
    for /l %%I in (1,1,!copy_rule_count!) do echo   !copy_rule_%%I!
)
pause
exit /b 0

:add_rule_with_parents
set "candidate=%~1"
:parent_loop
if exist "%source_work%\!candidate!\AGENTS.md" call :add_copy_rule "!candidate!"
for %%P in ("%source_work%\!candidate!\..") do set "parent_absolute=%%~fP"
set "parent=!parent_absolute:%source_work%=!"
if "!parent:~0,1!"=="\" set "parent=!parent:~1!"
if not defined parent goto :eof
if /i "!parent!"=="!candidate!" goto :eof
set "candidate=!parent!"
goto parent_loop

:add_copy_rule
set "candidate_rule=%~1"
for /l %%I in (1,1,!copy_rule_count!) do (
    if /i "!copy_rule_%%I!"=="!candidate_rule!" goto :eof
)
set /a copy_rule_count+=1
set "copy_rule_!copy_rule_count!=!candidate_rule!"
goto :eof

:failed_create
echo Error: failed to create the directory "!target_directory!".
pause
exit /b 1

:failed_skills_directory
echo Error: failed to create the skills directory.
pause
exit /b 1

:failed_skill_copy
echo Error: failed to copy the task skill.
pause
exit /b 1

:failed_work_directory
echo Error: failed to create a task work rule directory.
pause
exit /b 1

:failed_general_copy
echo Error: failed to copy the general task work rule.
pause
exit /b 1

:failed_rule_copy
echo Error: failed to copy the task work rule "!rule_path!".
pause
exit /b 1

:cancelled
echo Operation cancelled.
pause
exit /b 0
