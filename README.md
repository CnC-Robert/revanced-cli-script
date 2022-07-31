If you came here from the ReVanced telegram channel, please know it's fake. Any official links are on their [discord server](https://revanced.app/discord)

# revanced-cli-script

Bash script that builds & installs revanced automaticlly. Java &amp; Android sdk included. The script also works on windows if you use WSL.

# Requirements

 - Compatible YouTube APK, the same version needs to be installed on your phone
 - If you are building from source: Username & token set in ~/.gradle/gradle.properties or $GITHUB_TOKEN set with the token
 - Git, curl & adb installed
 - ZuluJDK 17
 - Android SDK
 - Java & Android SDK will be downloaded automatically if not installed already

# Usage

Variables you can use:

 - `$ROOT` If set to 1 the script will build the root variant.
 - `$EXCLUDED_PATCHES` Set all the patches you want to exclude seperated by a space. So `amoled disable-shorts-button` for example.
	\
	For YouTube or YouTube Music you need to exlude the `microg-support` or `music-microg-patch` when building the root variant.
 - `$INCLUDED_PATCHES` Same as `$EXCLUDED_PATCHES` but include the patches instead of exclude.
 - `$LIST` If set to 1 list all the patches and don't start patching.

Place a compatible apk in a folder named build like this: `./build/stock.apk` and run the script.
\
Optionally you can include an ADB device to automatically install the patched APK.

```bash
./build-from-source.sh "[adb device id]"
```

or

```bash
./build-from-prebuilt.sh "[adb device id]"
```
