:CongfigureCamera ModuleID: 6

REM Module responsibilities:
REM handle selection of camera size
REM declare font size and name and invoke SetFont to apply
REM configure the variables used to construct the camera macro
REM assign variables used for camera / player control, bounding
REM assign FPS target

REM e5.1.6.0 Expected format for Sizes List, Where Height and width are integers:
REM e5.1.6.0 "Height x Width" "Height x Width" ...
If not defined raise_Error (
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

%= DEPENDENCY - FORMATED MENU SELECTION TOOL =%
  Call "%~dp0init_menu.cmd"
  If errorlevel 1 exit /b %errorlevel%

%= Apply desired Font =%
  Call "%~dp0setFont.cmd" 10 "Cascadia Code"
  If errorlevel 1 exit /b %errorlevel%

REM default size applied.
Set $cam.Sizes=%* "40 x 200"

(%= STRUCTURED DATA Do Not Modify =%
  If not defined $cam.Sizes %raise_Error% 1.0 expected Variable: '$cam.Sizes' not defined.
  Set "$cam.Sizes="

  %= Iterate sizes list and rebuild as formated display for menu selection =%
  for %%G in (%$cam.Sizes%) Do (Set "$cam.sizesValid="
    For /f "tokens=1,2,3" %%H in ("%%~G") Do (%= Bound camera dimensions to map maximums =%
      %raise_Error.int:NoVar=% 6.0 %%~H
      If /i not "%%~I" == "x" %raise_Error% 6.0 Expected: X in place of "%%~I" in Size option "%%~G"
      %raise_Error.int:NoVar=% 6.0 %%~J
      Set "$cam.sizesValid=1"
      set /a "c.w=%%J,x=c.w,low=20,high=c.x.max,c.w=%clamp%",^
             "c.h=%%H,x=c.h,low=10,high=60,c.h=%clamp%",^
             "$cam.Hadj=c.h*2,c.a=c.w*c.h,c.qA=c.A/4"
    )
    (Call )
    2> nul (%= enforce multiple of 4 to camera width for segmentation =%
      Set /a "c.w.test=1 / (c.w %% 4)" && (
        Set /a "c.w+=4-(c.w %% 4 ),c.a=c.w*c.h,c.qA=c.A/4"
        Set "c.w.test="
      )
    )
    if not defined $cam.sizesValid %raise_Error% 6.0 no valid Arguments in $cam.Sizes set '%%G'

                                  %= Y            X            returnY    returnX   =%
    Call "%~dp0\Get_AspectRatio.cmd" $cam.Hadj    c.w          $cam.Har   $cam.War
    If errorlevel 1 (%= preserve errorlevel =%
      Call set "$cam.return=%%errorlevel%%"
      Setlocal EnableDelayedExpansion
      For /f "delims=" %%e in ("!$cam.return!") Do (
        Endlocal & Exit /b %%~e
      )
    )

    %= enforce y axis splitting for y dominant aspect ratio =%
    Set "$cam.splitmode="
    If !$cam.Har! GTR !$cam.War! Set "$cam.splitmode=y"
    %= enforce y axis splitting if required to extend camera height =%
    If !c.H! GTR 56 If !c.H! LEQ 60 Set "$cam.splitmode=y"
    If not defined $cam.splitmode Set "$cam.splitmode=x"

    %= map dimensions likely to exceed substitution density area requirement are rejected =%
    if not !c.A! GTR 10600 (
      Set "$cam.temp=!c.h! x !c.w!"
      %= tokens          1       2++3        4      5        6       7     8      9        10         11         12 =%
      Set Sizes=!Sizes! "!\e![33m!$cam.temp! !\e![0m=!\e![36m!\e![1m !c.A! !\e![0m!\e![30m !$cam.Har!:!$cam.War! !$cam.splitmode:x=w! !\e![0m"
    )
) )

  Set "$menu.Header=!\e![0;36mChoose the display size!\E![E * A smaller display area will offer better FPS performance.!\e![E!\e![33m    Y  * X   !\e![0m= !\e![36m!\E![1mArea!\E![22m!\e![0m"

  %menu:Header=!$menu.Header!%!Sizes! Exit

  %= extract Structured Data from selected display sequence =%
  For /f "tokens=2,3,7,10,11,12 Delims=:mx " %%i in ("!menu{string}!") Do (
    Set /a c.H=%%i,c.W=%%j,c.A=%%k,$cam.Har=%%l,$cam.War=%%m
    Set "$cam.splitmode=%%n"
    Set "$cam.splitmode=!$cam.splitmode:w=x!"
  )

  Set /a "c.x=0,c.y=1"

REM - METADATA RESERVATION =======================================================
REM this camera uses tokenised data to construct the camera view.
REM camera Y data [list/s containing variables that index the current Y positions]
REM exists at the 'tail' of the tokenising for loop/s [ $cam.Ydata $cam.Ydata2 ] 
REM to include additional metadata in the camera data ie expansion of pseudo-array
REM indices for animations etc, APPEND THE ESCAPED REFERENCE VARIABLE TO: Reserved.tokens
REM IMPORTANT: each additional token will reduce the maximum possible camera height.


  If "!$cam.splitmode!" == "y" Set "Reserved.tokens=^!c.x^! ^!c.w^!"
  If "!$cam.splitmode!" == "x" Set "Reserved.tokens=^!c.x.q[1]^! ^!c.x.q[2]^! ^!c.x.q[3]^! ^!c.x.q[4]^! ^!c.x.q^!"
  If defined animation.tokens Set "Reserved.tokens=!Reserved.tokens! !animation.tokens!"
  Set "$cam.metaData.tokenCount=0"
  For %%G in (!Reserved.tokens!) Do (
    Set /a "$cam.metaData.tokenCount+=1"
  )

  Set /a $cam.metavarTransition=31-$cam.metaData.tokenCount
  Set /a $cam.metavarTransition.SubstringOffset=$cam.metavarTransition + 1
  Set /a $cam.metavarRestrictedHeight=62-$cam.metaData.tokenCount
  Set /a "c.x.home=1","c.y.home=1","c.x.min=1","c.y.min=1"

REM This implementation is restricted to a maximum camera height of 62-metadata.tokenCount lines
REM IE: || Singularly nested for /f loop tokens = [31+31] - metadata.tokenCount [2|5] = 59|57 
REM Note: minimum metadata.tokenCount depends on $cam.splitmode, which is derived based on
REM       the effective aspect ratio.

REM  - console columns are 1 indexed
REM substring 0 indexing and VT x positioning via absolute column \e[nG do not align hence +1 offseting.
  REM tested to support an area of up to 8816 characters
  REM substituitons / VT sequences used may reduce the maximum map area that can be supported

REM Note: $cam.metavarRestrictedHeight is a stability and performance restriction limit.
  If !c.h! GTR !$cam.metavarRestrictedHeight! Set /a c.h=$cam.metavarRestrictedHeight

  %= - DO NOT MODIFY - CAMERA OPERATION AND PROPERTY VARIABLES =%
  Set /a "c.A=c.H*c.W,c.qA=c.A/4,$cam.m.A=c.x.max*c.y.max,c.x.q=c.w/4,c.y.q=c.h/4"
  Set /a "c.bX=(c.x.max-c.w)","c.bY=(c.y.max-c.h)",^
         "$cam.mapDensity=(($cam.char.count+(($cam.char.count/100)*10)) * 100)/$cam.m.A"

  If !c.bX! == 0 Set /a c.bX=0,c.x=0
  If !c.bY! == 0 Set /a "c.bY=1,c.y=1" %= prevents 0 indexing of #[array] in event camera height equ map height =%

  %= 24 20 and 16 fps correspond to meaningful centisecond tDiffs 4 5 and 6 respectfully =%
  Set /a "tFPS=24","FPS=100/(tFPS)" %= <-- DEFINE FRAMERATE target by modifing tFPS =%

  %unload:macro=menu%

exit /b 0