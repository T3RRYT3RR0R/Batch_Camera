@Echo off & cls
REM expected file encoding is bomless utf-8
REM Font used is Cascadia Code size 10 - SetFont by IcarusLives is used to assign this font.
REM This font represents UTF-8 Glyphs well across all sizes.

REM Author: T3RRYT3RR0R aka T3RRY or T3RR0R
REM This project includes Macros authored by:
REM Einst IcarusLives and Aacini
REM Time elapsed mechanism By dBenham - refined by aGerman
REM   https://www.dostips.com/forum/viewtopic.php?t=4741#p27330
REM   https://archive.is/Y6hgZ

:main ModuleID: 1
cd /d "%~dp0"
Setlocal EnableExtensions EnableDelayedexpansion
%= Prepare a clean and minimal Environment by undefining all but minimally required variables =%
 if not defined temp if defined tmp set "temp=!tmp!"
 Set "PathExt=.COM;.BAT;.CMD;.EXE"
 Set "exclude= temp PathExt comspec winDir cmdcmdline systemroot exclude "
 2> nul (
   for /f "tokens=1 delims==" %%G in ('Set') Do If "!exclude:%%~G=!" == "!exclude!" Set "%%~G="
   Set "exclude="
 )

REM to activate debugging define debug below
Set "debug=1" %= demo currently clones map horizontally using this assignment =%

Set unload=for /f "Tokens=1 delims==" %%G in ('Set macro') Do 2^> nul Set "%%G="

%= DEPENDENCIES are TOP LEVEL and may be required in module scripts =%
%= DEPENDENCY - \n used for Multiline Macros =% (Set \n=^^^

%= do not modify this \n definition =%)

%= DEPENDENCY - Virtual Terminal Sequences =% for /f %%e in ('echo prompt $E^|%comspec%') Do Set \e=%%e

  REM clamp macro Authored by IcarusLives and Aacini
  REM clamp Usage: || Set /a "x=VarToClamp, low=minValue, high=maxValue, VarToClamp=%clamp%"
  REM used to bound player and map and apply configuration defaults
%= DEPENDENCY - Value Range Bounding =%  Set "clamp= (leq=((low-(x))>>31)+1)*low  +  (geq=(((x)-high)>>31)+1)*high  +  ^^^!(leq+geq)*(x) "

%= DEPENDENCY - Error Logging. =%
  Call "%~dp0Modules\init_raise_Error.cmd"
  If errorlevel 1 exit /b %errorlevel%
:raise_Error.int ModuleID: 0
REM e5.1.0.0: Argument missing.

%= DEPENDENCY - String content discovery  =%
  Call "%~dp0Modules\init_strlen.cmd"
  If errorlevel 1 exit /b %errorlevel%

%= DEPENDENCY - Utf-8 =%
  chcp 65001 1> nul


REM TBA inspect Load_Map and confirm c. bounding variables are
REM     all defined to facilitate on-the-fly map changes 
%= DEFINES PREREQUISITE VARIABLES THAT CONSTRAIN SIZE SELECTION =%
  If "!debug!" == "1" ( Set "$cam.LoadSwitch=/r" ) Else Set "$cam.LoadSwitch="
  %=          filepath    MapID           Reset[Development_Testing] =%
  Call "%~dp0Modules\load_Map.cmd" "%~f0"        1           %$cam.LoadSwitch%
  If errorlevel 1 exit /b %errorlevel%

  Call "%~dp0Modules\Config_Camera.cmd" "40 x 125" "57 x 100" "27 x 148" "27 x 320" "40 x 252" "60 x 176"
  If errorlevel 1 exit /b %errorlevel%

REM optionally append tokens in the form Set "Animation.tokens=^!VarName^! ^!AnotherVarName^!"
REM to inlude animation reference variables into the camera expansion macro  
Set "Animation.tokens="

REM e1.1.1.1:     Appended Reserved.tokens that are undefined at runtime are prohibited
REM e1.1.1.1:     to prevent misalignment of expansion expressions, which
REM e1.1.1.1:     fail as an attempt to extract a substring from empty variables.
REM e1.1.1.1: IE, outputting the literal form of:
REM e1.1.1.1:     !#[int]:~offset:retain!!#[int]:~offset:retain!!#[int]:~offset:retain!...


