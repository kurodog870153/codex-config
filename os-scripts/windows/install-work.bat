@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..\..") do set "project_directory=%%~fI"
set "source_shared=%project_directory%\skills\shared\work\hierarchical-instructions.md"
set /a work_type_count=0
set /a copy_rule_count=0

if not "%~2"=="" goto invalid_arguments
if "%~1"=="" goto prompt_work_type
if /i "%~1"=="plan" goto select_plan
if /i "%~1"=="task" goto select_task
if /i "%~1"=="execute" goto select_execute
if /i "%~1"=="all" goto select_all
goto invalid_arguments

:prompt_work_type
echo Work types:
echo   1. plan
echo   2. task
echo   3. execute
echo   4. all
set "selection="
set /p "selection=Select a work type: "

if /i "!selection!"=="1" goto select_plan
if /i "!selection!"=="plan" goto select_plan
if /i "!selection!"=="2" goto select_task
if /i "!selection!"=="task" goto select_task
if /i "!selection!"=="3" goto select_execute
if /i "!selection!"=="execute" goto select_execute
if /i "!selection!"=="4" goto select_all
if /i "!selection!"=="all" goto select_all

echo Invalid selection. Please try again.
goto prompt_work_type

:select_plan
call :add_work_type plan
goto work_types_selected

:select_task
call :add_work_type task
goto work_types_selected

:select_execute
call :add_work_type execute
goto work_types_selected

:select_all
call :add_work_type plan
call :add_work_type task
call :add_work_type execute

:work_types_selected
if not exist "%source_shared%" (
    echo Error: shared work instructions not found: "%source_shared%".
    pause
    exit /b 1
)

for /l %%I in (1,1,!work_type_count!) do (
    set "work_type=!work_type_%%I!"
    if not exist "%project_directory%\skills\!work_type!\" (
        echo Error: skill source directory not found: "%project_directory%\skills\!work_type!".
        pause
        exit /b 1
    )
    if not exist "%project_directory%\work\!work_type!\general\AGENTS.md" (
        echo Error: general work rule not found: "%project_directory%\work\!work_type!\general\AGENTS.md".
        pause
        exit /b 1
    )
)

for /l %%I in (1,1,!work_type_count!) do call :select_optional_rules "!work_type_%%I!"

:prompt_directory
set "target_directory="
set /p "target_directory=Enter the target directory: "
set "target_directory=!target_directory:"=!"

if not defined target_directory (
    echo The directory cannot be empty. Please try again.
    goto prompt_directory
)

set "target_shared=!target_directory!\skills\shared\work\hierarchical-instructions.md"

if not exist "!target_directory!\" goto confirm_create
goto check_existing

:confirm_create
choice /c YN /n /m "The directory does not exist. Create it? [Y/N] "
if errorlevel 2 goto cancelled
mkdir "!target_directory!"
if errorlevel 1 (
    echo Error: failed to create the directory "!target_directory!".
    pause
    exit /b 1
)

:check_existing
set "copy_shared=1"
set "target_conflict="
if exist "!target_shared!" (
    fc /b "%source_shared%" "!target_shared!" >nul
    if errorlevel 1 (
        set "target_conflict=1"
    ) else (
        set "copy_shared="
    )
)

for /l %%I in (1,1,!work_type_count!) do (
    set "work_type=!work_type_%%I!"
    if exist "!target_directory!\skills\!work_type!\" set "target_conflict=1"
    if exist "!target_directory!\work\!work_type!\" set "target_conflict=1"
)

if defined target_conflict goto confirm_overwrite
goto copy_files

:confirm_overwrite
choice /c YN /n /m "Selected work skills, shared work instructions, or work rules already exist. Merge and overwrite matching files? [Y/N] "
if errorlevel 2 goto cancelled

:copy_files
if defined copy_shared (
    if not exist "!target_directory!\skills\shared\work\" (
        mkdir "!target_directory!\skills\shared\work"
        if errorlevel 1 (
            echo Error: failed to create the shared work instructions directory.
            pause
            exit /b 1
        )
    )
    copy /Y "%source_shared%" "!target_shared!" >nul
    if errorlevel 1 (
        echo Error: failed to copy the shared work instructions.
        pause
        exit /b 1
    )
)

