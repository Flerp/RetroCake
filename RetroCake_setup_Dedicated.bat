@echo off
::Admin Check
:check_Permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
        goto setvars
    ) else (
        goto AdminFail
    )

    pause >nul

:setvars
::Sets time variables for the backup files
set dayte=%date:~4,10%
set thyme=%time:~0,8%
set gooddayte=%dayte:/=%
set goodthyme=%thyme::=%
goto check7z

:check7z
IF EXIST C:\7za\7za.exe goto menu
goto install7z


:install7z
Echo Setting up 7-Zip environment.
mkdir C:\7za
powershell -command (New-Object Net.WebClient).DownloadFile('http://www.7-zip.org/a/7za920.zip','C:\7za\7za.zip');(new-object -com shell.application).namespace('C:\7za').CopyHere((new-object -com shell.application).namespace('C:\7za\7za.zip').Items(),16)
ping 127.0.0.1 -n 2 >nul
del C:\7za\7za.zip
goto menu

:menu
cls
echo ===========================================================================
echo =                                                                         =
Echo =    1.) Automated install of EmulationStation and RetroArch              =
echo =                                                                         =
echo =    2.) Update/Install EmulationStation with the latest Windows build    =
echo =                                                                         =
echo =    3.) Update RetroArch and Cores to the latest nightly build           =
echo =                                                                         =
echo =    4.) Setup ROM directories and shares                                 =
echo =                                                                         =
echo =    5.) Manage es_systems.cfg                                            =
echo =                                                                         =
echo =    6.) Set Windows to Start EmulationStation on login                   =
echo =                                                                         =
echo =    7.) Set Windows Hostname to RetroPieWin                              =
echo =                                                                         =
echo ===========================================================================
CHOICE /N /C:1234567 /M "Enter Corresponding Menu choice (1, 2, 3, 4, 5, 6, 7)"%1
IF ERRORLEVEL ==7 GOTO hostname
IF ERRORLEVEL ==6 GOTO startupES
IF ERRORLEVEL ==5 GOTO manageCFG
IF ERRORLEVEL ==4 GOTO mkdirROMS
IF ERRORLEVEL ==3 GOTO updateRA
IF ERRORLEVEL ==2 GOTO updateES
IF ERRORLEVEL ==1 GOTO BrandNew

:updateES
::Backs up old installation

C:\7za\7za.exe a "%USERPROFILE%\ES_Backup_%gooddayte%_%goodthyme%.zip" "%ProgramFiles%\EmulationStation\"


::Removes old Files
rmdir "%ProgramFiles%\EmulationStation" /s /q
rmdir "%ProgramFiles(x86)%\EmulationStation" /s /q
mkdir "%ProgramFiles%\EmulationStation"

::Deletes old shortcut
del "%USERPROFILE%\Desktop\*statio*.lnk

::Downloads the latest build of EmulationStation
cls
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo ====================================================
echo =                                                  =
echo = Downloading the latest build of EmulationStation =
echo =                                                  =
echo ====================================================
powershell -command "Invoke-WebRequest -Uri https://github.com/jrassa/EmulationStation/releases/download/continuous/EmulationStation-Win32.zip -OutFile "%USERPROFILE%\ES.zip""

::Extracts to the Program Files Directory.

C:\7za\7za.exe x "%USERPROFILE%\ES.zip" -o"%ProgramFiles%\EmulationStation"

::New Shortcut Maker
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%USERPROFILE%\CreateShortcut.vbs"
echo sLinkFile = "%USERPROFILE%\Desktop\EmulationStation.lnk" >> "%USERPROFILE%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%USERPROFILE%\CreateShortcut.vbs"
echo oLink.TargetPath = "%ProgramFiles%\EmulationStation\emulationstation.exe" >> "%USERPROFILE%\CreateShortcut.vbs"
echo oLink.Save >> "%USERPROFILE%\CreateShortcut.vbs"
cscript "%USERPROFILE%\CreateShortcut.vbs"
del "%USERPROFILE%\CreateShortcut.vbs"

::Cleans up Downlaoded zip
del "%USERPROFILE%\ES.zip"

::Checks for basic carbon theme.
IF EXIST "%USERPROFILE%\.emulationstation\themes\carbon" (
    goto menu
) ELSE (
    goto installtheme
)

:installtheme
cls
mkdir "%USERPROFILE%\.emulationstation\themes"
powershell -command "Invoke-WebRequest -Uri https://blog.petrockblock.com/wp-content/uploads/2015/09/ES_theme_carbon.zip -OutFile "%USERPROFILE%\Carbon.zip""

C:\7za\7za.exe x "%USERPROFILE%\Carbon.zip" -o"%USERPROFILE%\.emulationstation\themes"
ping 127.0.0.1 -n 4 >nul
del "%USERPROFILE%\Carbon.zip" /s /q
goto menu

:updateRA
cls
cls
mkdir "%USERPROFILE%\cores"
cls
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
		goto x64RA
	)
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		goto x86RA
	)
:x64RA
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo =================================================================
echo =                                                               =
echo =   Downloading RetroArch and cores. This will take some time   =
echo =                                                               =
echo =================================================================
mkdir C:\RetroArch
powershell -command "Invoke-WebRequest -Uri https://buildbot.libretro.com/stable/1.6.7/windows/x86_64/RetroArch.7z -OutFile "%USERPROFILE%\RetroArch_x64.zip""

C:\7za\7za.exe x "%USERPROFILE%\RetroArch_x64.zip" -o"C:\RetroArch" -aoa
ping 127.0.0.1 -n 4 >nul
del "%USERPROFILE%\RetroArch_x64.zip" /q
goto x64core

:x86RA
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo =================================================================
echo =                                                               =
echo =        Downloading RetroArch. This will take some time        =
echo =                                                               =
echo =================================================================
mkdir C:\RetroArch
powershell -command "Invoke-WebRequest -Uri https://buildbot.libretro.com/stable/1.6.7/windows/x86/RetroArch.7z -OutFile "%USERPROFILE%\RetroArch_x86.zip""

C:\7za\7za.exe x "%USERPROFILE%\RetroArch_x86.zip" -o"C:\RetroArch" -aoa
ping 127.0.0.1 -n 4 >nul
del "%USERPROFILE%\RetroArch_x86.zip" /q
goto x86core

:x64core
cls
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo =================================================================
echo =                                                               =
echo =        Downloading RetroArch. This will take some time        =
echo =                                                               =
echo =================================================================
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/2048_libretro.dll.zip -OutFile "%USERPROFILE%\cores\1.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/3dengine_libretro.dll.zip -OutFile "%USERPROFILE%\cores\2.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/4do_libretro.dll.zip -OutFile "%USERPROFILE%\cores\3.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/81_libretro.dll.zip -OutFile "%USERPROFILE%\cores\4.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/atari800_libretro.dll.zip -OutFile "%USERPROFILE%\cores\5.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bluemsx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\6.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bnes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\7.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_accuracy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\8.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_balanced_libretro.dll.zip -OutFile "%USERPROFILE%\cores\9.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_cplusplus98_libretro.dll.zip -OutFile "%USERPROFILE%\cores\10.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_mercury_accuracy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\11.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_mercury_balanced_libretro.dll.zip -OutFile "%USERPROFILE%\cores\12.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_mercury_performance_libretro.dll.zip -OutFile "%USERPROFILE%\cores\13.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_performance_libretro.dll.zip -OutFile "%USERPROFILE%\cores\14.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/cap32_libretro.dll.zip -OutFile "%USERPROFILE%\cores\15.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/citra_libretro.dll.zip -OutFile "%USERPROFILE%\cores\16.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/craft_libretro.dll.zip -OutFile "%USERPROFILE%\cores\17.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/crocods_libretro.dll.zip -OutFile "%USERPROFILE%\cores\18.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/desmume_libretro.dll.zip -OutFile "%USERPROFILE%\cores\19.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/dinothawr_libretro.dll.zip -OutFile "%USERPROFILE%\cores\20.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/dolphin_libretro.dll.zip -OutFile "%USERPROFILE%\cores\21.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/dosbox_libretro.dll.zip -OutFile "%USERPROFILE%\cores\22.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/emux_chip8_libretro.dll.zip -OutFile "%USERPROFILE%\cores\23.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/emux_gb_libretro.dll.zip -OutFile "%USERPROFILE%\cores\24.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/emux_nes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\25.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/emux_sms_libretro.dll.zip -OutFile "%USERPROFILE%\cores\26.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha2012_cps1_libretro.dll.zip -OutFile "%USERPROFILE%\cores\27.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha2012_cps2_libretro.dll.zip -OutFile "%USERPROFILE%\cores\28.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha2012_libretro.dll.zip -OutFile "%USERPROFILE%\cores\29.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha2012_neogeo_libretro.dll.zip -OutFile "%USERPROFILE%\cores\30.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha_libretro.dll.zip -OutFile "%USERPROFILE%\cores\31.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fceumm_libretro.dll.zip -OutFile "%USERPROFILE%\cores\32.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/ffmpeg_libretro.dll.zip -OutFile "%USERPROFILE%\cores\33.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fmsx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\34.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fuse_libretro.dll.zip -OutFile "%USERPROFILE%\cores\35.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/gambatte_libretro.dll.zip -OutFile "%USERPROFILE%\cores\36.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/genesis_plus_gx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\37.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/gme_libretro.dll.zip -OutFile "%USERPROFILE%\cores\38.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/gpsp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\39.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/gw_libretro.dll.zip -OutFile "%USERPROFILE%\cores\40.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/handy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\41.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/hatari_libretro.dll.zip -OutFile "%USERPROFILE%\cores\42.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/higan_sfc_libretro.dll.zip -OutFile "%USERPROFILE%\cores\43.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/imageviewer_libretro.dll.zip -OutFile "%USERPROFILE%\cores\44.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/lutro_libretro.dll.zip -OutFile "%USERPROFILE%\cores\45.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame2000_libretro.dll.zip -OutFile "%USERPROFILE%\cores\46.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame2003_libretro.dll.zip -OutFile "%USERPROFILE%\cores\47.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame2010_libretro.dll.zip -OutFile "%USERPROFILE%\cores\48.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\49.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame_libretro.dll.zip -OutFile "%USERPROFILE%\cores\50.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_gba_libretro.dll.zip -OutFile "%USERPROFILE%\cores\51.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_lynx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\52.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_ngp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\53.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_pce_fast_libretro.dll.zip -OutFile "%USERPROFILE%\cores\54.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_pcfx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\55.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_psx_hw_libretro.dll.zip -OutFile "%USERPROFILE%\cores\56.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_psx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\57.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_saturn_libretro.dll.zip -OutFile "%USERPROFILE%\cores\58.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_snes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\59.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_supergrafx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\60.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_vb_libretro.dll.zip -OutFile "%USERPROFILE%\cores\61.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_wswan_libretro.dll.zip -OutFile "%USERPROFILE%\cores\62.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/melonds_libretro.dll.zip -OutFile "%USERPROFILE%\cores\63.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mess2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\64.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/meteor_libretro.dll.zip -OutFile "%USERPROFILE%\cores\65.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mgba_libretro.dll.zip -OutFile "%USERPROFILE%\cores\66.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mrboom_libretro.dll.zip -OutFile "%USERPROFILE%\cores\67.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mupen64plus_libretro.dll.zip -OutFile "%USERPROFILE%\cores\68.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/nekop2_libretro.dll.zip -OutFile "%USERPROFILE%\cores\69.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/nestopia_libretro.dll.zip -OutFile "%USERPROFILE%\cores\70.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/np2kai_libretro.dll.zip -OutFile "%USERPROFILE%\cores\71.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/nxengine_libretro.dll.zip -OutFile "%USERPROFILE%\cores\72.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/o2em_libretro.dll.zip -OutFile "%USERPROFILE%\cores\73.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/openlara_libretro.dll.zip -OutFile "%USERPROFILE%\cores\74.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/parallel_n64_libretro.dll.zip -OutFile "%USERPROFILE%\cores\75.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/pcsx_rearmed_libretro.dll.zip -OutFile "%USERPROFILE%\cores\76.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/picodrive_libretro.dll.zip -OutFile "%USERPROFILE%\cores\77.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/pocketcdg_libretro.dll.zip -OutFile "%USERPROFILE%\cores\78.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/pokemini_libretro.dll.zip -OutFile "%USERPROFILE%\cores\79.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/ppsspp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\80.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/prboom_libretro.dll.zip -OutFile "%USERPROFILE%\cores\81.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/prosystem_libretro.dll.zip -OutFile "%USERPROFILE%\cores\82.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/puae_libretro.dll.zip -OutFile "%USERPROFILE%\cores\83.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/px68k_libretro.dll.zip -OutFile "%USERPROFILE%\cores\84.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/quicknes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\85.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/redream_libretro.dll.zip -OutFile "%USERPROFILE%\cores\86.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/reicast_libretro.dll.zip -OutFile "%USERPROFILE%\cores\87.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/remotejoy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\88.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/sameboy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\89.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/scummvm_libretro.dll.zip -OutFile "%USERPROFILE%\cores\90.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x2002_libretro.dll.zip -OutFile "%USERPROFILE%\cores\91.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x2005_libretro.dll.zip -OutFile "%USERPROFILE%\cores\92.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x2005_plus_libretro.dll.zip -OutFile "%USERPROFILE%\cores\93.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x2010_libretro.dll.zip -OutFile "%USERPROFILE%\cores\94.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x_libretro.dll.zip -OutFile "%USERPROFILE%\cores\95.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/stella_libretro.dll.zip -OutFile "%USERPROFILE%\cores\96.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/tgbdual_libretro.dll.zip -OutFile "%USERPROFILE%\cores\97.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/tyrquake_libretro.dll.zip -OutFile "%USERPROFILE%\cores\98.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/ume2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\99.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vba_next_libretro.dll.zip -OutFile "%USERPROFILE%\cores\100.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vbam_libretro.dll.zip -OutFile "%USERPROFILE%\cores\101.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vecx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\102.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vice_x64_libretro.dll.zip -OutFile "%USERPROFILE%\cores\103.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vice_xplus4_libretro.dll.zip -OutFile "%USERPROFILE%\cores\104.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vice_xvic_libretro.dll.zip -OutFile "%USERPROFILE%\cores\105.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/virtualjaguar_libretro.dll.zip -OutFile "%USERPROFILE%\cores\106.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/xrick_libretro.dll.zip -OutFile "%USERPROFILE%\cores\107.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/yabause_libretro.dll.zip -OutFile "%USERPROFILE%\cores\108.zip"
mkdir C:\RetroArch\Cores

