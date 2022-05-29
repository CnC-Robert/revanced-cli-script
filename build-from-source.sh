#!/bin/bash

DIR="$(pwd)"

# Check if wget & git are installed before continuing
if ! command -v "wget" &> "/dev/null"; then
	echo -e "\e[1;31mError, wget not found\e[0m"
	exit 1
fi

if ! command -v "git" &> "/dev/null"; then
	echo -e "\e[1;31mError, git not found\e[0m"
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
if [ ! -e "$(which java)" ] && [ -z "$JAVA_HOME" ]; then
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

# Check if android sdk is installed and if not, download and extract android sdk
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
	export ANDROID_HOME="$(readlink -f "$DIR/android-sdk")"
	if [ ! -e "$ANDROID_HOME" ]; then
		if [ ! -e "android-sdk.tar.gz" ]; then
			echo
			echo "Downloading Android SDK"
			wget -q "https://github.com/CnC-Robert/revanced-cli-script/releases/download/androidsdk/android-sdk.tar.gz"
		fi
		echo "Extracting android-sdk.tar.gz"
		tar xzf "android-sdk.tar.gz"
	fi
fi

echo

# Clone the patcher and publish it
git clone https://github.com/revanced/revanced-patcher
cd revanced-patcher
git checkout dev
chmod +x ./gradlew

# If $LOCALMAVEN is set to 1 use publishToMavenLocal instead of publish
./gradlew $(if [ "$LOCALMAVEN" == "1" ]; then echo "publishToMavenLocal"; else echo "publish"; fi)

# If the program did not build & publish correctly exit the script
if [ ! $? == 0 ]; then exit 1; fi

cd ..

echo

# Clone the patches and publish it
git clone https://github.com/revanced/revanced-patches
cd revanced-patches
git checkout dev
chmod +x ./gradlew

./gradlew $(if [ "$LOCALMAVEN" == "1" ]; then echo "publishToMavenLocal"; else echo "publish"; fi)

if [ ! $? == 0 ]; then exit 1; fi

cd ..

echo

# Clone the cli and build it
git clone https://github.com/revanced/revanced-cli
cd revanced-cli
git checkout dev
chmod +x ./gradlew

./gradlew build

if [ ! $? == 0 ]; then exit 1; fi

cd ..

echo

# Clone the integrations and build it
git clone https://github.com/revanced/revanced-integrations
cd revanced-integrations
chmod +x ./gradlew

./gradlew build

if [ ! $? == 0 ]; then exit 1; fi

cd ..

# Copy the cli, integrations, patches and patcher to the build directory
cp revanced-cli/build/libs/revanced-cli-*-all.jar build/revanced-cli.jar
cp revanced-integrations/app/build/outputs/apk/release/*.apk build/integrations.apk

# Since the cli does not need the -sources.jar & -javadoc.jar the script will copy the all files from the directory and stop after the first, this is bit crappy but it works
for file in $DIR/revanced-patches/build/libs/*.jar; do cp "$file" "$DIR/build/revanced-patches.jar"; break; done 
for file in $DIR/revanced-patcher/build/libs/*.jar; do cp "$file" "$DIR/build/revanced-patcher.jar"; break; done

cd build

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
