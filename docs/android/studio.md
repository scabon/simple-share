# Android Studio

## Pair devices over WiFi

The option to `Pair devices over WiFi` from Android Studio just fails without much information.
After some googling, here is what I did to make it work:

- Add the `adb.exe` installation directory to your `path` environment variable.
  - The default installation location on Windows is `C:\Users\derze\AppData\Local\Android\Sdk\platform-tools`
  - Add this folder to the path, without the `adb.exe` file name`
- Make sure that the WiFi network you are connected to is set as a `Private network` (*not* a `Public network`)

Then, on your phone, select the `Pair device with pairing code` option.
> Note that there are two distinct `abd` commands, one with *pair*, and one with *connect*.
> They both require different ports (provided by the Android device) and arguments (with or without code)

First, pair your computer with the Android device:
`adb pair [IP_ADDRESS]:[PORT] [PAIRING_CODE]`
For example
`adb pair 192.168.1.35:34893 923787`

Then you can connect to your device if needed:
`adb connect [IP_ADDRESS]:[PORT]`
For example
`adb connect 192.168.1.35:34255`

Your Android device should now be available in Android Studio.
