@echo off
echo Loading...
color f
set version=0.0.7
SET currentPath=%~dp0
title Advanced Minecraft Paper Server Maker
timeout 1 /nobreak >nul
:start
Ping www.google.nl -n 1 -w 1000 >nul
if errorlevel 1 (set internet=n) else (set internet=y)
timeout 1 /nobreak >nul
IF %internet%==n call:noInternet


Rem this programm will try to generate a start.bat with a java version between min and max if existing, otherwise ask to install

SET currentPath=%~dp0

call:checkForUpdates

net session >nul 2>&1
IF [%errorLevel%]==[0] (
cls
echo This bat was run as administrator, every feature will be available.
GOTO minIn
) else (
cls
echo This bat was not run as administrator, downloading a paper.jar or a java jdk may cause a crash.
echo Also setting JAVA_HOME will not be possible without administrator.
echo If you want to use any of the above listed features, please close this and rerun it as administrator.
)

:adminIn
SET /p adminIn= Do you want to continue anyways? (y/n):
IF [%adminIn%]==[] GOTO adminIn
IF NOT [%adminIn%]==[y] IF NOT [%adminIn%]==[n] GOTO adminIn
SET admin=%adminIn%

IF [%admin%]==[n] (
GOTO Exit
)


:minIn
SET /p minIn= Enter the minimum Java Version (e.g. 16):
IF [%minIn%]==[] GOTO minIn
SET /a param=%minIn%+0
IF %param%==0 GOTO minIn
SET /a min=%minIn%

:maxIn
SET /p maxIn= Enter the maximum Java Version (e.g. 16):
IF [%maxIn%]==[] GOTO maxIn
SET /a param=%maxIn%+0
IF %param%==0 GOTO maxIn
IF NOT %maxIn% GEQ %minIn% (
echo max has to be greater or equal than min
GOTO minIn
)
SET /a max=%maxIn%

:ramIn
SET /p ramIn= Do you want to set the ram usage (y/n):
IF [%ramIn%]==[] GOTO ramIn
IF NOT [%ramIn%]==[y] IF NOT [%ramIn%]==[n] GOTO ramIn
SET ram=%ramIn%

IF [%ram%]==[y] (
GOTO xmxIn
) else (
GOTO paperIn
)


:xmxIn
SET /p xmxIn= Enter the maximum amount of RAM (in MB, e.g 1024):
IF [%xmxIn%]==[] GOTO xmxIn
SET /a param=%xmxIn%+0
IF %param%==0 GOTO xmxIn
SET /a xmx=%xmxIn%

:paperIn
SET /p paperIn= Do you want to automatically download and use the newest paper version? (y/n):
IF [%paperIn%]==[] GOTO paperIn
IF NOT [%paperIn%]==[y] IF NOT [%paperIn%]==[n] GOTO paperIn
SET paper=%paperIn%

IF [%paper%]==[y] (
GOTO paperVersionIn
) else (
GOTO jarIn
)

:paperVersionIn
SET /p paperVersionIn= Enter the version you want to download (i.E. 1.16.5):
IF [%paperVersionIn%]==[] GOTO paperVersionIn
IF "x%paperVersionIn:1.=%"=="x%paperVersionIn%" GOTO paperVersionIn
SET paperVersion=%paperVersionIn%
SET jar=paper-%paperVersion%.jar
GOTO aikarFlags

:jarIn
SET /p jarIn= Enter the name of your server.jar (i.E. paper.jar):
IF [%jarIn%]==[] GOTO jarIn
IF "x%jarIn:.jar=%"=="x%jarIn%" GOTO jarIn
SET jar=%jarIn%
GOTO aikarFlags

:aikarFlags
SET /p aikarFlags= Do you want to use Aikar's Flags? (recommended, this flags might optimize the performance of your server) (y/n):
IF [%aikarFlags%]==[] GOTO aikarFlags
IF NOT [%aikarFlags%]==[y] IF NOT [%aikarFlags%]==[n] GOTO aikarFlags
SET aikarFlags=%aikarFlags%

