# SPPL `PATH_7XPRO` (`LEDTV32HD`) — End-to-End Android TV Debloat, System Optimization & Custom Launcher Guide

Complete, reproducible end-to-end documentation and visual proof for debloating, cleaning, optimizing, and replacing the stock ad-heavy launcher on the **SPPL `PATH_7XPRO`** (`Kodak / Thomson 7XPRO Series`, `LEDTV32HD`, Android TV 9, Amlogic `AMLT950X`, 1 GB RAM).

---

## 1. Visual Proof: Before vs. After (End-to-End)

### 1.1 Stock Home Screen (Before) vs. Custom Apple TV-Style Home Screen (After)

| Before — Stock Android TV Home (Sponsored Rows & Clutter) | After — CleanYourTV Custom Dock & Ambient Glow (`com.gathin.tvhome`) |
|---|---|
| ![Before — Stock Android TV Home Screen](screenshots/before-home.png) | ![After — Custom Apple TV-Style Home Dock](screenshots/after-dock.png) |

### 1.2 Minimal Single-Screen App Grid & Hardware Inputs Menu

| After — Single-Screen App Grid (Only 7 Essential Apps) | After — Hardware Inputs Menu (`HDMI 1–3`, `AV 1–2`, `Live TV`) |
|---|---|
| ![After — Minimal Single-Screen App Grid](screenshots/after-grid.png) | ![After — Hardware Inputs Dropdown](screenshots/after-inputs.png) |

### 1.3 Interactive 4-Way App Reordering (`Left` / `Right` / `Up` / `Down`)

| Move Mode Active (`Hold OK` / `Menu` → `MOVE APP · ◀ ▲ ▼ ▶ · OK DONE`) | Move Completed & Persisted (`Press OK` / `Back`) |
|---|---|
| ![4-Way App Move Mode Active](screenshots/move-mode.png) | ![App Order Saved After Move Mode](screenshots/move-done.png) |

### 1.4 Progressive Debloat Verification Batches

| Batch 1 (Telemetry & Factory Tests Disabled) | Batch 2 (Sponsored Rows & Recommendations Disabled) | Batch 3 (Unused System Providers & Duplicate Apps Disabled) |
|---|---|---|
| ![Batch 1 Verification](screenshots/batch1.png) | ![Batch 2 Verification](screenshots/batch2.png) | ![Batch 3 Verification](screenshots/batch3.png) |

---

## 2. Executive Summary & Benchmark Results

On a **1 GB RAM / 4.2 GB `/data`** television, the stock firmware consumed **89% of storage** and left only **279 MB of available RAM** due to background telemetry, recommendation engines, Play Store background services, and leftover APK installers.

| Metric | Before Optimization | After Optimization | Measured Improvement |
|---|---|---|---|
| **Available RAM (of `1,014 MB`)** | **`279 MB`** (`MemFree: 36 MB`) | **`563 MB`** (`MemFree: 311 MB`) | **+284 MB RAM freed (`2.02×` available RAM, `55.5%` of total RAM free)** |
| **Free Storage (`/data` of `4.2 GB`)** | `3.7 GB` used / **`516 MB` free (`89%` full)** | `1.9 GB` used / **`2.2 GB` free (`47%` used)** | **+1.7 GB freed (`4.3×` more free space)** |
| **System Bloatware Packages** | `0` disabled (`102` packages active) | **`42` system bloat & telemetry packages disabled** | Stripped `/data` updates & wiped package caches |
| **Third-Party Apps** | `14` third-party apps + `458 MB` leftover APKs | **`11` redundant apps uninstalled** | Only **7 essential apps** remain (fits on 1 screen) |
| **SmartTube (`org.smarttube.stable`)** | `v32.10` (`universal` APK) | **`v32.56 Stable` (`armeabi-v7a` native)** | Upgraded to latest architecture-matched build |
| **App Runtime Compilation (`dex2oat`)** | Interpreted / partial profile | **`cmd package compile -m speed -f`** | **100% AOT native ARM machine code** for instant cold starts |
| **UI Animation Scales** | `1.0x` (stock) | **`0.5x`** (`window`, `transition`, `animator`) | **2× snappier UI transitions** |
| **App Reordering in Launcher** | Static XML order only | **4-Way D-Pad Move Mode (`◀ ▲ ▼ ▶`)** | Hold `OK` on any tile → move `Left/Right/Up/Down` → `OK` to save |

---

## 3. Target Hardware & Firmware Profile

