AOSPA device tree for Xiaomi `dash`
=============================================

EN | [简体中文](README_zh.md)

The Redmi Turbo 5 Max is ~~a performance flagship powered by a nerfed previous-generation MediaTek flagship chip~~ a proper MediaTek-powered performance flagship with a current-generation chip running at full speed.

## Features

- [x] Cellular / VoLTE
- [x] Wi-Fi
- [x] Bluetooth
- [x] NFC
- [x] Cameras
- [x] GPS
- [x] USB OTG
- [x] Dual rear camera ring lights
- [x] Fingerprint
- [x] Face unlock
- [x] Automatic brightness
- [x] Dolby Atmos
- [x] Dolby Vision
- [x] App scheduling
- [x] Always-on display
- [x] SELinux enforcing
- [x] Charging
  - Fast charging
  - Reverse charging
  - Charge limit
  - Bypass charging (see the description in Settings)
- [x] Sleep and wake
  - Lift to wake / put down to sleep
  - Double-tap to wake
  - Screen attention
- [x] Encryption / decryption

## Build dependencies

- [Kernel](https://github.com/Content-Creation-Club/android_kernel_device_modules_xiaomi_dash) — PA expects the synced `kernel/platform/kernel-6.6` workspace at `kernel/xiaomi/dash`.
- [Hardware](https://github.com/YorokobiMaster/android_hardware_xiaomi_dash/)
- eSIM profile management requires [OpenEUICC](https://gitea.angry.im/PeterCxy/OpenEUICC/src/commit/cad687c50eb2c74adae8bfbc67265efc43f467a7) and [its prebuilts](https://gitea.angry.im/PeterCxy/android_prebuilts_openeuicc-deps/src/commit/540216793010cabc49782bd01844cd8dd28a4c7c). Until a manifest is provided, sync them manually to `packages/apps/OpenEUICC` (including submodules) and `prebuilts/openeuicc-deps`, respectively.

## Credits

- [AOSPA-2e](https://github.com/AOSPA-2e)
- [AOSPA](https://github.com/AOSPA)

## License

[Apache-2.0](LICENSE)

## Device picture

![Redmi Turbo 5 Max](redmi_turbo_5_max.png "Redmi Turbo 5 Max")