:eulaIn
SET /p eulaIn= Do you want to automatically accept the minecraft eula? (y/n):
IF [%eulaIn%]==[] GOTO eulaIn
IF NOT [%eulaIn%]==[y] IF NOT [%eulaIn%]==[n] GOTO eulaIn
SET eula=%eulaIn%

:keepOnline
SET /p keepOnline= Do you want keep the server always online after every startup? (y/n):
IF [%keepOnline%]==[] GOTO keepOnline
IF NOT [%keepOnline%]==[y] IF NOT [%keepOnline%]==[n] GOTO keepOnline
SET online=%keepOnline%

:optimize
SET /p optimize= Do you want to auto optimize the server? (y/n):
IF [%optimize%]==[] GOTO optimize
IF NOT [%optimize%]==[y] IF NOT [%optimize%]==[n] GOTO optimize
SET optimization=%optimize%

set port=n
goto skip

:portForward
SET /p portForward= Do you want to auto port forward the server? (y/n):
IF [%portForward%]==[] GOTO portForward
IF NOT [%portForward%]==[y] IF NOT [%portForward%]==[n] GOTO portForward
SET port=%portForward%

:skip

cls

IF %min% EQU %max% (
echo java version: %min%
) ELSE (
echo java version between %min% and %max%
)
echo download paper.jar: %paper%
echo auto-accept eula: %eula%
echo jar-name: %jar%
echo 24/7: %online%
IF [%ram%]==[y] (
echo    Xmx: %xmx%MB
)
IF %min% LEQ 8 (
echo.
echo  --------------------------------------------------------------- WARNING ---------------------------------------------------------------
echo.
echo  your selected Java version is pretty outdated, if you don't need to use this version I strongly recommend using a more recent version.
echo.
echo  --------------------------------------------------------------- WARNING ---------------------------------------------------------------
echo.
)
echo  ---------------------------------
echo    Searching for java versions..
echo    this may take several minutes
echo  ---------------------------------
echo.


SET javaPath=java
FOR /f "tokens=3" %%g IN ('java -version 2^>^&1 ^| findstr /i "version"') DO (
SET JAVAVER=%%g
)
SET JAVAVER=%JAVAVER:"=%
FOR /f "delims=. tokens=1-3" %%v IN ("%JAVAVER%") DO CALL :javaVersionCheck %%v %%w %%x

SET javaPath=%CD:~0,3%
cd %javaPath%
echo %javaPath%


:: loop through all java.exe's
FOR /f %%i IN ('dir java.exe /b /s') DO CALL :javaCheck %%i
GOTO noJavaVersion



:javaCheck
SET searchString=%1
SET key=java.exe
CALL SET keyRemoved=%%searchString:%key%=%%
:: if path contains a java.exe
IF NOT "x%keyRemoved%"=="x%searchString%" (
IF "x%searchString:$Recycle.Bin=%"=="x%searchString%" (
CALL :javaVersionTrim %searchString%
)
GOTO End
)
GOTO End



:javaVersionTrim
SET javaPath=%1

:: extract java version
FOR /f "tokens=3" %%g IN ('%1 -version 2^>^&1 ^| findstr /i "version"') DO (
SET JAVAVER=%%g
)
SET JAVAVER=%JAVAVER:"=%
IF NOT "x%JAVAVER:.=%"=="x%JAVAVER%" (
	FOR /f "delims=. tokens=1-3" %%v IN ("%JAVAVER%") DO CALL :javaVersionCheck %%v %%w %%x
	GOTO End
)
SET /a ver=%JAVAVER%
:: IF %ver% EQU 16 (
CALL :javaVersionCheck %JAVAVER%,0,0
:: )
GOTO End



:javaVersionCheck

SET /a major=%1
SET /a minor=%2
SET build=%3

