@echo off
chcp 65001 >nul
setlocal

set "source_file=%~dp0AGENTS.md"
set "source_work=%~dp0work"
set "source_skills=%~dp0skills"

if not exist "%source_file%" (
    echo Error: source file not found: "%source_file%".
    pause
    exit /b 1
)

if not exist "%source_work%\" (
    echo Error: work source directory not found: "%source_work%"
    pause
    exit /b 1
)

if not exist "%source_skills%\" (
    echo Error: skills source directory not found: "%source_skills%"
    pause
    exit /b 1
)

:prompt_directory
set "target_directory="
set /p "target_directory=Enter the target directory: "
set "target_directory=%target_directory:"=%"

if not defined target_directory (
    echo The directory cannot be empty. Please try again.
    goto prompt_directory
)

if not exist "%target_directory%\" goto confirm_create
goto check_target_file

:confirm_create
choice /c YN /n /m "The directory does not exist. Create it? [Y/N] "
if errorlevel 2 goto cancelled
mkdir "%target_directory%"
if errorlevel 1 goto failed_create

:check_target_file
if not exist "%target_directory%\AGENTS.md" goto check_target_work
choice /c YN /n /m "AGENTS.md already exists in the target directory. Overwrite it? [Y/N] "
if errorlevel 2 goto cancelled

:check_target_work
if not exist "%target_directory%\work\" goto check_target_skills
choice /c YN /n /m "The work directory already exists. Merge and overwrite matching files? [Y/N] "
if errorlevel 2 goto cancelled

:check_target_skills
if not exist "%target_directory%\skills\" goto copy_files
choice /c YN /n /m "The skills directory already exists. Merge and overwrite matching files? [Y/N] "
if errorlevel 2 goto cancelled

:copy_files
copy /Y "%source_file%" "%target_directory%\AGENTS.md" >nul
if errorlevel 1 goto failed_copy
xcopy "%source_work%\*" "%target_directory%\work\" /E /I /Y /Q >nul
if errorlevel 1 goto failed_work_copy
xcopy "%source_skills%\*" "%target_directory%\skills\" /E /I /Y /Q >nul
if errorlevel 1 goto failed_skills_copy
echo AGENTS.md, work, and skills were copied to "%target_directory%".
pause
exit /b 0

:failed_create
echo Error: failed to create the directory "%target_directory%".
pause
exit /b 1

:failed_copy
echo Error: failed to copy AGENTS.md.
pause
exit /b 1

:failed_work_copy
echo Error: failed to copy the work directory.
pause
exit /b 1

:failed_skills_copy
echo Error: failed to copy the skills directory.
pause
exit /b 1

:cancelled
echo Operation cancelled.
pause
exit /b 0
