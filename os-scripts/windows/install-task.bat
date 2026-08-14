@echo off
chcp 65001 >nul
call "%~dp0install-work.bat" task
exit /b %errorlevel%
