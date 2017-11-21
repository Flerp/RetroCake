# RetroCake

I Initially created the script because I grew tired of the sub par graphics drivers and screen tearing issues on the debian based distros I was using to create a more powerful emulator box.

# What can this do?

So far this script hass the following capabilities:

# Automated Installers

There are 3 options for automated installation.

1. No ROM Dirs

This option is if you do not wish to use the default ROM directories (C:\RetroCake\ROMS)
Once the setup is completed you will need to edit the es_systems.cfg to change the ROM directories to your liking. 
This option is great for people who have ROMS on another drive (like me), or just do not wish to use the default folder.

2. Default Installer.

This option handles the ROM directories for you.
It creates a system folder for most supported ROMS.
Once installation completes the ROMS folder is opened and you can transfer ROMs into the system folders.
This option is great for people who do not have gigantic (1TB+) collections and can easily fit their ROMs on the C: drive.

3. Custom Installer

This option is to setup ROM directories like option 2, but in a place of your choosing.
You will be prompted for the main folder you'd like to use.

	Syntax: E:\ROMS, D:\Games, F:\Retro, etc.
	No trailing \
	All system subdirectories will be added to the folder specified.
	EX:
	If E:\ROMS is specified the following folders will be created
	E:\ROMS\amiga
	E:\ROMS\atari2600
	E:\ROMS\atari5200
	E:\ROMS\atari7800
	E:\ROMS\atari800
	E:\ROMS\atarijaguar
	E:\ROMS\atarilynx
	E:\ROMS\coleco
	E:\ROMS\fba
	E:\ROMS\fds
	E:\ROMS\gamegear
	E:\ROMS\gb
	E:\ROMS\gba
	E:\ROMS\gbc
	E:\ROMS\gc
	E:\ROMS\intellivision
	E:\ROMS\mame-libretro
	E:\ROMS\mastersystem
	E:\ROMS\megadrive
	E:\ROMS\msx
	E:\ROMS\n64
	E:\ROMS\neogeo
	E:\ROMS\nes
	E:\ROMS\nds
	E:\ROMS\ngp
	E:\ROMS\ngpc
	E:\ROMS\pcengine
	E:\ROMS\psx
	E:\ROMS\ps2
	E:\ROMS\sega32x
	E:\ROMS\segacd
	E:\ROMS\sg-1000
	E:\ROMS\snes
	E:\ROMS\vectrex
	E:\ROMS\zxspectrum

And a config file for EmulationStation will be generated to make adding ROMS drag and drop


# Manage EmulationStation

1. Update/Install EmulationStation

This is for updating EmulationStation
It also backs up your current EmulationStation to C:\RetroCake\Backups with a timestamped Zip file.
The backup is in case something breaks with a newer build when updating.

2. Manage es_systems.cfg

This is for generating and editing es_systems.cfg

3. Manage EmulationStation Themes.

This tool has several features, and will setup GIT to C:\RetroCake\Tools\Git 

	a. Install/update all themes.
		Relatively Self explanatory. This installs every avaiable theme for EmulationStation.
		
	b. Install/Update Individual Themes
		This option lets you select the theme you want by name and install 1 by one. 
		Userful if you do like wish to install 80 themes and just want a specific one.
		
	c. Theme Gallery/Previews.
		This downloads previews for all available themes and writes them to a HTML file.
		The HTML file is them launched with your default browser.
		Hover over the image to see which theme it belongs to.
		This is to help with the Individual theme downloader so you can see what you're getting.
		
# Manage RetroArch

1. Install RetroArch 1.6.7

This installes the latest Stable Build of RetroArch. In case you wanted to revert from a nightly build.

2. Update RetroArch to the latest nightly

Updates RetroArch, self explanatory.

3. Generate Clean Retroarch.cfg

This generates a RetroArch.cfg with nearly default settings
Changes made are as follows:

	a. All Games Start in Fullscreen.
	
	b. You can bring up the RetroArch menu with Start and Select
	
4 Update REtroArch Cores to the latest Nightly Build.

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

This creates the default ROM directories in C:\RetroCake\ROMS
You can also Share the ROM Directories from here if using a dedicated Emulator Box.
WIP - Will be adding a custom ROM directory structure in the next few updates.

# System Cleanup

This options deletes ALL RetroCake Files.
Mostly used by me for Testing, but if anyone needs to clean up and remove files this is for you.