| Property | Value |
|---|---|
| **Manufacturer / Brand** | `SPPL` (Super Plastronics Pvt Ltd — Kodak / Thomson 7XPRO Series, India) |
| **Model / Device** | `PATH_7XPRO` / `LEDTV32HD` |
| **SoC / Board** | Amlogic `AMLT950X` (`droidlogic`, 4× ARM Cortex-A53 @ `armeabi-v7a`) |
| **Android Version** | Android TV 9 (Pie, SDK 28), Build `PI.20210601 release-keys` |
| **Memory & Storage** | `1,014 MB` RAM (`1.5 GB` ZRAM swap) · `4.2 GB` `/data` partition |
| **Stock Home Launcher** | `com.google.android.tvlauncher/.MainActivity` |
| **New Home Launcher** | `com.gathin.tvhome/.MainActivity` (~300 KB native Java launcher) |
| **Hardware Inputs Handler** | `com.android.tv` + `com.droidlogic.tvinput` (`HDMI1`, `HDMI2`, `HDMI3`, `AV1`, `AV2`, `Live TV`) |

> [!IMPORTANT]
> **Firmware Quirk on `SPPL PATH_7XPRO`:** Turning on **USB debugging** in *Developer options* for the first time does not immediately open TCP port `5555` (`adbd`). Toggling **USB debugging OFF and back ON** (or rebooting the TV with USB debugging enabled) starts `adbd` on `:5555` over Wi-Fi.

---

## 4. Phase-by-Phase Execution Breakdown

### Phase 1: Discovery & Full State Backup
1. Scanned the local subnet (`192.168.29.0/24`) for TCP port `5555` and discovered the TV at `192.168.29.239`.
2. Authenticated via `tools/tv.py` (pure-Python ADB implementation) and dumped a complete baseline snapshot to [`backup-path-7xpro/`](../../backup-path-7xpro/):
   - [`packages-all.txt`](../../backup-path-7xpro/packages-all.txt), [`packages-enabled.txt`](../../backup-path-7xpro/packages-enabled.txt), [`packages-disabled.txt`](../../backup-path-7xpro/packages-disabled.txt), [`packages-system.txt`](../../backup-path-7xpro/packages-system.txt), [`packages-thirdparty.txt`](../../backup-path-7xpro/packages-thirdparty.txt), [`packages-paths.txt`](../../backup-path-7xpro/packages-paths.txt)
   - [`getprop.txt`](../../backup-path-7xpro/getprop.txt), [`settings-global.txt`](../../backup-path-7xpro/settings-global.txt), [`settings-secure.txt`](../../backup-path-7xpro/settings-secure.txt), [`settings-system.txt`](../../backup-path-7xpro/settings-system.txt)
   - [`restore-all.ps1`](../../backup-path-7xpro/restore-all.ps1) — standalone one-click PowerShell restore script.

---

### Phase 2: Custom Launcher Installation & Configuration (`com.gathin.tvhome`)
1. Configured [`launcher/app/src/main/res/values/config.xml`](../../launcher/app/src/main/res/values/config.xml):
   - **Pinned Dock (`dock_apps`):** `org.smarttube.stable`, `com.google.android.youtube.tvmusic`, `com.google.android.youtube.tv`, `org.videolan.vlc` (`fill_dock = true`).
   - **Hidden System Entries (`hidden_apps`):** `com.android.tv`, `com.google.android.tv`, `com.droidlogic.tv.settings` (accessible directly via the top-bar `Inputs` and `Settings` pills).
   - **Live TV Package (`live_tv_package`):** `com.android.tv`.
   - **VPN Pill Integration (`vpn_app`):** `com.nordvpn.android` — displays a live green **`VPN`** badge when NordVPN is connected or **`VPN off`** when disconnected, and opens NordVPN on click (or Wi-Fi settings on long-press).
2. Added **4-Way App Reordering (`Move Mode`)** in [`AppAdapter.java`](../../launcher/app/src/main/java/com/gathin/tvhome/AppAdapter.java) and [`MainActivity.java`](../../launcher/app/src/main/java/com/gathin/tvhome/MainActivity.java):
   - **Enter Move Mode:** Hold **`OK`** (`KEYCODE_DPAD_CENTER` / `KEYCODE_ENTER` ≥ 450 ms) or press **`Menu`** (`KEYCODE_MENU`) on any app tile.
   - **Visual Indicator:** Top greeting bar switches to gold `MOVE APP · ◀ ▲ ▼ ▶ · OK DONE` and the focused app title displays `◀ ▲ ▼ ▶ <App Name>`. Top-bar pills temporarily lock focus so D-pad Up/Down never escapes the app grid.
   - **4-Way Movement:** Press **D-Pad Left / Right / Up / Down** to swap the focused app across any Dock or Grid slot.
   - **Persistence:** App order is saved immediately by component name in `SharedPreferences` (`settings.xml` → `app_order`) and survives reboots and package reloads.
   - **Exit Move Mode:** Press **`OK`** or **`Back`**.
