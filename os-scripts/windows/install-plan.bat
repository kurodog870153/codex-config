@echo off
chcp 65001 >nul
call "%~dp0install-work.bat" plan
exit /b %errorlevel%
