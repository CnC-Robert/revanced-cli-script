# revanced-cli-script
Bash script that builds & installs revanced automaticlly. Java &amp; Android sdk included. The script also works on windows if you use WSL.

# Requirements
 - A rooted android device
 - Compatible YouTube version installed on your phone
 - Username & token set in ~/.gradle/gradle.properties or $GITHUB_TOKEN set with the token
 - Git & curl installed
 - Java & Android SDK will be downloaded automaticlly if not installed already

# Usage
Place a compatible youtube apk in a folder named build like this: `./build/youtube.apk` and execute the script `./build-from-source.sh "adb device name (optional)"`. If an adb device name is given revanced will automaticlly be installed to your phone.
