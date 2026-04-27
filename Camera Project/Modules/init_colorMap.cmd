@echo off
:init_ColorMap ModuleID: 2

 REM defines $cam.push.colorMap
 REM $cam.push.colorMap Usage:
 REM %$cam.push.colorMap% SearchChar VTcolor ReplaceChar

 REM substitutions will be performed in the order they are pushed to the colorMap

 REM defines $cam.transforms
 REM used in engine to apply per-map transforms to current screen frame. 

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
 
 REM e5.1.2.4: Too few Substitutions. Minimum of 8 required
 

  if "!\e!" == "" For /f %%E in ('echo prompt $E^|cmd.exe') do set \e=%%E

  Set "$cam.UnsupportedSubs= 0 1 2 3 4 5 6 7 8 9 [ m M B b G g d D e E !\E! "
 
  If not defined #[1] %raise_Error% 2.1 #[indexes] not defined.
 
  For /l %%i in (1 1 4)Do Set "$cam.sub.quad.%%i="
  For /l %%i in (1 1 16)Do Set "$sub.%%i="


  Set $cam.Transforms=For /f "tokens=1-16 delims= " %%k in ("^!$sub.1^! ^!$sub.2^! ^!$sub.3^! ^!$sub.4^! ^!$sub.5^! ^!$sub.6^! ^!$sub.7^! ^!$sub.8^! ^!$sub.9^! ^!$sub.10^! ^!$sub.11^! ^!$sub.12^! ^!$sub.13^! ^!$sub.14^! ^!$sub.15^! ^!$sub.16^!") Do (%\n%
    Set "$quad.1=^!$quad.1:%%~k^!"^&Set "$quad.2=^!$quad.2:%%~k^!"^&Set "$quad.3=^!$quad.3:%%~k^!"^&Set "$quad.4=^!$quad.4:%%~k^!"%\n%
    Set "$quad.1=^!$quad.1:%%~l^!"^&Set "$quad.2=^!$quad.2:%%~l^!"^&Set "$quad.3=^!$quad.3:%%~l^!"^&Set "$quad.4=^!$quad.4:%%~l^!"%\n%
    Set "$quad.1=^!$quad.1:%%~m^!"^&Set "$quad.2=^!$quad.2:%%~m^!"^&Set "$quad.3=^!$quad.3:%%~m^!"^&Set "$quad.4=^!$quad.4:%%~m^!"%\n%
    Set "$quad.1=^!$quad.1:%%~n^!"^&Set "$quad.2=^!$quad.2:%%~n^!"^&Set "$quad.3=^!$quad.3:%%~n^!"^&Set "$quad.4=^!$quad.4:%%~n^!"%\n%
    Set "$quad.1=^!$quad.1:%%~o^!"^&Set "$quad.2=^!$quad.2:%%~o^!"^&Set "$quad.3=^!$quad.3:%%~o^!"^&Set "$quad.4=^!$quad.4:%%~o^!"%\n%
    Set "$quad.1=^!$quad.1:%%~p^!"^&Set "$quad.2=^!$quad.2:%%~p^!"^&Set "$quad.3=^!$quad.3:%%~p^!"^&Set "$quad.4=^!$quad.4:%%~p^!"%\n%
    Set "$quad.1=^!$quad.1:%%~q^!"^&Set "$quad.2=^!$quad.2:%%~q^!"^&Set "$quad.3=^!$quad.3:%%~q^!"^&Set "$quad.4=^!$quad.4:%%~q^!"%\n%
    Set "$quad.1=^!$quad.1:%%~r^!"^&Set "$quad.2=^!$quad.2:%%~r^!"^&Set "$quad.3=^!$quad.3:%%~r^!"^&Set "$quad.4=^!$quad.4:%%~r^!"%\n%
    if not .^^!$sub.9^^! == . Set "$quad.1=^!$quad.1:%%~s^!"^&Set "$quad.2=^!$quad.2:%%~s^!"^&Set "$quad.3=^!$quad.3:%%~s^!"^&Set "$quad.4=^!$quad.4:%%~s^!"%\n%
    if not .^^!$sub.10^^! == . Set "$quad.1=^!$quad.1:%%~t^!"^&Set "$quad.2=^!$quad.2:%%~t^!"^&Set "$quad.3=^!$quad.3:%%~t^!"^&Set "$quad.4=^!$quad.4:%%~t^!"%\n%
    if not .^^!$sub.11^^! == . Set "$quad.1=^!$quad.1:%%~u^!"^&Set "$quad.2=^!$quad.2:%%~u^!"^&Set "$quad.3=^!$quad.3:%%~u^!"^&Set "$quad.4=^!$quad.4:%%~u^!"%\n%
    if not .^^!$sub.12^^! == . Set "$quad.1=^!$quad.1:%%~v^!"^&Set "$quad.2=^!$quad.2:%%~v^!"^&Set "$quad.3=^!$quad.3:%%~v^!"^&Set "$quad.4=^!$quad.4:%%~v^!"%\n%
    if not .^^!$sub.13^^! == . Set "$quad.1=^!$quad.1:%%~w^!"^&Set "$quad.2=^!$quad.2:%%~w^!"^&Set "$quad.3=^!$quad.3:%%~w^!"^&Set "$quad.4=^!$quad.4:%%~w^!"%\n%
    if not .^^!$sub.14^^! == . Set "$quad.1=^!$quad.1:%%~x^!"^&Set "$quad.2=^!$quad.2:%%~x^!"^&Set "$quad.3=^!$quad.3:%%~x^!"^&Set "$quad.4=^!$quad.4:%%~x^!"%\n%
    if not .^^!$sub.15^^! == . Set "$quad.1=^!$quad.1:%%~y^!"^&Set "$quad.2=^!$quad.2:%%~y^!"^&Set "$quad.3=^!$quad.3:%%~y^!"^&Set "$quad.4=^!$quad.4:%%~y^!"%\n%
    if not .^^!$sub.16^^! == . Set "$quad.1=^!$quad.1:%%~z^!"^&Set "$quad.2=^!$quad.2:%%~z^!"^&Set "$quad.3=^!$quad.3:%%~z^!"^&Set "$quad.4=^!$quad.4:%%~z^!"%\n%
  )

  Set "$cam.Transforms=!$cam.Transforms:  =!"

  Set "$cam.subs=0"

  Set $cam.PUSH.colorMap=for %%n in (1 2)do If %%n == 2 (%\n%
    if not defined args !raise_Error! 2.2 Missing: All.%\n%
    For /f "tokens=1,2,* delims= " %%G in ("^!args^!") Do If "^!$cam.UnsupportedSubs: %%G =^!" == "^!$cam.UnsupportedSubs^!" (%\n%
      If "%%~H" == "" !raise_Error! 2.2 Missing: Arg2 and Arg3%\n%
      If "%%~I" == "" !raise_Error! 2.2 Missing: Arg3%\n%
      Set /a "$cam.subs=$cam.subs+1"%\n%
      For /f "delims=" %%v in ("^!$cam.subs^!") Do (%\n%
        Set "$sub.%%v=%%~G=%\e%[%%~Hm%%~I"%\n%
        Set "$sub.%%v=^!$sub.%%v:\E=%\e%^!"%\n%
      )%\n%
    ) else (%\n%
      !raise_Error! 2.3 Invalid Substitution search candidate: "%%~G"%\n%
    )%\n%
  )Else Set args=
 
  Set "$cam.PUSH.colorMap=!$cam.PUSH.colorMap:  =!"

  Set "$cam.pipe=|"
  For /f "tokens=2 Delims=+" %%^" in ("+"+"+")Do For /f "tokens=1,2,* Delims=:" %%O in ('Findstr.exe /BRIC:"[:]%~2[:]transform[:]" "%~f1" 2^> nul')Do ( 
     %$cam.PUSH.colorMap% %%~"%%~Q%%~"
  )

  If !$cam.subs! LSS 8 %raise_Error% 2.4 Substitutions Used: %$cam.subs% in map:"%~2" file "%~f1"%\n%

exit /b 0