C:\7za\7za.exe x "%USERPROFILE%\cores\*.zip" -o"C:\RetroArch\Cores" -aoa
ping 127.0.0.1 -n 6 >nul
rmdir "%USERPROFILE%\cores" /s /q
goto menu

:x86core
cls
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo =================================================================
echo =                                                               =
echo =     Downloading RetroArch Cores. This will take some time     =
echo =                                                               =
echo =================================================================
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/2048_libretro.dll.zip -OutFile "%USERPROFILE%\cores\1.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/3dengine_libretro.dll.zip -OutFile "%USERPROFILE%\cores\2.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/4do_libretro.dll.zip -OutFile "%USERPROFILE%\cores\3.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/81_libretro.dll.zip -OutFile "%USERPROFILE%\cores\4.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/atari800_libretro.dll.zip -OutFile "%USERPROFILE%\cores\5.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bluemsx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\6.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bnes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\7.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_accuracy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\8.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_balanced_libretro.dll.zip -OutFile "%USERPROFILE%\cores\9.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_cplusplus98_libretro.dll.zip -OutFile "%USERPROFILE%\cores\10.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_mercury_accuracy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\11.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_mercury_balanced_libretro.dll.zip -OutFile "%USERPROFILE%\cores\12.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_mercury_performance_libretro.dll.zip -OutFile "%USERPROFILE%\cores\13.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_performance_libretro.dll.zip -OutFile "%USERPROFILE%\cores\14.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/cap32_libretro.dll.zip -OutFile "%USERPROFILE%\cores\15.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/citra_libretro.dll.zip -OutFile "%USERPROFILE%\cores\16.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/craft_libretro.dll.zip -OutFile "%USERPROFILE%\cores\17.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/crocods_libretro.dll.zip -OutFile "%USERPROFILE%\cores\18.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/desmume_libretro.dll.zip -OutFile "%USERPROFILE%\cores\19.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/dinothawr_libretro.dll.zip -OutFile "%USERPROFILE%\cores\20.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/dolphin_libretro.dll.zip -OutFile "%USERPROFILE%\cores\21.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/dosbox_libretro.dll.zip -OutFile "%USERPROFILE%\cores\22.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/emux_chip8_libretro.dll.zip -OutFile "%USERPROFILE%\cores\23.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/emux_gb_libretro.dll.zip -OutFile "%USERPROFILE%\cores\24.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/emux_nes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\25.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/emux_sms_libretro.dll.zip -OutFile "%USERPROFILE%\cores\26.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha2012_cps1_libretro.dll.zip -OutFile "%USERPROFILE%\cores\27.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha2012_cps2_libretro.dll.zip -OutFile "%USERPROFILE%\cores\28.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha2012_libretro.dll.zip -OutFile "%USERPROFILE%\cores\29.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha2012_neogeo_libretro.dll.zip -OutFile "%USERPROFILE%\cores\30.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha_libretro.dll.zip -OutFile "%USERPROFILE%\cores\31.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fceumm_libretro.dll.zip -OutFile "%USERPROFILE%\cores\32.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/ffmpeg_libretro.dll.zip -OutFile "%USERPROFILE%\cores\33.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fmsx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\34.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fuse_libretro.dll.zip -OutFile "%USERPROFILE%\cores\35.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/gambatte_libretro.dll.zip -OutFile "%USERPROFILE%\cores\36.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/genesis_plus_gx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\37.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/gme_libretro.dll.zip -OutFile "%USERPROFILE%\cores\38.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/gpsp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\39.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/gw_libretro.dll.zip -OutFile "%USERPROFILE%\cores\40.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/handy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\41.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/hatari_libretro.dll.zip -OutFile "%USERPROFILE%\cores\42.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/higan_sfc_libretro.dll.zip -OutFile "%USERPROFILE%\cores\43.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/imageviewer_libretro.dll.zip -OutFile "%USERPROFILE%\cores\44.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/lutro_libretro.dll.zip -OutFile "%USERPROFILE%\cores\45.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame2000_libretro.dll.zip -OutFile "%USERPROFILE%\cores\46.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame2003_libretro.dll.zip -OutFile "%USERPROFILE%\cores\47.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame2010_libretro.dll.zip -OutFile "%USERPROFILE%\cores\48.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\49.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame_libretro.dll.zip -OutFile "%USERPROFILE%\cores\50.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_gba_libretro.dll.zip -OutFile "%USERPROFILE%\cores\51.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_lynx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\52.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_ngp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\53.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_pce_fast_libretro.dll.zip -OutFile "%USERPROFILE%\cores\54.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_pcfx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\55.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_psx_hw_libretro.dll.zip -OutFile "%USERPROFILE%\cores\56.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_psx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\57.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_saturn_libretro.dll.zip -OutFile "%USERPROFILE%\cores\58.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_snes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\59.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_supergrafx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\60.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_vb_libretro.dll.zip -OutFile "%USERPROFILE%\cores\61.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_wswan_libretro.dll.zip -OutFile "%USERPROFILE%\cores\62.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/melonds_libretro.dll.zip -OutFile "%USERPROFILE%\cores\63.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mess2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\64.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/meteor_libretro.dll.zip -OutFile "%USERPROFILE%\cores\65.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mgba_libretro.dll.zip -OutFile "%USERPROFILE%\cores\66.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mrboom_libretro.dll.zip -OutFile "%USERPROFILE%\cores\67.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mupen64plus_libretro.dll.zip -OutFile "%USERPROFILE%\cores\68.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/nekop2_libretro.dll.zip -OutFile "%USERPROFILE%\cores\69.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/nestopia_libretro.dll.zip -OutFile "%USERPROFILE%\cores\70.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/np2kai_libretro.dll.zip -OutFile "%USERPROFILE%\cores\71.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/nxengine_libretro.dll.zip -OutFile "%USERPROFILE%\cores\72.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/o2em_libretro.dll.zip -OutFile "%USERPROFILE%\cores\73.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/openlara_libretro.dll.zip -OutFile "%USERPROFILE%\cores\74.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/parallel_n64_libretro.dll.zip -OutFile "%USERPROFILE%\cores\75.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/pcsx_rearmed_libretro.dll.zip -OutFile "%USERPROFILE%\cores\76.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/picodrive_libretro.dll.zip -OutFile "%USERPROFILE%\cores\77.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/pocketcdg_libretro.dll.zip -OutFile "%USERPROFILE%\cores\78.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/pokemini_libretro.dll.zip -OutFile "%USERPROFILE%\cores\79.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/ppsspp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\80.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/prboom_libretro.dll.zip -OutFile "%USERPROFILE%\cores\81.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/prosystem_libretro.dll.zip -OutFile "%USERPROFILE%\cores\82.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/puae_libretro.dll.zip -OutFile "%USERPROFILE%\cores\83.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/px68k_libretro.dll.zip -OutFile "%USERPROFILE%\cores\84.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/quicknes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\85.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/redream_libretro.dll.zip -OutFile "%USERPROFILE%\cores\86.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/reicast_libretro.dll.zip -OutFile "%USERPROFILE%\cores\87.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/remotejoy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\88.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/sameboy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\89.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/scummvm_libretro.dll.zip -OutFile "%USERPROFILE%\cores\90.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x2002_libretro.dll.zip -OutFile "%USERPROFILE%\cores\91.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x2005_libretro.dll.zip -OutFile "%USERPROFILE%\cores\92.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x2005_plus_libretro.dll.zip -OutFile "%USERPROFILE%\cores\93.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x2010_libretro.dll.zip -OutFile "%USERPROFILE%\cores\94.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x_libretro.dll.zip -OutFile "%USERPROFILE%\cores\95.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/stella_libretro.dll.zip -OutFile "%USERPROFILE%\cores\96.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/tgbdual_libretro.dll.zip -OutFile "%USERPROFILE%\cores\97.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/tyrquake_libretro.dll.zip -OutFile "%USERPROFILE%\cores\98.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/ume2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\99.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vba_next_libretro.dll.zip -OutFile "%USERPROFILE%\cores\100.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vbam_libretro.dll.zip -OutFile "%USERPROFILE%\cores\101.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vecx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\102.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vice_x64_libretro.dll.zip -OutFile "%USERPROFILE%\cores\103.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vice_xplus4_libretro.dll.zip -OutFile "%USERPROFILE%\cores\104.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vice_xvic_libretro.dll.zip -OutFile "%USERPROFILE%\cores\105.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/virtualjaguar_libretro.dll.zip -OutFile "%USERPROFILE%\cores\106.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/xrick_libretro.dll.zip -OutFile "%USERPROFILE%\cores\107.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/yabause_libretro.dll.zip -OutFile "%USERPROFILE%\cores\108.zip"
mkdir C:\RetroArch\Cores

C:\7za\7za.exe x "%USERPROFILE%\cores\*.zip" -o"C:\RetroArch\Cores" -aoa
ping 127.0.0.1 -n 6 >nul
rmdir "%USERPROFILE%\cores" /s /q
goto menu

:mkdirROMS
mkdir C:\ROMS\amiga
mkdir C:\ROMS\atari2600
mkdir C:\ROMS\atari5200
mkdir C:\ROMS\atari7800
mkdir C:\ROMS\atari800
mkdir C:\ROMS\atarijaguar
mkdir C:\ROMS\atarilynx
mkdir C:\ROMS\coleco
mkdir C:\ROMS\fba
mkdir C:\ROMS\fds
mkdir C:\ROMS\gamegear
mkdir C:\ROMS\gb
mkdir C:\ROMS\gba
mkdir C:\ROMS\gbc
mkdir C:\ROMS\gc
mkdir C:\ROMS\intellivision
mkdir C:\ROMS\mame-libretro
mkdir C:\ROMS\mastersystem
mkdir C:\ROMS\megadrive
mkdir C:\ROMS\msx
mkdir C:\ROMS\n64
mkdir C:\ROMS\neogeo
mkdir C:\ROMS\nes
mkdir C:\ROMS\nds
mkdir C:\ROMS\ngp
mkdir C:\ROMS\ngpc
mkdir C:\ROMS\pcengine
mkdir C:\ROMS\psx
mkdir C:\ROMS\ps2
mkdir C:\ROMS\sega32x
mkdir C:\ROMS\segacd
mkdir C:\ROMS\sg-1000
mkdir C:\ROMS\snes
mkdir C:\ROMS\vectrex
mkdir C:\ROMS\zxspectrum
goto setshares

:setshares

net share amiga=C:\ROMS\amiga /grant:everyone,full
net share atari2600=C:\ROMS\atari2600 /grant:everyone,full
net share atari5200=C:\ROMS\atari5200 /grant:everyone,full
net share atari7800=C:\ROMS\atari7800 /grant:everyone,full
net share atari800=C:\ROMS\atari800 /grant:everyone,full
net share atarijaguar=C:\ROMS\atarijaguar /grant:everyone,full
net share atarilynx=C:\ROMS\atarilynx /grant:everyone,full
net share coleco=C:\ROMS\coleco /grant:everyone,full
net share fba=C:\ROMS\fba /grant:everyone,full
net share fds=C:\ROMS\fds /grant:everyone,full
net share gamegear=C:\ROMS\gamegear /grant:everyone,full
net share gb=C:\ROMS\gb /grant:everyone,full
net share gba=C:\ROMS\gba /grant:everyone,full
net share gbc=C:\ROMS\gbc /grant:everyone,full
net share gc=C:\ROMS\gc /grant:everyone,full
net share intellivision=C:\ROMS\intellivision /grant:everyone,full
net share mame-libretro=C:\ROMS\mame-libretro /grant:everyone,full
net share mastersystem=C:\ROMS\mastersystem /grant:everyone,full
net share megadrive=C:\ROMS\megadrive /grant:everyone,full
net share msx=C:\ROMS\msx /grant:everyone,full
net share n64=C:\ROMS\n64 /grant:everyone,full
net share neogeo=C:\ROMS\neogeo /grant:everyone,full
net share nes=C:\ROMS\nes /grant:everyone,full
net share nds=C:\ROMS\nds /grant:everyone,full
net share ngp=C:\ROMS\ngp /grant:everyone,full
net share ngpc=C:\ROMS\ngpc /grant:everyone,full
net share pcengine=C:\ROMS\pcengine /grant:everyone,full
net share psx=C:\ROMS\psx /grant:everyone,full
net share ps2=C:\ROMS\ps2 /grant:everyone,full
net share sega32x=C:\ROMS\sega32x /grant:everyone,full
net share segacd=C:\ROMS\segacd /grant:everyone,full
net share sg-1000=C:\ROMS\sg-1000 /grant:everyone,full
net share snes=C:\ROMS\snes /grant:everyone,full
net share vectrex=C:\ROMS\vectrex /grant:everyone,full
net share zxspectrum=C:\ROMS\zxspectrum /grant:everyone,full
goto setperms

