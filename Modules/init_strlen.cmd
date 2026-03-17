:init_strlen Macro Author: Einst
::  Computes the number of bytes in a string.
::
::  %strLen% <str> [len]
::   str - [ByRef In] Name of the variable containing the string to be measured.
::   len - [ByRef Out] Name of the variable that receives the measured length. Dafualts to $len If unsupplied
:: Strings of up to 8191 characters are supported.
   REM See: https://www.dostips.com/forum/viewtopic.php?p=71415#p71415
   REM optimized for best performance averaged across supported string lengths.

                                                FOR /F %%! IN ("! ^! ^^^!") DO ^
Set strLen=^
for /f "tokens=2" %%? in ("%%!%%! D E") do for %%. in (1 2) do If %%.==2 (^
%=   =% for /f "tokens=1,2 delims= " %%1 in ("%%!$args%%! $len") do If not "%%~2" == "" (^
%=                        =% If defined %%~1 (^
%=                                     =% (^
%=                                        =% If "" neq "%%!%%1:~255%%!" (^
%=                                                =% If "" neq "%%!%%~1:~4095%%!" (Set "$=%%!%%~1:~4096%%!") else Set "$=%%!%%~1%%!"^
%=                                                =% ) ^& (^
%=                                                        =% If defined $ (^
%=                                                                 =% Set ^"$Scale=^
%=                                                                =%%%!$:~255,1%%!%%!$:~511,1%%!%%!$:~767,1%%!%%!$:~1023,1%%!%%!$:~1279,1%%!^
%=                This zone is empty                                =%%%!$:~1535,1%%!%%!$:~1791,1%%!%%!$:~2047,1%%!%%!$:~2303,1%%!%%!$:~2559,1%%!^
%=                                                                =%%%!$:~2815,1%%!%%!$:~3071,1%%!%%!$:~3327,1%%!%%!$:~3583,1%%!%%!$:~3839,1%%!^
%=                                                                =%FEDCBA9876543210^"^&^
%=                                                                =% If "" neq "%%!%%~1:~4095%%!" (^
%=                                                                        =% Set /a "$L=0x%%!$Scale:~15,1%%!*256+4096"^
%=                                                                =% ) else Set /a "$L=0x%%!$Scale:~15,1%%!*256"^
%=                                                        =% ) else If "" neq "%%!%%~1:~4095%%!" Set "$L=4096"^
%=                                       =% ) else Set "$L=0"^
%=                                =% )^&^
%=                                =% for %%# in (%%!$L%%!) do Set ^"$=%%!%%~1:~%%#%%!^
%= Leading space not supported    =%FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210^
%=                                =%FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210^
%=                                =%FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210^
%=                                =%FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210^
%=                                =%FFFFFFFFFFFFFFFFEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCC^
%=                                =%BBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAA99999999999999998888888888888888^
%=                                =%7777777777777777666666666666666655555555555555554444444444444444^
%=                                =%333333333333333322222222222222221111111111111111^"^&^
%=                                =% for %%# in ("%%!$L%%!+0x%%!$:~511,1%%!%%!$:~255,1%%!") do (If %%?==D endlocal)^&Set /A "%%~2=%%#"^
%=                        =%) else (If %%?==D endlocal)^&Set "%%~2=0"^
%==% )^
) else (If %%?==D setlocal EnableDelayedExpansion)^&Set $args=
Exit /b 0
