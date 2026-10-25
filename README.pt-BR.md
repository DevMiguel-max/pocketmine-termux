# PocketMine-MP no Termux

🇬🇧 [English](README.md) · 🇧🇷 **Português**

Cria e roda um servidor **Minecraft Bedrock** (PocketMine-MP) no Termux com um comando. Usa o PHP compilado pela PMMP (Android arm64) e um `PocketMine-MP.phar` pronto (de um fork da comunidade por padrão, veja abaixo), não o código-fonte.

> Por que não clonar `pmmp/PocketMine-MP`? Rodar do fonte exige PHP com a extensão `pmmpthread`, que o PHP do Termux (`pkg install php`) não tem. O PHP oficial da PMMP já vem com tudo.

## Sobre o fork (leia)

A equipe da PMMP **encerrou o suporte em 2026-07-09** (anúncio no README do `pmmp/PocketMine-MP`). A última versão oficial, a 5.44.3, só suporta o Minecraft **v26.30**, e não haverá novas atualizações. Por isso um jogo atual não consegue entrar no servidor oficial.

O `config.env` aponta `PM_REPO` por padrão para o fork da comunidade **`BetterLite/PocketMine-MP`**, cuja versão 5.50.0 anuncia a **v26.50** (as notas citam também a 26.52; o phar embutido reporta v26.50). Para voltar ao oficial: `PM_REPO="pmmp/PocketMine-MP"` (só funciona com o Minecraft 26.30).

É um **software não oficial, de mantenedores que não conheço**, e o histórico do git foi achatado, então não dá para rastrear as mudanças commit a commit. O que eu verifiquei (análise estática, **não** é uma auditoria completa):
- Contra o upstream 5.44.3: nenhum padrão novo de `exec`/`eval`/`base64`/chamada de rede no código alterado de `src/`. Os únicos domínios novos são as URLs de atualização/Discord/tradução do próprio fork no lugar das da PMMP.
- O código do phar publicado bate com o código da tag, exceto por um erro de digitação corrigido.
- As bibliotecas `betterlite/*` (protocolo, schemas de blocos/itens) têm os mesmos padrões suspeitos que as equivalentes do upstream, e as extensões PHP exigidas são idênticas.
- As bibliotecas de terceiros que ele atualizou (brick/math, jsonmapper, ramsey/uuid, symfony/filesystem) são idênticas, byte a byte, às versões originais no GitHub. O phar não tem executáveis nem código empacotado/ofuscado, e a heurística de ofuscação dá os mesmos resultados do upstream.

Não verifiquei: a leitura linha a linha dos ~130 arquivos alterados. O binário do PHP e as extensões continuam vindo dos builds da PMMP. O `./pmmp setup` e o `./pmmp update` **desligam** o atualizador interno no `pocketmine.yml` (ele consultaria o `update.betterlite.org`); atualize com `./pmmp update`.

Existe outro fork em andamento (`phpMine-MP`) que não tinha nenhuma versão publicada quando olhei.

## Uso rápido

Use o Termux do F-Droid ou do GitHub (não o da Play Store). Rode os comandos **um de cada vez**:

```bash
termux-setup-storage
pkg install -y git
git clone https://github.com/DevMiguel-max/pocketmine-termux.git
cd pocketmine-termux
bash install.sh
```

O `termux-setup-storage` precisa ser aceito (responda `y` e permita o acesso): o PHP da PMMP lê o DNS de `/sdcard/resolv.conf`. O `install.sh` faz um `pkg upgrade` completo, instala as dependências, baixa PHP + phar (+ playit) e inicia o servidor.

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
| `./pmmp status` | estado, IP local e versão do Minecraft do servidor |
| `./pmmp doctor` | diagnóstico (arch, PHP, pmmpthread, DNS, status da conta playit) |
| `./pmmp boot` | inicia junto com o celular (requer app Termux:Boot) |