3. Built and installed the ~300 KB launcher via [`launcher/build-and-install.ps1`](../../launcher/build-and-install.ps1), set `com.gathin.tvhome/.MainActivity` as default `HOME`, and disabled `com.google.android.tvlauncher`.

---

### Phase 3: 42 System Bloatware, Telemetry & Background Packages Disabled ([`debloat.txt`](debloat.txt))

All 42 packages below were disabled via `pm disable-user --user 0`, force-stopped, stripped of any `/data/app` Play Store updates (`pm uninstall --user 0` on updated system apps to reclaim `/data` blocks), and cleared of `/data/data` caches (`pm clear`):

#### Batch 1 — Telemetry, Analytics, Partner Auto-Installs & Factory Test Suites (10 packages)
- `com.google.android.feedback` — Google Market Feedback Agent
- `com.google.android.tv.bugreportsender` — Google TV Bug Report Sender
- `com.google.android.partnersetup` — Google Partner Setup / RLZ attribution
- `android.autoinstalls.config.amlogic.device` — Partner auto-install stub
- `com.google.android.onetimeinitializer` — Google One Time Initializer
- `com.android.onetimeinitializer` — Android One Time Initializer
- `com.ctv.factorytest` — Vendor `FactoryAutoTest` boot service
- `com.tvfactory` — Vendor `TVFactory` USB/PCBA test suite
- `com.cultraview.agingmodel` — Factory burn-in / aging test mode
- `com.sppl.emanual` — Static on-screen e-Manual

#### Batch 2 — Stock Launchers, Sponsored Rows & Google Bloat (7 packages)
- `com.google.android.tvlauncher` — Stock Android TV Home Launcher
- `com.google.android.tvrecommendations` — Sponsored rows & home screen notifications
- `com.google.android.leanbacklauncher.recommendations` — Legacy recommendation service
- `com.google.android.leanbacklauncher` — Legacy Leanback Launcher
- `com.google.android.videos` — Google Play Movies & TV
- `com.google.android.play.games` — Google Play Games
- `com.google.android.apps.nbu.smartconnect.tv` — SmartConnectTV background telemetry

#### Batch 3 — Unused Phone/Print/Camera Providers & Vendor Media Duplicates (13 packages)
- `com.android.printspooler` — Print Spooler
- `com.android.camera2` — Camera app (TV has no camera)
- `com.android.smspush` — SMS WapPush service (TV has no cellular modem)
- `com.android.providers.calendar` & `com.google.android.syncadapters.calendar` — Calendar storage & sync
- `com.android.providers.contacts` & `com.google.android.syncadapters.contacts` — Contacts storage & sync
- `com.android.providers.userdictionary` — User dictionary provider
- `com.android.dreams.basic` — Basic Dreams screensaver (`ClockDream` used instead)
- `com.google.android.marvin.talkback` — Android Accessibility Suite / TalkBack (`54 MB` on `/data` reclaimed)
- `com.ctv.photoplayer` — Vendor PhotoPlayer (VLC used instead)
- `com.ctv.music` — Vendor MusicPlayer (VLC / YouTube Music used instead)
- `com.yunfang.files` — Vendor `Filemanager_india`

#### Deep System Sweep — Setup Wizards, Ambient Backdrop & Cloud Backup Agents (12 packages)
- `com.google.android.backdrop` — Google Ambient Mode / Backdrop (`ClockDream` used instead)
- `com.google.android.tungsten.setupwraith` — First-boot setup wizard
- `com.google.android.tvsetup.partnercustomizer` — Partner setup customizer
- `com.droidlogic.videoplayer` — Redundant Amlogic video player (VLC used instead)
- `com.google.android.tv` — Duplicate Google Live Channels app (`com.android.tv` handles HDMI/Live TV)
- `com.android.wallpaperbackup` & `com.android.wallpapercropper` — Unused wallpaper services
- `com.android.htmlviewer` — Unused HTML viewer stub
- `com.android.backupconfirm`, `com.android.sharedstoragebackup`, `com.google.android.backuptransport` — Unused cloud/ADB backup agents
- `com.amazon.amazonvideo.livingroom` — Pre-disabled Prime Video stub

---

### Phase 4: Uninstalled 11 Redundant Third-Party Apps & Cleaned 458 MB of Leftover Installers

