#!/usr/bin/env bash
set -euo pipefail
HTML="$(find . -maxdepth 2 -type f -iname '*Estrutura*Comercial*Simplificada*.html' | head -n 1 || true)"
if [ -z "$HTML" ]; then echo "ERRO: HTML-base não encontrado."; exit 1; fi
mkdir -p assets/web legacy
cp "$HTML" assets/web/personal_ia.html
cp "$HTML" legacy/personal_ia_original.html
python3 tools/ajustar_html.py assets/web/personal_ia.html
echo "[OK] HTML funcional importado: $HTML"
