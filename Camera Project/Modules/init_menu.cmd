:init_menu
======================================================================================
  REM Modular menu macro by T3RRYT3RR0R

  REM Version Update 21/01/2024
    REM Variable Structure reworked to minimize variable reservations required by
    REM constraining all internal variables to a single  prefix: menu*
    REM Macro help and usage now embeded in the Macro.
    REM Expanding the macro without arguments will now display the help output.
    REM return variables are now named:
    REM           Menu{String}
    REM           Menu{Key}
    REM           Menu{Number}

  ================================================ REM = Menu macro Definition BEGIN
  REM IMPORTANT - Defines the following Variables:  \n Console_Width Menu*
    REM         Reserved Variable Prefix:      Menu
    REM          - Do not define other variables with the leading name 'Menu' in your
    REM         script to prevent any possibility of variable contamination.
                REM   - Companion macro %menu.unload%
                REM     Undefines all menu prefixed macros to free environment space.

  REM Recommended Learning resources: 
    REM https://www.dostips.com/forum/viewtopic.php?t=9265#p60294
    REM https://www.dostips.com/forum/viewtopic.php?f=3&t=10983&sid=f6937e02068d93bc5a97ef63d4e5319e
    REM Macros with arguments learning resource:
    REM https://www.dostips.com/forum/viewtopic.php?f=3&t=1827

(Set \n=^^^

%= Newline var \n for multi-line macro definition - Do not modify This codeblock. =%)

REM - use REM / remove REM on the below line to enable / disable menu dividing line
  REM Goto :NoDividingLine

  REM Enable DE environment to perform variable concatenation within a for loop
    Setlocal EnableDelayedExpansion

  REM Get console width for dividing line NOTE: not locale independant
  For /f "usebackq tokens=2* delims=: " %%W in (`mode con ^| %__APPDIR__%findstr.exe /LIC:"Columns"`) do Set /A Console_Width=%%W
    Set "Menu_Div=" & For /L %%i in (1 1 %Console_Width%)Do Set "Menu_Div=!Menu_Div!-"
    Endlocal & Set "Menu_Div=%Menu_Div%"

:NoDividingLine
  REM Menu internal variables
  REM keymap. translates literal keypress to the numeric position of the item in the menu list
    Set /a Menu@0=36,Menu@1=1,Menu@2=2,Menu@3=3,Menu@4=4,Menu@5=5,Menu@6=6,Menu@7=7,Menu@8=8,Menu@9=9,Menu@a=10,Menu@b=11,Menu@c=12,Menu@d=13,Menu@e=14,Menu@f=15,Menu@g=16,Menu@h=17,Menu@i=18,Menu@j=19,Menu@k=20,Menu@l=21,Menu@m=22,Menu@n=23,Menu@o=24,Menu@p=25,Menu@q=26,Menu@r=27,Menu@s=28,Menu@t=29,Menu@u=30,Menu@v=31,Menu@w=32,Menu@x=33,Menu@y=34,Menu@z=35
  REM Valid choice characters
    Set "Menu.Keys=123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
    Set "Menu.Hash=Header"

