#!/usr/bin/env bash
# install.sh — instala dependências do Termux, baixa PHP + PocketMine-MP e (opcional) inicia.
# Uso: bash install.sh [--no-start]
set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

START=1
for a in "$@"; do
  case "$a" in
    --no-start) START=0 ;;
    *) echo "Opção desconhecida: $a (use --no-start)"; exit 1 ;;
  esac
done

case "$(uname -m)" in
  aarch64|arm64) ;;
  *) echo "[erro] CPU $(uname -m) não suportada. A PMMP só publica PHP para Android arm64."; exit 1 ;;
esac

if command -v pkg >/dev/null 2>&1; then
  echo "[install] Atualizando pacotes do Termux..."
  export DEBIAN_FRONTEND=noninteractive
  pkg update -y || echo "[aviso] pkg update falhou; tentando seguir"
  echo "[install] Instalando dependências..."
  pkg install -y curl tar tmux proot ca-certificates
else
  echo "[aviso] 'pkg' não encontrado (fora do Termux?). Garanta manualmente: curl tar tmux proot."
fi

if [ ! -d /sdcard ] || [ ! -w /sdcard ]; then
  echo "[aviso] Sem acesso ao armazenamento. Rode 'termux-setup-storage', aceite, e depois ./pmmp setup"
  echo "        (o PHP da PMMP precisa de /sdcard/resolv.conf pra resolver DNS)."
fi

chmod +x "$ROOT/pmmp" "$ROOT/install.sh"
"$ROOT/pmmp" setup

if [ "$START" -eq 1 ]; then
  "$ROOT/pmmp" start
  echo
  echo "Pronto. Comandos: ./pmmp help   |   console: ./pmmp console"
else
  echo
  echo "Pronto. Inicie com: ./pmmp start"
fi
