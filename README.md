# RetroCake

I Initially created the script because I grew tired of the sub par graphics drivers and screen tearing issues on the debian based distros I was using to create a more powerful emulator box.

# What can this do?

So far this script ahs the following capabilities:

1. Fully install and setup EmulationStation and RetroArch from the latest builds (Or Stable Releases if chosen).
2. Generate a functional es_systems.cfg (Just needs ROM paths).
3. Manage the es_systems.cfg file to add your ROM paths.
4. Clean any and all files created by this script.
5. Individually update RetroArch and EmulationStation.
6. Update RetroArch cores to their latest compiled version.
7. Install and manage EmulationStation themes.

# Script Flavors

The Script comes in two flavors

The first is the desktop edition
This one is used to install alongside a normal windows installation.
It can be launched at will and great if you're using your regular PC and would like EmulationStation and RetroArch.

The second is meant for a dedicated Windows PC connected to a TV or other.
This one differs in several key ways.

1. This sets up rom directories to C:\ROMS\systemname.
2. It shares all ROM folders for easy ROM transfer.
3. It sets the PC to automatically start EmulationStation on startup.
4. It sets the PC to automatically login. (You will be prompted for your user password.
5. It kills Windows Explorer on login to save resources.
6. It changes with PC's name to RetroCake for easier access.

The dedicated machine script should not be run on your regular day to day PC as it will make

# Dedicated version is currently untested