:: check java version
IF DEFINED major (
IF DEFINED minor (
IF %min% LEQ 8 (
	IF %major% EQU 1 (
		IF %minor% GEQ %min% (
			IF %minor% LEQ %max% (
				IF %minor% LEQ 8 (
					echo FOUND JAVA VERSION: %minor%

					IF %paper%==y (
						CALL :downloadPaper
						GOTO End
					) else (
						CALL :createBat
						GOTO End
					)
					GOTO End
				)
				GOTO End
			)
			GOTO End
		)
		GOTO End
	)
	GOTO End
)
)
IF %major% GEQ %min% (
	IF %major% LEQ %max% (
		echo FOUND JAVA VERSION: %major%
		IF %paper%==y (
			CALL :downloadPaper
			GOTO End
		) else (
			CALL :createBat
			GOTO End
		)
		GOTO End
	)
	GOTO End
)
GOTO End
)
GOTO End



:downloadPaper
echo Downloading paper.jar
curl.exe -# -L -o "%currentPath%paper-%paperVersion%.jar" "https://papermc.io/api/v1/paper/%paperVersion%/latest/download"
echo Download complete.
CALL :createBat
GOTO End

:shortcut
goto:EOF
set shortcut=y
if %shortcut%==n goto:EOF
echo  Creating shortcut
set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%USERPROFILE%\Desktop\Minecraft Server.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = ""%currentPath%start.bat"" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%

cscript /nologo %SCRIPT%
del %SCRIPT%
echo  Shortcut created.
goto:EOF

:createBat
IF [%aikarFlags%]==[y] (
SET "jvmFlags=-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar"
) else (
SET "jvmFlags=-jar"
)

IF [%ram%]==[y] (
SET content="%javaPath%" -Xmx%xmx%M %jvmFlags% %jar% nogui
) else (
SET content="%javaPath%" %jvmFlags% %jar% nogui
)

call:port
echo Creating start.bat
echo @echo off>"%currentPath%start.bat"
echo title Minecraft Server>>"%currentPath%start.bat"
echo :start>>"%currentPath%start.bat"
::if %ported%==y echo taskkill /f /im ngrok.exe>>"%currentPath%start.bat"
::if %ported%==y echo start port.bat>>"%currentPath%start.bat"
echo %content%>>"%currentPath%start.bat"
if %online%==y echo timeout 10>>"%currentPath%start.bat"
if %online%==y echo goto start>>"%currentPath%start.bat"
echo pause>>"%currentPath%start.bat"
echo start.bat created^!
IF %eula% == y (
echo eula=true>"%currentPath%eula.txt"
echo eula accepted!
)
call:shortcut
call:optimizeFiles
GOTO Exit


:optimizeFiles
if %optimization%==n set %ported%=n & goto:EOF
echo Optimizing server.
curl.exe -s -L -o "%currentPath%Bukkit.yml" "https://raw.githubusercontent.com/Kotsasmin/Advanced_Minecraft_Paper_Server_Maker/main/Bukkit.yml?token=AQLITFRBFQ6S5PMCT2FQL23A3VWWE"
curl.exe -s -L -o "%currentPath%paper.yml" "https://raw.githubusercontent.com/Kotsasmin/Advanced_Minecraft_Paper_Server_Maker/main/paper.yml?token=AQLITFTAT22RS6GBXJGX7TDA3VWX4"
curl.exe -s -L -o "%currentPath%spigot.yml" "https://raw.githubusercontent.com/Kotsasmin/Advanced_Minecraft_Paper_Server_Maker/main/spigot.yml?token=AQLITFSTHJWX5V6SFEX3BQLA3VWZI"
(
echo maxt-tick-time=10
echo view-distance=6
)>%currentPath%server.properties
echo Server is optimized^!
goto:EOF

:port
if %port%==n goto:EOF
::curl.exe -s -L -o "%currentPath%ngrok.exe" "https://www.dropbox.com/s/ryety6bb36fuxnv/ngrok.exe?dl=1"

