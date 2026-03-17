:Get_AspectRatio ModuleID: 4
if not defined raise_Error (
  Echo(Dependency undefined: %%raise_Error%%
  Pause
  Exit /b 1
)
If not "!!" == "" (
  Echo Setlocal EnableDelayedExpansion must be invoked before calling "%~n0"
  Pause
  Exit /b 1
)

REM e2.1.4.1: Argument Mandatory.
REM e1.1.4.2: Argument lacks expected definition
REM e5.1.4.3: Agrument must be defined with an integer value.

If "%~1" == "" %raise_Error% 4.1 Arg1: Y
If "%~2" == "" %raise_Error% 4.1 Arg2: X
If "%~3" == "" %raise_Error% 4.1 Arg3: Y returnVar
If "%~4" == "" %raise_Error% 4.1 Arg4: X returnVar

If "!%~1!" == "" %raise_Error% 4.2 Arg1: "%~1"
If "!%~2!" == "" %raise_Error% 4.2 Arg2: "%~2"

%raise_Error.Int% 4.3 "%~1"
%raise_Error.Int% 4.3 "%~2"

  Setlocal EnableDelayedExpansion
  If !%~1!0 GTR !%~2!0 (
     Set /a "large=%~1,small=%~2"
  ) else Set /a "large=%~2,small=%~1"

  :repeatDiv_Get_AspectRatio
    For /l %%i in (1 1 !small!) Do (
      Set /a "remainder=!large! - (!small!*%%i)"
      Set "remainder=!remainder:-=!"
      If !remainder! EQU 0 (
        for /f "delims=" %%v in ("!small!") do Endlocal & Set /a "%~3=%~1/%%v,%~4=%~2/%%v,%~3.real=((%~1/%%v)/2)"
        exit /b 0
      )
      Set /a large=!small!,small=!remainder!
      Goto:repeatDiv_Get_AspectRatio
    )
Goto:repeatDiv_Get_AspectRatio

:raise_Error.int ModuleID: 0
REM e5.1.0.0: Argument missing.
