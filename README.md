# macOS-Screen-Saver-and-Wallpaper

With the introduction of the new screen saver to wallpaper transition feature of macOS Sonoma comes a new mechanism for controlling the screen saver and wallpaper. This repository contains four scripts that are designed to be used within Jamf (not tested with other MDMs). 

## Scripts

### Get Screen Saver and Wallpaper Information

This script will output data for three variables that are used for the other three scripts mentioned below. Depending on which script you choose to use, you may only need one, two, or all three of the variables below. This script outputs the following data:
* `screenSaverBase64` - screen saver specific base64 code
* `wallpaperBase64` - wallpaper specific base64 code
* `wallpaperLocation` - custom set wallpaper directory

### Set Screen Saver and Keep User's Wallpaper
This script sets a custom screen saver, but keeps the user's wallpaper settings.

### Set Screen Saver and Reset Default Wallpaper
This script sets a custom screen saver and resets the wallpaper to use the default Sonoma wallpaper.

### Set Screen Saver and Wallpaper
This script sets a custom screen saver and wallpaper.

## How To Use

1. On a Mac, manually set your desired screen saver and wallpaper settings via System Settings.
2. Add the "Get Screen Saver and Wallpaper Information" script to Jamf.
3. In Jamf, create a policy named "Get Screen Saver and Wallpaper Information" and add the "Get Screen Saver and Wallpaper Information" script to the script payload. Scope the policy to the Mac where you have set your desired screen saver and wallpaper settings.
4. Run the "Get Screen Saver and Wallpaper Information" policy on the Mac where you have set the desired screen saver and wallpaper settings.
5. Once the policy is finished running, check the policy log to get the output of the variables needed for the other script(s). You'll use some or all of the variables depending on which script you use to deploy the screen saver and wallpaper settings.
6. Insert the output of the variables from the log to the script(s) you plan to use in your environment:
    * If using the "Set Screen Saver and Keep User's Wallpaper" script, you'll need to insert the output of the `screenSaverBase64` variable.
    * If using the "Set Screen Saver and Reset Default Wallpaper" script, you'll need to insert the output of the `screenSaverBase64` variable.
    * If using the "Set Screen Saver and Wallpaper" script, you'll need to insert the output of all three `screenSaverBase64`, `wallpaperBase64`, and `wallpaperLocation` variables.
7. Once the variables have been plugged in, upload the desired script to Jamf.
8. In Jamf, create a policy for setting the screen saver and wallpaper, and add the desired script in the script payload. You do **not** need to add the "Get Screen Saver and Wallpaper Information" script to the script payload of this policy.
9. Deploy the policy which sets the screen saver and wallaper to desired Mac endpoints. Please note, the Mac endpoints should have macOS Sonoma at the very least.

## Troubleshooting
* If the "Set Screen Saver and Reset Default Wallpaper" script is not working correcty, try setting the default wallpaper on a Mac and then running the "Get Screen Saver and Wallpaper Information" script to get the `wallpaperBase64` code and replacing the current `wallpaperBase64` variable in the "Set Screen Saver and Reset Default Wallpaper" script.