%= EXAMPLE OF DEFINING A SPRITE ENTITY =%
Set "Player=%\e%[7;^!p.c^!m%\e%[^!p.Y1^!;^!p.x^!H▓▓▓%\e%[^!p.Y2^!;^!p.x^!H^!p.occupied:~3,3^!%\e%[^!p.Y3^!;^!p.x^!H^!p.occupied:~6,3^!%\e%[^!p.u^!;^!p.x^!H^!p.above^!%\e%[48;2;^!Map.bgc^!;27m"
REM %sprites% are appended each $quad.n echo like an overlay to eliminate flickering.
REM           IE: Echo(!$quad.1!%sprites%
REM the number and complexity of sprites will reduce the maximum possible area / substitutions possible.

%= APPEND ANY SPRITE ENTITY TO THE sprites VARIABLE =%
%= MAXIMUM SUPPORTED CAMERA AREA WIL BE REDUCED BY A VOLUME EQUAL TO THE LENGTH OF THIS VARIABLE =% 
Set "sprites=!Player!"

  %= capture expected strlen cost of sprites variable =%
  set "$cam.sprite=%sprites%"
  %strlen:$len=$cam.spr.len% c.sprite

  %= ENFORCE DEFINITION OF c.x AND c.y =%
  If not defined c.y Set /a c.y=1
  If not defined c.x Set /a c.x=1

  %= ENFORCE TYPING AND BOUNDING OF DEFINITION =%
  Set /a x=c.x,low=0,high=c.bX,"c.x=%clamp%"
  Set /a x=c.y,low=1,high=c.bY,"c.y=%clamp%"
  cls
  Set /a con.h=c.h+5
mode !c.w!,!con.h!

==============================================

REM $shift.y $shift.y macro's update camera X or Y position arrays.
REM USEAGE: || Set /a "c.x[+|-]=1,x=c.x,low=c.x.min,high=c.x.max,c.x=%clamp%,%$shift.x%"
REM USEAGE: || Set /a "c.y[+|-]=1,x=c.y,low=c.y.min,high=c.y.max,c.y=%clamp%,%$shift.y%"
REM   Note: || '[ ]' demarks a Set of options. '|' indicates the options are mutually exclusive.
REM substring extraction fails when the operation is performed on an undefined variable
REM clamp ensures the camera view remains within the dimensions of the map

%= defines $shift.y and $shift.x expressions to handle modification of c.x.q[i] and c.yi List elements =%
Set "$shift.y="
Set "$shift.x="
Set "$cam.Ydata="
Set "$cam.Ydata2="
For /l %%i in (1 1 !c.h!) do (
  If %%i == 1 (
    Set "$shift.y=c.y1=c.y"
    Set "$shift.x=c.x.q[%%i]=c.x"
  ) else (
    Set /a "$cam.temp.offset=%%i-1","$cam.x.offset=(%%i-1)*c.x.q"
    If %%i lss 5 Set "$shift.x=!$shift.x!,c.x.q[%%i]=c.x+!$cam.x.offset!" 
    Set "$shift.y=!$shift.y!,c.y%%i=c.y+!$cam.temp.offset!"
  )
  If %%i LEQ !$cam.metavarTransition! (
    Set "$cam.Ydata=!$cam.Ydata! ^!c.y%%i^!"
  ) else Set "$cam.Ydata2=!$cam.Ydata2! ^!c.y%%i^!"
  Set /a "c.y%%i=(%%i+c.y)-1"
)

REM segment camera quardants based on aspect ratio
Call:Cam.%$cam.splitmode%_init


%= ColorMap is not integral to the Camera system    =%
%= It is just a means of facilitating Substitutions =%
%= of each $quad.i segment                          =%
%= If not used, define $cam.subs with a value of 1  =%
call:init_cam.ColorMap
If errorlevel 1 exit /b %errorlevel%

REM performance and maximum area are impacted by the number of substitutions applied
REM 12 mappings should provide decent performance for most users

Set "$cam.pipe=^^|"

If not defined reject.substitutions (
  %$cam.PUSH.colorMap% + 38;5;114 ░
  %$cam.PUSH.colorMap% - 38;5;115 ▀
  %$cam.PUSH.colorMap% i 38;2;180;180;120 ▄
  %$cam.PUSH.colorMap% / 38;5;190 /
  %$cam.PUSH.colorMap% \ 38;5;190 \
  %$cam.PUSH.colorMap% _ 38;5;190 %\e%[4m_%\e%[24m
  %$cam.PUSH.colorMap% !$cam.pipe! 38;5;190 !$cam.pipe!
  %$cam.PUSH.colorMap% v 38;2;190;130;80 ▒
  %$cam.PUSH.colorMap% w 38;5;36 §
  %$cam.PUSH.colorMap% n 5;38;5;36 §%\e%[25m
  %$cam.PUSH.colorMap% O 38;5;133 ▒
  %$cam.PUSH.colorMap% R 31 ▒
  %$cam.PUSH.colorMap% { 32 \
  %$cam.PUSH.colorMap% } 32 /
  %$cam.PUSH.colorMap% ¦ 38;5;94 ▒
  %$cam.PUSH.colorMap% @ 34 @
)

REM e5.1.1.2: Camera quadrant Area post Substitution must not exceed the line
REM e5.1.1.2:  length limit of:                8192,
REM e5.1.1.2:  inclusive of %sprites% length.
REM e5.1.1.2: The safe area limit is:          8100.
REM e5.1.1.2:  This figure is conservative to allow for density spikes in maps.
REM e5.1.1.2: Quadrant area substitution densities exceeding 8100 characters
REM e5.1.1.2:  inclusive of sprite output will be denied execution as exceeding
REM e5.1.1.2:  this limit results in termination of the conhost process.
REM e5.1.1.2: Area Substitution density is derived using a floored quadrant
REM e5.1.1.2:  size [2700], the character density of the map, and a modulated linear
REM e5.1.1.2:  scaling factor of the number of substitution passes defined.
REM e5.1.1.2:  - cameras with an area lss 5120 characters are scaled differently to
REM e5.1.1.2:    accomomadate the extra substitutions afforded by their reduced area.
REM e5.1.1.2:    the floor is redused to the quadrant areas size, with
REM e5.1.1.2:    area density scaling on an exponent of the number of substitutions.
REM e5.1.1.2:    ((((Subs-1)*2)*((Subs-1)*2)))/2

  Set "$cam.LinearScale=((x-1)*2)"
  %= approx 2700 floor was derived from testing a variety of sizes and substitution densities. =%
  if !c.qA! LEQ 1280 (
    set /a "x=$cam.subs,$cam.restraint=c.qA+((%$cam.LinearScale% * %$cam.LinearScale%)/2)"
  ) else if !c.qA! LSS 2652 (
    set /a "$cam.restraint=2652+$cam.subs"
  ) else set /a "x=$cam.subs,$cam.restraint=c.qa+%$cam.LinearScale%"

  Set /a "$cam.safeSubs=(($cam.restraint*$cam.mapDensity)/4)+$cam.spr.len"

  If !$cam.safeSubs! GTR 8100 For /f "delims=" %%i in ("!$cam.safeSubs!") Do (
    %raise_Error% 1.2 Camera Area Substitution Density: %%i exceeds safe limit.
  )

%= suppress cursor icon output =%
  Echo(%\e%[?25l

REM functional demonstrations
  %= initialise a 3x3 clipping tool for entity-map collisioning =%
  Call:Construct.$cam.clip 3 3

  Set /a p.x=10,p.y=2,p.w=3,p.h=3,p.c=32
  %= reject execution in event missing variable would trigger metavariable misalignment =%


  For %%G in (!reserved.tokens!) do if "%%G" == "" (
    %raise_Error% 1.1 token: %%G in reserved.tokens
  )


( %= Preloading engine / gameloop into the environment prior to execution by   =%
  %= wrapping in parentheses. facilitates enviroment unloading while retaining =%
  %= access to macros / variables using percent expansion =%
  cls
  Set "pXmode=+"
  Set "pYmode=+"
  Set "Ymode=+"
  Set "Xmode=+"

  Set /a x=c.y,low=c.y.min,high=c.y.max,"c.y=%clamp%",^
         x=c.x,low=c.x.min,high=c.x.max,"c.x=%clamp%",^
         "%$shift.x%,%$shift.y%"

  Set /a %$cam.update.obj:id=p%
  %$cam.clip.3x3% p !p.xA! %Ydata.3x3:ID=p%
  If "!p.collided!" == "" ( Set /a "p.c=32" ) Else Set "p.c=31"

  Set "frameLock="
  Set /a "fReady=0","oFPS=4","frames=0"
  Set /a "droppedFR=0","metFR=0","framesTtl=0"
  Set "last=!TIME:~-2!"

  %unload:macro=raise_Error%
  %unload:macro=$cam%
  %unload:macro=unload%

  %= DEFAULT MAP BACKGROUND COLOR =%
  If not defined Map.bgc Set "Map.bgc=30;30;60"

  for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do Set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1"
  Set /a t1=t2
 
  for /l %%i in () Do (%= infinite forL provides superior time resolution / drastically reduces dropped frames compared to while =%
    
    If NOT "!last!" == "!time:~-2!" (%= CALCULATE tDiff SINCE LAST FRAME IF MINIMUM OF 1cs ELAPSED =%
      for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do Set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1"
      If !tDiff! lss 0 Set /a tDiff+=24*60*60*100
      %= UPDATE LAST cs FLAG =% Set "last=!time:~-2!"
      %= FLAG READY STATE    =% Set "fReady=0"
    )

    If !tDiff! geq !FPS! If "!fReady!"=="0" (%= Enact Game Logic if Frame interval met =%
      %= UPDATE FRAME TRACKING VARIABLES =%
      Set /a "fReady=1","frames+=1"

      %= PSEUDO CONTROLLOR TO DEMONSTRATE FUNCTIONALITY =%
      If !c.x! == !c.bX! Set Xmode=-
      If !Xmode! == - If !c.x! == !c.x.min! Set Xmode=+
      %= Y axis controller disabled to prevent jitter and demonstrate clamp bounding =%
      REM %= DISABLED =% If !c.Y! == !c.bY! Set Ymode=-
      REM %= DISABLED =% If !Ymode! == - If !c.Y! == !c.Y.min! Set Ymode=+
      If !p.x! == !p.x.end! Set pXmode=-
      If !pXmode! == - If !p.x! == !c.x.min! Set pXmode=+
      If !p.y1A! == !p.y.end! Set pYmode=-
      If !pYmode! == - If !p.Y! == !c.Y.min! Set pYmode=+

      %= ENACT CAMERA MOVEMENT BOUND TO MAP DIMENSIONS USING CLAMP =%

      Set /a c.y!Ymode!=1,c.x!Xmode!=1,^
             x=c.x,low=c.x.min,high=c.bX,"c.x=%clamp%",^
             x=c.y,low=c.y.min,high=c.bY,"c.y=%clamp%",^
             "%$shift.y%,%$shift.x%"

      %= ENACT ENTITY MOVEMENT BOUND TO CURRENT CAMERA FRAME USING CLAMP =%
      Set /a "p.y!pYmode!=1,x=p.y,low=c.y.min,high=(c.h-p.h)+1,p.y=%clamp%",^
             "p.x!pXmode!=1,x=p.x,low=c.x.min,high=(c.w-p.w)+1,p.x=%clamp%",^
             %$cam.update.obj:id=p%

      If !tDiff! gtr !FPS! (Set /a "droppedFR+=1,decFPS=(droppedFR-metFR),incFPS=(metFR-droppedFR)") Else Set /a "metFR+=1,incFPS=(metFR-droppedFR)" 
      Set /a "t1=t2,framesTtl+=tDiff,fAvg=framesTtl/frames"
      If not defined frameLock (
        If !fAvg! GTR !FPS! If !decFPS! GTR 0 Set /a FPS=fAvg+1
        If !incFPS! GTR 0 If !tDiff! GEQ !oFPS! If !FPS! GTR !oFPS! Set /a FPS-=1
        If !frames! GTR 350 If !metFr! GTR !droppedFr! Set /a FPS=fAvg,frameLock=frames,LkDropped=droppedFR,droppedFR=0
      )
      %$cam.clip.3x3% !p.up! !p.dn! !p.lt! !p.rt! p !p.xA! %Ydata.3x3:ID=p%
      %= demonstrative visual indicator of collision state =% If "!p.collided!" == "" ( Set "p.c=32" ) Else (
        Set "p.c=31"
        Set "p.f="%= definition flags play vector flipped to restrict to once per collision event =%
        %= example of refining collision type after flagging collision =%
        If not "!p.occupied!" == "!p.occupied:¦=!" Set "p.c=38;2;250;80;120" & if "!p.f!" == "" (
          If "!pXmode!" == "+" (Set "pXmode=-")else Set "pXmode=+"
          If "!pYmode!" == "+" (Set "pYmode=-")else Set "pYmode=+"
          Set "p.f=1"
          Set /a "p.y!pYmode!=p.h,x=p.y,low=c.y.min,high=(c.h-p.h)+1,p.y=%clamp%",^
             "p.x!pXmode!=p.w,x=p.x,low=c.x.min,high=(c.w-p.w)+1,p.x=%clamp%",^
             %$cam.update.obj:id=p%
        )
        If not "!p.occupied!" == "!p.occupied:}=!" Set "p.c=38;2;250;80;120" & if "!p.f!" == "" (
          If "!pXmode!" == "+" (Set "pXmode=-")else Set "pXmode=+"
          If "!pYmode!" == "+" (Set "pYmode=-")else Set "pYmode=+"
          Set "p.f=1"
          Set /a "p.y!pYmode!=p.h,x=p.y,low=c.y.min,high=(c.h-p.h)+1,p.y=%clamp%",^
             "p.x!pXmode!=p.w,x=p.x,low=c.x.min,high=(c.w-p.w)+1,p.x=%clamp%",^
             %$cam.update.obj:id=p%
        )
        If not "!p.occupied!" == "!p.occupied:{=!" Set "p.c=38;2;250;80;120"
        If not "!p.occupied!" == "!p.occupied:\=!" Set "p.c=38;2;0;100;180"
        If not "!p.occupied!" == "!p.occupied:/=!" Set "p.c=38;2;0;100;180"
        If not "!p.occupied!" == "!p.occupied:_=!" Set "p.c=38;2;0;100;180"
        If not "!p.occupied!" == "!p.occupied:o=!" Set "p.c=38;2;0;100;180"
        If not "!p.occupied!" == "!p.occupied:+=!" Set "p.c=38;2;0;100;180"
        If not "!p.occupied!" == "!p.occupied:R=!" Set "p.c=38;2;0;100;180"
        If not "!p.occupied!" == "!p.occupied:|=!" Set "p.c=38;2;0;100;180"
      )
      %$cam.clip.frame%
      %$cam.sub.quad.1%
      %$cam.sub.quad.2%
      %$cam.sub.quad.3%
      %$cam.sub.quad.4%
      %= DEBUG =% If defined debug (
      %= DEBUG =%   %strlen:$len=$quad.a1% $quad.1
      %= DEBUG =%   %strlen:$len=$quad.a2% $quad.2
      %= DEBUG =%   %strlen:$len=$quad.a3% $quad.3
      %= DEBUG =%   %strlen:$len=$quad.a4% $quad.4
      %= DEBUG =%   Set /a "$quad.ttlA=$quad.a1+$quad.a2+$quad.a3+$quad.a4,$quad.avg=$quad.ttlA/4,$quad.ttlA+=(%$cam.spr.len%*4)" 
      %= DEBUG =%   title -!c.h!x!c.w!- -%$cam.Har%:%$cam.War%- c!c.A! cSubbed!$quad.ttlA! [!p.y1!;!p.x!]
      %= DEBUG =% )
      echo(%\e%[H%\e%[48;2;^!Map.bgc^!m!$quad.1!%sprites%
      echo(!$quad.2!%sprites%
      echo(!$quad.3!%sprites%
      echo(!$quad.4!%sprites%
      if defined debug Echo(%\e%[!c.h!;1H%\e%[2E%\e%[0m%\e%[K fps=!tFPS! RENDER start %time% frame:!frames! end:!time!%\e%[E%\e%[K cs/frame = a:!tDiff!/t:!FPS! d:!droppedFR! m:!metFR! a:!fAvg! Frame Locked @:!frameLock! Dropped prior Lock:!LkDropped!%\e%[0m%\e%[K
      If !frames! GEQ 500 (
        PAUSE > nul
        EXIT
      )
    )
  )
)
%= infinite ForL should prevent this line ever being reached =% EXIT 1


:init_cam.colormap No_Arguments ModuleID: 2
 If not defined raise_Error exit /b 1
 REM defines $cam.push.colorMap
 REM $cam.push.colorMap Usage:
 REM %$cam.push.colorMap% SearchChar VTcolor ReplaceChar

 REM substitutions will be performed in the order they are pushed to the colorMap

 REM e1.1.2.1: Map data must be defined to #[indexes] Psuedo-array prior
 REM e1.1.2.1: to calling init_cam.colormap

 REM e2.1.2.2: Missing Arg/s in expansion of %$cam.Push.ColorMap%
 REM e2.1.2.2: Arg1: Search character 
 REM e2.1.2.2: Arg2: VT Sequence
 REM e2.1.2.2: Arg3: Replace character

 REM e5.1.2.3: %$cam.Push.ColorMap%
 REM e5.1.2.3: Unsupported Character in arg1:        SearchCharacter
 REM e5.1.2.3: Characters reserved for VT sequences: 0 1 2 3 4 5 6 7 8 9 [ mM bB gG dD eE
 REM e5.1.2.3: Substitutions are NOT case aware.
 
 Set "$cam.UnsupportedSubs= 0 1 2 3 4 5 6 7 8 9 [ m M B b G g d D e E !\E! "
 
 If not defined #[1] %raise_Error% 2.1 #[indexes] not defined.
 
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
     )%\n%
    Set /a "$cam.subs+=1"%\n%
   ) else (%\n%
     !raise_Error! 2.3 Invalid Substitution search candidate: "%%~G"%\n%
   )%\n%
 )Else Set args=
 
 Set "$cam.PUSH.colorMap=!$cam.PUSH.colorMap:  =!"
 exit /b 0


:Cam.y_init
Set "$cam.metaVars=123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}"
Set "$cam.metaVars= !$cam.metaVars:~%$cam.metaData.tokenCount%!"

For /l %%n in (2 1 3) do Set /a "c.y.q[1]=c.h/4,c.y.q[%%n]=c.y.q[1]*%%n"

Set "$cam.frame.clip=%\e%[^!c.Y.home^!d"
for /l %%i in (1 1 !c.h!) Do (
  Set "$cam.metaVar=^^!$cam.metaVars:~%%i,1!"
  For /f "delims=" %%} in ("!$cam.metaVar!") Do (
    If %%i lss !c.y.q[1]! Set "$cam.frame.clip[1]=!$cam.frame.clip[1]!^^^!#[%%^^%%}]:~%%1,%c.w%^^^!%\e%[1E"
    If %%i geq !c.y.q[1]! If %%i lss !c.y.q[2]! Set "$cam.frame.clip[2]=!$cam.frame.clip[2]!^^^!#[%%^^%%}]:~%%1,%c.w%^^^!%\e%[1E"
    If %%i geq !c.y.q[2]! If %%i lss !c.y.q[3]! Set "$cam.frame.clip[3]=!$cam.frame.clip[3]!^^^!#[%%^^%%}]:~%%1,%c.w%^^^!%\e%[1E"
    If %%i geq !c.y.q[3]! Set "$cam.frame.clip[4]=!$cam.frame.clip[4]!^^^!#[%%^^%%}]:~%%1,%c.w%^^^!%\e%[1E"
  )
)

Set "$cam.r.build="
If !c.h! GTR !$cam.metavarTransition! (
  Set "$cam.c.Build=31"
  Set /a "$cam.r.Build=c.h-$cam.metavarTransition"
) else Set /a "$cam.c.Build=c.h + $cam.metaData.tokenCount"
If not defined $cam.r.build Set $cam.clip.frame=For /f "tokens=1-!$cam.c.build!" %%1 in ("!Reserved.tokens! !$cam.Ydata:~1!") Do (%\n%
  Set "$quad.1=%\e%[1;1H%$cam.frame.clip[1]%"%\n%
  Set "$quad.2=%\e%[!c.y.q[1]!;1H%$cam.frame.clip[2]%"%\n%
  Set "$quad.3=%\e%[!c.y.q[2]!;1H%$cam.frame.clip[3]%"%\n%
  Set "$quad.4=%\e%[!c.y.q[3]!;1H%$cam.frame.clip[4]%"%\n%
)

If defined $cam.r.build Set $cam.clip.frame=For /f "tokens=1-!$cam.c.build!" %%1 in ("!Reserved.Tokens! !$cam.Ydata:~1!") Do (%\n%
  For /f "tokens=1-!$cam.r.build!" %%!$cam.metaVars:~%$cam.metavarTransition.SubstringOffset%,1! in ("!$cam.Ydata2:~1!") Do (%\n%
    Set "$quad.1=%\e%[1;1H%$cam.frame.clip[1]%"%\n%
    Set "$quad.2=%\e%[!c.y.q[1]!;1H%$cam.frame.clip[2]%"%\n%
    Set "$quad.3=%\e%[!c.y.q[2]!;1H%$cam.frame.clip[3]%"%\n%
    Set "$quad.4=%\e%[!c.y.q[3]!;1H%$cam.frame.clip[4]%"%\n%
  )%\n%
)
Exit /b 0

:Cam.x_init
Set "$cam.metaVars=123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}"
Set "$cam.metaVars= !$cam.metaVars:~%$cam.metaData.tokenCount%!"

Set /a c.x.q[1]=0,c.xP[1]=c.x.q[1],^
       c.x.q[2]=c.x.q,c.xP[2]=c.x.q[2]+1,^
       c.x.q[3]=c.x.q*2,c.xP[3]=c.x.q[3]+1,^
       c.x.q[4]=c.x.q*3,c.xP[4]=c.x.q[4]+1

Set "$cam.frame.clip=%\e%[^!c.Y.home^!d"
for /l %%i in (1 1 !c.h!) Do (
  Set "$cam.metaVar=^^!$cam.metaVars:~%%i,1!"
  For /f "delims=" %%} in ("!$cam.metaVar!") Do (
    Set "$cam.frame.clip=!$cam.frame.clip!%\e%[^!c.xP[Qd]^!G^^^!#[%%^^%%}]:~%%Qd,%%5^^^!%\e%[1E"
  )
)

Set "$cam.r.build="
If !c.h! GTR !$cam.metavarTransition! (
  Set "$cam.c.Build=31"
  Set /a "$cam.r.Build=c.h-$cam.metavarTransition"
) else Set /a "$cam.c.Build=c.h + $cam.metaData.tokenCount"
If not defined $cam.r.build Set $cam.clip.frame=For /f "tokens=1-!$cam.c.build!" %%1 in ("!Reserved.tokens! !$cam.Ydata:~1!") Do (%\n%
  Set "$quad.1=%$cam.frame.clip:Qd=1%"%\n%
  Set "$quad.2=%$cam.frame.clip:Qd=2%"%\n%
  Set "$quad.3=%$cam.frame.clip:Qd=3%"%\n%
  Set "$quad.4=%$cam.frame.clip:Qd=4%"%\n%
)

If defined $cam.r.build Set $cam.clip.frame=For /f "tokens=1-!$cam.c.build!" %%1 in ("!Reserved.Tokens! !$cam.Ydata:~1!") Do (%\n%
  For /f "tokens=1-!$cam.r.build!" %%!$cam.metaVars:~%$cam.metavarTransition.SubstringOffset%,1! in ("!$cam.Ydata2:~1!") Do (%\n%
    Set "$quad.1=%$cam.frame.clip:Qd=1%"%\n%
    Set "$quad.2=%$cam.frame.clip:Qd=2%"%\n%
    Set "$quad.3=%$cam.frame.clip:Qd=3%"%\n%
    Set "$quad.4=%$cam.frame.clip:Qd=4%"%\n%
  )%\n%
)
exit /b 0

:construct.$cam.clip
REM call:construct.$cam.clip <Height> <Width>
REM  Where H is the height as an int and W is the width as an int 
REM -- does not currently support sprites that have width GTR height
REM    as the extractor is built by iterating the height.

REM TBA consideration: modify $cam.clip extractor to return collision data for:
REM Above Below Left and Right of sprite-Map relation. This will require:
REM modify:
REM Set /a $cam.vp.metaVarCount=$cam.vp.H+2
REM To accomodate 4 additional fixed expansion pointers: 
REM Set /a $cam.vp.metaVarCount=$cam.vp.H+6
REM those being the following variables, where "id.xA=c.X+(id.X-1)" and "id.Y1A=(c.Y+id.Y)-1"
REM id.lft=id.xA-1
REM id.rght=id.xA+id.W
REM id.up=id.Y1A-1
REM id.dwn=id.Y1A+id.H
REM the aforementioned variables will be built into and updated with expansions of $cam.update.Obj
REM changing the for /f expansion loop of $cam.clip.%$cam.vp.H%x%$cam.vp.W% to begin reference from %%e
REM Modify clamp bounding constraint to prevent sprite from getting within 1 character space of any
REM camera edge to prevent attempts to access undefined variables.
REM build the appropriate expansion string to extract map overlap data to variables:
REM id.left id.right id.above id.below and use same whitespace removal method for direct overlap collisions

REM This function constructs a macro to generate something equivalent to a cropped screenshot of the
REM area of the map occupied by an object [ie player] to facilitate collisioning logic.
REM basic collisioning is determined by the defined state of returnID.collided
REM advanced collisioning is performed by testing for specific substrings in the returnID.occupied
REM variable. for map based collisioning, this macro serves better than a traditional bounding box
REM algorithm  as:
REM  - the position of collidable objects/structures does not need to be known
REM  - the performance cost is fixed. the number of the structures in the map does not increase
REM    the cost as there is no requirement to test the positions corresponding to structures
REM  the presense of structure / state of collision is impicit when objectID.collided is defined
REM  Characters corresponding to specific structures can then be tested using the data in
REM  object.occupied If DESIRED for specific game logic.
REM  operations are still saved here, as only object * structureTypes needs testing
REM  rather than using a BBA for objectArea * UniqueStructureAreas
REM  As an example, To identify collision with a tree in a map containing many trees
REM  instead of having to use logic testing the players position against the position
REM  of every tree, p.occupied just needs to be tested for the character/s used
REM  represent trees. 

REM returns: returnID.occupied = a string containing all characters the area overlaps with
REM          returnID.collided = defined If the overlap character contains any non whitespace character
REM          NOTE: original map characters returned - NOT the substituted mappings
REM  %$cam.clip.HxW% ReturnID xpos !obj.HxW.Ydata:ID=objectID!
rem abcde fghij
REM Tokens     1      ~      16
Set "$cam.vp.metavars= klmnopqrstuvwxyz"
Set /a "$cam.vp.H=%~1","$cam.vp.W=%~2","1/$cam.vp.H","1/$cam.vp.W" || Exit /b 1
If !$cam.vp.H! GTR 16 exit /b 1

Set /a $cam.vp.metaVarCount=$cam.vp.H+2
Set "$cam.vp.Oc="
Set $cam.update.Obj="id.xA=c.X+(id.X-1)","id.Y1A=(c.Y+id.Y)-1","id.Y1=p.Y","id.Y.end=(c.y+c.h)-%~1","id.X.end=(c.w-%~2)+1"
Set "Ydata.%$cam.vp.H%x%$cam.vp.W%="

for /l %%_ in (1,1,%$cam.vp.H%) do (
  Set /A $cam.y.offset=%%_-1
  If %%_ GTR 1 Set $cam.update.Obj=!$cam.update.Obj!,"id.y%%_A=id.y1A+!$cam.y.offset!","id.y%%_=id.y+!$cam.y.offset!"
  for /f "delims=" %%G in ("!$cam.vp.metavars:~%%_,1!") do (
    Set "$cam.vp.Oc=!$cam.vp.Oc!^!#[%%~%%~G]:~%%~j,%$cam.vp.W%^!"
    Set "Ydata.%$cam.vp.H%x%$cam.vp.W%=!Ydata.%$cam.vp.H%x%$cam.vp.W%! ^!ID.Y%%_A^!"
) )

Set "Ydata.%$cam.vp.H%x%$cam.vp.W%=!Ydata.%$cam.vp.H%x%$cam.vp.W%:* =!"

Set $cam.clip.%$cam.vp.H%x%$cam.vp.W%=For %%n in (1 2) Do If %%n == 2 For /f "tokens=1-%$cam.vp.metaVarCount%" %%i in ("^!obj.inf^!") Do (%\n%
  Set "%%~i.occupied=!$cam.vp.Oc!"%\n%
  Set "%%~i.collided=^!%%~i.occupied: =^!"%\n%
) else Set obj.inf=


exit /b 0


REM                     ▒ ▓ ░ █ ▬ ▄ ▀ ¦

:1:     // /  |           @   //RR/  |                                                                                                                                  || 
:1:    /R\/   |           I  /RR\/   |                                              ___                                                                                 -- 
:1:   |   |+o+o+o+o+o+o+o+o+o|   |   /                                             (+o+)|                                                                               || 
:1:   |   |o+o+o+/--\o+o+o+o+|   |  /                                              [o+o]/                                                                               || 
:1:   |   |+o+o+o|vv|+o+o+o+o|   | /                                               vvvvv                                                                                || 
:1:   |   |o+o+o+|vv|o+o+o+o+|   |/                                                                                                                                     || 
:1:                                                                                                          ___________            }{{}{                               -- 
:1:                                               @y                                                      /RRRRRRRRRRR/R\             {}                                || 
:1:    @                                          Y                                                      /+o+o+o+o+o+o\RR\            ¦¦                                || 
:1:    Y                                          i                                                     /+o+o+o+o+o+o+o\/|            ¦¦                                || 
:1:    i                   i-----i                                                                      |o+o[ ]o+o[ ]o+| |                                              || 
:1:                    wwwwnnwwwwwwnn                                                                   |+o+o+o+o+o+o+o| |                                              -- 
:1:                 wwwwwnnwwnnnwwwwn                                                                   |o+o+o+o+o+o+o+| |                                              || 
:1:                wwnnnwwwnnwwwnnnwwn                                                                                                                                  || 
:1:               wnnwwwnnwwwwnnwwwwnn                                                                                                                                  || 
:1:                                                                                                                                                                     || 
:1:                                                                                                                                                                     -- 
:1:                                                                                   }-{                                                                               || 
:1:                                                                                  }}¦{{                                                                              || 
:1:                                                                                 }} W {{                                                                             || 
:1:                                                                                @-¦   ¦                                                                              || 
:1:                                                                                 o+o+o+o                                                                             -- 
:1:                                                                                 +++++++  @-                                                                        |  |
:1:                                                                                                                                                                    |  |
:1:                                                                                                                                                                     -- 
:1:                                                                                                                                                                     || 
:1:                                                                                                                                                                     || 
:1:                                                                                                       _____  _____  _____                                           || 
:1:                                                                                                      /RRRRR\/RRRRR\/RRRR\\                                          || 
:1:       }{ }{ }{ }{ }{ }{ }{ }{}{{                                                                    |+o+o+o|+o+o+o|+o+o+o||                                         -- 
:1:      }}{}}{}}{}}{}}{}}{}}{{}{{}{{                                                                   |o+o+_____+o_____ o_____                                        || 
:1:       ¦¦ ¦¦ ¦¦ ¦¦ ¦¦ ¦¦ ¦¦ ¦¦ ¦¦                                                                    |+o+/RRRRR\/RRRRR\/RRRRR\\                                      || 
:1:       ¦¦ ¦¦ ¦¦ ¦}{¦}{¦}{¦}{¦}{¦}{ }{                                                                    |+o+o+o|+o+o+o|+o+o+o||                                     || 
:1:                }}{}}{}}{}}{}}{}}{}}{{                                                                   |o+o+o+|o+o+o+|o+o+o+||                                     || 
:1:                 ¦¦ ¦¦ ¦¦ ¦¦ ¦¦ ¦¦ ¦¦                                                                    |+o+o+o|+o+o+o|+o+o+o||                                     -- 
:1:                 ¦¦ ¦¦ ¦¦ ¦¦ ¦¦ ¦¦ ¦¦                                                                                                          }{                    || 
:1:                                                                                                                                            }{}}{{}{                 || 
:1:                                                                                                                                           }}{{¦¦}}{{}{              || 
:1:                                                                                                                                       }{ }{¦¦}{¦}{¦}}{{             || 
:1:                                                                                                                                      }}{{}{{}}{{}{{ ¦¦              -- 
:1:                                                                                                                                       ¦¦ ¦¦  ¦¦ ¦¦  ¦¦              || 
:1:                                                                                                                                       ¦¦ ¦¦  ¦¦ ¦¦                  || 
:1:                                                                                                                                                                     || 
:1:                                                                             _____  _____  _____                                                                     || 
:1:                                                                            /RRRRR\/RRRRR\/RRRRR\\                                                                   -- 
:1:   }{ }{                                                                    |+o+o+o|+o+o+o|+o+o+o||                                                                  || 
:1:  }}{{}{{                                                                   |o+o+_____ +o_____ o_____                                                                || 
:1:   ¦¦ ¦¦                                                                    |+o+/RRRRRR\/RRRRR\/RRRR\\                                                               || 
:1:   }{ }{{                                                                       |+o+o+o|+o+o+o|+o+o+o||                                                              || 
:1: }{}}{}}{{                                                                      |o+o+o+|o+o+o+|o+o+o+||                                                              -- 
:1: ¦¦ ¦¦ ¦¦                                                                       |+o+o+o|+o+o+o|+o+o+o||                                                              || 
:1:                                                                                                                                               }{                    || 
:1:                                                                                                                                            }{}}{{}{                 || 
:1:                                                                                                                                           }}{{¦¦}}{{}{              || 
:1:                                                                                                                                       }{ }{¦¦}{¦}{¦}}{{             -- 
:1:                                                                                                                                      }}{{}{{}}{{}{{ ¦¦              || 
:1:                                                                                                                                       ¦¦ ¦¦  ¦¦ ¦¦  ¦¦              || 
:1:                                                                                                                                       ¦¦ ¦¦  ¦¦ ¦¦                  || 
:1:                                                                                                                                                                     || 
:1:                                                                                                                                                                     || 