:setperms
icacls "C:\ROMS" /grant everyone:(OI)(CI)F /T
goto menu


:ManageCFG
cls
echo ===========================================================================
echo =                                                                         =
Echo =    1.) Create new es_systems.cfg without ROM paths                      =
echo =                                                                         =
echo =    2.) Create new es_systems.cfg with default ROM path C:\ROMS\system   =
echo =                                                                         =
echo =    3.) Edit es_systems.cfg                                              =
echo =                                                                         =
echo ===========================================================================
CHOICE /N /C:123 /M "Enter Corresponding Menu choice (1, 2, 3)"%1
IF ERRORLEVEL ==3 GOTO editES
IF ERRORLEVEL ==2 GOTO defaultES
IF ERRORLEVEL ==1 GOTO blankES



:blankES
::Backs up current es_systems.cfg

C:\7za\7za.exe a "%USERPROFILE%\es_systems_%gooddayte%_%goodthyme%.zip" "%USERPROFILE%\.emulationstation\es_systems.cfg"

::Deletes old es_systems.cfg
del "%USERPROFILE%\.emulationstation\es_systems.cfg" /q

::Creates a new es_systems.cfg
cls
mkdir "%USERPROFILE%\.emulationstation"
echo ^<?xml version="1.0"?^> > "%USERPROFILE%\.emulationstation\es_systems.cfg"
echo ^<systemList^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>amstradcpc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Amstrad CPC^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.cdt .cpc .dsk .CDT .CPC .DSK^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\cap32_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>amstradcpc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>amstradcpc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari2600^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 2600^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .a26 .bin .rom .zip .gz .7Z .A26 .BIN .ROM .ZIP .GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\stella_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari2600^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari2600^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari5200^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 5200^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.a52 .bin .car .A52 .BIN .CAR^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\atari800_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari5200^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari5200^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari7800^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 7800 ProSystem^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .a78 .bin .zip .7Z .A78 .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\prosystem_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari7800^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari7800^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari800^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 800^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.bas .bin .car .com .xex .atr .xfd .dcm .atr.gz .xfd.gz .BAS .BIN .CAR .COM .XEX .ATR .XFD .DCM .ATR.GZ .XFD.GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\atari800_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari800^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari800^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atarijaguar^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari Jaguar^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.j64 .jag .zip .J64 .JAG .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\virtualjaguar_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atarijaguar^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atarijaguar^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atarilynx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari Lynx^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .lnx .zip .7Z .LNX .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\handy_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atarilynx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atarilynx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>coleco^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>ColecoVision^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.bin .col .rom .zip .BIN .COL .ROM .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bluemsx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>colecovision^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>colecovision^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>fba^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Final Burn Alpha^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.fba .zip .FBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fbalpha_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>arcade^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>fba^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>fds^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Famicom Disk System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.nes .fds .zip .NES .FDS .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fceumm_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>fds^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>fds^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gamegear^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Gamegear^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gg .bin .sms .zip .7Z .GG .BIN .SMS .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gamegear^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gamegear^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gb^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gb .zip .7Z .GB .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gambatte_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gb^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gb^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gba^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy Advance^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gba .zip .7Z .GBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gpsp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gba^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gba^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gbc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy Color^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gbc .zip .7Z .GBC .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gambatte_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gbc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gbc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>gc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Nintendo Gamecube^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.iso .gcz .gcn .ISO .GCZ .GCN^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\dolphin_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>gc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>gc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^>  >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>intellivision^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Intellivision^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.int .bin .INT .BIN^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>NEEDS ADDITIONAL EMULATOR "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>intellivision^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>intellivision^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>mame-libretro^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Multiple Arcade Machine Emulator^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.zip .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mame2003_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>arcade^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>mame^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>mastersystem^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Master System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .sms .bin .zip .7Z .SMS .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>mastersystem^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>mastersystem^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>megadrive^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Mega Drive^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .smd .bin .gen .md .sg .zip .7Z .SMD .BIN .GEN .MD .SG .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>megadrive^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>megadrive^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>msx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>MSX^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.rom .mx1 .mx2 .col .dsk .zip .ROM .MX1 .MX2 .COL .DSK .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bluemsx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>msx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>msx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>n64^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Nintendo 64^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.z64 .n64 .v64 .Z64 .N64 .V64^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mupen64plus_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>n64^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>n64^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>neogeo^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.fba .zip .FBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fbalpha_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>neogeo^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>neogeo^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>nes^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Nintendo Entertainment System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .nes .zip .7Z .NES .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fceumm_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>nes^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>nes^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>nds^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Nintendo DS^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.zip .ZIP .nds .NDS^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\melonds_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>nds^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>nds^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>ngp^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo Pocket^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.ngp .zip .NGP .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_ngp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>ngp^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>ngp^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>ngpc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo Pocket Color^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.ngc .zip .NGC .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_ngp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>ngpc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>ngpc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>pcengine^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>PC Engine^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .pce .ccd .cue .zip .7Z .PCE .CCD .CUE .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_pce_fast_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>pcengine^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>pcengine^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>psx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>PlayStation^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx .CUE .CBN .IMG .ISO .M3U .MDF .PBP .TOC .Z .ZNX^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\pcsx_rearmed_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>psx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>psx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>ps2^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Sony Playstation 2^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.iso .gz .ISO .GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\PCSX2\pcsx2.exe "%%ROM_RAW%%" --fullscreen^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>ps2^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>ps2^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>sega32x^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega 32X^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .32x .smd .bin .md .zip .7Z .32X .SMD .BIN .MD .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\picodrive_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>sega32x^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>sega32x^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>segacd^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Mega CD^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.iso .cue .ISO .CUE^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>segacd^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>segacd^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>sg-1000^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega SG-1000^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.sg .bin .zip .SG .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>sg-1000^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>sg-1000^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>snes^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Super Nintendo^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .bin .smc .sfc .fig .swc .mgd .zip .7Z .BIN .SMC .SFC .FIG .SWC .MGD .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\snes9x2010_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>snes^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>snes^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>vectrex^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Vectrex^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .vec .gam .bin .zip .7Z .VEC .GAM .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\vecx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>vectrex^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>vectrex^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>zxspectrum^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>ZX Spectrum^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\PATH\TO\ROM\FOLDER^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .sh .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip .7Z .SH .SNA .SZX .Z80 .TAP .TZX .GZ .UDI .MGT .IMG .TRD .SCL .DSK .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fuse_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>zxspectrum^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>zxspectrum^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo ^</systemList^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
goto menu

:defaultES
echo ^<?xml version="1.0"?^> > "%USERPROFILE%\.emulationstation\es_systems.cfg"
echo ^<systemList^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>amiga^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Amiga^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\amiga^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.adf .ADF .zip .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\puae_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>amiga^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>amiga^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>amstradcpc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Amstrad CPC^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\amstradcpc^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.cdt .cpc .dsk .CDT .CPC .DSK^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\cap32_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>amstradcpc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>amstradcpc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari2600^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 2600^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atari2600^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .a26 .bin .rom .zip .gz .7Z .A26 .BIN .ROM .ZIP .GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\stella_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari2600^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari2600^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari5200^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 5200^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atari5200^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.a52 .bin .car .A52 .BIN .CAR^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\atari800_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari5200^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari5200^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari7800^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 7800 ProSystem^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atari7800^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .a78 .bin .zip .7Z .A78 .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\prosystem_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari7800^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari7800^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari800^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 800^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atari800^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.bas .bin .car .com .xex .atr .xfd .dcm .atr.gz .xfd.gz .BAS .BIN .CAR .COM .XEX .ATR .XFD .DCM .ATR.GZ .XFD.GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\atari800_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari800^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari800^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atarijaguar^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari Jaguar^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atarijaguar^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.j64 .jag .zip .J64 .JAG .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\virtualjaguar_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atarijaguar^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atarijaguar^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atarilynx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari Lynx^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atarilynx^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .lnx .zip .7Z .LNX .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\handy_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atarilynx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atarilynx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>coleco^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>ColecoVision^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\coleco^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.bin .col .rom .zip .BIN .COL .ROM .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bluemsx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>colecovision^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>colecovision^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>fba^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Final Burn Alpha^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\fba^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.fba .zip .FBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fbalpha_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>arcade^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>fba^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>fds^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Famicom Disk System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\fds^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.nes .fds .zip .NES .FDS .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bnes_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>fds^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>fds^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gamegear^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Gamegear^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\gamegear^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gg .bin .sms .zip .7Z .GG .BIN .SMS .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gamegear^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gamegear^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gb^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\gb^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gb .zip .7Z .GB .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gambatte_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gb^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gb^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gba^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy Advance^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\gba^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gba .zip .7Z .GBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gpsp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gba^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gba^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gbc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy Color^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\gbc^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gbc .zip .7Z .GBC .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gambatte_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gbc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gbc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>gc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Nintendo Gamecube^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\ROMS\gc^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.iso .gcz .gcn .ISO .GCZ .GCN^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\dolphin_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>gc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>gc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^>  >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>intellivision^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Intellivision^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\intellivision^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.int .bin .INT .BIN^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>NEEDS ADDITIONAL EMULATOR "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>intellivision^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>intellivision^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>mame-libretro^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Multiple Arcade Machine Emulator^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\mame-libretro^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.zip .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mame2003_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>arcade^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>mame^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>mastersystem^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Master System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\mastersystem^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .sms .bin .zip .7Z .SMS .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>mastersystem^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>mastersystem^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>megadrive^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Mega Drive^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\megadrive^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .smd .bin .gen .md .sg .zip .7Z .SMD .BIN .GEN .MD .SG .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>megadrive^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>megadrive^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>msx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>MSX^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\msx^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.rom .mx1 .mx2 .col .dsk .zip .ROM .MX1 .MX2 .COL .DSK .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bluemsx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>msx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>msx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>n64^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Nintendo 64^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\n64^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.z64 .n64 .v64 .Z64 .N64 .V64^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mupen64plus_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>n64^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>n64^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>neogeo^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\neogeo^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.fba .zip .FBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fbalpha_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>neogeo^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>neogeo^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>nes^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Nintendo Entertainment System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\nes^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .nes .zip .7Z .NES .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bnes_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>nes^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>nes^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>nds^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Nintendo DS^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\ROMS\nds^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.zip .ZIP .nds .NDS^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\melonds_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>nds^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>nds^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>ngp^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo Pocket^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\ngp^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.ngp .zip .NGP .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_ngp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>ngp^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>ngp^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>ngpc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo Pocket Color^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\ngpc^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.ngc .zip .NGC .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_ngp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>ngpc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>ngpc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>pcengine^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>PC Engine^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\pcengine^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .pce .ccd .cue .zip .7Z .PCE .CCD .CUE .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_pce_fast_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>pcengine^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>pcengine^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>psx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>PlayStation^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\psx^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx .CUE .CBN .IMG .ISO .M3U .MDF .PBP .TOC .Z .ZNX^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\pcsx_rearmed_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>psx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>psx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>ps2^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Sony Playstation 2^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\ROMS\ps2^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.iso .gz .ISO .GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\PCSX2\pcsx2.exe "%%ROM_RAW%%" --fullscreen^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>ps2^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>ps2^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>sega32x^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega 32X^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\sega32x^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .32x .smd .bin .md .zip .7Z .32X .SMD .BIN .MD .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\picodrive_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>sega32x^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>sega32x^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>segacd^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Mega CD^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\segacd^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.iso .cue .ISO .CUE^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>segacd^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>segacd^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>sg-1000^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega SG-1000^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\sg-1000^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.sg .bin .zip .SG .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>sg-1000^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>sg-1000^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>snes^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Super Nintendo^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\snes^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .bin .smc .sfc .fig .swc .mgd .zip .7Z .BIN .SMC .SFC .FIG .SWC .MGD .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\snes9x2010_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>snes^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>snes^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>vectrex^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Vectrex^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\vectrex^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .vec .gam .bin .zip .7Z .VEC .GAM .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\vecx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>vectrex^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>vectrex^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>zxspectrum^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>ZX Spectrum^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\zxspectrum^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .sh .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip .7Z .SH .SNA .SZX .Z80 .TAP .TZX .GZ .UDI .MGT .IMG .TRD .SCL .DSK .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fuse_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>zxspectrum^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>zxspectrum^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo ^</systemList^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
goto menu