timeout 1 /nobreak >nul

echo.
echo.
echo.
echo In order to port forward your server you need to finish some steps...
echo.
echo 1st step: Sign up in this website: https://dashboard.ngrok.com/signup
echo.
echo Press any key to continue...
start https://dashboard.ngrok.com/signup
pause>nul
echo.
echo.
echo 2nd step: Go to this website: https://dashboard.ngrok.com/get-started/setup
echo.
echo Press any key to continue...
start https://dashboard.ngrok.com/get-started/setup
pause>nul
echo.
echo.
echo 3rd step: Copy the authtoken from the website. It will be something like
echo           this: 2uiQ1I5fW76kFu6PSKIRaPTGRi8_3VsXUkt1rwbkiZtT6ZQBS (only the authtoken^!)
echo.
echo Press any key to continue...
pause>nul
echo.
set /p "auth=4th step: Paste here the auth token: "
echo.
echo Trying to port forward the server...
curl.exe -s -L -o "%currentPath%ngrok.zip" "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip"
powershell -Command Expand-Archive -Path "%currentPath%ngrok.zip" -DestinationPath "%currentPath%ngrok.exe"
%currentPath%ngrok.exe authtoken %auth%
::%currentPath%ngrok.exe tcp -region eu 25565
echo @echo off>%currentPath%port.bat
echo title Port forwarder
echo echo Please wait...>>%currentPath%port.bat
echo timeout 120 /nobreak >nul>>%currentPath%port.bat
echo ngrok.exe\ngrok.exe tcp -region eu 25565>>%currentPath%port.bat
set ported=y
echo The server has been port forwarded^!
goto:EOF




:noJavaVersion
cls
IF %min% EQU %max% (
echo No Java %max% found.
) else (
echo No version between Java %min% and Java %max% found.
)
echo Please download it from https://adoptopenjdk.net/installation.html



:javaIn
SET /p javaIn= Do you want to automatically download java? (y/n):
IF [%javaIn%]==[] GOTO javaIn
IF NOT [%javaIn%]==[y] IF NOT [%javaIn%]==[n] GOTO javaIn
SET java=%javaIn%

IF [%java%]==[y] (
GOTO downloadJava
)
GOTO Exit



:downloadJava
cls
echo.
echo  Which java version do you want to download?
echo.
echo  [8] 8 (LTS)
echo  [9] 9
echo  [10] 10
echo  [11] 11 (LTS)
echo  [13] 13
echo  [14] 14
echo  [15] 15
echo  [16] 16 (Latest)
echo.

SET /p downloadJavaVersionIn= Enter which version you want to download: 
IF [%downloadJavaVersionIn%]==[] GOTO downloadJava
SET /a param=%downloadJavaVersionIn%+0
IF %param% == 0 GOTO downloadJava
IF %param% LEQ 7 GOTO downloadJava
IF %param% == 12 GOTO downloadJava
IF %param% GEQ 17 GOTO downloadJava
SET /a downloadJavaVersion=%downloadJavaVersionIn%

:: Detect OS bit-ness on running system.  Assumes 32-bit if 64-bit components do not exist.
SET "ARCH=x64"
IF NOT EXIST "%SystemRoot%\SysWOW64\cmd.exe" (
	IF NOT DEFINED PROCESSOR_ARCHITEW6432 (
		echo Your System runs on 32-bit. Currently only 64-bit is supported.
		GOTO Exit
	)
)


SET "link=https://jdk-%downloadJavaVersion%.l4zs.de/"


CALL :downloadJDK %link%



:downloadJDK
IF NOT EXIST "C:\Java" (
md C:\Java
)
cls
echo Downloading Java...
curl.exe -# -L -o "C:\Java\jdk-%downloadJavaVersion%.zip" "%1"
echo Download completed^!
echo Installing Java

