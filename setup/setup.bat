echo off
set user=%1
shift
shift
powershell ./setup.ps1 %user%