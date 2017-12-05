If you like my project and would like to donate click the button below.\
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=R477DPAUW89PU)


# What is this?

RetroCake is a tool used to setup a RetroPie-like environment on Windows Operating Systems.\
You can use EmulationStation as a desktop application, or you can setup a Windows machine to be a dedicated Emulator Machine.\
I developed this script initially due to XServer on debian based linux distros having screen tearing issues.\
After initial developement I really grew to like having EmulationStation as a desktop app, and I figured others may like it, too.

This tool does not include ROM or BIOS files, they need to be supplied.

All RetroCake files are contained in C:\RetroCake\
If you find a bug, or have a feature request please use the github issue tracker.

## Supported Systems include:

	3do
	ags
	amiga
	amstradcpc
	apple2
	atari2600
	atari5200
	atari7800
	atari800
	atarijaguar
	atarilynx
	atarist
	bbcmicro
	c64
	coco
	colecovision
	daphne
	dragon32
	dreamcast
	fba
	fds
	gameandwatch
	gamegear
	gb
	gba
	gbc
	gc
	intellivision
	mame
	mastersystem
	mega-cd
	mega32x
	megadrive
	msx
	mvs
	n64
	nds
	neogeo
	nes
	ngp
	ngpc
	pcengine
	ps2
	psp
	psx
	saturn
	scraper.exe
	sega32x
	segacd
	sfc
	sg-1000
	snes
	vectrex
	virtualboy
	wii
	zxspectrum

## Some Systems Require BIOS files.
They are listed below

	Amiga         C:\RetroCake\RetroArch\system\kick13.rom OR C:\RetroCake\RetroArch\system\kick20.rom OR C:\RetroCake\RetroArch\system\kick31.rom
	Atari800      C:\RetroCake\RetroArch\system\ATARIXL.ROM (BIOS for Atari XL/XE OS) OR C:\RetroCake\RetroArch\system\ATARIBAS.ROM (BIOS for the BASIC interpreter) OR C:\RetroCake\RetroArch\system\ATARIOSA.ROM (BIOS for Atari 400/800 PAL) OR C:\RetroCake\RetroArch\system\ATARIOSB.ROM (BIOS for Atari 400/800 NTSC) OR C:\RetroCake\RetroArch\system\5200.ROM (BIOS for the Atari 5200)
	Atari 7800    C:\RetroCake\RetroArch\system\7800 BIOS (U).rom
	CoCo          C:\RetroCake\RetroArch\system\bas13.rom
	Dragon32      C:\RetroCake\RetroArch\system\d32.rom
	Dreamcast     C:\RetroCake\RetroArch\system\dc_boot.bin AND C:\RetroCake\RetroArch\system\dc_flash.bin
	FDS           C:\RetroCake\RetroArch\system\disksys.rom
	gba           C:\RetroCake\RetroArch\system\gba_bios.bin
	psx           C:\RetroCake\RetroArch\system\SCPH1001.BIN
	PS2           C:\RetroCake\Emulators\PCSX2\bios\ANYPS2BIOS.bin
	neo geo       C:\PATH\TO\ROMS\neogeo\neogeo.zip
	sega cd       C:\RetroCake\RetroArch\system\us_scd1_9210.bin (or rename to bios_CD_U.bin) OR eu_mcd1_9210.bin (or rename to bios_CD_E.bin) OR jp_mcd1_9112.bin (or rename to bios_CD_J.bin) for Europe and Japan respectively
	Sega Saturn   C:\RetroCake\RetroArch\system\saturn_bios.bin

	
### Once the Automated installer is done simply double click EmuLationStation on your desktop.

#### The list of features is as follows:

# Automated Installers

There are 3 options for automated installation.

## No ROM Dirs

This option is if you do not wish to use the default ROM directories (C:\RetroCake\ROMS)\
Once the setup is completed you will need to edit the es_systems.cfg to change the ROM directories to your liking.\
This option is great for people who have ROMS on another drive (like me), or just do not wish to use the default folder.

## Default Installer.

This option handles the ROM directories for you.\
It creates a system folder for most supported ROMS.\
Once installation completes the ROMS folder is opened and you can transfer ROMs into the system folders.\
This option is great for people who do not have gigantic (1TB+) collections and can easily fit their ROMs on the C: drive.

## Custom Installer

This option is to setup ROM directories like option 2, but in a place of your choosing.\
You will be prompted for the main folder you'd like to use.

Syntax: E:\ROMS, D:\Games, F:\Retro, etc.\
No trailing \\

