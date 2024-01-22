#!/bin/bash

# Title:	Set Screen Saver and Wallpaper
# Version:	2024.01.22
# Author:	https://github.com/itjimbo

# Notes:	This script is based on scripts provided by user Pico (https://github.com/PicoMitchell) on the Mac Admins Slack channel. 

function getDefinedVariables() {
	# Insert desired macOS minimum version for script to run. Default is 14 for macOS 14 Sonoma and later.
	desiredmacOSVersion='14'

	# Insert the output of the screenSaverBase64 variable from the 'Get Screen Saver and Wallpaper Settings' script.
	screenSaverBase64='INSERT_BASE64_CODE_HERE'

	# Insert the output of the wallpaperBase64 variable from the 'Get Screen Saver and Wallpaper Settings' script.
	wallpaperBase64='INSERT_BASE64_CODE_HERE'

	# Insert the output of the wallpaperLocation variable from the 'Get Screen Saver and Wallpaper Settings' script.
	wallpaperLocation="INSERT_WALLPAPER_LOCATION_HERE"

	# Do not edit beyond this point...
	getStarterVariables
}

function getStarterVariables() {
	# Do not edit these variables.
	echo "$(date) - Script will only run on macOS version ${desiredmacOSVersion} or later (macOS ${desiredmacOSVersion} - Present)."
	echo "$(date) - screenSaverBase64: ${screenSaverBase64}"
	echo "$(date) - wallpaperBase64: ${wallpaperBase64}"
	echo "$(date) - wallpaperLocation: ${wallpaperLocation}"
	currentRFC3339UTCDate="$(date -u '+%FT%TZ')"
	echo "$(date) - currentRFC3339UTCDate: ${currentRFC3339UTCDate}"
	loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
	echo "$(date) - Logged in user: ${loggedInUser}"
	macOSFullProductVersion=$(sw_vers -productVersion)
	echo "$(date) - macOS Full Product Version: ${macOSFullProductVersion}"
	macOSMainProductVersion="${macOSFullProductVersion:0:2}"
	echo "$(date) - macOS Main Product Version: ${macOSMainProductVersion}"
	wallpaperStoreDirectory="/Users/${loggedInUser}/Library/Application Support/com.apple.wallpaper/Store"
	echo "$(date) - wallpaperStoreDirectory: ${wallpaperStoreDirectory}"
	wallpaperStoreFile="Index.plist"
	echo "$(date) - wallpaperStoreFile: ${wallpaperStoreFile}"
	wallpaperStoreFullPath="${wallpaperStoreDirectory}/${wallpaperStoreFile}"
	echo "$(date) - wallpaperStoreFullPath: ${wallpaperStoreFullPath}"
	checkmacOSVersion
}

function checkmacOSVersion() {
	echo "$(date) - Checking macOS version..."
    if [[ "${macOSMainProductVersion}" == "" ]]; then
        echo "$(date) - Could not determine macOSMainProductVersion variable."
        exitCode='1'
		finalize
    elif [[ "${macOSMainProductVersion}" -ge "${desiredmacOSVersion}" ]]; then
        checkUser
    else
        echo "$(date) - macOS is on version $macOSFullProductVersion; do not run."
        exitCode='0'
		finalize
    fi
}

function checkUser() {
	echo "$(date) - Checking valid user..."
	if [[ "${loggedInUser}" == "root" ]]; then
		echo "$(date) - Script should not be run as root user."
		exitCode='1'
		finalize
	elif [[ "${loggedInUser}" == "" ]]; then
		echo "$(date) - User cannot be defined."
		exitCode='1'
		finalize
	else
		setScreenSaverSettings
	fi
}

function setScreenSaverSettings() {
	echo "$(date) - Setting screen saver settings..."
	aerialDesktopAndScreenSaverSettingsPlist="$(plutil -create xml1 - |
		plutil -insert 'Desktop' -dictionary -o - - |
		plutil -insert 'Desktop.Content' -dictionary -o - - |
		plutil -insert 'Desktop.Content.Choices' -array -o - - |
		plutil -insert 'Desktop.Content.Choices' -dictionary -append -o - - |
		plutil -insert 'Desktop.Content.Choices.0.Configuration' -data "${wallpaperBase64}" -o - - |
		plutil -insert 'Desktop.Content.Choices.0.Files' -array -o - - |
		plutil -insert 'Desktop.Content.Choices.0.Files' -dictionary -append -o - - |
		plutil -insert 'Desktop.Content.Choices.0.Files.0.relative' -string "${wallpaperLocation}" -o - - |
		plutil -insert 'Desktop.Content.Choices.0.Provider' -string 'com.apple.wallpaper.choice.image' -o - - |
		plutil -insert 'Desktop.Content.Shuffle' -string '$null' -o - - |
		plutil -insert 'Desktop.LastSet' -date "${currentRFC3339UTCDate}" -o - - |
		plutil -insert 'Desktop.LastUse' -date "${currentRFC3339UTCDate}" -o - - |
		plutil -insert 'Idle' -dictionary -o - - |
		plutil -insert 'Idle.Content' -dictionary -o - - |
		plutil -insert 'Idle.Content.Choices' -array -o - - |
		plutil -insert 'Idle.Content.Choices' -dictionary -append -o - - |
		plutil -insert 'Idle.Content.Choices.0.Configuration' -data "${screenSaverBase64}" -o - - |
		plutil -insert 'Idle.Content.Choices.0.Files' -array -o - - |
		plutil -insert 'Idle.Content.Choices.0.Provider' -string 'com.apple.wallpaper.choice.screen-saver' -o - - |
		plutil -insert 'Idle.Content.Shuffle' -string '$null' -o - - |
		plutil -insert 'Idle.LastSet' -date "${currentRFC3339UTCDate}" -o - - |
		plutil -insert 'Idle.LastUse' -date "${currentRFC3339UTCDate}" -o - - |
		plutil -insert 'Type' -string 'individual' -o - -)"
	makeScreenSaverDirectory
}

function makeScreenSaverDirectory() {
	# Create the path to the screen saver/wallpaper Index.plist.
	echo "$(date) - Creating screen saver directory..."
	mkdir -p "${wallpaperStoreDirectory}"
	createIndexPlist
}

function createIndexPlist() {
	# Create the Index.plist
	echo "$(date) - Creating screen saver Index.plist..."
	plutil -create binary1 - |
		plutil -insert 'AllSpacesAndDisplays' -xml "${aerialDesktopAndScreenSaverSettingsPlist}" -o - - |
		plutil -insert 'Displays' -dictionary -o - - |
		plutil -insert 'Spaces' -dictionary -o - - |
		plutil -insert 'SystemDefault' -xml "${aerialDesktopAndScreenSaverSettingsPlist}" -o "${wallpaperStoreFullPath}" -
	killWallpaperAgent
}

function killWallpaperAgent() {
	# Kill the wallpaperAgent to refresh and apply the screen saver/wallpaper settings.
	echo "$(date) - Restarting wallpaper agent..."
	killall WallpaperAgent
	exitCode='0'
	finalize
}

function finalize() {
    echo ""
    if [[ "${exitCode}" == "0" ]]; then
        echo "$(date) - Mission accomplished!"
        exit 0
    else
        echo "$(date) - Abort mission..."
        exit 1
    fi    
}

echo ""
getDefinedVariables