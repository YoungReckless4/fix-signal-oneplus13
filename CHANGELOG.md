# Changelog

<!-- new entries are inserted directly below this line -->

## 16.0.10.501

Fork of [K58/fix-signal-oneplus13](https://github.com/K58/fix-signal-oneplus13), focused solely on fixing signal on OxygenOS 16.

- `nvbk/oplusstanvbk.img` synced from `PJZ110_16.0.10.501-CN01_CN-image-firmware.7z`
  - source: `stmtc233/oneplus_archive` release `PJZ110_16.0.10.501(CN01)_CN` (published 2026-08-17)
  - image SHA256: `2cb7cca37abdd3c199f4c01d36e0c8119ce5cbc15a6652b6296b64ff82d11cfa`
  - archive SHA256: `07a493d1df183e3aceb1e2e82e4f201180bdc5e24819a54fe3d97566605804eb`
- Install and forget: there is no button to press and nothing to do around OTA updates. **The module no longer writes to any partition** — it only redirects a symlink in `/dev` that the system recreates each boot.
- Version numbers now follow the firmware the bundled image comes from, so it is obvious which OxygenOS build a release matches.
- Fixed `post-fs-data.sh` naming its partition variable `PATH`, which clobbered the shell's command search path for the rest of the script.
- `post-fs-data.sh` falls back to `getprop` when `resetprop` is unavailable, so the module also works under root managers that omit it.
- The previous boot's log is kept as `post-fs-data.log.1`, which is usually the one worth reading when signal breaks.
- Fixed `updateJson` pointing at a URL that returns 404, which left in-app update checks broken.
- Added `.gitattributes` forcing LF. A Windows checkout previously converted every module script to CRLF, which Android's `sh` cannot execute.
- Release zips now include `LICENSE`, as GPL-3.0 requires for a distributed binary artifact.
- Added `build.sh` plus ShellCheck, firmware-sync and release workflows, so a locally built zip is identical to a published one.

### Unchanged from upstream

- `system.prop` still clears `ro.vendor.oplus.radio.sar_regionmark`.
- `/system/bin/losetup` is still called by absolute path: `-sf` is toybox syntax that a busybox `losetup` in `PATH` would reject.
- `nvbk/` remains outside the GPL-3.0 grant, as upstream's `nvbk/README.txt` states.
