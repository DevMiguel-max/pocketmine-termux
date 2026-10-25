# PocketMine-MP on Termux

🇬🇧 **English** · 🇧🇷 [Português](README.pt-BR.md)

Creates and runs a **Minecraft Bedrock** server (PocketMine-MP) on Termux with a single command. It uses the **official** PMMP binaries (Android arm64 PHP + `PocketMine-MP.phar`), not the source code.

> Why not clone `pmmp/PocketMine-MP`? Running from source requires a PHP build with the `pmmpthread` extension, which Termux's own PHP (`pkg install php`) does not have. The official PMMP PHP ships with everything needed.

## Quick start

Use the F-Droid or GitHub build of Termux (not the Play Store one). Run the commands **one at a time**:

```bash
termux-setup-storage
pkg install -y git
git clone https://github.com/DevMiguel-max/pocketmine-termux.git
cd pocketmine-termux
bash install.sh
```

`termux-setup-storage` must be accepted (answer `y` and allow the permission): PMMP's PHP reads its DNS config from `/sdcard/resolv.conf`. `install.sh` does a full `pkg upgrade`, installs deps, downloads PHP + phar (+ playit) and starts the server.

Requirements: Android **arm64** (aarch64), ~300 MB free, internet on first run.

## Commands

| Command | What it does |
|---|---|
| `./pmmp start` / `stop` / `restart` / `status` | lifecycle (runs inside tmux, with wake-lock) |
| `./pmmp console` | server console (detach without stopping: `Ctrl+B`, then `D`) |
| `./pmmp cmd op Steve` | send a command to the server without opening the console |
| `./pmmp logs` | follow `server/server.log` |
| `./pmmp run` | foreground, no tmux — use it to see startup errors |
| `./pmmp backup` | archive worlds/config into `backups/` (keeps the latest 5) |
| `./pmmp update [--php]` | update the phar (and PHP), with a backup first |
| `./pmmp status` | running state, local IP, server Minecraft version |
| `./pmmp doctor` | diagnostics (arch, PHP, pmmpthread, DNS, playit account status) |
| `./pmmp boot` | start with the phone (requires the Termux:Boot app) |

If the files lose their executable bit when copied into your repo, `bash pmmp ...` works the same, or run `git update-index --chmod=+x pmmp install.sh`.

Settings live in `config.env` (versions, port, players, view distance...). Server values only apply when `server/server.properties` is **created**; after that, edit that file directly.

## Playing

- **Same Wi-Fi:** Minecraft Bedrock → Servers → Add Server → your phone's IP (`./pmmp status` shows it), port `19132`.
- **Over the internet (playit, optional):**
  1. `./pmmp playit-setup` — prints a link; open it, sign in to playit and approve the agent.
  2. **Verify your playit account e-mail.** Until you do, the agent logs `account_status="email_not_verified"` and the tunnel does not work (`./pmmp doctor` flags this).
  3. In the playit.gg dashboard, create a **Minecraft Bedrock** tunnel with origin `127.0.0.1` port `19132`. *(Manual; the CLI cannot do it.)*
  4. `./pmmp restart`. The **public address is on the tunnel's Overview tab on the website** — it is not printed in the terminal.

  The dashboard may warn "Minecraft Bedrock requires RakNet" and suggest `transport=raknet`. **Ignore it**: that is for Mojang's official server. PocketMine-MP only speaks RakNet, and the property does not exist in it.

## Android: what usually kills the server

- **Phantom process killer (Android 12+):** the system kills Termux's background processes (shows up as `Killed` / signal 9). Disable it once via ADB:
  `adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent; /system/bin/device_config put activity_manager max_phantom_processes 2147483647"`
  (Android 14+: also `adb shell settings put global settings_enable_monitor_phantom_procs false`)
- Turn off battery optimization for Termux.
- High `view-distance` plus many players will exhaust a phone's RAM/CPU. Start with 6 and 8 players.

## Players can't connect

Test in this order; each step rules something out.

1. `./pmmp status` — server and playit running? Note the **server version** it prints: Bedrock clients generally must match it, so compare with your game's version first.
2. Join from **another device on the same Wi-Fi** using the local IP and port `19132` (Wi-Fi "client isolation" and guest networks block this; don't use the server phone's own hotspot).
3. While trying, run `./pmmp logs`: a login/"Outdated" line means the packet arrived (version problem); nothing at all means it never reached the server (network/IP).
4. Only after the local test works, test the playit address. Watch the tunnel's *Active Connections*/bandwidth on the website while you try.
5. `./pmmp doctor` — checks the PHP DNS (`/sdcard/resolv.conf`) and the playit account status.

In the playit log, a single `Network unreachable` on an IPv6 address and a couple of `SessionNotSetup` lines right after connecting are normal. A `SessionNotSetup` loop that never stops is not.

## Security

`playit/secret` is the key to your tunnel account. It is already in `.gitignore` together with `server/` and `backups/` — do not remove it.

## What was tested (and what wasn't)

Emulated aarch64: binary downloads, extraction, `pmmpthread`/`leveldb` loaded, the phar boots with `--no-wizard` up to `Done` on `0.0.0.0:19132`, start/stop/restart/cmd/backup, crash-loop protection, playit claim flow.

On a real phone (confirmed by the author): installation (after a full `apt` upgrade), server start, playit daemon running through `proot` and connecting with the tunnel loaded.

**Not confirmed yet:** a player actually joining, locally or through playit. `playit-attach` and `playit-login` were added without being run.
