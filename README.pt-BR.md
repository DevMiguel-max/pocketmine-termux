# PocketMine-MP no Termux

🇬🇧 [English](README.md) · 🇧🇷 **Português**

Cria e roda um servidor **Minecraft Bedrock** (PocketMine-MP) no Termux com um comando. Usa os binários **oficiais** da PMMP (PHP Android arm64 + `PocketMine-MP.phar`), não o código-fonte.

> Por que não clonar `pmmp/PocketMine-MP`? Rodar do fonte exige PHP com a extensão `pmmpthread`, que o PHP do Termux (`pkg install php`) não tem. O PHP oficial da PMMP já vem com tudo.

## Uso rápido

```bash
# Termux (F-Droid ou GitHub — não use a versão da Play Store)
termux-setup-storage            # aceite; o PHP da PMMP lê DNS de /sdcard/resolv.conf
pkg install -y git
git clone https://github.com/DevMiguel-max/pocketmine-termux.git && cd https://github.com/DevMiguel-max/pocketmine-termux.git
bash install.sh                 # instala deps, baixa PHP + phar (+ playit) e inicia
```

Requisitos: Android **arm64** (aarch64), ~300 MB livres, internet na primeira execução.

## Comandos

| Comando | O que faz |
|---|---|
| `./pmmp start` / `stop` / `restart` / `status` | ciclo de vida (roda em tmux, com wake-lock) |
| `./pmmp console` | console do servidor (sair sem parar: `Ctrl+B`, depois `D`) |
| `./pmmp cmd op Steve` | envia comando ao servidor sem abrir o console |
| `./pmmp logs` | acompanha `server/server.log` |
| `./pmmp run` | primeiro plano, sem tmux — use pra ver erros de inicialização |
| `./pmmp backup` | compacta mundos/config em `backups/` (mantém os 5 últimos) |
| `./pmmp update [--php]` | atualiza o phar (e o PHP), com backup antes |
| `./pmmp doctor` | diagnóstico (arch, PHP, pmmpthread, DNS, playit) |
| `./pmmp boot` | inicia junto com o celular (requer app Termux:Boot) |

Se o arquivo perder o bit de execução ao colar no repo: `bash pmmp ...` funciona igual, ou `git update-index --chmod=+x pmmp install.sh`.

Configuração: `config.env` (versões, porta, jogadores, view-distance...). Os valores do servidor só valem na **criação** do `server/server.properties`; depois edite esse arquivo.

## Jogar

- **Mesma rede Wi-Fi:** Minecraft Bedrock → Servidores → Adicionar → IP do celular (`./pmmp status` mostra), porta `19132`.
- **Pela internet (playit, opcional):**
  1. `./pmmp playit-setup` — mostra um link; abra, entre na conta playit e aprove.
  2. No painel playit.gg, crie um túnel **Minecraft Bedrock** apontando para `127.0.0.1:19132`. *(Esse passo é manual; não há como automatizar pela CLI.)*
  3. `./pmmp restart` — o endereço público aparece em `./pmmp playit-status`.

## Android: o que costuma derrubar o servidor

- **Phantom process killer (Android 12+):** o sistema mata processos de fundo do Termux (aparece como `Killed`/signal 9). Desative via ADB (uma vez):
  `adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent; /system/bin/device_config put activity_manager max_phantom_processes 2147483647"`
  (Android 14+: também `adb shell settings put global settings_enable_monitor_phantom_procs false`)
- Desative a otimização de bateria do Termux.
- `view-distance` alto + muitos jogadores esgotam RAM/CPU de celular. Comece com 6 e 8 jogadores.

## Segurança

`playit/secret` é a chave da sua conta de túnel. Já está no `.gitignore` junto com `server/` e `backups/` — não remova.

## O que foi testado (e o que não)

Testado em ambiente aarch64 emulado: download dos binários, extração, `pmmpthread`/`leveldb` carregados, o phar sobe com `--no-wizard` até `Done` escutando em `0.0.0.0:19132`, geração de arquivos, start/stop/restart/cmd/backup, proteção contra crash-loop, fluxo de claim do playit (`claim generate`/`url` com o binário real).

**Não testado em celular real:** DNS do playit via `proot -b $PREFIX/etc:/etc` (se não conectar, tente `PLAYIT_WRAPPER="none"` no `config.env` ou me mande o `./pmmp playit-logs`); formato exato da saída de `playit-cli claim exchange` (o script valida e aborta com mensagem se vier algo estranho); o console interativo dentro do tmux.
