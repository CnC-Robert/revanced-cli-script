#!/bin/bash

DIR="$(pwd)"

if [ ! -e "$(which java)" ] && [ -z "$JAVA_HOME" ]; then
	export JAVA_HOME="$(readlink -f "$DIR/openjdk")"
	if [ ! -e "$JAVA_HOME/bin/java" ]; then
		if [ ! -e "openjdk.tar.gz" ]; then
			echo "Donwloading openjdk..."
			wget "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz" -O "openjdk.tar.gz"
		fi
		echo "Extracting openjdk..."
		tar xzf "openjdk.tar.gz"
		mv jdk-* "openjdk"
	fi
fi

if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
	export ANDROID_HOME="$(readlink -f "$DIR/android-sdk")"
	if [ ! -e "$ANDROID_HOME" ]; then
		if [ ! -e "android-sdk.tar.gz" ]; then
			echo "Donwloading Android SDK"
			echo
			wget "https://github.com/CnC-Robert/revanced-cli-script/releases/download/java-androidsdk/android-sdk.tar.gz"
		fi
		echo "Extracting android-sdk.tar.gz"
		tar xzf "android-sdk.tar.gz"
	fi
fi

if [ ! -e "$DIR/build/youtube.apk" ]; then
	echo "Error, ./build/youtube.apk not found"
	exit 1
fi

if [ ! -e "$(which wget)" ]; then
	echo "Error, wget not found"
	exit 1
fi

if [ ! -e "$(which git)" ]; then
	echo "Error, git not found"
	exit 1
fi


echo
git clone https://github.com/revanced/revanced-patcher
cd revanced-patcher
git checkout dev
chmod +x ./gradlew

./gradlew publish

if [ ! $? == 0 ]; then
	echo Build failed
	exit 1
fi

cd ..

echo
git clone https://github.com/revanced/revanced-patches
cd revanced-patches
git checkout dev
chmod +x ./gradlew

./gradlew publish

if [ ! $? == 0 ]; then
	echo Build failed
	exit 1
fi

cd ..

echo
git clone https://github.com/revanced/revanced-cli
cd revanced-cli
git checkout dev
chmod +x ./gradlew

./gradlew build

if [ ! $? == 0 ]; then
	echo Build failed
	exit 1
fi

cd ..

echo
git clone https://github.com/revanced/revanced-integrations
cd revanced-integrations
chmod +x ./gradlew

./gradlew build

if [ ! $? == 0 ]; then
	echo Build failed
	exit 1
fi

cd ..

cp revanced-cli/build/libs/revanced-cli-*-all.jar build/revanced-cli.jar
cp revanced-integrations/app/build/outputs/apk/release/*.apk build/integrations.apk
for file in $DIR/revanced-patches/build/libs/*.jar; do cp "$file" "$DIR/build/revanced-patches.jar"; break; done 
for file in $DIR/revanced-patcher/build/libs/*.jar; do cp "$file" "$DIR/build/revanced-patcher.jar"; break; done

cd build

if [ ! -z "$JAVA_HOME" ]; then
	"$JAVA_HOME/bin/java" -jar "revanced-cli.jar" -a "youtube.apk" -m "integrations.apk" -o "revanced.apk" -p "revanced-patches.jar" -r -t "temp"
else
	java -jar "revanced-cli.jar" -a "youtube.apk" -m "integrations.apk" -o "revanced.apk" -p "revanced-patches.jar" -r -t "temp"
fi

cp "$DIR/build/revanced.apk" "$DIR/revanced.apk"

exit 0
