:load_Map <"path\to\filename.ext"> <index> [/r] ModuleID: 3
if not defined raise_Error (
  Echo(Dependency undefined: %%raise_Error%%
  Pause
  Exit /b 1
)
If not "!!" == "" (
  Echo( Setlocal EnableDelayedExpansion must be invoked
  Echo( Prior to calling "%~f0"
  Pause
  Exit /b 1
)

 REM e4.1.3.1: arg 1: source Filepath for maps is invalid
 REM e4.1.3.1:  - or -
 REM e4.1.3.1: Map data does not conform to findstr pattern:
 REM e4.1.3.1: ^:index:lineContent$
 REM e4.1.3.1:  - or -
 REM e4.1.3.1: Destination file is locked for writing.

 REM e1.1.3.2: Prerequiste StrLen macro is missing.

 REM e5.1.3.3: Empty lines are incompatible with the substring indexing of variables
 REM e5.1.3.3:  this camera uses. Use whitespaces equal to the width of the world map
 REM e5.1.3.3:  to implement a line consisting of 'empty' space 

 REM e5.1.3.4: Consistent Line Lengths for Maps are enforced to prevent attempts
 REM e5.1.3.4: to index empty variable space that would result in display errors.
 REM e5.1.3.4: use whitespace to pad map lines until equal length.

 REM e5.1.3.5: Camera quadrant Area post Substitution must not exceed the line
 REM e5.1.3.5:  length limit of:                8192,
 REM e5.1.3.5:  inclusive of %sprites% length.
 REM e5.1.3.5: The safe area limit is:          8100.
 REM e5.1.3.5:  This figure is conservative to allow for density spikes in maps.
 REM e5.1.3.5: Quadrant area substitution densities exceeding 8100 characters
 REM e5.1.3.5:  inclusive of sprite output will be denied execution as exceeding
 REM e5.1.3.5:  this limit results in termination of the conhost process.
 REM e5.1.3.5: Area Substitution density is derived using a floored quadrant
 REM e5.1.3.5:  size [2700], the character density of the map, and a modulated linear
 REM e5.1.3.5:  scaling factor of the number of substitution passes defined.
 REM e5.1.3.5:  - cameras with an area lss 5120 characters are scaled differently to
 REM e5.1.3.5:    accomomadate the extra substitutions afforded by their reduced area.
 REM e5.1.3.5:    the floor is redused to the quadrant areas size, with
 REM e5.1.3.5:    area density scaling on an exponent of the number of substitutions.
 REM e5.1.3.5:    ((((Subs-1)*2)*((Subs-1)*2)))/2

  IF not defined strlen %raise_Error% 3.2 StrLen macro undefined.
  IF not exist "%~f1" %raise_Error% 3.1 Map File does not exist at filepath: "%~f1"
  set "$cam.map.invalid=1"
  Set "$cam.spaces=  "
  For /l %%i in (1 1 5) Do Set "$cam.spaces=!$cam.spaces: =    !"


  Setlocal DISABLEdelayedExpansion

  Set "$cam.extract=0"
  REM DEL "%TEMP%\%~n1_map[%~2].txt"
  If exist "%TEMP%\%~n1_map[%~2].txt" ( set "$cam.map.invalid=" ) else Set "$cam.extract=1"
  If "%~3" == "/r" Set "$cam.extract=1"
  If "%$cam.extract%" == "1" For /f "tokens=2 Delims=+" %%^" in ("+"+"+")Do (
      (Call )
      1> nul 2> nul (Findstr.exe /BRIC:"[:]%~2[:]map[:]" "%~f1")
      If errorlevel 1 Setlocal EnableDelayedExpansion & %raise_Error% 3.1 Map Validation Failed for "%~f1" Map :%~2:.
      1>"%TEMP%\%~n1_map[%~2].txt" (
        For /f "tokens=1,2,* Delims=:" %%G in ('Findstr.exe /BRIC:"[:]%~2[:]map[:]" "%~f1" 2^> nul')Do (
          if defined $cam.map.invalid set "$cam.map.invalid="
          echo(%%~"%%I%%~"
        )
      )
      If not exist "%TEMP%\%~n1_map[%~2].txt" (
        %raise_Error% 3.1 Map could not be written to: "%TEMP%\%~n1_map[%~2].txt"
      )
    )
  )
  <"%TEMP%\%~n1_map[%~2].txt" Set /p "$cam.mapvalidate=" || (
    %raise_Error% 3.1 Pre-existing Map file exists with Incorrectly formatted data%\e%[K^
    %\e%[E%\e%[K Ensure arg 2: "%~2" corresponds to an existing map index^
    %\e%[E%\e%[K Delete "%TEMP%\%~n1_map[%~2].txt" 
  ) 
  Endlocal & set "$cam.map.invalid=%$cam.map.invalid%"
  (Call )
  if defined $cam.map.invalid (
    If exist "%TEMP%\%~n1_map[%~2].txt" (
      Del "%TEMP%\%~n1_map[%~2].txt" 2> nul && (
        %raise_Error% 3.1 file could not be written and has been removed: "%TEMP%\%~n1_map[%~2].txt"
      ) || (
        %raise_Error% 3.1 Map extraction file Access fail. from: "%~f1" to "%TEMP%\%~n1_map[%~2].txt"
      )
    ) Else (
      %raise_Error% 3.1 Unkown error when attempting to extract Map :%~2: from "%~f1" to "%TEMP%\%~n1_map[%~2].txt"
    )
  )
  Set "c.y.max=0"
  Set "$cam.char.count=0"
  For /f "tokens=1,2 delims=:" %%V in ('findstr /lnv "_false_" "%TEMP%\%~n1_map[%~2].txt"') Do (
    Set "#[%%V]=%%W"
    if "!debug!" == "1" Set "#[%%V]=%%W%%W"
    If  "!#[%%V]!" == "" (
      %raise_Error% 3.3 Empty lines not permitted in maps. Line: %%V
    )
    If %%V GTR 1 Set /a $cam.temp=%%V-1
    For /f "delims=" %%i in ("!$cam.temp!") Do (
      %strlen:$len=c.x.max% #[%%V]
      %strlen% #[%%i]
      If not "!$len!" == "!c.x.max!" (
        %raise_Error% 3.4 Inconsistent line lengths detected In World map data.%\E%[K^
        %\E%[E%\E%[K Source file: "%~f1"^
        %\E%[E%\E%[K         Map: "%~2"^
        %\E%[E%\E%[K       Lines: %%i and %%V
      )
    ) 
    Set "$cam.temp=!#[%%V]: =!"
    %strlen% $cam.temp
    Set /a $cam.char.count+=$len  
    If %%V GTR !c.y.max! Set /a c.y.max=%%V
  )

  2> nul Set /a "c.w.test=1 / ((c.x.max-4) %% 4)" && (
    Set /a "c.x.max+=4-(c.x.max %% 4 )"
    Set "c.w.test="
  )

  Call "%~dp0init_ColorMap.cmd" "%~1" "%~2"

  Set "$cam.LinearScale=((x-1)*2)"
  %= approx 2700 floor was derived from testing a variety of sizes and substitution densities. =%
  if !c.qA! LEQ 1280 (
    set /a "x=$cam.subs,$cam.restraint=c.qA+((%$cam.LinearScale% * %$cam.LinearScale%)/2)"
  ) else if !c.qA! LSS 2652 (
    set /a "$cam.restraint=2652+$cam.subs"
  ) else set /a "x=$cam.subs,$cam.restraint=c.qa+%$cam.LinearScale%"

  Set /a "$cam.safeSubs=(($cam.restraint*$cam.mapDensity)/4)+$cam.spr.len"

  If !$cam.safeSubs! GTR 8100 For /f "delims=" %%i in ("!$cam.safeSubs!") Do (
    %raise_Error% 3.5 Map Substitution Density: %%i exceeds safe limit.
  )

exit /b 0

