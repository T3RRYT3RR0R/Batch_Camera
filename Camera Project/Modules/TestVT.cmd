 :TestVT Author:  T3RRY ; Released: 21/01/2022 ==========================================================================
 REM     PURPOSE: For use with scripts that utilise Vertual terminal sequences.
 REM See:         https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
 REM     METHOD:  Utilizes powershell to Identify if the terminal running the batch script is succesfully executing virual terminal sequences,
 REM              by assessing which character occupies the buffer cell the cursor is currently positioned at.
 REM              As this method is slow, an ADS of this file or a temporary file is used to remember if virtual terminal supported
 Cls

 %= Ascii Escape char 0x1b =% for /f %%e in ('Echo Prompt $E^|cmd') Do Set "\E=%%e"

 2> nul (
	Set "NTFSdrive=true"
	(Echo(verify) >"%~f0:ntfs.test" && (
		Set "SupportINFO=%~f0:VTSupport.dat"
	) || (
		Set "NTFSdrive="
		For /f delims^= %%G in ("%~f0")Do Set "SupportINFO=%TEMP%\%%~nG_VTSupport.dat"
  	)
 )

 2> nul (
	More < "%SupportINFO%" > nul && (
		Exit /b 0
	) || (
		<Nul Set /P "=Verifying Compatability %\E%[2D" 1> CON
		for /F "delims=" %%a in ('"PowerShell.exe $console=$Host.UI.RawUI; $curPos=$console.CursorPosition; $rect=new-object System.Management.Automation.Host.Rectangle $curPos.X,$curPos.Y,$curPos.X,$curPos.Y; $BufCellArray=$console.GetBufferContents($rect); Write-Host $BufCellArray[0,0].Character;"') do (
			Cls
			If "%%a" == "y" (
				(Echo(true) >"%SupportINFO%"
				Exit /b 0
			)else (
				Exit /b 1
			)
		)
	)
 )
 Exit /b 2