Se o arquivo perder o bit de execução ao colar no repo: `bash pmmp ...` funciona igual, ou `git update-index --chmod=+x pmmp install.sh`.

Configuração: `config.env` (versões, porta, jogadores, view-distance...). Os valores do servidor só valem na **criação** do `server/server.properties`; depois edite esse arquivo.

## Jogar

- **Mesma rede Wi-Fi:** Minecraft Bedrock → Servidores → Adicionar → IP do celular (`./pmmp status` mostra), porta `19132`.
- **Pela internet (playit, opcional):**
  1. `./pmmp playit-setup` — mostra um link; abra, entre na conta playit e aprove o agente.
  2. **Confirme o e-mail da conta playit.** Enquanto não confirmar, o agente loga `account_status="email_not_verified"` e o túnel não funciona (o `./pmmp doctor` avisa).
  3. No painel playit.gg, crie um túnel **Minecraft Bedrock** com origem `127.0.0.1` porta `19132`. *(Manual; a CLI não faz isso.)*
  4. `./pmmp restart`. O **endereço público fica na aba Overview do túnel, no site** — ele não aparece no terminal.

  O painel pode avisar "Minecraft Bedrock requires RakNet" e sugerir `transport=raknet`. **Ignore**: isso vale para o servidor oficial da Mojang. O PocketMine-MP só fala RakNet, e essa propriedade não existe nele.

## Android: o que costuma derrubar o servidor

- **Phantom process killer (Android 12+):** o sistema mata processos de fundo do Termux (aparece como `Killed`/signal 9). Desative via ADB (uma vez):
  `adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent; /system/bin/device_config put activity_manager max_phantom_processes 2147483647"`
  (Android 14+: também `adb shell settings put global settings_enable_monitor_phantom_procs false`)
- Desative a otimização de bateria do Termux.
- `view-distance` alto + muitos jogadores esgotam RAM/CPU de celular. Comece com 6 e 8 jogadores.

## Jogadores não conectam

Teste nesta ordem; cada passo elimina uma causa.

1. `./pmmp status` — servidor e playit rodando? Veja a **versão do servidor** que ele mostra: o Bedrock geralmente exige a mesma versão, então compare com a do seu jogo primeiro.
2. Entre por **outro aparelho no mesmo Wi-Fi**, com o IP local e a porta `19132` (isolamento de clientes e rede de visitantes bloqueiam isso; não use o hotspot do próprio celular-servidor).
3. Durante a tentativa, rode `./pmmp logs`: uma linha de login ou "Outdated" significa que o pacote chegou (problema de versão); nada aparecer significa que não chegou ao servidor (rede/IP).
4. Só depois que o teste local funcionar, teste o endereço do playit. Acompanhe *Active Connections*/banda do túnel no site enquanto tenta.
5. `./pmmp doctor` — confere o DNS do PHP (`/sdcard/resolv.conf`) e o status da conta playit.

No log do playit, um único `Network unreachable` num endereço IPv6 e algumas linhas `SessionNotSetup` logo após conectar são normais. Um loop de `SessionNotSetup` que não para, não.

## Segurança

`playit/secret` é a chave da sua conta de túnel. Já está no `.gitignore` junto com `server/` e `backups/` — não remova.

## O que foi testado (e o que não)

Em aarch64 emulado (inclusive o phar 5.50.0 do fork, que sobe até `Done` anunciando a v26.50): download dos binários, extração, `pmmpthread`/`leveldb` carregados, o phar sobe com `--no-wizard` até `Done` em `0.0.0.0:19132`, start/stop/restart/cmd/backup, proteção contra crash-loop, fluxo de claim do playit.

Em celular real (confirmado pelo autor): instalação (depois de um upgrade completo do `apt`), servidor iniciando, daemon do playit rodando via `proot`, conectando e com o túnel carregado.

**Ainda não confirmado:** um jogador de fato entrando, localmente ou pelo playit. O `playit-attach` e o `playit-login` foram adicionados sem terem sido executados.