:editES
cls
notepad %USERPROFILE%\.emulationstation\es_systems.cfg
goto menu

:startupES
cd "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
echo taskkill /im explorer.exe /f > "%USERPROFILE%\startES.bat"
echo "%ProgramFiles%\EmulationStation\emulationstation.exe" >> "%USERPROFILE%\startES.bat"

del "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\startES.lnk"
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%USERPROFILE%\CreateShortcut2.vbs"
echo sLinkFile = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\startES.lnk" >> "%USERPROFILE%\CreateShortcut2.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%USERPROFILE%\CreateShortcut2.vbs"
echo oLink.TargetPath = "%USERPROFILE%\startES.bat" >> "%USERPROFILE%\CreateShortcut2.vbs"
echo oLink.Save >> "%USERPROFILE%\CreateShortcut2.vbs"
cscript "%USERPROFILE%\CreateShortcut2.vbs"
del "%USERPROFILE%\CreateShortcut2.vbs"
goto autologin

:autologin
cls
set /p ESpassword="Enter Windows Password: "
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d %username% /f
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d %ESpassword% /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonCount /t REG_DWORD /d 0
goto menu

:hostname
WMIC computersystem where caption='%COMPUTERNAME%' rename RetroCake
goto menu

::===================================================================================================================================================================================================================================================================================================================

:BrandNew
cls
::Backs up old installation

C:\7za\7za.exe a "%USERPROFILE%\ES_Backup_%gooddayte%_%goodthyme%.zip" "%ProgramFiles%\EmulationStation\"


::Removes old Files
rmdir "%ProgramFiles%\EmulationStation" /s /q
rmdir "%ProgramFiles(x86)%\EmulationStation" /s /q
mkdir "%ProgramFiles%\EmulationStation"

::Deletes old shortcut
del "%USERPROFILE%\Desktop\*statio*.lnk

::Downloads the latest build of EmulationStation
cls
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo ====================================================
echo =                                                  =
echo = Downloading the latest build of EmulationStation =
echo =                                                  =
echo ====================================================
powershell -command "Invoke-WebRequest -Uri https://github.com/jrassa/EmulationStation/releases/download/continuous/EmulationStation-Win32.zip -OutFile "%USERPROFILE%\ES.zip""

::Extracts to the Program Files Directory.

C:\7za\7za.exe x "%USERPROFILE%\ES.zip" -o"%ProgramFiles%\EmulationStation"

::New Shortcut Maker
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%USERPROFILE%\CreateShortcut.vbs"
echo sLinkFile = "%USERPROFILE%\Desktop\EmulationStation.lnk" >> "%USERPROFILE%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%USERPROFILE%\CreateShortcut.vbs"
echo oLink.TargetPath = "%ProgramFiles%\EmulationStation\emulationstation.exe" >> "%USERPROFILE%\CreateShortcut.vbs"
echo oLink.Save >> "%USERPROFILE%\CreateShortcut.vbs"
cscript "%USERPROFILE%\CreateShortcut.vbs"
del "%USERPROFILE%\CreateShortcut.vbs"

::Install basic Carbon Theme
mkdir "%USERPROFILE%\.emulationstation\themes"
powershell -command "Invoke-WebRequest -Uri https://blog.petrockblock.com/wp-content/uploads/2015/09/ES_theme_carbon.zip -OutFile "%USERPROFILE%\Carbon.zip"

C:\7za\7za.exe x "%USERPROFILE%\Carbon.zip" -o"%USERPROFILE%\.emulationstation\themes"

::Cleans up Downlaoded zip
del "%USERPROFILE%\ES.zip"
del "%USERPROFILE%\Carbon.zip"

::Creates default es_systems.cfg
cls
mkdir "%USERPROFILE%\.emulationstation"
echo ^<?xml version="1.0"?^> > "%USERPROFILE%\.emulationstation\es_systems.cfg"
echo ^<systemList^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>amiga^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Amiga^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\amiga^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.adf .ADF .zip .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\puae_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>amiga^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>amiga^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>amstradcpc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Amstrad CPC^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\amstradcpc^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.cdt .cpc .dsk .CDT .CPC .DSK^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\cap32_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>amstradcpc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>amstradcpc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari2600^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 2600^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atari2600^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .a26 .bin .rom .zip .gz .7Z .A26 .BIN .ROM .ZIP .GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\stella_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari2600^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari2600^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari5200^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 5200^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atari5200^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.a52 .bin .car .A52 .BIN .CAR^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\atari800_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari5200^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari5200^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari7800^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 7800 ProSystem^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atari7800^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .a78 .bin .zip .7Z .A78 .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\prosystem_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari7800^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari7800^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atari800^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari 800^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atari800^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.bas .bin .car .com .xex .atr .xfd .dcm .atr.gz .xfd.gz .BAS .BIN .CAR .COM .XEX .ATR .XFD .DCM .ATR.GZ .XFD.GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\atari800_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atari800^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atari800^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atarijaguar^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari Jaguar^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atarijaguar^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.j64 .jag .zip .J64 .JAG .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\virtualjaguar_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atarijaguar^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atarijaguar^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>atarilynx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Atari Lynx^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\atarilynx^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .lnx .zip .7Z .LNX .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\handy_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>atarilynx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>atarilynx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>coleco^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>ColecoVision^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\coleco^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.bin .col .rom .zip .BIN .COL .ROM .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bluemsx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>colecovision^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>colecovision^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>fba^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Final Burn Alpha^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\fba^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.fba .zip .FBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fbalpha_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>arcade^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>fba^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>fds^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Famicom Disk System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\fds^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.nes .fds .zip .NES .FDS .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bnes_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>fds^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>fds^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gamegear^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Gamegear^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\gamegear^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gg .bin .sms .zip .7Z .GG .BIN .SMS .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gamegear^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gamegear^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gb^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\gb^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gb .zip .7Z .GB .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gambatte_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gb^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gb^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gba^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy Advance^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\gba^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gba .zip .7Z .GBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gpsp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gba^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gba^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>gbc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Game Boy Color^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\gbc^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .gbc .zip .7Z .GBC .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\gambatte_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>gbc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>gbc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>gc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Nintendo Gamecube^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\ROMS\gc^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.iso .gcz .gcn .ISO .GCZ .GCN^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\dolphin_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>gc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>gc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^>  >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>intellivision^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Intellivision^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\intellivision^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.int .bin .INT .BIN^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>NEEDS ADDITIONAL EMULATOR "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>intellivision^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>intellivision^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>mame-libretro^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Multiple Arcade Machine Emulator^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\mame-libretro^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.zip .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mame2003_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>arcade^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>mame^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>mastersystem^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Master System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\mastersystem^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .sms .bin .zip .7Z .SMS .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>mastersystem^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>mastersystem^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>megadrive^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega Mega Drive^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\megadrive^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .smd .bin .gen .md .sg .zip .7Z .SMD .BIN .GEN .MD .SG .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>megadrive^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>megadrive^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>msx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>MSX^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\msx^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.rom .mx1 .mx2 .col .dsk .zip .ROM .MX1 .MX2 .COL .DSK .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bluemsx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>msx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>msx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>n64^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Nintendo 64^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\n64^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.z64 .n64 .v64 .Z64 .N64 .V64^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mupen64plus_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>n64^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>n64^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>neogeo^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\neogeo^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.fba .zip .FBA .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fbalpha_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>neogeo^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>neogeo^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>nes^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Nintendo Entertainment System^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\nes^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .nes .zip .7Z .NES .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\bnes_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>nes^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>nes^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>nds^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Nintendo DS^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\ROMS\nds^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.zip .ZIP .nds .NDS^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\melonds_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>nds^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>nds^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>ngp^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo Pocket^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\ngp^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.ngp .zip .NGP .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_ngp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>ngp^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>ngp^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>ngpc^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Neo Geo Pocket Color^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\ngpc^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.ngc .zip .NGC .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_ngp_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>ngpc^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>ngpc^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>pcengine^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>PC Engine^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\pcengine^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .pce .ccd .cue .zip .7Z .PCE .CCD .CUE .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\mednafen_pce_fast_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>pcengine^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>pcengine^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>psx^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>PlayStation^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\psx^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx .CUE .CBN .IMG .ISO .M3U .MDF .PBP .TOC .Z .ZNX^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\pcsx_rearmed_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>psx^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>psx^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<name^>ps2^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<fullname^>Sony Playstation 2^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<path^>C:\ROMS\ps2^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<extension^>.iso .gz .ISO .GZ^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<command^>C:\PCSX2\pcsx2.exe "%%ROM_RAW%%" --fullscreen^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<platform^>ps2^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo 	^<theme^>ps2^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo    ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>sega32x^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega 32X^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\sega32x^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .32x .smd .bin .md .zip .7Z .32X .SMD .BIN .MD .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\picodrive_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>sega32x^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>sega32x^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>segacd^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Mega CD^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\segacd^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.iso .cue .ISO .CUE^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>segacd^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>segacd^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>sg-1000^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Sega SG-1000^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\sg-1000^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.sg .bin .zip .SG .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\genesis_plus_gx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>sg-1000^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>sg-1000^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>snes^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Super Nintendo^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\snes^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .bin .smc .sfc .fig .swc .mgd .zip .7Z .BIN .SMC .SFC .FIG .SWC .MGD .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\snes9x2010_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>snes^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>snes^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>vectrex^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>Vectrex^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\vectrex^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .vec .gam .bin .zip .7Z .VEC .GAM .BIN .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\vecx_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>vectrex^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>vectrex^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^<system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<name^>zxspectrum^</name^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<fullname^>ZX Spectrum^</fullname^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<path^>C:\ROMS\zxspectrum^</path^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<extension^>.7z .sh .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip .7Z .SH .SNA .SZX .Z80 .TAP .TZX .GZ .UDI .MGT .IMG .TRD .SCL .DSK .ZIP^</extension^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<command^>C:\RetroArch\retroarch.exe -L C:\RetroArch\cores\fuse_libretro.dll "%%ROM_RAW%%"^</command^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<platform^>zxspectrum^</platform^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo     ^<theme^>zxspectrum^</theme^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo   ^</system^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"
echo ^</systemList^> >> %USERPROFILE%\.emulationstation\es_systems.cfg"

::RetroArch Download and Installation.
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
		goto x64
	)
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		goto x86
	)

