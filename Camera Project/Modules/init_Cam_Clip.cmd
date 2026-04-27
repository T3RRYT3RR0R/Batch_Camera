:init_Cam_Clip ModuleID: 8
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

:raise_Error.int ModuleID: 0
REM e2.1.0.0: Argument missing.

REM e5.1.8.1 Expected Integer recieved string. 
REM e2.1.8.2 Arg1: IntegerHeight
REM e2.1.8.2 Arg2: IntegerWidth

If "%~1" == "" %raise_Error% 8.2 Argument 1 Missing.
If "%~2" == "" %raise_Error% 8.2 Argument 2 Missing.

%raise_Error.int:NoVar=% 8.1 %~1
%raise_Error.int:NoVar=% 8.1 %~2

%= DEPENDENCY - Value Range Bounding =%
  Set "clamp= (leq=((low-(x))>>31)+1)*low  +  (geq=(((x)-high)>>31)+1)*high  +  ^^^!(leq+geq)*(x) "

REM call:init_Cam_Clip <Height> <Width>
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

rem tokens map:
rem i = id reference key      
rem j = idxA                     [map adjusted idX position]
rem k = idxA-1                   [id left adjacent]
rem l = idxA+id.w+1              [id right adjacent]
rem m = idyA-1                   [id above]
rem n = idyA+id.h+1              [id below]
rem o ~ { = id.y1A ~ id.y1A+id.H [object y occupied lines]
REM Tokens     1      ~      13
  Set "$cam.vp.metavars= opqrstuvwxyz{"

Set "$cam.adjacents=^!id.xLeft^! ^!id.xRight^! ^!id.yAbove^! ^!id.yBelow^!"


Set /a "low=1,high=13,x=%~1,$cam.vp.H=%clamp%",^
       "low=1,high=13,x=%~2,$cam.vp.W=%clamp%"

rem tokens = height + id reference + left + right + above + below
Set /a $cam.vp.metaVarCount=$cam.vp.H+6
Set "$cam.vp.Oc="
REM %= to cameraEdge _ comparitor is id.x =% Set $cam.update.Obj="id.xA=c.X+(id.X-1),id.Y1A=c.Y+(id.Y-1),id.Y1=p.Y,id.Y.end=(c.y+c.h)-%~1,id.X.end=(c.w-%~2)+1,id.yAbove=id.y1A-1,id.yBelow=id.y1A+id.h+1,id.xLeft=id.xA-1,id.xRight=id.xA+id.W+1"
rem cap traversal to mapEdge-1  _ comparitor is id.xA : id.x.max="(c.x.max-id.w)-id.w"
%= id.x.max cap traversal to cameraEdge-1 _ comparitor is id.x  =% Set $cam.update.Obj="id.xA=c.X+(id.X-1),id.Y1A=(c.Y+id.Y)-1,id.Y1=p.Y,id.Y.end=(c.y.max-id.h)-1,id.X.end=(c.x.max-id.w)-1,id.yAbove=id.y1A-1,id.yBelow=id.y1A+id.h+1,id.xLeft=id.xA-1,id.xRight=id.xA+id.W+1"

Set "Ydata.%$cam.vp.H%x%$cam.vp.W%="

for /l %%_ in (1,1,%$cam.vp.H%) do (
  Set /A $cam.y.offset=%%_-1
  If %%_ GTR 1 Set $cam.update.Obj=!$cam.update.Obj!,"id.y%%_A=id.y1A+!$cam.y.offset!","id.y%%_=id.y+!$cam.y.offset!"
  for /f "delims=" %%G in ("!$cam.vp.metavars:~%%_,1!") do (
    Set "$cam.vp.Oc=!$cam.vp.Oc!^!#[%%~%%~G]:~%%~j,%$cam.vp.W%^!"
    Set "Ydata.%$cam.vp.H%x%$cam.vp.W%=!Ydata.%$cam.vp.H%x%$cam.vp.W%! ^!ID.Y%%_A^!"
) )

Set "$cam.%$cam.vp.H%x%$cam.vp.X%.left="
Set "$cam.%$cam.vp.H%x%$cam.vp.X%.right="
For /f "tokens=1,2" %%X in ("%$cam.vp.W% %$cam.vp.H%") Do (
  For /l %%i in (1 1 %%Y) Do (
    For /f "delims=" %%G in ("!$cam.vp.metavars:~%%i,1!") do (
      Set "$cam.%%Yx%%X.left=!$cam.%%Yx%%X.left!^!#[%%~%%~G]:~%%~k,1^!"
      Set "$cam.%%Yx%%X.right=!$cam.%%Yx%%X.right!^!#[%%~%%~G]:~%%~l,1^!"
      if %%i==1 (
        Set "$cam.%%Yx%%X.above=^!#[%%~m]:~%%~j,%%~X^!"
        Set "$cam.%%Yx%%X.below=^!#[%%~n]:~%%~j,%%~X^!"
      )
    )
  )
)

Set "Ydata.%$cam.vp.H%x%$cam.vp.W%=!Ydata.%$cam.vp.H%x%$cam.vp.W%:* =!"

Set $cam.clip.%$cam.vp.H%x%$cam.vp.W%=For %%n in (1 2) Do If %%n == 2 For /f "tokens=1-%$cam.vp.metaVarCount%" %%i in ("^!obj.inf^!") Do (%\n%
  Set "%%~i.occupied=!$cam.vp.Oc!"%\n%
  Set "%%~i.collided=^!%%~i.occupied: =^!"%\n%
  Set "%%~i.Left="%\n%
  Set "%%~i.Right="%\n%
  Set "%%~i.Above="%\n%
  Set "%%~i.Below="%\n%
  If "^!%%~iXmode^!" == "-" (%\n%
    Set "%%~i.ocL=!$cam.%$cam.vp.H%x%$cam.vp.W%.left!"%\n%
    Set "%%~i.Left=^!%%~i.ocL: =^!"%\n%
  )%\n%
  If "^!%%~iXmode^!" == "+" (%\n%
    Set "%%~i.ocR=!$cam.%$cam.vp.H%x%$cam.vp.W%.right!"%\n%
    Set "%%~i.Right=^!%%~i.ocR: =^!"%\n%
  )%\n%
  If "^!%%~iYmode^!" == "-" (%\n%
    Set "%%~i.ocA=!$cam.%$cam.vp.H%x%$cam.vp.W%.Above!"%\n%
    Set "%%~i.Above=^!%%~i.ocA: =^!"%\n%
  )%\n%
  If "^!%%~iYmode^!" == "+" (%\n%
    Set "%%~i.ocB=!$cam.%$cam.vp.H%x%$cam.vp.W%.below!"%\n%
    Set "%%~i.Below=^!%%~i.ocB: =^!"%\n%
  )%\n%
) else Set obj.inf=

exit /b 0

