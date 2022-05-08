# revanced-cli-script
Script that builds revanced automaticlly. Java &amp; Android sdk included

# Requirements
You need to have git installed and have a username & token set in ~/.gradle/gradle.properties.
Java & Android SDK will be downloaded automaticlly to the script directory.

# Mounting the apk
Copy the revanced.apk to your phone (Not to /sdcard or /storage/emulated/0) and set the $base_path below to the location of the apk.
Copy the lines below to mount the apk (in adb root or termux root)

base_path="/data/revanced.apk"
stock_path=${ pm path com.google.android.youtube | grep base | sed 's/package://g' }

chmod 644 $base_path
chown system:system $base_path
chcon u:object_r:apk_data_file:s0  $base_path

mount -o bind $base_path $stock_path
