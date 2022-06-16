#!/bin/bash

DIR="$(pwd)"

# Check if a youtube.apk is provided before continuing
if [ ! -e "$DIR/build/youtube.apk" ]; then
	echo
	echo -e "\e[1;31mError: ./build/youtube.apk not found\e[0m"
	echo
	exit 1
fi

# Check if curl is installed before continuing
if ! command -v "curl" &> "/dev/null"; then
	echo	
	echo -e "\e[1;31mError: curl not found\e[0m"
	echo
	exit 1
fi

# Check if java is installed and if not, download and extract openjdk 17
if ! command -v "java" &> "/dev/null" && [ -z "$JAVA_HOME" ]; then
	export JAVA_HOME="$(readlink -f "$DIR/openjdk")"
	if [ ! -e "$JAVA_HOME/bin/java" ]; then
		echo
		if [ ! -e "openjdk.tar.gz" ]; then
			echo "Downloading openjdk..."
			wget -q "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz" -O "openjdk.tar.gz"
		fi
		echo "Extracting openjdk..."
		tar xzf "openjdk.tar.gz"
		mv jdk-* "openjdk"
	fi
else
	if java -version 2>&1 | grep "1.8" &> "/dev/null"; then
		echo
		echo -e "\e[1;31mError: Java 8 is not supported\e[0m"
		echo
		exit 1
	fi
fi

# Check if adb device is connected before continuing
if [ -n "$1" ]; then

	# Check if adb is installed before continuing
	if ! command -v "adb" &> "/dev/null"; then
		echo
		echo -e "\e[1;31mError: adb not found\e[0m"
		echo
		exit 1
	fi

	# Check if the adb device is connected
	if ! adb devices | grep "$1" &> "/dev/null"; then
		echo
		echo -e "\e[1;31mError: device $1 not connected\e[0m"
		echo
		exit 1
	fi

	# Check if adb has shell & root access
	if ! adb shell su -c exit; then
		echo
		echo -e "\e[1;31mError: device $1 either has no shell access or root access\e[0m"
		echo
		exit 1
	fi

else
	echo
	echo -e "\e[1;33mWarning: no adb device specified. It is recommended to do so to automatically install the patched apk\e[0m"
fi

# Check $GITHUB_TOKEN if set
if [ -n "$GITHUB_TOKEN" ]; then
	if curl "https://api.github.com/rate_limit" -L -s -H "Authorization: token $GITHUB_TOKEN" | grep "Bad credentials" &> "/dev/null"; then
		echo
		echo -e "\e[1;31mError: \$GITHUB_TOKEN is not set correctly\e[0m"
		echo
		exit 1
	fi
fi

# Check if api has reached request limit
API_LIMIT="$(curl "https://api.github.com/rate_limit" -L -s $(if [ -z "$GITHUB_TOKEN" ]; then echo -H "Authorization: token $GITHUB_TOKEN" ;fi) | grep "remaining" | head -1)"
API_LIMIT="${API_LIMIT:19:-1}"

if [ "$API_LIMIT" -lt "3" ]; then
	echo
	echo -e "\e[1;31mError: Less than 3 Github API request left: $API_LIMIT left. $(if [ -z "$GITHUB_TOKEN" ]; then echo "Set \$GITHUB_TOKEN with a token to get more API requests"; fi)\e[0m"
	echo
	exit 1
fi

echo
echo "Downloading required packages..."
echo

# Get latest cli version
CLI_VERSION="$(curl -s "https://api.github.com/repos/revanced/revanced-cli/releases/latest" -L -s $(if [ -z "$GITHUB_TOKEN" ]; then echo -H "Authorization: token $GITHUB_TOKEN" ;fi) | grep "tag_name")"
CLI_VERSION="${CLI_VERSION:16:-2}"

# Download cli and check if it downloaded correctly
if ! curl "https://github.com/revanced/revanced-cli/releases/download/v$CLI_VERSION/revanced-cli-$CLI_VERSION-all.jar" -L -s -o "$DIR/build/revanced-cli.jar"; then exit 1; fi

# Get latest integrations version
INTEGRATIONS_VERSION="$(curl -s "https://api.github.com/repos/revanced/revanced-integrations/releases/latest" -L -s $(if [ -z "$GITHUB_TOKEN" ]; then echo -H "Authorization: token $GITHUB_TOKEN" ;fi) | grep "tag_name")"
INTEGRATIONS_VERSION="${INTEGRATIONS_VERSION:16:-2}"

# Download integrations and check if it downloaded correctly
if ! curl "https://github.com/revanced/revanced-integrations/releases/download/v$INTEGRATIONS_VERSION/app-release-unsigned.apk" -L -s -o "$DIR/build/integrations.apk"; then exit 1; fi

# Get latest patches version
PATCHES_VERSION="$(curl -s "https://api.github.com/repos/revanced/revanced-patches/releases/latest" -L -s $(if [ -z "$GITHUB_TOKEN" ]; then echo -H "Authorization: token $GITHUB_TOKEN" ;fi) | grep "tag_name")"
PATCHES_VERSION="${PATCHES_VERSION:16:-2}"

# Download patches and check if it downloaded correctly
if ! curl "https://github.com/revanced/revanced-patches/releases/download/v$PATCHES_VERSION/revanced-patches-$PATCHES_VERSION.jar" -L -s -o "$DIR/build/revanced-patches.jar"; then exit 1; fi

cd "$DIR/build"

echo "Executing the CLI..."
echo

# Set the correct java executable
if [ -z "$JAVA_HOME" ]; then
	JAVA="java"
else
	JAVA="$JAVA_HOME/bin/java"
fi

# Execute the cli and if an adb device name is given deploy on device
"$JAVA" -jar "revanced-cli.jar" -a "youtube.apk" $(if [ -n "$1" ]; then echo "-d $1"; fi) -m "integrations.apk" -o "revanced.apk" -p "revanced-patches.jar" -t "temp" $(if [ -n "$1" ] && [ "$ROOT" != "1" ]; then echo "--install"; fi)  $(if [ "$ROOT" != "1" ]; then echo "-i codecs-unlock -i exclusive-audio-playback -i background-play -i upgrade-button-remover -i tasteBuilder-remover -i seekbar-tapping -i old-quality-layout -i minimized-playback -i disable-create-button -i shorts-button -i amoled -i microg-patch -i general-ads -i video-ads"; fi)

cp "$DIR/build/revanced.apk" "$DIR/revanced.apk"

exit 0
