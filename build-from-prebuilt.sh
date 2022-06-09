#!/bin/bash

DIR="$(pwd)"

# Check if $GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
	echo -e "\e[1;31mError: \$GITHUB_TOKEN not set\e[0m"
	exit 1
fi

# Check if curl is installed before continuing
if ! command -v "curl" &> "/dev/null"; then
	echo -e "\e[1;31mError: curl not found\e[0m"
	exit 1
fi

# Check if a youtube.apk is provided before continuing
if [ ! -e "$DIR/build/youtube.apk" ]; then
	echo -e "\e[1;31mError: ./build/youtube.apk not found\e[0m"
	exit 1
fi

# Check if adb device is connected before continuing
if [ ! -z "$1" ]; then

	# Check if adb is installed before continuing
	if ! command -v "adb" &> "/dev/null"; then
		echo -e "\e[1;31mError: adb not found\e[0m"
		exit 1
	fi

	# Check if the adb device is connected
	if ! adb devices | grep "$1" &> "/dev/null"; then
		echo -e "\e[1;31mError: device $1 not connected\e[0m"
		exit 1
	fi

	# Check if adb has shell & root access
	if ! adb shell su -c exit; then
		echo -e "\e[1;31mError: device $1 either has no shell access or root access\e[0m"
		exit 1
	fi

else
	echo
	echo -e "\e[1;33mWarning: no adb device specified. It is recommended to do so to automatically install the apk\e[0m"
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
fi

echo

# Get latest cli version
CLI_VERSION="$(curl -s https://api.github.com/repos/revanced/revanced-cli/releases/latest | grep "tag_name")"
CLI_VERSION="${CLI_VERSION:16:-2}"

# Download cli and check if it downloaded correctly
curl "https://maven.pkg.github.com/revanced/revanced-cli/app/revanced/revanced-cli/$CLI_VERSION/revanced-cli-$CLI_VERSION-all.jar" -s -H "Authorization: Bearer $GITHUB_TOKEN" -L -o "$DIR/build/revanced-cli.jar"
if [ ! $? == 0 ]; then exit 1; fi

# Get latest integrations version
INTEGRATIONS_VERSION="$(curl -s https://api.github.com/repos/revanced/revanced-integrations/releases/latest | grep "tag_name")"
INTEGRATIONS_VERSION="${INTEGRATIONS_VERSION:15:-2}"

# Download integrations and check if it downloaded correctly
curl "https://github.com/revanced/revanced-integrations/releases/download/$INTEGRATIONS_VERSION/app-release-unsigned.apk" -s -L -o "$DIR/build/integrations.apk"
if [ ! $? == 0 ]; then exit 1; fi

# Get latest patches version
PATCHES_VERSION="$(curl -s https://api.github.com/repos/revanced/revanced-patches/releases/latest | grep "tag_name")"
PATCHES_VERSION="${PATCHES_VERSION:16:-2}"

# Download patches and check if it downloaded correctly
curl "https://maven.pkg.github.com/revanced/revanced-patches/app/revanced/revanced-patches/$PATCHES_VERSION/revanced-patches-$PATCHES_VERSION.jar" -s -H "Authorization: Bearer $GITHUB_TOKEN" -L -o "$DIR/build/revanced-patches.jar"
if [ ! $? == 0 ]; then exit 1; fi

# Get latest patcher version
PATCHER_VERSION="$(curl -s https://api.github.com/repos/revanced/revanced-patcher/releases/latest | grep "tag_name")"
PATCHER_VERSION="${PATCHER_VERSION:16:-2}"

# Download patcher and check if it downloaded correctly
curl "https://maven.pkg.github.com/revanced/revanced-patcher/app/revanced/revanced-patcher/$PATCHER_VERSION/revanced-patcher-$PATCHER_VERSION.jar" -s -H "Authorization: Bearer $GITHUB_TOKEN" -L -o "$DIR/build/revanced-patcher.jar"
if [ ! $? == 0 ]; then exit 1; fi

cd "$DIR/build"

# Set the correct java executable
if [ -z "$JAVA_HOME" ]; then
	JAVA="java"
else
	JAVA="$JAVA_HOME/bin/java"
fi

# Execute the cli and if an adb device name is given deploy on device
"$JAVA" -jar "revanced-cli.jar" -a "youtube.apk" $(if [ ! -z "$1" ]; then echo "-d $1"; fi) -m "integrations.apk" -o "revanced.apk" -p "revanced-patches.jar" -t "temp"

cp "$DIR/build/revanced.apk" "$DIR/revanced.apk"

exit 0
