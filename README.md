# PocketMine-MP on Termux

🇬🇧 **English** · 🇧🇷 [Português](README.pt-BR.md)

Creates and runs a **Minecraft Bedrock** server (PocketMine-MP) on Termux with a single command. It uses the **official** PMMP binaries (Android arm64 PHP + `PocketMine-MP.phar`), not the source code.

> Why not clone `pmmp/PocketMine-MP`? Running from source requires a PHP build with the `pmmpthread` extension, which Termux's own PHP (`pkg install php`) does not have. The official PMMP PHP ships with everything needed.

## Quick start

```bash
# Termux (F-Droid or GitHub build — not the Play Store version)
termux-setup-storage            # accept; PMMP's PHP reads DNS config from /sdcard/resolv.conf
pkg install -y git
git clone https://github.com/DevMiguel-max/pocketmine-termux.git && cd pocketmine-termux
bash install.sh                 # installs deps, downloads PHP + phar (+ playit) and starts
```

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
| `./pmmp doctor` | diagnostics (arch, PHP, pmmpthread, DNS, playit) |
| `./pmmp boot` | start with the phone (requires the Termux:Boot app) |

If the files lose their executable bit when copied into your repo, `bash pmmp ...` works the same, or run `git update-index --chmod=+x pmmp install.sh`.

Settings live in `config.env` (versions, port, players, view distance...). Server values only apply when `server/server.properties` is **created**; after that, edit that file directly.

## Playing

- **Same Wi-Fi:** Minecraft Bedrock → Servers → Add Server → your phone's IP (`./pmmp status` shows it), port `19132`.
- **Over the internet (playit, optional):**
  1. `./pmmp playit-setup` — prints a link; open it, sign in to playit and approve the agent.
  2. In the playit.gg dashboard, create a **Minecraft Bedrock** tunnel pointing to `127.0.0.1:19132`. *(This step is manual; the CLI has no way to automate it.)*
  3. `./pmmp restart` — the public address shows up in `./pmmp playit-status`.

## Android: what usually kills the server

- **Phantom process killer (Android 12+):** the system kills Termux's background processes (shows up as `Killed` / signal 9). Disable it once via ADB:
  `adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent; /system/bin/device_config put activity_manager max_phantom_processes 2147483647"`
  (Android 14+: also `adb shell settings put global settings_enable_monitor_phantom_procs false`)
- Turn off battery optimization for Termux.
- High `view-distance` plus many players will exhaust a phone's RAM/CPU. Start with 6 and 8 players.

## Security

`playit/secret` is the key to your tunnel account. It is already in `.gitignore` together with `server/` and `backups/` — do not remove it.

## What was tested (and what wasn't)

Tested in an emulated aarch64 environment: binary downloads, extraction, `pmmpthread`/`leveldb` loaded, the phar boots with `--no-wizard` up to `Done` listening on `0.0.0.0:19132`, file generation, start/stop/restart/cmd/backup, crash-loop protection, and the playit claim flow (`claim generate`/`url` with the real binary).

**Not tested on a real phone:** playit DNS through `proot -b $PREFIX/etc:/etc` (if it fails to connect, set `PLAYIT_WRAPPER="none"` in `config.env` or inspect `./pmmp playit-logs`); the exact output format of `playit-cli claim exchange` (the script validates it and aborts with a message if it looks wrong); the interactive console inside tmux.
