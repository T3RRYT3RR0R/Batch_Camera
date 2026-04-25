@echo off
:init_ColorMap ModuleID: 2
REM TBA [in progress]
REM     to support per map transforms, substitution method needs to be redesigned to allow runtime mappings to be modified.
REM     Redesign will utilize the same for tokenisation method as the camera snipping tools.
 REM defines $cam.push.colorMap
 REM $cam.push.colorMap Usage:
 REM %$cam.push.colorMap% SearchChar VTcolor ReplaceChar

 REM substitutions will be performed in the order they are pushed to the colorMap

 REM e1.1.2.1: Map data must be defined to #[indexes] Psuedo-array prior
 REM e1.1.2.1: to calling init_ColorMap

 REM e2.1.2.2: Missing Arg/s in expansion of %$cam.Push.ColorMap%
 REM e2.1.2.2: Arg1: Search character 
 REM e2.1.2.2: Arg2: VT Sequence
 REM e2.1.2.2: Arg3: Replace character

 Set "$cam.Push.ColorMap="
 REM e5.1.2.3: %$cam.Push.ColorMap%
 REM e5.1.2.3: Unsupported Character in arg1:        SearchCharacter
 REM e5.1.2.3: Characters reserved for VT sequences: 0 1 2 3 4 5 6 7 8 9 [ mM bB gG dD eE
 REM e5.1.2.3: Substitutions are NOT case aware.
 

  if "!\e!" == "" For /f %%E in ('echo prompt $E^|cmd.exe') do set \e=%%E

  Set "$cam.UnsupportedSubs= 0 1 2 3 4 5 6 7 8 9 [ m M B b G g d D e E !\E! "
 
  If not defined #[1] %raise_Error% 2.1 #[indexes] not defined.
 
  For /l %%i in (1 1 4)Do Set "$cam.sub.quad.%%i="

  Set $cam.PUSH.colorMap=for %%n in (1 2)do If %%n == 2 (%\n%
    if not defined args !raise_Error! 2.2 Missing: All.%\n%
    For /f "tokens=1,2,* delims= " %%G in ("^!args^!") Do If "^!$cam.UnsupportedSubs: %%G =^!" == "^!$cam.UnsupportedSubs^!" (%\n%
      If "%%~H" == "" !raise_Error! 2.2 Missing: Arg2 and Arg3%\n%
      If "%%~I" == "" !raise_Error! 2.2 Missing: Arg3%\n%
      For /l %%i in (1 1 4)Do (%\n%
        If defined $cam.sub.quad.%%i (%\n%
          Set "$cam.sub.quad.%%i=^!$cam.sub.quad.%%i^!^&Set $quad.%%i=^^^!$quad.%%i:%%~G=%\e%[%%~Hm%%~I^^^!"%\n%
        ) else (%\n%
          Set $cam.sub.quad.%%i=Set "$quad.%%i=^^^!$quad.%%i:%%~G=%\e%[%%~Hm%%~I^^^!"%\n%
        )%\n%
        Set "$cam.sub.quad.%%i=^!$cam.sub.quad.%%i:\E=%\e%^!"%\n%
      )%\n%
     Set /a "$cam.subs+=1"%\n%
    ) else (%\n%
      !raise_Error! 2.3 Invalid Substitution search candidate: "%%~G"%\n%
    )%\n%
  )Else Set args=
 
  Set "$cam.PUSH.colorMap=!$cam.PUSH.colorMap:  =!"

  Set "$cam.pipe=^^|"
  For /f "tokens=2 Delims=+" %%^" in ("+"+"+")Do For /f "tokens=1,2,* Delims=:" %%O in ('Findstr.exe /BRIC:"[:]%~2[:]transform[:]" "%~f1" 2^> nul')Do (
      %$cam.PUSH.colorMap% %%~"%%~Q%%~"
  )

exit /b 0
