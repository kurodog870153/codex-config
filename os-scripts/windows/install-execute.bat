@echo off
chcp 65001 >nul
call "%~dp0install-work.bat" execute
exit /b %errorlevel%
