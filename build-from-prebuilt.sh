#!/bin/bash

DIR="$(pwd)"

# Check if $TOKEN is set
if [ -z "$TOKEN" ]; then
	echo -e "\e[1;31mError, \$TOKEN not set\e[0m"
	exit 1
fi

# Check if curl is installed before continuing
if ! command -v "curl" &> "/dev/null"; then
	echo -e "\e[1;31mError, curl not found\e[0m"
	exit 1
fi

# Check if a youtube.apk is provided before continuing
if [ ! -e "$DIR/build/youtube.apk" ]; then
	echo -e "\e[1;31mError, ./build/youtube.apk not found\e[0m"
	exit 1
fi

# Check if adb device is connected before continuing
if [ ! -z "$1" ]; then
	if ! adb devices | grep "$1" &> "/dev/null"; then
		echo -e "\e[1;31mError, device $1 not connected\e[0m"
		exit 1
	fi
else
	echo
	echo -e "\e[1;33mWarning, no adb device specified. It is recommended to do so to automatically install the apk\e[0m"
fi

# Check if java is installed and if not, download and extract openjdk 17
if ! command -v "java" &> "/dev/null" && [ -z "$JAVA_HOME" ]; then
	export JAVA_HOME="$(readlink -f "$DIR/openjdk")"
	if [ ! -e "$JAVA_HOME/bin/java" ]; then
		if [ ! -e "openjdk.tar.gz" ]; then
			echo
			echo "Downloading openjdk..."
			wget -q "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz" -O "openjdk.tar.gz"
		fi
		echo "Extracting openjdk..."
		tar xzf "openjdk.tar.gz"
		mv jdk-* "openjdk"
	fi
fi

echo

curl https://maven.pkg.github.com/revanced/revanced-cli/app/revanced/revanced-cli/1.1.6-dev.1/revanced-cli-1.1.6-dev.1-all.jar -s -H "Authorization: Bearer $TOKEN" -L -o "$DIR/build/revanced-cli.jar"
if [ ! $? == 0 ]; then exit 1; fi

curl https://github.com/revanced/revanced-integrations/releases/download/v0.1.0/app-release-unsigned.apk -s -L -o "$DIR/build/integrations.apk"
if [ ! $? == 0 ]; then exit 1; fi

curl https://maven.pkg.github.com/revanced/revanced-patches/app/revanced/revanced-patches/1.0.0-dev.13/revanced-patches-1.0.0-dev.13.jar -s -H "Authorization: Bearer $TOKEN" -L -o "$DIR/build/revanced-patches.jar"
if [ ! $? == 0 ]; then exit 1; fi

curl https://maven.pkg.github.com/revanced/revanced-patches/app/revanced/revanced-patcher/1.0.0-dev.17/revanced-patcher-1.0.0-dev.17.jar -s -H "Authorization: Bearer $TOKEN" -L -o "$DIR/build/revanced-patcher.jar"
if [ ! $? == 0 ]; then exit 1; fi

cd "$DIR/build"

# Set the correct java executable
if [ -z "$JAVA_HOME" ]; then
	JAVA="java"
else
	JAVA="$JAVA_HOME/bin/java"
fi

# Execute the cli and if an adb device name is given deploy on device
"$JAVA" -jar "revanced-cli.jar" -a "youtube.apk" $(if [ ! -z "$1" ]; then echo "-d $1"; fi) -m "integrations.apk" -o "revanced.apk" -p "revanced-patches.jar" -r -t "temp"

cp "$DIR/build/revanced.apk" "$DIR/revanced.apk"

exit 0

