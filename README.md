# fix-signal-oneplus13

Fix signal for OnePlus 13 CN (PJZ110) on OxygenOS 16.

[Download](https://github.com/YoungReckless4/fix-signal-oneplus13/releases)

> [!WARNING]
> **PSA: Anti-Rollback Protection**
>
> OnePlus has implemented anti-rollback protection starting with firmware version **16.0.3.50x**.
>
> If you are on **16.0.3.50x or higher**, **DO NOT downgrade** to any earlier version:
> * This will cause a **HARD BRICK**.
> * **Leaked EDL tools will not work.** Anti-rollback is specifically designed to block them.
> * Only official/authorized EDL access can fix this state.
>
> Please be careful when flashing any ROMs.
>
> ~~Never Settle.~~ **Sometimes Settle.**

## Install

Install the zip in Magisk (or another root manager) and reboot.

That is all there is to it — there is no button to press and nothing to do around OTA updates.

## What it fixes

On a OnePlus 13 CN running OxygenOS, the `oplusstanvbk` partition — the modem's NV backup — does not match the firmware. That shows up as weak or missing signal, SMS failing on SIM2, and 5G SA not connecting.

The module ships the stock `oplusstanvbk.img` taken from the matching ColorOS build for PJZ110. On every boot it attaches that image to a loop device and repoints the partition's symlink at it, so the modem reads the correct NV data. It also clears `ro.vendor.oplus.radio.sar_regionmark`, which otherwise limits transmit power.

**The module never writes to any partition.** It only redirects a symlink in `/dev`, which the system recreates on each boot. Uninstalling it and rebooting restores the original state.

Because the shipped image is tied to a firmware version, keep the module on the release that matches your OxygenOS build. Version numbers follow the firmware, so module `16.0.10.501` carries the image from PJZ110 firmware `16.0.10.501`.

## Troubleshooting

If signal does not improve, check the log the module writes on each boot:

```
/data/adb/modules/fix-signal-oneplus13/post-fs-data.log
```

The previous boot is kept alongside it as `post-fs-data.log.1`. A healthy log ends with a symlink pointing at a `_mod` loop device and contains no `ERROR:` lines.

## Relocking the bootloader

**Please don't.**

Your device will **brick** if you relock the bootloader with any modification present in **any** slot (root, a custom kernel, a modified partition, and so on).

> [!CAUTION]
> **This module is for rooted users. You **MUST** keep your bootloader unlocked. Do NOT lock the bootloader.** <br>
>
> To relock the bootloader, you **MUST** remove root and restore the device to stock state.<br>
> **Relocking the bootloader is a dangerous operation.** Do not relock your bootloader unless you fully understand what you are doing.<br>
> On OnePlus 13, you cannot access fastboot again via key combination if the bootloader is locked.<br>
> If you lock your bootloader while rooted or modified, your phone will hard brick and cannot be recovered by yourself.
>
> If **any** of the following are not met, relocking the bootloader **will brick your device**:
>
> * **Every system partition in BOTH slots must be 100% stock and unmodified.**
>   * To ensure this, after restoring the latest version of stock OS on your device, download the full OTA ROM (.zip) for that OS version and local install it TWICE: local install, then reboot, then local install it AGAIN.
>   * Be very careful when rolling back to an older OS version. If your device has upgraded to an OS version with anti-rollback, downgrading to any earlier version will brick it. **Please read [the warning](#fix-signal-oneplus13) above.**
> * **Google account must be removed.**
>   * On older ColorOS / OxygenOS versions, due to a critical bug, FRP (Factory Reset Protection, a.k.a. activation lock) prevents completing the initial setup, effectively bricking it.

## Building

```sh
./build.sh
```

Produces `dist/fix-signal-oneplus13-<version>.zip`. CI runs the same script, so a locally built zip is identical to a published one.

----

## Thanks to

- [Fly / @K58](https://github.com/K58) — original module, which this repository is a fork of

- [@koaaN](https://xdaforums.com/m/koaan.3433581/)

- [@docnok63](https://xdaforums.com/m/docnok63.4967345/)

- [rapperskull](https://github.com/rapperskull) — the `oplusstanvbk` loop-device technique

## License

GPL-3.0, inherited from upstream. `nvbk/` contains proprietary firmware files and is **not** covered by that grant — see [nvbk/README.txt](nvbk/README.txt).
