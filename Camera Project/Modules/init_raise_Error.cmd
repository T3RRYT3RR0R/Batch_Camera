:init_raise_Error ModuleID: 0
REM scripts using raise_Error.int Must contain the following two lines.
:raise_Error.int ModuleID: 0
REM e5.1.0.0: Argument missing.

%= DEPENDENCY =% If not "!!" == "" (
  Echo( Setlocal EnableDelayedExpansion must be invoked
  Echo( Prior to calling "%~f0"
  Pause
  Exit /b 1
)

%= DEPENDENCY =% For /f %%e in ('echo prompt $E^|%Comspec%') Do Set "\e=%%e"

%= DEPENDENCY =% (Set \n=^^^

%= Do not modify this escaped Newline definition =%)
 
REM raise_Error is defined into other macros. It should not be modified as
REM  an increase to its size can result in variable overflow in those defintions.
REM The defined size of this macro is 1993 characters.
REM  Macros that embed raise_Error should consider this when doing so.
REM  Recommendation: Use state flagging and message definitions to build Raise_Error
REM    arguments within a macro, and embed at the end of the host macro to
REM    Raise_Error once only. A For /F loop will be required to expand the argument string.

  Set "raise_error.File=%~f0"
  Set raise_error.log="%temp%\raise_Error_Environment.log"
  Set raise_Error=For %%n in (1 2) Do if %%n==2 (%\n%
    Call Set "raise_error.host=%%~f0"%\n%
    Set "raise_Error.OK="%\n%
    Setlocal EnableDelayedExpansion%\n%
     For /f "delims=" %%S in ("^!raise_error.host^!") Do For /f "tokens=1,2,* Delims=. " %%G in ("^!args^! ^^^!%= ! Guards against empty Args  =%") Do Endlocal ^& (%\n%
      Set "raise_Errored="%\n%
      For /f "tokens=2,3,4,5,* delims=e:. " %%B in ('%systemroot%\system32\findstr.exe /RIC:"REM e[0123456789]\.[0123456789]\.%%G\.%%H" "%%S"') Do (%\n%
        If not "%%~H" == "" Set "raise_Error.OK=1"%\n%
        If not defined raise_Errored (%\n%
          Set "raise_Errored=1"%\n%
          For /f "tokens=1,2,3,* Delims=e.: " %%0 in ('%systemroot%\system32\findstr.exe /RIC:"REM=u %%B\.%%C[:]" "%raise_error.File%"') Do (%\n%
            Set /a "raise_Error.T=%%1","raise_Error.S=%%2"%\n%
            Echo( %%3%\n%
          )%\n%
          Setlocal EnableDelayedExpansion%\n%
          Echo(%\n%
          Set "raise_error.Found="%\n%
          For /f "tokens=1 Delims==: " %%T in ('%systemroot%\system32\findstr.exe /RIC:"ModuleID[:] %%D" "%%S"') Do (%\n%
             Echo( Error raised by: "%%T" in: "%%S"%\e%[E%\n%
             Set "raise_error.Found=1"%\n%
          )%\n%
          If not defined raise_error.Found Echo( Error raised by: %%~nS%= unspecified module =%%\n%
          Echo( Error Type: ^^!raise_Error.T^^! Severity: ^^!raise_Error.S^^! Module: %%D ID: %%E%\n%
          Echo(%\n%
          Endlocal%\n%
          Echo(%\e%[48;2;120;120;150m%\e%[38;2;0;0;0m %%I%\e%[K%\n%
          Echo(%\e%[0m%\n%
        )%\n%
        Echo( %%F%\n%
      )%\n%
      Echo(%\n%
      If not defined raise_Error.OK (Echo Undefined Lookup table: e#.#.%%G.%%H%\n%
        For /f "tokens=1,* Delims=u" %%V in ('%systemroot%\system32\findstr.exe /BRIC:"REM=u" "%raise_Error.File%"') Do Echo(%%W%\n%
        PAUSE ^& Exit /b 1%\n%
      )%\n%
      Echo(environment data available in %raise_error.log%%\n%
      Set /a "raise_error#=(%%G*100)+%%H"%\n%
      Pause%\n%
      Setlocal EnableDelayedExpansion%\n%
      if "^!raise_error#^!" == "0" set "raise_error#=1"%\n%
      For /f "delims=" %%e in ("^!raise_error#^!") Do Endlocal ^& Exit /b %%e%\n%
    )%\n%
  ) Else Set "" ^>"%raise_error.log%" ^& Endlocal ^& Setlocal DisableDelayedExpansion ^& Set Args=

Set "raise_Error=!raise_Error:  =!"
Set "raise_Error=!raise_Error:) Do =)Do !"
Set "raise_Error=!raise_Error: &=&!"

REM usage: %raise_Error.Int% <moduleNumber.ErrorSequenceNumber> <TestValue-Or-VariableName>
Set raise_Error.Int=For %%n in (1 2) do if %%n == 2 (Set "Raise_ErrorNoArgs="%\n%
  For /f "tokens=1,2 delims= " %%o in ("^!args^! Missing Missing") Do (%\n%
    If /i "%%~o" == "Missing" Set "Raise_ErrorNoArgs=1"%\n%
    If /i "%%~p" == "Missing" Set "Raise_ErrorNoArgs=2"%\n%
    If defined Raise_ErrorNoArgs (!raise_Error! 0.0 Invalid. arg1="%%~o" arg2="%%~p"%\n%
    Exit /b 1)%\n%
    2> nul Set /a "raise_Error.tmp=%%~p" ^|^| Set "raise_Error.tmp=0"%\n%
    For /f "delims=0123456789" %%V in ("%%~p") Do (%\n%
      if "^!%%~p^!" == "" ( Set "raise_Error.tmp=0" ^& Set "%%~p=unassigned" )%\n%
      if "NoVar" == "" ( Set "raise_Error.tmp=0" ^& Set "%%~p=Variable reference Prohibited" )%\n%
    )%\n%
    If not "^!%%~p^!" == "" if not "^!%%~p^!" == "^!raise_Error.tmp^!" if not "^!%%~p:~0,2^!" == "0x" Set "raise_Error.tmp=0"%\n%
    If "^!raise_Error.tmp^!" == "0" For /f "delims=" %%V in ("^!%%~p^!") do (%\n%
      !raise_Error! 0.0 %%o Invalid: Variable:"%%~p"="%%V"%\n%
    )%\n%
  )%\n%
) else set args=

Set "raise_Error.int=!raise_Error.int:  =!"
Set "raise_Error.int=!raise_Error.int:) Do =)Do !"
Set "raise_Error.int=!raise_Error.int: &=&!"


exit /b 0

REM=u raise_Error help file
REM=u 
REM=u Usage of error system:
REM=u 
REM=u Declare Module identifier with callable functions
REM=u :FunctionName [module usage info] ModuleID: ModuleIdentifier
REM=u 
REM=u Declare error lookup data for ModuleIdentifier.SequentialErrorID
REM=u REM eType.Severity.ModuleIdentifier.SequentialErrorID: description of generic error details / usage / resolution
REM=u 
REM=u IE:  
REM=u REM en.n.n.n error help info
REM=u 
REM=u test condition and activate lookup with error specific message
REM=u if not "condition" == "expected" %raise_Error% ModuleIdentifier.SequentialErrorID Your_Specific_error_messsage
REM=u 
REM=u After calling a function module, use:
REM=u if errorlevel 1 exit /b %errorlevel%
REM=u Note: the raise_Error macro executes endlocal upon the callers environment
REM=u       when activated by the condition
REM=u 
REM=u Type.Severity Lookup table
REM=u 1.1: Undefined Variable  - Execution Denied
REM=u 1.1:                       Variable use case is not considered compatable with assuming a default value.
REM=u 2.1: Missing Argument    - Execution Denied.
REM=u 3.1: Missing Dependency  - Execution Denied.
REM=u 4.1: File error          - Execution Denied.
REM=u 4.1:                       File not found / Data not found in file / File unwriteable
REM=u 5.1: Formatting error    - Execution Denied. 
REM=u 5.1:                       Data does not meet the formatting or type requirements.
REM=u Note:
REM=u Severity 0 should not use raise_Error
REM=u          0 would indicate a non-breaking / default applicable state.
REM=u          This macro is intended to notify breaking errors and abort the script.
REM=u Severity is a reserved system for later expansion.
REM=u 
REM=u Lookup tables will not be found in the context of a Called Script if the
REM=u Call was made without the fully qualified filepath ( inclusive of extension ).
REM=u 