for /l %%I in (1,1,!work_type_count!) do (
    set "work_type=!work_type_%%I!"
    set "source_skill=%project_directory%\skills\!work_type!"
    set "source_work=%project_directory%\work\!work_type!"
    set "target_skill=!target_directory!\skills\!work_type!"
    set "target_work=!target_directory!\work\!work_type!"

    if not exist "!target_skill!\" (
        mkdir "!target_skill!"
        if errorlevel 1 (
            echo Error: failed to create the !work_type! skill directory.
            pause
            exit /b 1
        )
    )
    xcopy "!source_skill!\*" "!target_skill!\" /E /I /Y /Q >nul
    if errorlevel 1 (
        echo Error: failed to copy the !work_type! skill.
        pause
        exit /b 1
    )

    if not exist "!target_work!\general\" (
        mkdir "!target_work!\general"
        if errorlevel 1 (
            echo Error: failed to create a !work_type! work rule directory.
            pause
            exit /b 1
        )
    )
    copy /Y "!source_work!\general\AGENTS.md" "!target_work!\general\AGENTS.md" >nul
    if errorlevel 1 (
        echo Error: failed to copy the general !work_type! work rule.
        pause
        exit /b 1
    )

    for /l %%R in (1,1,!copy_rule_count!) do (
        if /i "!copy_rule_type_%%R!"=="!work_type!" (
            set "rule_path=!copy_rule_path_%%R!"
            if not exist "!target_work!\!rule_path!\" (
                mkdir "!target_work!\!rule_path!"
                if errorlevel 1 (
                    echo Error: failed to create a !work_type! work rule directory.
                    pause
                    exit /b 1
                )
            )
            copy /Y "!source_work!\!rule_path!\AGENTS.md" "!target_work!\!rule_path!\AGENTS.md" >nul
            if errorlevel 1 (
                echo Error: failed to copy the !work_type! work rule "!rule_path!".
                pause
                exit /b 1
            )
        )
    )
)

echo Selected work skills, shared work instructions, and general work rules were installed in "!target_directory!".
echo Work types installed:
for /l %%I in (1,1,!work_type_count!) do echo   !work_type_%%I!
if !copy_rule_count! gtr 0 (
    echo Optional work rules installed:
    for /l %%I in (1,1,!copy_rule_count!) do echo   !copy_rule_type_%%I!: !copy_rule_path_%%I!
)
pause
exit /b 0

:add_work_type
set /a work_type_count+=1
set "work_type_!work_type_count!=%~1"
exit /b 0

:select_optional_rules
set "current_work_type=%~1"
set "source_work=%project_directory%\work\%~1"
set /a option_count=0

for /f "delims=" %%F in ('dir /b /s /a-d "!source_work!\AGENTS.md" 2^>nul ^| sort') do (
    set "relative_file=%%~fF"
    set "relative_file=!relative_file:%source_work%\=!"
    if /i not "!relative_file!"=="general\AGENTS.md" (
        set "rule_path=!relative_file:\AGENTS.md=!"
        set /a option_count+=1
        set "option_!option_count!=!rule_path!"
    )
)

if !option_count! equ 0 (
    echo No optional !current_work_type! work rules were found. General will be installed.
    exit /b 0
)

echo Optional !current_work_type! work rules:
for /l %%I in (1,1,!option_count!) do echo   %%I. !option_%%I!

:prompt_rule_selection
set "selection="
set /p "selection=Select rule numbers separated by spaces, enter "all", or press Enter for general only: "

if not defined selection exit /b 0
if /i "!selection!"=="all" (
    for /l %%I in (1,1,!option_count!) do call :add_rule_with_parents "!current_work_type!" "!option_%%I!"
    exit /b 0
)

for /f "delims=0123456789 " %%A in ("!selection!") do goto invalid_rule_selection

for %%N in (!selection!) do (
    if %%N lss 1 goto invalid_rule_selection
    if %%N gtr !option_count! goto invalid_rule_selection
)

for %%N in (!selection!) do call :add_rule_with_parents "!current_work_type!" "!option_%%N!"
exit /b 0

:invalid_rule_selection
echo Invalid selection. Please try again.
goto prompt_rule_selection

:add_rule_with_parents
set "candidate_type=%~1"
set "candidate=%~2"
set "candidate_source_work=%project_directory%\work\%~1"

:parent_loop
if exist "!candidate_source_work!\!candidate!\AGENTS.md" call :add_copy_rule "!candidate_type!" "!candidate!"
for %%P in ("!candidate_source_work!\!candidate!\..") do set "parent_absolute=%%~fP"
set "parent=!parent_absolute:%candidate_source_work%=!"
if "!parent:~0,1!"=="\" set "parent=!parent:~1!"
if not defined parent exit /b 0
if /i "!parent!"=="!candidate!" exit /b 0
set "candidate=!parent!"
goto parent_loop

:add_copy_rule
for /l %%I in (1,1,!copy_rule_count!) do (
    if /i "!copy_rule_type_%%I!"=="%~1" (
        if /i "!copy_rule_path_%%I!"=="%~2" exit /b 0
    )
)
set /a copy_rule_count+=1
set "copy_rule_type_!copy_rule_count!=%~1"
set "copy_rule_path_!copy_rule_count!=%~2"
exit /b 0

:invalid_arguments
echo Error: expected no argument or one of: plan, task, execute, all.
pause
exit /b 1

:cancelled
echo Operation cancelled.
pause
exit /b 0
