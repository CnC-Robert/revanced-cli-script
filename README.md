If you came here from the ReVanced telegram channel, please know it's fake. Any official links are on their [discord server](https://revanced.app/discord)

# revanced-cli-script

Bash script that builds & installs revanced automaticlly. Java &amp; Android sdk included. The script also works on windows if you use WSL.

# Requirements

 - Compatible YouTube APK, the same version needs to be installed on your phone
 - If you are building from source: Username & token set in ~/.gradle/gradle.properties or $GITHUB_TOKEN set with the token
 - Git, curl & adb installed
 - ZuluJDK 17 or OpenJDK 17
 - Android SDK
 - Java & Android SDK will be downloaded automaticlly if not installed already

# Usage

By default the script will build the non-root version unless your set $ROOT to 1.

Place a compatible youtube apk in a folder named build like this: `./build/youtube.apk` and execute the script `./build-from-source.sh "adb device name (optional)"` or `./build-from-prebuilt.sh "adb device name (optional)"`. If an adb device name is given revanced will automaticlly be installed to your phone.
