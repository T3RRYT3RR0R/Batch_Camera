@echo off & CD /d "%~dp0"

if not exist "..\modules\init_menu.cmd" (
  echo("%~nx0" requires init_menu.cmd to exist in ..\modules
  Pause
  exit /b 1
)

Call "..\modules\init_menu.cmd"

Set "files="
Setlocal EnableDelayedExpansion
For /f "delims=" %%G in ('Findstr.exe /MBRIC:"[:][0123456789]*[:]" "*.txt"') Do Set Files=!files! "%%~G"
Endlocal & Set "files=%files:~1%"

%menu:Header= Select Source file: % %files% exit
set file=%menu{string}%

Set "IDs= "
Setlocal EnableDelayedExpansion
For /f "tokens=1,* delims=:" %%G in ('Findstr.exe /BRIC:"[:][0123456789]*[:]" "%file%"') Do if "!IDs: %%G =!" == "!IDs!" Set "IDs=!IDs!%%~G "

%menu:Header= Select source ID: % %IDs%
Set "ID=%menu{string}: =%"

:oID
Call:GetNum oID "Output map ID"
if errorlevel 1 exit /b 1

%menu:Header= Select output destination% "output to source" "enter custom destination"
If "%menu{number}%" == "1" (
  set "oFile=%file%"
  Goto:SkipOut
)

:outFile
Set "oFile="
Set /p "oFile= Enter outfile name" || Goto:outFile

:SkipOut
If exist "%oFile%" (
  Set write=^>^>
)else Set write=^>

Set "tID=%oID%"
:UniqueID
If exist "%oFile%" (
  For /f "tokens=1,* Delims=:" %%G in ('Findstr.exe /BRIC:"[:]%oID%[:]" "%oFile%" 2^> nul')Do (
    Set /a oID+=1
    Goto:UniqueID
  )
)
If not "%oID%" == "%tID%" Echo(Output ID %tID% existed. Overridden to: %oID%

chcp 65001 1> nul

%write%"%~dp0%oFile%" (
  Echo(
  For /f "tokens=2 Delims=+" %%^" in ("+"+"+")Do For /f "tokens=1,* Delims=:" %%G in ('Findstr.exe /BRIC:"[:]%ID%[:]" "%file%" 2^> nul')Do (
    <nul Set /p "=:%oID%:"
    Echo(%%~"%%H%%~"
  )
)
Pause
Goto:Eof

:GetNum
Set "%~1=" || exit /b 1
Set /P "%~1=Confirm %~2 ID :#: " || Goto:GetNum
2> nul Set /a "1/%~1" || Goto:GetNum
Setlocal EnableDelayedExpansion
For /f "delims=0123456789" %%G in ("!%~1!") Do (Endlocal & Goto:GetNum)
Endlocal
exit /b 0