:x64
::Download all files
mkdir C:\Retroarch
mkdir "%USERPROFILE%\cores"
cls
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo =================================================================
echo =                                                               =
echo = Downloading RetroArch and All Cores. This will take some time =
echo =                                                               =
echo =================================================================
powershell -command "Invoke-WebRequest -Uri https://buildbot.libretro.com/stable/1.6.7/windows/x86_64/RetroArch.7z -OutFile "%USERPROFILE%\RetroArch_x64.zip""
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/2048_libretro.dll.zip -OutFile "%USERPROFILE%\cores\1.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/3dengine_libretro.dll.zip -OutFile "%USERPROFILE%\cores\2.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/4do_libretro.dll.zip -OutFile "%USERPROFILE%\cores\3.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/81_libretro.dll.zip -OutFile "%USERPROFILE%\cores\4.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/atari800_libretro.dll.zip -OutFile "%USERPROFILE%\cores\5.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bluemsx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\6.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bnes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\7.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_accuracy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\8.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_balanced_libretro.dll.zip -OutFile "%USERPROFILE%\cores\9.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_cplusplus98_libretro.dll.zip -OutFile "%USERPROFILE%\cores\10.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_mercury_accuracy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\11.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_mercury_balanced_libretro.dll.zip -OutFile "%USERPROFILE%\cores\12.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_mercury_performance_libretro.dll.zip -OutFile "%USERPROFILE%\cores\13.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/bsnes_performance_libretro.dll.zip -OutFile "%USERPROFILE%\cores\14.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/cap32_libretro.dll.zip -OutFile "%USERPROFILE%\cores\15.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/citra_libretro.dll.zip -OutFile "%USERPROFILE%\cores\16.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/craft_libretro.dll.zip -OutFile "%USERPROFILE%\cores\17.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/crocods_libretro.dll.zip -OutFile "%USERPROFILE%\cores\18.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/desmume_libretro.dll.zip -OutFile "%USERPROFILE%\cores\19.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/dinothawr_libretro.dll.zip -OutFile "%USERPROFILE%\cores\20.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/dolphin_libretro.dll.zip -OutFile "%USERPROFILE%\cores\21.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/dosbox_libretro.dll.zip -OutFile "%USERPROFILE%\cores\22.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/emux_chip8_libretro.dll.zip -OutFile "%USERPROFILE%\cores\23.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/emux_gb_libretro.dll.zip -OutFile "%USERPROFILE%\cores\24.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/emux_nes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\25.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/emux_sms_libretro.dll.zip -OutFile "%USERPROFILE%\cores\26.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha2012_cps1_libretro.dll.zip -OutFile "%USERPROFILE%\cores\27.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha2012_cps2_libretro.dll.zip -OutFile "%USERPROFILE%\cores\28.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha2012_libretro.dll.zip -OutFile "%USERPROFILE%\cores\29.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha2012_neogeo_libretro.dll.zip -OutFile "%USERPROFILE%\cores\30.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fbalpha_libretro.dll.zip -OutFile "%USERPROFILE%\cores\31.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fceumm_libretro.dll.zip -OutFile "%USERPROFILE%\cores\32.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/ffmpeg_libretro.dll.zip -OutFile "%USERPROFILE%\cores\33.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fmsx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\34.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/fuse_libretro.dll.zip -OutFile "%USERPROFILE%\cores\35.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/gambatte_libretro.dll.zip -OutFile "%USERPROFILE%\cores\36.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/genesis_plus_gx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\37.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/gme_libretro.dll.zip -OutFile "%USERPROFILE%\cores\38.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/gpsp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\39.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/gw_libretro.dll.zip -OutFile "%USERPROFILE%\cores\40.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/handy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\41.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/hatari_libretro.dll.zip -OutFile "%USERPROFILE%\cores\42.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/higan_sfc_libretro.dll.zip -OutFile "%USERPROFILE%\cores\43.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/imageviewer_libretro.dll.zip -OutFile "%USERPROFILE%\cores\44.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/lutro_libretro.dll.zip -OutFile "%USERPROFILE%\cores\45.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame2000_libretro.dll.zip -OutFile "%USERPROFILE%\cores\46.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame2003_libretro.dll.zip -OutFile "%USERPROFILE%\cores\47.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame2010_libretro.dll.zip -OutFile "%USERPROFILE%\cores\48.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\49.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mame_libretro.dll.zip -OutFile "%USERPROFILE%\cores\50.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_gba_libretro.dll.zip -OutFile "%USERPROFILE%\cores\51.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_lynx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\52.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_ngp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\53.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_pce_fast_libretro.dll.zip -OutFile "%USERPROFILE%\cores\54.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_pcfx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\55.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_psx_hw_libretro.dll.zip -OutFile "%USERPROFILE%\cores\56.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_psx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\57.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_saturn_libretro.dll.zip -OutFile "%USERPROFILE%\cores\58.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_snes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\59.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_supergrafx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\60.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_vb_libretro.dll.zip -OutFile "%USERPROFILE%\cores\61.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mednafen_wswan_libretro.dll.zip -OutFile "%USERPROFILE%\cores\62.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/melonds_libretro.dll.zip -OutFile "%USERPROFILE%\cores\63.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mess2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\64.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/meteor_libretro.dll.zip -OutFile "%USERPROFILE%\cores\65.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mgba_libretro.dll.zip -OutFile "%USERPROFILE%\cores\66.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mrboom_libretro.dll.zip -OutFile "%USERPROFILE%\cores\67.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/mupen64plus_libretro.dll.zip -OutFile "%USERPROFILE%\cores\68.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/nekop2_libretro.dll.zip -OutFile "%USERPROFILE%\cores\69.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/nestopia_libretro.dll.zip -OutFile "%USERPROFILE%\cores\70.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/np2kai_libretro.dll.zip -OutFile "%USERPROFILE%\cores\71.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/nxengine_libretro.dll.zip -OutFile "%USERPROFILE%\cores\72.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/o2em_libretro.dll.zip -OutFile "%USERPROFILE%\cores\73.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/openlara_libretro.dll.zip -OutFile "%USERPROFILE%\cores\74.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/parallel_n64_libretro.dll.zip -OutFile "%USERPROFILE%\cores\75.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/pcsx_rearmed_libretro.dll.zip -OutFile "%USERPROFILE%\cores\76.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/picodrive_libretro.dll.zip -OutFile "%USERPROFILE%\cores\77.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/pocketcdg_libretro.dll.zip -OutFile "%USERPROFILE%\cores\78.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/pokemini_libretro.dll.zip -OutFile "%USERPROFILE%\cores\79.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/ppsspp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\80.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/prboom_libretro.dll.zip -OutFile "%USERPROFILE%\cores\81.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/prosystem_libretro.dll.zip -OutFile "%USERPROFILE%\cores\82.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/puae_libretro.dll.zip -OutFile "%USERPROFILE%\cores\83.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/px68k_libretro.dll.zip -OutFile "%USERPROFILE%\cores\84.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/quicknes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\85.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/redream_libretro.dll.zip -OutFile "%USERPROFILE%\cores\86.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/reicast_libretro.dll.zip -OutFile "%USERPROFILE%\cores\87.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/remotejoy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\88.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/sameboy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\89.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/scummvm_libretro.dll.zip -OutFile "%USERPROFILE%\cores\90.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x2002_libretro.dll.zip -OutFile "%USERPROFILE%\cores\91.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x2005_libretro.dll.zip -OutFile "%USERPROFILE%\cores\92.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x2005_plus_libretro.dll.zip -OutFile "%USERPROFILE%\cores\93.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x2010_libretro.dll.zip -OutFile "%USERPROFILE%\cores\94.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/snes9x_libretro.dll.zip -OutFile "%USERPROFILE%\cores\95.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/stella_libretro.dll.zip -OutFile "%USERPROFILE%\cores\96.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/tgbdual_libretro.dll.zip -OutFile "%USERPROFILE%\cores\97.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/tyrquake_libretro.dll.zip -OutFile "%USERPROFILE%\cores\98.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/ume2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\99.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vba_next_libretro.dll.zip -OutFile "%USERPROFILE%\cores\100.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vbam_libretro.dll.zip -OutFile "%USERPROFILE%\cores\101.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vecx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\102.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vice_x64_libretro.dll.zip -OutFile "%USERPROFILE%\cores\103.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vice_xplus4_libretro.dll.zip -OutFile "%USERPROFILE%\cores\104.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/vice_xvic_libretro.dll.zip -OutFile "%USERPROFILE%\cores\105.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/virtualjaguar_libretro.dll.zip -OutFile "%USERPROFILE%\cores\106.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/xrick_libretro.dll.zip -OutFile "%USERPROFILE%\cores\107.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86_64/latest/yabause_libretro.dll.zip -OutFile "%USERPROFILE%\cores\108.zip"

::Install RetroArch

C:\7za\7za.exe x "%USERPROFILE%\RetroArch_x64.zip" -o"C:\RetroArch" -aoa

:: Install cores

mkdir C:\RetroArch\Cores
C:\7za\7za.exe x "%USERPROFILE%\cores\*.zip" -o"C:\RetroArch\Cores" -aoa

::Cleanup
rmdir "%USERPROFILE%\cores /s /q
del "%USERPROFILE%\RetroArch_x64.zip" /q

goto RAShortcut

:x86
::Download all files
mkdir C:\Retroarch
mkdir "%USERPROFILE%\cores"
cls
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo =================================================================
echo =                                                               =
echo = Downloading RetroArch and All Cores. This will take some time =
echo =                                                               =
echo =================================================================
powershell -command "Invoke-WebRequest -Uri https://buildbot.libretro.com/stable/1.6.7/windows/x86/RetroArch.7z -OutFile "%USERPROFILE%\RetroArch_x86.zip""
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/2048_libretro.dll.zip -OutFile "%USERPROFILE%\cores\1.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/3dengine_libretro.dll.zip -OutFile "%USERPROFILE%\cores\2.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/4do_libretro.dll.zip -OutFile "%USERPROFILE%\cores\3.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/81_libretro.dll.zip -OutFile "%USERPROFILE%\cores\4.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/atari800_libretro.dll.zip -OutFile "%USERPROFILE%\cores\5.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bluemsx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\6.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bnes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\7.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_accuracy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\8.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_balanced_libretro.dll.zip -OutFile "%USERPROFILE%\cores\9.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_cplusplus98_libretro.dll.zip -OutFile "%USERPROFILE%\cores\10.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_mercury_accuracy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\11.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_mercury_balanced_libretro.dll.zip -OutFile "%USERPROFILE%\cores\12.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_mercury_performance_libretro.dll.zip -OutFile "%USERPROFILE%\cores\13.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/bsnes_performance_libretro.dll.zip -OutFile "%USERPROFILE%\cores\14.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/cap32_libretro.dll.zip -OutFile "%USERPROFILE%\cores\15.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/citra_libretro.dll.zip -OutFile "%USERPROFILE%\cores\16.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/craft_libretro.dll.zip -OutFile "%USERPROFILE%\cores\17.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/crocods_libretro.dll.zip -OutFile "%USERPROFILE%\cores\18.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/desmume_libretro.dll.zip -OutFile "%USERPROFILE%\cores\19.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/dinothawr_libretro.dll.zip -OutFile "%USERPROFILE%\cores\20.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/dolphin_libretro.dll.zip -OutFile "%USERPROFILE%\cores\21.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/dosbox_libretro.dll.zip -OutFile "%USERPROFILE%\cores\22.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/emux_chip8_libretro.dll.zip -OutFile "%USERPROFILE%\cores\23.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/emux_gb_libretro.dll.zip -OutFile "%USERPROFILE%\cores\24.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/emux_nes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\25.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/emux_sms_libretro.dll.zip -OutFile "%USERPROFILE%\cores\26.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha2012_cps1_libretro.dll.zip -OutFile "%USERPROFILE%\cores\27.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha2012_cps2_libretro.dll.zip -OutFile "%USERPROFILE%\cores\28.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha2012_libretro.dll.zip -OutFile "%USERPROFILE%\cores\29.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha2012_neogeo_libretro.dll.zip -OutFile "%USERPROFILE%\cores\30.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fbalpha_libretro.dll.zip -OutFile "%USERPROFILE%\cores\31.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fceumm_libretro.dll.zip -OutFile "%USERPROFILE%\cores\32.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/ffmpeg_libretro.dll.zip -OutFile "%USERPROFILE%\cores\33.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fmsx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\34.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/fuse_libretro.dll.zip -OutFile "%USERPROFILE%\cores\35.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/gambatte_libretro.dll.zip -OutFile "%USERPROFILE%\cores\36.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/genesis_plus_gx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\37.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/gme_libretro.dll.zip -OutFile "%USERPROFILE%\cores\38.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/gpsp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\39.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/gw_libretro.dll.zip -OutFile "%USERPROFILE%\cores\40.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/handy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\41.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/hatari_libretro.dll.zip -OutFile "%USERPROFILE%\cores\42.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/higan_sfc_libretro.dll.zip -OutFile "%USERPROFILE%\cores\43.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/imageviewer_libretro.dll.zip -OutFile "%USERPROFILE%\cores\44.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/lutro_libretro.dll.zip -OutFile "%USERPROFILE%\cores\45.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame2000_libretro.dll.zip -OutFile "%USERPROFILE%\cores\46.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame2003_libretro.dll.zip -OutFile "%USERPROFILE%\cores\47.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame2010_libretro.dll.zip -OutFile "%USERPROFILE%\cores\48.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\49.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mame_libretro.dll.zip -OutFile "%USERPROFILE%\cores\50.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_gba_libretro.dll.zip -OutFile "%USERPROFILE%\cores\51.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_lynx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\52.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_ngp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\53.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_pce_fast_libretro.dll.zip -OutFile "%USERPROFILE%\cores\54.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_pcfx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\55.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_psx_hw_libretro.dll.zip -OutFile "%USERPROFILE%\cores\56.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_psx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\57.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_saturn_libretro.dll.zip -OutFile "%USERPROFILE%\cores\58.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_snes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\59.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_supergrafx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\60.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_vb_libretro.dll.zip -OutFile "%USERPROFILE%\cores\61.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mednafen_wswan_libretro.dll.zip -OutFile "%USERPROFILE%\cores\62.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/melonds_libretro.dll.zip -OutFile "%USERPROFILE%\cores\63.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mess2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\64.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/meteor_libretro.dll.zip -OutFile "%USERPROFILE%\cores\65.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mgba_libretro.dll.zip -OutFile "%USERPROFILE%\cores\66.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mrboom_libretro.dll.zip -OutFile "%USERPROFILE%\cores\67.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/mupen64plus_libretro.dll.zip -OutFile "%USERPROFILE%\cores\68.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/nekop2_libretro.dll.zip -OutFile "%USERPROFILE%\cores\69.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/nestopia_libretro.dll.zip -OutFile "%USERPROFILE%\cores\70.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/np2kai_libretro.dll.zip -OutFile "%USERPROFILE%\cores\71.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/nxengine_libretro.dll.zip -OutFile "%USERPROFILE%\cores\72.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/o2em_libretro.dll.zip -OutFile "%USERPROFILE%\cores\73.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/openlara_libretro.dll.zip -OutFile "%USERPROFILE%\cores\74.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/parallel_n64_libretro.dll.zip -OutFile "%USERPROFILE%\cores\75.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/pcsx_rearmed_libretro.dll.zip -OutFile "%USERPROFILE%\cores\76.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/picodrive_libretro.dll.zip -OutFile "%USERPROFILE%\cores\77.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/pocketcdg_libretro.dll.zip -OutFile "%USERPROFILE%\cores\78.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/pokemini_libretro.dll.zip -OutFile "%USERPROFILE%\cores\79.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/ppsspp_libretro.dll.zip -OutFile "%USERPROFILE%\cores\80.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/prboom_libretro.dll.zip -OutFile "%USERPROFILE%\cores\81.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/prosystem_libretro.dll.zip -OutFile "%USERPROFILE%\cores\82.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/puae_libretro.dll.zip -OutFile "%USERPROFILE%\cores\83.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/px68k_libretro.dll.zip -OutFile "%USERPROFILE%\cores\84.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/quicknes_libretro.dll.zip -OutFile "%USERPROFILE%\cores\85.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/redream_libretro.dll.zip -OutFile "%USERPROFILE%\cores\86.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/reicast_libretro.dll.zip -OutFile "%USERPROFILE%\cores\87.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/remotejoy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\88.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/sameboy_libretro.dll.zip -OutFile "%USERPROFILE%\cores\89.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/scummvm_libretro.dll.zip -OutFile "%USERPROFILE%\cores\90.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x2002_libretro.dll.zip -OutFile "%USERPROFILE%\cores\91.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x2005_libretro.dll.zip -OutFile "%USERPROFILE%\cores\92.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x2005_plus_libretro.dll.zip -OutFile "%USERPROFILE%\cores\93.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x2010_libretro.dll.zip -OutFile "%USERPROFILE%\cores\94.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/snes9x_libretro.dll.zip -OutFile "%USERPROFILE%\cores\95.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/stella_libretro.dll.zip -OutFile "%USERPROFILE%\cores\96.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/tgbdual_libretro.dll.zip -OutFile "%USERPROFILE%\cores\97.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/tyrquake_libretro.dll.zip -OutFile "%USERPROFILE%\cores\98.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/ume2014_libretro.dll.zip -OutFile "%USERPROFILE%\cores\99.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vba_next_libretro.dll.zip -OutFile "%USERPROFILE%\cores\100.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vbam_libretro.dll.zip -OutFile "%USERPROFILE%\cores\101.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vecx_libretro.dll.zip -OutFile "%USERPROFILE%\cores\102.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vice_x64_libretro.dll.zip -OutFile "%USERPROFILE%\cores\103.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vice_xplus4_libretro.dll.zip -OutFile "%USERPROFILE%\cores\104.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/vice_xvic_libretro.dll.zip -OutFile "%USERPROFILE%\cores\105.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/virtualjaguar_libretro.dll.zip -OutFile "%USERPROFILE%\cores\106.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/xrick_libretro.dll.zip -OutFile "%USERPROFILE%\cores\107.zip"
powershell -command "Invoke-WebRequest -Uri http://buildbot.libretro.com/nightly/windows/x86/latest/yabause_libretro.dll.zip -OutFile "%USERPROFILE%\cores\108.zip"