powershell -Command Expand-Archive -Path "C:\Java\jdk-%downloadJavaVersion%.zip" -DestinationPath "C:\Java"
timeout 1 /nobreak >nul
del "C:\Java\jdk-%downloadJavaVersion%.zip"

IF %downloadJavaVersion%==8 (
SET "folder=jdk8u282-b08"
) ELSE IF %downloadJavaVersion%==9 (
SET "folder=jdk-9.0.4+11"
) ELSE IF %downloadJavaVersion%==10 (
SET "folder=jdk-10.0.2+13"
) ELSE IF %downloadJavaVersion%==11 (
SET "folder=jdk-11.0.10+9"
) ELSE IF %downloadJavaVersion%==13 (
SET "folder=jdk-13.0.2+8"
) ELSE IF %downloadJavaVersion%==14 (
SET "folder=jdk-14.0.2+12"
) ELSE IF %downloadJavaVersion%==15 (
SET "folder=jdk-15.0.2+7"
) ELSE IF %downloadJavaVersion%==16 (
SET "folder=jdk-16.0.1+9"
)
cls
echo.
echo Installed Java %downloadJavaVersion%

SET "javaPath=C:\Java\%folder%\bin\java.exe"



:javaHomeIn
SET /p javaHomeIn= Do you want to set Java %downloadJavaVersion% as JAVA_HOME? - INFO: THIS REQUIRES THE BAT TO BE RUN AS ADMINISTRATOR (y/n):
IF [%javaHomeIn%]==[] GOTO javaHomeIn
IF NOT [%javaHomeIn%]==[y] IF NOT [%javaHomeIn%]==[n] GOTO javaHomeIn
SET javaHome=%javaHomeIn%

IF [%javaHome%]==[y] (
setx -m JAVA_HOME "C:\Java\%folder%"
setx -m PATH "C:\Java\%folder%\bin;%PATH%"
echo Set JAVA_HOME to Java %downloadJavaVersion%
SET javaPath=java
)

IF %paper%==y (
	CALL :downloadPaper
	GOTO End
) else (
	CALL :createBat
	GOTO End
)

pause


GOTO Exit

:noInternet
cls
echo You need internet connection to proceed... Please check your internet connection and wait...
timeout 3 /nobreak >nul
Ping www.google.nl -n 1 -w 1000 >nul
if errorlevel 1 (set internet=n) else (set internet=y)
if %internet%==n goto noInternet
goto:EOF

:checkForUpdates
if exist "%currentPath%version.txt" del "%currentPath%version.txt"
curl -s -L -o "%currentPath%version.txt" "https://raw.githubusercontent.com/Kotsasmin/Advanced_Minecraft_Paper_Server_Maker/main/version.txt"
set /p newVersion=<"%currentPath%version.txt"
timeout 1 /nobreak >nul
del %currentPath%version.txt
if %newVersion%==%version% goto:EOF
cls
SET /p newInstall= There is a new version of this software: %newVersion% Do you want to download it? (y/n):
IF [%newInstall%]==[] GOTO javaHomeIn
IF NOT [%newInstall%]==[y] IF NOT [%newInstall%]==[n] GOTO newInstall
SET newInstallation=%newInstall%
if %newInstallation%==n goto:EOF
cls
echo Downloading new version...
curl -s -L -o "%currentPath%Advanced Minecraft Paper Server Maker (%newVersion%).bat" "https://raw.githubusercontent.com/Kotsasmin/Advanced_Minecraft_Paper_Server_Maker/main/advanced-minecraft-paper-server-maker.bat"
timeout 1 /nobreak >nul
start "" "%currentPath%Advanced Minecraft Paper Server Maker (%newVersion%).bat"
(goto) 2>nul & del "%~f0"
exit


:ti
set currentTime=%time:~0,-3%
goto:EOF


:Exit
echo Press any key to exit
echo.
PAUSE
EXIT
GOTO eof



:End
                                                
