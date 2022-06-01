# revanced-cli-script
Bash script that builds revanced automaticlly. Java &amp; Android sdk included. The script also works on windows if you use WSL.

# Requirements
You need to have git & wget installed and have a username & token set in ~/.gradle/gradle.properties.
Java & Android SDK will be downloaded automaticlly if not installed already.

# Usage
Place the youtube apk in a folder named build like this: `./build/youtube.apk` and execute the script `./build-from-source.sh "adb device name (optional)"`

# Mounting the apk

This is no longer needed to do manually since the cli will already do it for you when you deploy with adb.
