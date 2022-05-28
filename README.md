# revanced-cli-script
Script that builds revanced automaticlly. Java &amp; Android sdk included

# Usage
Place the youtube apk in a folder named build like this: `script-dir/build/youtube.apk` and execute the script `./build-from-source.sh (adb device name (optional))`

# Requirements
You need to have git installed and have a username & token set in ~/.gradle/gradle.properties.
Java & Android SDK will be downloaded automaticlly to the script directory.

# Mounting the apk

This is no longer needed to do manually since the cli will already do it for you when you deploy with adb.

~~Copy the revanced.apk to your phone (Not to /sdcard or /storage/emulated/0, Something like /data/revanced/revanced.apk) and set the $base_path below to the location of the apk.
Copy the lines below to mount the apk (in adb root or termux root)~~

~~export base_path="/data/revanced/revanced.apk"~~

~~export stock_path=${ pm path com.google.android.youtube | grep base | sed 's/package://g' }~~

~~chmod 644 $base_path~~

~~chown system:system $base_path~~

~~chcon u:object_r:apk_data_file:s0  $base_path~~

~~mount -o bind $base_path $stock_path~~
