@echo off
rem Wrapper to launch snapshot_agent.ps1 in -Loop mode.
rem Spawning a detached PowerShell loop via Start-Process directly is unreliable on PS 5.1
rem (the loop dies within seconds under -WindowStyle Hidden + -File + persistent loop).
rem Routing through cmd.exe with this batch makes the child genuinely detached.
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0snapshot_agent.ps1" -Loop -LoopIntervalMin 15