::Install downloaded Retroarch

C:\7za\7za.exe x "%USERPROFILE%\RetroArch_x64.zip" -o"C:\RetroArch" -aoa
C:\7za\7za.exe x "%USERPROFILE%\RetroArch_x86.zip" -o"C:\RetroArch" -aoa

:: Install downloaded cores

mkdir C:\RetroArch\Cores
C:\7za\7za.exe x "%USERPROFILE%\cores\*.zip" -o"C:\RetroArch\Cores" -aoa

::Cleanup
del "%USERPROFILE%\RetroArch_x86.zip" /q
ping 127.0.0.1 -n 6 >nul
rmdir "%USERPROFILE%\cores" /s /q
goto :RACFG

:RACFG
echo config_save_on_exit = "true" > C:\RetroArch\retroarch.cfg
echo core_updater_buildbot_url = "http://buildbot.libretro.com/nightly/windows/x86_64/latest/" >> C:\RetroArch\retroarch.cfg
echo core_updater_buildbot_assets_url = "http://buildbot.libretro.com/assets/" >> C:\RetroArch\retroarch.cfg
echo libretro_directory = ":\cores" >> C:\RetroArch\retroarch.cfg
echo libretro_info_path = ":\info" >> C:\RetroArch\retroarch.cfg
echo content_database_path = ":\database\rdb" >> C:\RetroArch\retroarch.cfg
echo cheat_database_path = ":\cheats" >> C:\RetroArch\retroarch.cfg
echo content_history_path = ":\content_history.lpl" >> C:\RetroArch\retroarch.cfg
echo content_favorites_path = ":\content_favorites.lpl" >> C:\RetroArch\retroarch.cfg
echo content_music_history_path = ":\content_music_history.lpl" >> C:\RetroArch\retroarch.cfg
echo content_video_history_path = ":\content_video_history.lpl" >> C:\RetroArch\retroarch.cfg
echo content_image_history_path = ":\content_image_history.lpl" >> C:\RetroArch\retroarch.cfg
echo cursor_directory = ":\database\cursors" >> C:\RetroArch\retroarch.cfg
echo screenshot_directory = ":\screenshots" >> C:\RetroArch\retroarch.cfg
echo system_directory = ":\system" >> C:\RetroArch\retroarch.cfg
echo input_remapping_directory = ":\config\remaps" >> C:\RetroArch\retroarch.cfg
echo video_shader_dir = ":\shaders" >> C:\RetroArch\retroarch.cfg
echo video_filter_dir = ":\filters\video" >> C:\RetroArch\retroarch.cfg
echo core_assets_directory = ":\downloads" >> C:\RetroArch\retroarch.cfg
echo assets_directory = ":\assets" >> C:\RetroArch\retroarch.cfg
echo dynamic_wallpapers_directory = ":\assets\wallpapers" >> C:\RetroArch\retroarch.cfg
echo thumbnails_directory = ":\thumbnails" >> C:\RetroArch\retroarch.cfg
echo playlist_directory = ":\playlists" >> C:\RetroArch\retroarch.cfg
echo joypad_autoconfig_dir = ":\autoconfig" >> C:\RetroArch\retroarch.cfg
echo audio_filter_dir = ":\filters\audio" >> C:\RetroArch\retroarch.cfg
echo savefile_directory = ":\saves" >> C:\RetroArch\retroarch.cfg
echo savestate_directory = ":\states" >> C:\RetroArch\retroarch.cfg
echo rgui_browser_directory = "default" >> C:\RetroArch\retroarch.cfg
echo rgui_config_directory = ":\config" >> C:\RetroArch\retroarch.cfg
echo overlay_directory = ":\overlays" >> C:\RetroArch\retroarch.cfg
echo screenshot_directory = ":\screenshots" >> C:\RetroArch\retroarch.cfg
echo video_driver = "gl" >> C:\RetroArch\retroarch.cfg
echo record_driver = "ffmpeg" >> C:\RetroArch\retroarch.cfg
echo camera_driver = "null" >> C:\RetroArch\retroarch.cfg
echo wifi_driver = "null" >> C:\RetroArch\retroarch.cfg
echo location_driver = "null" >> C:\RetroArch\retroarch.cfg
echo menu_driver = "xmb" >> C:\RetroArch\retroarch.cfg
echo audio_driver = "xaudio" >> C:\RetroArch\retroarch.cfg
echo audio_resampler = "sinc" >> C:\RetroArch\retroarch.cfg
echo input_driver = "dinput" >> C:\RetroArch\retroarch.cfg
echo input_joypad_driver = "xinput" >> C:\RetroArch\retroarch.cfg
echo video_aspect_ratio = "-1.000000" >> C:\RetroArch\retroarch.cfg
echo video_scale = "3.000000" >> C:\RetroArch\retroarch.cfg
echo video_refresh_rate = "59.940060" >> C:\RetroArch\retroarch.cfg
echo audio_rate_control_delta = "0.005000" >> C:\RetroArch\retroarch.cfg
echo audio_max_timing_skew = "0.050000" >> C:\RetroArch\retroarch.cfg
echo audio_volume = "0.000000" >> C:\RetroArch\retroarch.cfg
echo audio_mixer_volume = "0.000000" >> C:\RetroArch\retroarch.cfg
echo input_overlay_opacity = "0.700000" >> C:\RetroArch\retroarch.cfg
echo input_overlay_scale = "1.000000" >> C:\RetroArch\retroarch.cfg
echo menu_wallpaper_opacity = "0.300000" >> C:\RetroArch\retroarch.cfg
echo menu_framebuffer_opacity = "0.900000" >> C:\RetroArch\retroarch.cfg
echo menu_footer_opacity = "1.000000" >> C:\RetroArch\retroarch.cfg
echo menu_header_opacity = "1.000000" >> C:\RetroArch\retroarch.cfg
echo video_message_pos_x = "0.050000" >> C:\RetroArch\retroarch.cfg
echo video_message_pos_y = "0.050000" >> C:\RetroArch\retroarch.cfg
echo video_font_size = "32.000000" >> C:\RetroArch\retroarch.cfg
echo fastforward_ratio = "0.000000" >> C:\RetroArch\retroarch.cfg
echo slowmotion_ratio = "3.000000" >> C:\RetroArch\retroarch.cfg
echo input_axis_threshold = "0.500000" >> C:\RetroArch\retroarch.cfg
echo state_slot = "0" >> C:\RetroArch\retroarch.cfg
echo netplay_check_frames = "30" >> C:\RetroArch\retroarch.cfg
echo audio_wasapi_sh_buffer_length = "-16" >> C:\RetroArch\retroarch.cfg
echo input_bind_timeout = "5" >> C:\RetroArch\retroarch.cfg
echo input_turbo_period = "6" >> C:\RetroArch\retroarch.cfg
echo input_duty_cycle = "3" >> C:\RetroArch\retroarch.cfg
echo input_max_users = "5" >> C:\RetroArch\retroarch.cfg
echo input_menu_toggle_gamepad_combo = "0" >> C:\RetroArch\retroarch.cfg
echo audio_latency = "64" >> C:\RetroArch\retroarch.cfg
echo audio_block_frames = "0" >> C:\RetroArch\retroarch.cfg
echo rewind_granularity = "1" >> C:\RetroArch\retroarch.cfg
echo autosave_interval = "0" >> C:\RetroArch\retroarch.cfg
echo libretro_log_level = "1" >> C:\RetroArch\retroarch.cfg
echo keyboard_gamepad_mapping_type = "1" >> C:\RetroArch\retroarch.cfg
echo input_poll_type_behavior = "2" >> C:\RetroArch\retroarch.cfg
echo video_monitor_index = "0" >> C:\RetroArch\retroarch.cfg
echo video_fullscreen_x = "0" >> C:\RetroArch\retroarch.cfg
echo video_fullscreen_y = "0" >> C:\RetroArch\retroarch.cfg
echo video_window_x = "0" >> C:\RetroArch\retroarch.cfg
echo video_window_y = "0" >> C:\RetroArch\retroarch.cfg
echo network_cmd_port = "55355" >> C:\RetroArch\retroarch.cfg
echo network_remote_base_port = "55400" >> C:\RetroArch\retroarch.cfg
echo dpi_override_value = "200" >> C:\RetroArch\retroarch.cfg
echo menu_thumbnails = "3" >> C:\RetroArch\retroarch.cfg
echo xmb_alpha_factor = "75" >> C:\RetroArch\retroarch.cfg
echo xmb_scale_factor = "100" >> C:\RetroArch\retroarch.cfg
echo xmb_theme = "0" >> C:\RetroArch\retroarch.cfg
echo xmb_menu_color_theme = "4" >> C:\RetroArch\retroarch.cfg
echo materialui_menu_color_theme = "0" >> C:\RetroArch\retroarch.cfg
echo menu_shader_pipeline = "2" >> C:\RetroArch\retroarch.cfg
echo audio_out_rate = "48000" >> C:\RetroArch\retroarch.cfg
echo custom_viewport_width = "840" >> C:\RetroArch\retroarch.cfg
echo custom_viewport_height = "630" >> C:\RetroArch\retroarch.cfg
echo custom_viewport_x = "0" >> C:\RetroArch\retroarch.cfg
echo custom_viewport_y = "0" >> C:\RetroArch\retroarch.cfg
echo content_history_size = "100" >> C:\RetroArch\retroarch.cfg
echo video_hard_sync_frames = "0" >> C:\RetroArch\retroarch.cfg
echo video_frame_delay = "0" >> C:\RetroArch\retroarch.cfg
echo video_max_swapchain_images = "3" >> C:\RetroArch\retroarch.cfg
echo video_swap_interval = "1" >> C:\RetroArch\retroarch.cfg
echo video_rotation = "0" >> C:\RetroArch\retroarch.cfg
echo aspect_ratio_index = "21" >> C:\RetroArch\retroarch.cfg
echo netplay_ip_port = "55435" >> C:\RetroArch\retroarch.cfg
echo netplay_input_latency_frames_min = "0" >> C:\RetroArch\retroarch.cfg
echo netplay_input_latency_frames_range = "0" >> C:\RetroArch\retroarch.cfg
echo user_language = "0" >> C:\RetroArch\retroarch.cfg
echo bundle_assets_extract_version_current = "0" >> C:\RetroArch\retroarch.cfg
echo bundle_assets_extract_last_version = "0" >> C:\RetroArch\retroarch.cfg
echo input_overlay_show_physical_inputs_port = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p1 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player1_joypad_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p1 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player1_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player1_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p2 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player2_joypad_index = "1" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p2 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player2_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player2_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p3 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player3_joypad_index = "2" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p3 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player3_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player3_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p4 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player4_joypad_index = "3" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p4 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player4_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player4_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p5 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player5_joypad_index = "4" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p5 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player5_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player5_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p6 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player6_joypad_index = "5" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p6 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player6_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player6_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p7 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player7_joypad_index = "6" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p7 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player7_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player7_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p8 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player8_joypad_index = "7" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p8 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player8_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player8_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p9 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player9_joypad_index = "8" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p9 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player9_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player9_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p10 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player10_joypad_index = "9" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p10 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player10_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player10_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p11 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player11_joypad_index = "10" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p11 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player11_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player11_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p12 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player12_joypad_index = "11" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p12 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player12_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player12_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p13 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player13_joypad_index = "12" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p13 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player13_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player13_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p14 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player14_joypad_index = "13" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p14 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player14_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player14_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p15 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player15_joypad_index = "14" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p15 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player15_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player15_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_device_p16 = "0" >> C:\RetroArch\retroarch.cfg
echo input_player16_joypad_index = "15" >> C:\RetroArch\retroarch.cfg
echo input_libretro_device_p16 = "1" >> C:\RetroArch\retroarch.cfg
echo input_player16_analog_dpad_mode = "0" >> C:\RetroArch\retroarch.cfg
echo input_player16_mouse_index = "0" >> C:\RetroArch\retroarch.cfg
echo ui_companion_start_on_boot = "true" >> C:\RetroArch\retroarch.cfg
echo ui_companion_enable = "false" >> C:\RetroArch\retroarch.cfg
echo video_gpu_record = "false" >> C:\RetroArch\retroarch.cfg
echo input_remap_binds_enable = "true" >> C:\RetroArch\retroarch.cfg
echo all_users_control_menu = "false" >> C:\RetroArch\retroarch.cfg
echo menu_swap_ok_cancel_buttons = "true" >> C:\RetroArch\retroarch.cfg
echo netplay_public_announce = "true" >> C:\RetroArch\retroarch.cfg
echo netplay_start_as_spectator = "false" >> C:\RetroArch\retroarch.cfg
echo netplay_allow_slaves = "true" >> C:\RetroArch\retroarch.cfg
echo netplay_require_slaves = "false" >> C:\RetroArch\retroarch.cfg
echo netplay_stateless_mode = "false" >> C:\RetroArch\retroarch.cfg
echo netplay_client_swap_input = "true" >> C:\RetroArch\retroarch.cfg
echo netplay_use_mitm_server = "false" >> C:\RetroArch\retroarch.cfg
echo input_descriptor_label_show = "true" >> C:\RetroArch\retroarch.cfg
echo input_descriptor_hide_unbound = "false" >> C:\RetroArch\retroarch.cfg
echo load_dummy_on_core_shutdown = "true" >> C:\RetroArch\retroarch.cfg
echo check_firmware_before_loading = "false" >> C:\RetroArch\retroarch.cfg
echo builtin_mediaplayer_enable = "true" >> C:\RetroArch\retroarch.cfg
echo builtin_imageviewer_enable = "true" >> C:\RetroArch\retroarch.cfg
echo fps_show = "false" >> C:\RetroArch\retroarch.cfg
echo ui_menubar_enable = "true" >> C:\RetroArch\retroarch.cfg
echo suspend_screensaver_enable = "true" >> C:\RetroArch\retroarch.cfg
echo rewind_enable = "false" >> C:\RetroArch\retroarch.cfg
echo audio_sync = "true" >> C:\RetroArch\retroarch.cfg
echo video_shader_enable = "false" >> C:\RetroArch\retroarch.cfg
echo video_aspect_ratio_auto = "false" >> C:\RetroArch\retroarch.cfg
echo video_allow_rotate = "true" >> C:\RetroArch\retroarch.cfg
echo video_windowed_fullscreen = "true" >> C:\RetroArch\retroarch.cfg
echo video_crop_overscan = "true" >> C:\RetroArch\retroarch.cfg
echo video_scale_integer = "false" >> C:\RetroArch\retroarch.cfg
echo video_smooth = "true" >> C:\RetroArch\retroarch.cfg
echo video_force_aspect = "true" >> C:\RetroArch\retroarch.cfg
echo video_threaded = "false" >> C:\RetroArch\retroarch.cfg
echo video_shared_context = "false" >> C:\RetroArch\retroarch.cfg
echo auto_screenshot_filename = "true" >> C:\RetroArch\retroarch.cfg
echo video_force_srgb_disable = "false" >> C:\RetroArch\retroarch.cfg
echo video_fullscreen = "true" >> C:\RetroArch\retroarch.cfg
echo bundle_assets_extract_enable = "false" >> C:\RetroArch\retroarch.cfg
echo video_vsync = "true" >> C:\RetroArch\retroarch.cfg
echo video_hard_sync = "false" >> C:\RetroArch\retroarch.cfg
echo video_black_frame_insertion = "false" >> C:\RetroArch\retroarch.cfg
echo video_disable_composition = "false" >> C:\RetroArch\retroarch.cfg
echo pause_nonactive = "true" >> C:\RetroArch\retroarch.cfg
echo video_gpu_screenshot = "true" >> C:\RetroArch\retroarch.cfg
echo video_post_filter_record = "false" >> C:\RetroArch\retroarch.cfg
echo keyboard_gamepad_enable = "true" >> C:\RetroArch\retroarch.cfg
echo core_set_supports_no_game_enable = "true" >> C:\RetroArch\retroarch.cfg
echo audio_enable = "true" >> C:\RetroArch\retroarch.cfg
echo audio_mute_enable = "false" >> C:\RetroArch\retroarch.cfg
echo audio_mixer_mute_enable = "false" >> C:\RetroArch\retroarch.cfg
echo location_allow = "false" >> C:\RetroArch\retroarch.cfg
echo video_font_enable = "true" >> C:\RetroArch\retroarch.cfg
echo core_updater_auto_extract_archive = "true" >> C:\RetroArch\retroarch.cfg
echo camera_allow = "false" >> C:\RetroArch\retroarch.cfg
echo menu_unified_controls = "false" >> C:\RetroArch\retroarch.cfg
echo threaded_data_runloop_enable = "true" >> C:\RetroArch\retroarch.cfg
echo menu_throttle_framerate = "true" >> C:\RetroArch\retroarch.cfg
echo menu_linear_filter = "true" >> C:\RetroArch\retroarch.cfg
echo menu_horizontal_animation = "true" >> C:\RetroArch\retroarch.cfg
echo dpi_override_enable = "true" >> C:\RetroArch\retroarch.cfg
echo menu_pause_libretro = "true" >> C:\RetroArch\retroarch.cfg
echo menu_mouse_enable = "true" >> C:\RetroArch\retroarch.cfg
echo menu_pointer_enable = "false" >> C:\RetroArch\retroarch.cfg
echo menu_timedate_enable = "true" >> C:\RetroArch\retroarch.cfg
echo menu_battery_level_enable = "true" >> C:\RetroArch\retroarch.cfg
echo menu_core_enable = "true" >> C:\RetroArch\retroarch.cfg
echo menu_dynamic_wallpaper_enable = "false" >> C:\RetroArch\retroarch.cfg
echo materialui_icons_enable = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_shadows_enable = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_show_settings = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_show_favorites = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_show_images = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_show_music = "true" >> C:\RetroArch\retroarch.cfg
echo menu_show_online_updater = "true" >> C:\RetroArch\retroarch.cfg
echo menu_show_core_updater = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_show_video = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_show_netplay = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_show_history = "true" >> C:\RetroArch\retroarch.cfg
echo xmb_show_add = "true" >> C:\RetroArch\retroarch.cfg
echo filter_by_current_core = "false" >> C:\RetroArch\retroarch.cfg
echo rgui_show_start_screen = "false" >> C:\RetroArch\retroarch.cfg
echo menu_navigation_wraparound_enable = "true" >> C:\RetroArch\retroarch.cfg
echo menu_navigation_browser_filter_supported_extensions_enable = "true" >> C:\RetroArch\retroarch.cfg
echo menu_show_advanced_settings = "false" >> C:\RetroArch\retroarch.cfg
echo cheevos_enable = "false" >> C:\RetroArch\retroarch.cfg
echo cheevos_test_unofficial = "false" >> C:\RetroArch\retroarch.cfg
echo cheevos_hardcore_mode_enable = "false" >> C:\RetroArch\retroarch.cfg
echo cheevos_verbose_enable = "false" >> C:\RetroArch\retroarch.cfg
echo input_overlay_enable = "true" >> C:\RetroArch\retroarch.cfg
echo input_overlay_enable_autopreferred = "true" >> C:\RetroArch\retroarch.cfg
echo input_overlay_show_physical_inputs = "false" >> C:\RetroArch\retroarch.cfg
echo input_overlay_hide_in_menu = "true" >> C:\RetroArch\retroarch.cfg
echo network_cmd_enable = "false" >> C:\RetroArch\retroarch.cfg
echo stdin_cmd_enable = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable = "false" >> C:\RetroArch\retroarch.cfg
echo netplay_nat_traversal = "true" >> C:\RetroArch\retroarch.cfg
echo block_sram_overwrite = "false" >> C:\RetroArch\retroarch.cfg
echo savestate_auto_index = "false" >> C:\RetroArch\retroarch.cfg
echo savestate_auto_save = "false" >> C:\RetroArch\retroarch.cfg
echo savestate_auto_load = "false" >> C:\RetroArch\retroarch.cfg
echo savestate_thumbnail_enable = "false" >> C:\RetroArch\retroarch.cfg
echo history_list_enable = "true" >> C:\RetroArch\retroarch.cfg
echo playlist_entry_remove = "true" >> C:\RetroArch\retroarch.cfg
echo game_specific_options = "true" >> C:\RetroArch\retroarch.cfg
echo auto_overrides_enable = "true" >> C:\RetroArch\retroarch.cfg
echo auto_remaps_enable = "true" >> C:\RetroArch\retroarch.cfg
echo auto_shaders_enable = "true" >> C:\RetroArch\retroarch.cfg
echo sort_savefiles_enable = "false" >> C:\RetroArch\retroarch.cfg
echo sort_savestates_enable = "false" >> C:\RetroArch\retroarch.cfg
echo show_hidden_files = "false" >> C:\RetroArch\retroarch.cfg
echo input_autodetect_enable = "true" >> C:\RetroArch\retroarch.cfg
echo audio_rate_control = "true" >> C:\RetroArch\retroarch.cfg
echo audio_wasapi_exclusive_mode = "true" >> C:\RetroArch\retroarch.cfg
echo audio_wasapi_float_format = "false" >> C:\RetroArch\retroarch.cfg
echo savestates_in_content_dir = "false" >> C:\RetroArch\retroarch.cfg
echo savefiles_in_content_dir = "false" >> C:\RetroArch\retroarch.cfg
echo systemfiles_in_content_dir = "false" >> C:\RetroArch\retroarch.cfg
echo screenshots_in_content_dir = "false" >> C:\RetroArch\retroarch.cfg
echo custom_bgm_enable = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p1 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p2 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p3 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p4 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p5 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p6 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p7 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p8 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p9 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p10 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p11 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p12 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p13 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p14 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p15 = "false" >> C:\RetroArch\retroarch.cfg
echo network_remote_enable_user_p16 = "false" >> C:\RetroArch\retroarch.cfg
echo log_verbosity = "false" >> C:\RetroArch\retroarch.cfg
echo perfcnt_enable = "false" >> C:\RetroArch\retroarch.cfg
echo video_message_color = "ffff00" >> C:\RetroArch\retroarch.cfg
echo menu_entry_normal_color = "ffffffff" >> C:\RetroArch\retroarch.cfg
echo menu_entry_hover_color = "ff64ff64" >> C:\RetroArch\retroarch.cfg
echo menu_title_color = "ff64ff64" >> C:\RetroArch\retroarch.cfg
echo gamma_correction = "false" >> C:\RetroArch\retroarch.cfg
echo flicker_filter_enable = "false" >> C:\RetroArch\retroarch.cfg
echo soft_filter_enable = "false" >> C:\RetroArch\retroarch.cfg
echo soft_filter_index = "0" >> C:\RetroArch\retroarch.cfg
echo current_resolution_id = "0" >> C:\RetroArch\retroarch.cfg
echo flicker_filter_index = "0" >> C:\RetroArch\retroarch.cfg
echo input_player1_b = "z" >> C:\RetroArch\retroarch.cfg
echo input_player1_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_y = "a" >> C:\RetroArch\retroarch.cfg
echo input_player1_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_select = "rshift" >> C:\RetroArch\retroarch.cfg
echo input_player1_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_start = "enter" >> C:\RetroArch\retroarch.cfg
echo input_player1_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_up = "up" >> C:\RetroArch\retroarch.cfg
echo input_player1_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_down = "down" >> C:\RetroArch\retroarch.cfg
echo input_player1_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_left = "left" >> C:\RetroArch\retroarch.cfg
echo input_player1_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_right = "right" >> C:\RetroArch\retroarch.cfg
echo input_player1_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_a = "x" >> C:\RetroArch\retroarch.cfg
echo input_player1_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_x = "s" >> C:\RetroArch\retroarch.cfg
echo input_player1_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l = "q" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r = "w" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player1_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_toggle_fast_forward = "space" >> C:\RetroArch\retroarch.cfg
echo input_toggle_fast_forward_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_toggle_fast_forward_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_hold_fast_forward = "l" >> C:\RetroArch\retroarch.cfg
echo input_hold_fast_forward_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_hold_fast_forward_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_load_state = "f4" >> C:\RetroArch\retroarch.cfg
echo input_load_state_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_load_state_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_save_state = "f2" >> C:\RetroArch\retroarch.cfg
echo input_save_state_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_save_state_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_toggle_fullscreen = "f" >> C:\RetroArch\retroarch.cfg
echo input_toggle_fullscreen_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_toggle_fullscreen_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_exit_emulator = "escape" >> C:\RetroArch\retroarch.cfg
echo input_exit_emulator_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_exit_emulator_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_state_slot_increase = "f7" >> C:\RetroArch\retroarch.cfg
echo input_state_slot_increase_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_state_slot_increase_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_state_slot_decrease = "f6" >> C:\RetroArch\retroarch.cfg
echo input_state_slot_decrease_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_state_slot_decrease_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_rewind = "r" >> C:\RetroArch\retroarch.cfg
echo input_rewind_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_rewind_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_movie_record_toggle = "o" >> C:\RetroArch\retroarch.cfg
echo input_movie_record_toggle_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_movie_record_toggle_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_pause_toggle = "p" >> C:\RetroArch\retroarch.cfg
echo input_pause_toggle_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_pause_toggle_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_frame_advance = "k" >> C:\RetroArch\retroarch.cfg
echo input_frame_advance_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_frame_advance_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_reset = "h" >> C:\RetroArch\retroarch.cfg
echo input_reset_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_reset_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_shader_next = "m" >> C:\RetroArch\retroarch.cfg
echo input_shader_next_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_shader_next_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_shader_prev = "n" >> C:\RetroArch\retroarch.cfg
echo input_shader_prev_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_shader_prev_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_cheat_index_plus = "y" >> C:\RetroArch\retroarch.cfg
echo input_cheat_index_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_cheat_index_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_cheat_index_minus = "t" >> C:\RetroArch\retroarch.cfg
echo input_cheat_index_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_cheat_index_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_cheat_toggle = "u" >> C:\RetroArch\retroarch.cfg
echo input_cheat_toggle_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_cheat_toggle_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_screenshot = "f8" >> C:\RetroArch\retroarch.cfg
echo input_screenshot_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_screenshot_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_audio_mute = "f9" >> C:\RetroArch\retroarch.cfg
echo input_audio_mute_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_audio_mute_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_osk_toggle = "f12" >> C:\RetroArch\retroarch.cfg
echo input_osk_toggle_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_osk_toggle_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_netplay_flip_players_1_2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_netplay_flip_players_1_2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_netplay_flip_players_1_2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_netplay_game_watch = "i" >> C:\RetroArch\retroarch.cfg
echo input_netplay_game_watch_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_netplay_game_watch_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_slowmotion = "e" >> C:\RetroArch\retroarch.cfg
echo input_slowmotion_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_slowmotion_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_enable_hotkey = "nul" >> C:\RetroArch\retroarch.cfg
echo input_enable_hotkey_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_enable_hotkey_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_volume_up = "add" >> C:\RetroArch\retroarch.cfg
echo input_volume_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_volume_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_volume_down = "subtract" >> C:\RetroArch\retroarch.cfg
echo input_volume_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_volume_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_overlay_next = "nul" >> C:\RetroArch\retroarch.cfg
echo input_overlay_next_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_overlay_next_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_eject_toggle = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_eject_toggle_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_eject_toggle_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_next = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_next_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_next_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_prev = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_prev_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_disk_prev_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_grab_mouse_toggle = "f11" >> C:\RetroArch\retroarch.cfg
echo input_grab_mouse_toggle_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_grab_mouse_toggle_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_game_focus_toggle = "scroll_lock" >> C:\RetroArch\retroarch.cfg
echo input_game_focus_toggle_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_game_focus_toggle_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_menu_toggle = "f1" >> C:\RetroArch\retroarch.cfg
echo input_menu_toggle_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_menu_toggle_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player2_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player3_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player4_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player5_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player6_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player7_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player8_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player9_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player10_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player11_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player12_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player13_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player14_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player15_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_b = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_b_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_b_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_y = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_y_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_y_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_select = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_select_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_select_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_start = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_start_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_start_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_up = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_up_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_up_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_down = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_down_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_down_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_left = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_left_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_left_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_right = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_right_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_right_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_a = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_a_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_a_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_x = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_x_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_x_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r2 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r2_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r2_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r3 = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r3_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r3_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_l_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_x_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_x_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_x_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_x_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_x_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_x_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_y_plus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_y_plus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_y_plus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_y_minus = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_y_minus_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_r_y_minus_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_turbo = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_turbo_btn = "nul" >> C:\RetroArch\retroarch.cfg
echo input_player16_turbo_axis = "nul" >> C:\RetroArch\retroarch.cfg
echo xmb_font = "" >> C:\RetroArch\retroarch.cfg
echo netplay_nickname = "" >> C:\RetroArch\retroarch.cfg
echo video_filter = "" >> C:\RetroArch\retroarch.cfg
echo audio_dsp_plugin = "" >> C:\RetroArch\retroarch.cfg
echo netplay_ip_address = "" >> C:\RetroArch\retroarch.cfg
echo netplay_password = "" >> C:\RetroArch\retroarch.cfg
echo netplay_spectate_password = "" >> C:\RetroArch\retroarch.cfg
echo core_options_path = "" >> C:\RetroArch\retroarch.cfg
echo video_shader = "" >> C:\RetroArch\retroarch.cfg
echo menu_wallpaper = "" >> C:\RetroArch\retroarch.cfg
echo input_overlay = "" >> C:\RetroArch\retroarch.cfg
echo video_font_path = "" >> C:\RetroArch\retroarch.cfg
echo content_history_dir = "" >> C:\RetroArch\retroarch.cfg
echo cache_directory = "" >> C:\RetroArch\retroarch.cfg
echo resampler_directory = "" >> C:\RetroArch\retroarch.cfg
echo recording_output_directory = "" >> C:\RetroArch\retroarch.cfg
echo recording_config_directory = "" >> C:\RetroArch\retroarch.cfg
echo xmb_font = "" >> C:\RetroArch\retroarch.cfg
echo playlist_names = "" >> C:\RetroArch\retroarch.cfg
echo playlist_cores = "" >> C:\RetroArch\retroarch.cfg
echo audio_device = "" >> C:\RetroArch\retroarch.cfg
echo camera_device = "" >> C:\RetroArch\retroarch.cfg
echo cheevos_username = "" >> C:\RetroArch\retroarch.cfg
echo cheevos_password = "" >> C:\RetroArch\retroarch.cfg
echo video_context_driver = "" >> C:\RetroArch\retroarch.cfg
echo input_keyboard_layout = "" >> C:\RetroArch\retroarch.cfg
echo bundle_assets_src_path = "" >> C:\RetroArch\retroarch.cfg
echo bundle_assets_dst_path = "" >> C:\RetroArch\retroarch.cfg
echo bundle_assets_dst_path_subdir = "" >> C:\RetroArch\retroarch.cfg
goto mkdirROMSnew

