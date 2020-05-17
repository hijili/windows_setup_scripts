cd /d %~dp0
powershell -NoProfile -ExecutionPolicy Unrestricted .\setup.ps1
pause > nul
exit /B 0