REM Menu macro Usage: %Menu% "quoted" "list of" "options"
%= Outer for loop allows environment independant definition =% For /f %%! in ("! ^! ^^^!") Do ^
%= IMPORTANT - No whitespace permitted here =%Set ^"Menu=For %%n in (1 2)Do If %%n==2 (%\n%
  If defined Menu{Args} (%\n%
    %= Switch control via !! Expansion outcome  =%  for /f "tokens=2" %%? in ("%%!%%! D E") do (%\n%
    %= Switch - Setlocal / NOP                  =%    If %%~? == D SetLocal EnableDelayedExpansion%\n%
    %= If Header Substitute Output substitution =%      If not "Header" == "%%!Menu.Hash%%!" (%\n%
        REM If Defined Menu_Div Echo(%%!Menu_Div%%!%\n%
        Echo(Header%\n%
       )%\n%
       If Defined Menu_Div Echo(%%!Menu_Div%%!%\n%
    %= ReSet Menu.# index for Menu.Item[#]      =%    Set "Menu.#=0"%\n%
    %= Undefine choice command key list         =%    Set "Menu.Chars="%\n%
    %= Redirect output to ADS; For Each in List =%    For %%G in (%%!Menu{Args}%%!)Do (%\n%
    %= For Menu.Item Index value                =%      For %%i in (%%!Menu.#%%!)Do If not %%i GTR 35 (%\n%
    %= Build the Choice key list                =%        Set "Menu.Chars=%%!Menu.Chars%%!%%!Menu.Keys:~%%i,1%%!"%\n%
    %= Define Menu.Item array                   =%        Set "Menu.Item[%%!Menu.Keys:~%%i,1%%!]=%%~G"%\n%
    %= Assign String for safe output            =%        Set "Menu.Output=%%~G"%\n%
    %= Display as [key] Option String           =%        Echo([%%!Menu.Keys:~%%i,1%%!] %%!Menu.Output%%!%\n%
    %= Increment Menu.# Index var               =%        Set /A "Menu.#+=1"%\n%
    %= Close Menu.# expansion loop              =%      )%\n%
    %= Close Menu{Args} String loop             =%    ) %\n%
    %= Output Dividing Line                     =%    If Defined Menu_Div Echo(%%!Menu_Div%%!%\n%
    %= Select option by character index         =%    For /f "delims=" %%o in ('%__APPDIR__%Choice.exe /N /C:%%!Menu.Chars%%!')Do For /f "tokens=1,2 delims=;" %%V in ("%%!Menu.Item[%%o]%%!;%%!Menu@%%o%%!")Do (%\n%
    %= Switch - Endlocal / NOP ; returnVars     =%      ( If %%~? EQU == D EndLocal ) ^& (%\n%
    %= exit [sub]script w/out modifying option  =%        If /I "%%V" == "Exit" Exit /B 2%\n%
    %= Assign 'Menu{String}' w/literal string   =%        Set "Menu{String}=%%V"%\n%
    %= Assign 'Menu{key}' with key pressed      =%        Set "Menu{Key}=%%o"%\n%
    %= Assign 'Menu{Number} with list position  =%        Set "Menu{Number}=%%~W"%\n%
    %= ReSet Menu Argument variable             =%        Set "Menu{Args}="%\n%
    %= Set errorlevel to match Menu{Number}     =%        CMD /C Exit %%~W%\n%
    %= Close Menu macro processing loops        =%  )  )  )%\n%
  )Else (%\n: Show Macro Help If no arguments supplied - will not display If expanded menu variable has trailing whitespace =%
    CLS%\n%
    Echo(Usage:%\n%
    Echo(%\n%
    Echo(%%Menu%%%\n%
    Echo(    Output this help info, Returns Errorlevel 0%\n%
    Echo(%\n%
    Echo(%%Menu%% "DoubleQuoted List" "Of Options"%\n%
    Echo(    Output the Menu list, Take input%\n%
    Echo(%\n%
    Echo(%%Menu:Header=Your Custom Header%% "DoubleQuoted List" "Of Options"%\n%
    Echo(    Outputs substituted Header, Output Menu list; Take input%\n%
    Echo(%\n%
    Echo(Return Variables:%\n%
    Echo(    Menu{String}  : The literal String%\n%
    Echo(    Menu{Key}     : The Key Pressed%\n%
    Echo(    Menu{Number}  : The list position of the option as an Integer%\n%
    Echo(          IE:  Option 1 = 1, Option A = 10%\n%
    Echo(          Note:  The Errorlevel is also Set to this value%\n%
    Echo(%\n%
    Echo(  Note:      The number of options available is limited to 36.%\n%
    Echo(%\n%
    Echo( Important: The following variable prefix is reserved: Menu%\n%
    Echo(%\n%
    Pause%\n%
    CLS%\n%
    %= If Menu expanded without Args Set Errorlevel 0 =%(Call )%\n%
  )%\n%
%= Capture Macro input - Options List       =%)Else Set Menu{Args}=^"

========================================== REM = Menu Macro Definition END
exit /b 0