:mkdirROMSnew
mkdir C:\ROMS\amiga
mkdir C:\ROMS\atari2600
mkdir C:\ROMS\atari5200
mkdir C:\ROMS\atari7800
mkdir C:\ROMS\atari800
mkdir C:\ROMS\atarijaguar
mkdir C:\ROMS\atarilynx
mkdir C:\ROMS\coleco
mkdir C:\ROMS\fba
mkdir C:\ROMS\fds
mkdir C:\ROMS\gamegear
mkdir C:\ROMS\gb
mkdir C:\ROMS\gba
mkdir C:\ROMS\gbc
mkdir C:\ROMS\gc
mkdir C:\ROMS\intellivision
mkdir C:\ROMS\mame-libretro
mkdir C:\ROMS\mastersystem
mkdir C:\ROMS\megadrive
mkdir C:\ROMS\msx
mkdir C:\ROMS\n64
mkdir C:\ROMS\neogeo
mkdir C:\ROMS\nes
mkdir C:\ROMS\nds
mkdir C:\ROMS\ngp
mkdir C:\ROMS\ngpc
mkdir C:\ROMS\pcengine
mkdir C:\ROMS\psx
mkdir C:\ROMS\ps2
mkdir C:\ROMS\sega32x
mkdir C:\ROMS\segacd
mkdir C:\ROMS\sg-1000
mkdir C:\ROMS\snes
mkdir C:\ROMS\vectrex
mkdir C:\ROMS\zxspectrum
goto setsharesnew