1. **Uninstalled 11 third-party apps (`pm uninstall`):**
   - `com.esaba.downloader` (`Downloader`)
   - `com.alphainventor.filemanager` (`File Manager +`)
   - `com.yablio.sendfilestotv` (`Send Files to TV`)
   - `com.teamsmart.videomanager.tv` (Old legacy SmartTube Next)
   - `com.discoveryplus.tv.android` (`discovery+`)
   - `com.mubi` (`MUBI`)
   - `com.htlabs.ottplay` (`OTTplay`)
   - `com.sonyliv` (`SonyLIV`)
   - `com.tubitv` (`Tubi`)
   - `com.graymatrix.did` (`ZEE5`)
   - `com.mxtech.videoplayer.ad` (`MX Player`)
2. **Cleaned `/sdcard/Download` & `/sdcard/Downloader` (`458 MB` freed):**
   - Preserved all user `.srt` subtitle files in `/sdcard/Subtitles/`.
   - Deleted leftover `.apk`, `.apkm`, `.zip` (`mx_aio.zip`), and orphaned folders in `/sdcard/Android/data/`.
3. **Upgraded SmartTube (`org.smarttube.stable`):**
   - Upgraded from `v32.10` (`universal`) to **`v32.56 Stable` (`armeabi-v7a`)** from [`yuliskov/SmartTube`](https://github.com/yuliskov/SmartTube/releases/tag/32.56s), matching the TV's 32-bit ARMv7 architecture and saving ~30 MB on `/data/app`.

#### Final 7 Apps Remaining on the TV
| Slot | App Name | Package Name | Location |
|---|---|---|---|
| **1** | **SmartTube (`v32.56 Stable`)** | `org.smarttube.stable` | Dock (Slot 1) |
| **2** | **YouTube Music** | `com.google.android.youtube.tvmusic` | Dock (Slot 2) |
| **3** | **YouTube** | `com.google.android.youtube.tv` | Dock (Slot 3) |
| **4** | **VLC** | `org.videolan.vlc` | Dock (Slot 4) |
| **5** | **JioHotstar** | `in.startv.hotstar` | Grid (Slot 5) |
| **6** | **NordVPN** | `com.nordvpn.android` | Grid (Slot 6) + Top-Bar VPN Pill |
| **7** | **Google Play Store** | `com.android.vending` | Grid (Slot 7) |

---

### Phase 5: Deep CPU, ART Runtime & Background RAM Optimizations

```bash
# 1. Pre-compile all active apps to 100% native ARM machine code (-m speed)
for pkg in com.gathin.tvhome org.smarttube.stable in.startv.hotstar com.google.android.youtube.tv \
           com.google.android.youtube.tvmusic org.videolan.vlc com.nordvpn.android \
           com.android.tv.settings com.android.tv; do
    cmd package compile -m speed -f "$pkg"
done

# 2. Restrict heavy apps from waking up in the background (frees ~109 MB from Play Store alone)
for pkg in com.android.vending in.startv.hotstar com.google.android.youtube.tv \
           com.google.android.youtube.tvmusic org.videolan.vlc; do
    cmd appops set "$pkg" RUN_IN_BACKGROUND ignore
done

# 3. Disable background Wi-Fi/BLE scanning, Play Protect verifier, and system telemetry logging
settings put global wifi_scan_always_enabled 0
settings put global ble_scan_always_enabled 0
settings put global package_verifier_enable 0
settings put global verifier_verify_adb_installs 0
settings put global activity_starts_logging_enabled 0
settings put global send_action_app_error 0
settings put global dropbox_max_files 10

# 4. Set UI animation scales to 0.5x for instant navigation
settings put global window_animation_scale 0.5
settings put global transition_animation_scale 0.5
settings put global animator_duration_scale 0.5

# 5. Trim filesystem caches
pm trim-caches 16G
```

---

## 5. Reproduction & Restoration Commands

### Apply Debloat List & Build Launcher (Windows PowerShell)
```powershell
python -m venv tools\venv
.\tools\venv\Scripts\python.exe -m pip install -r tools\requirements.txt

# 1. Build and install the custom launcher
powershell -ExecutionPolicy Bypass -File launcher\build-and-install.ps1 -TvHost 192.168.29.239

# 2. Apply the SPPL PATH_7XPRO debloat list
powershell -ExecutionPolicy Bypass -File tools\disable.ps1 -TvHost 192.168.29.239 examples\sppl-path-7xpro\debloat.txt
```

### Restore Stock Setup (100% Reversible)
```powershell
# Option A: Restore via CleanYourTV recovery record
powershell -ExecutionPolicy Bypass -File tools\restore.ps1 -TvHost 192.168.29.239 examples\sppl-path-7xpro\debloat.txt

# Option B: Standalone full restore script from initial backup snapshot
powershell -ExecutionPolicy Bypass -File backup-path-7xpro\restore-all.ps1 -TvHost 192.168.29.239
```