All system subdirectories will be added to the folder specified.\
EX:\
If E:\ROMS is specified the following folders will be created

	E:\ROMS\3do
	E:\ROMS\ags
	E:\ROMS\amiga
	E:\ROMS\amstradcpc
	E:\ROMS\apple2
	E:\ROMS\atari2600
	E:\ROMS\atari5200
	E:\ROMS\atari7800
	E:\ROMS\atari800
	E:\ROMS\atarijaguar
	E:\ROMS\atarilynx
	E:\ROMS\atarist
	E:\ROMS\bbcmicro
	E:\ROMS\c64
	E:\ROMS\coco
	E:\ROMS\colecovision
	E:\ROMS\daphne
	E:\ROMS\dragon32
	E:\ROMS\dreamcast
	E:\ROMS\fba
	E:\ROMS\fds
	E:\ROMS\gameandwatch
	E:\ROMS\gamegear
	E:\ROMS\gb
	E:\ROMS\gba
	E:\ROMS\gbc
	E:\ROMS\gc
	E:\ROMS\intellivision
	E:\ROMS\mame
	E:\ROMS\mastersystem
	E:\ROMS\mega32x
	E:\ROMS\mega-cd
	E:\ROMS\megadrive
	E:\ROMS\msx
	E:\ROMS\mvs
	E:\ROMS\n64
	E:\ROMS\nds
	E:\ROMS\neogeo
	E:\ROMS\nes
	E:\ROMS\ngp
	E:\ROMS\ngpc
	E:\ROMS\pcengine
	E:\ROMS\ps2
	E:\ROMS\psp
	E:\ROMS\psx
	E:\ROMS\saturn
	E:\ROMS\sega32x
	E:\ROMS\segacd
	E:\ROMS\sfc
	E:\ROMS\sg-1000
	E:\ROMS\snes
	E:\ROMS\vectrex
	E:\ROMS\virtualboy
	E:\ROMS\wii
	E:\ROMS\zxspectrum

And a config file for EmulationStation will be generated to make adding ROMS drag and drop


# Manage EmulationStation

## Update/Install EmulationStation

This is for updating EmulationStation.\
It also backs up your current EmulationStation to C:\RetroCake\Backups with a timestamped Zip file.\
The backup is in case something breaks with a newer build when updating.

## Manage es_systems.cfg
This is for generating and editing es_systems.cfg

## Manage EmulationStation Themes.

This tool has several features, and will setup GIT to C:\RetroCake\Tools\Git 

### Install/update all themes.
Relatively Self explanatory. This installs every avaiable theme for EmulationStation.
		
### Install/Update Individual Themes
This option lets you select the theme you want by name and install 1 by one. \
Userful if you do like wish to install 80 themes and just want a specific one.
		
### Theme Gallery/Previews.
This downloads previews for all available themes and writes them to a HTML file.\
The HTML file is them launched with your default browser.\
Hover over the image to see which theme it belongs to.\
This is to help with the Individual theme downloader so you can see what you're getting.
		
# Manage RetroArch

## Install RetroArch 1.6.7

This installs the latest Stable Build of RetroArch. In case you wanted to revert from a nightly build.

## Update RetroArch to the latest nightly

Updates RetroArch, self explanatory.

## Generate Clean Retroarch.cfg

This generates a RetroArch.cfg with nearly default settings\
Changes made are as follows:

	All Games Start in Fullscreen.
	You can bring up the RetroArch menu with Start and Select
	
## Update RetroArch Cores to the latest Nightly Build.

Self Explanatory.
This updates all RetroArch Cores (108 total)

# Manage Additional Emulators.

This option installs emulators for systems that RetroArch cannot emulate.
Current emulators are:

	AppleWin
	Hatari
	BeebEm
	XRoar
	Daphne
	jzIntv
	PCSX2

# Manage ROM Directories.

This creates the default ROM directories in C:\RetroCake\ROMS\
You can also create custom ROM directories like E:\ROMS\
You can also Share the ROM Directories from here if using a dedicated Emulator Box.

# Manage Dedicated EmuBox Settings (Not fully tested yet)

## Setup all dedicated emubox settings

This option will do a full setup and turn your RetroCake Installation into a Dedicate Emu Box.\
This option inclused installation of all of the options below.\
The only user requires input is during the Auto Login setup.\
This is due to how Windows handles Auto login.

## RetroCake auto start options  

From here you can select if you'd like to Automatically start RetroCake (EmulationStation) upon login.\
This goes hand in hand with Auto Login.\
You can also remove the Auto Start settings if you no longer with to have Auto Start.

## Setup Auto Login

Self Explanatory.\
Opens the netplwiz menu.\
Guides you through setting up Auto Login.

## Setup RetroCake folder shares 

### Setup RetroCake shares with default rom directory
 
Sets up the following shares

	ROMS
	BIOS
	EMULATORS
	EMULATIONSTATION
    
The ROMS folder uses the default C:\RetroCake\ROMS

### Setup RetroCake shares with custom rom directory

Sets up the following shares

	ROMS
	BIOS
	EMULATORS
	EMULATIONSTATION

You will be asked to enter the ROMS directory.\
This option is if you installed using a custom ROMS directory.

### Remove RetroCake shares

Self Explanatory.\
Removes all shares created by this script.

## Setup system name

From here you can set your PC's hostname to the default RetroCake, or to any custom hostname you'd like.\
This is to make it easier to access the shares on the computer.


# System Cleanup

This option is for cleaning up parts of RetroCake or removing REtroCake entirely.\
Mostly used by me for Testing, but if anyone needs to clean up and remove files this is for you.