:setsharesnew

net share amiga=C:\ROMS\amiga /grant:everyone,full
net share atari2600=C:\ROMS\atari2600 /grant:everyone,full
net share atari5200=C:\ROMS\atari5200 /grant:everyone,full
net share atari7800=C:\ROMS\atari7800 /grant:everyone,full
net share atari800=C:\ROMS\atari800 /grant:everyone,full
net share atarijaguar=C:\ROMS\atarijaguar /grant:everyone,full
net share atarilynx=C:\ROMS\atarilynx /grant:everyone,full
net share coleco=C:\ROMS\coleco /grant:everyone,full
net share fba=C:\ROMS\fba /grant:everyone,full
net share fds=C:\ROMS\fds /grant:everyone,full
net share gamegear=C:\ROMS\gamegear /grant:everyone,full
net share gb=C:\ROMS\gb /grant:everyone,full
net share gba=C:\ROMS\gba /grant:everyone,full
net share gbc=C:\ROMS\gbc /grant:everyone,full
net share gc=C:\ROMS\gc /grant:everyone,full
net share intellivision=C:\ROMS\intellivision /grant:everyone,full
net share mame-libretro=C:\ROMS\mame-libretro /grant:everyone,full
net share mastersystem=C:\ROMS\mastersystem /grant:everyone,full
net share megadrive=C:\ROMS\megadrive /grant:everyone,full
net share msx=C:\ROMS\msx /grant:everyone,full
net share n64=C:\ROMS\n64 /grant:everyone,full
net share neogeo=C:\ROMS\neogeo /grant:everyone,full
net share nes=C:\ROMS\nes /grant:everyone,full
net share nds=C:\ROMS\nds /grant:everyone,full
net share ngp=C:\ROMS\ngp /grant:everyone,full
net share ngpc=C:\ROMS\ngpc /grant:everyone,full
net share pcengine=C:\ROMS\pcengine /grant:everyone,full
net share psx=C:\ROMS\psx /grant:everyone,full
net share ps2=C:\ROMS\ps2 /grant:everyone,full
net share sega32x=C:\ROMS\sega32x /grant:everyone,full
net share segacd=C:\ROMS\segacd /grant:everyone,full
net share sg-1000=C:\ROMS\sg-1000 /grant:everyone,full
net share snes=C:\ROMS\snes /grant:everyone,full
net share vectrex=C:\ROMS\vectrex /grant:everyone,full
net share zxspectrum=C:\ROMS\zxspectrum /grant:everyone,full
goto setpermsnew

:setpermsnew
icacls "C:\ROMS" /grant everyone:(OI)(CI)F /T
goto startupESnew

:startupESnew
cd "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
echo taskkill /im explorer.exe /f > "%USERPROFILE%\startES.bat"
echo "%ProgramFiles%\EmulationStation\emulationstation.exe" >> "%USERPROFILE%\startES.bat"

del "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\startES.lnk"
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%USERPROFILE%\CreateShortcut2.vbs"
echo sLinkFile = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\startES.lnk" >> "%USERPROFILE%\CreateShortcut2.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%USERPROFILE%\CreateShortcut2.vbs"
echo oLink.TargetPath = "%USERPROFILE%\startES.bat" >> "%USERPROFILE%\CreateShortcut2.vbs"
echo oLink.Save >> "%USERPROFILE%\CreateShortcut2.vbs"
cscript "%USERPROFILE%\CreateShortcut2.vbs"
del "%USERPROFILE%\CreateShortcut2.vbs"
goto autologinnew

:autologinnew
cls
set /p ESpassword="Enter Windows Password: "
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d %username% /f
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d %ESpassword% /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonCount /t REG_DWORD /d 0
goto hostnamenew

:hostnamenew
WMIC computersystem where caption='%COMPUTERNAME%' rename RetroCake
goto menu

::===================================================================================================================================================================================================================================================================================================================

:AdminFail
echo =============================================
echo =                                           =
echo =           RUN AS ADMINISTRATOR            =
echo =                                           =
echo =============================================
echo            Press Any Key to Exit
pause >nul
exit