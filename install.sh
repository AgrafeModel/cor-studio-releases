#!/bin/bash
# Installe (ou met à jour) CØR Studio sur Mac depuis la dernière release publique.
# À copier dans le dépôt de releases (install.sh). Téléchargé par curl, le zip n'a pas de quarantaine :
# macOS n'affiche donc pas « app endommagée » (l'app n'est pas signée par Apple).
set -euo pipefail

REPO="AgrafeModel/cor-studio-releases"
APP="CØR Studio.app"
DEST="/Applications"
[ -w "$DEST" ] || DEST="$HOME/Applications"
mkdir -p "$DEST"

[ "$(uname -m)" = "arm64" ] || { echo "Cette version est faite pour les Mac Apple Silicon (M1 et plus)."; exit 1; }

echo "→ Recherche de la dernière version…"
URL="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep -o '"browser_download_url": *"[^"]*mac\.zip"' | head -1 | cut -d'"' -f4)"
[ -n "$URL" ] || { echo "Aucune version Mac trouvée sur https://github.com/$REPO/releases"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "→ Téléchargement…"
curl -fL --progress-bar "$URL" -o "$TMP/app.zip"
ditto -x -k "$TMP/app.zip" "$TMP"

osascript -e 'tell application "CØR Studio" to quit' >/dev/null 2>&1 || true
sleep 1
rm -rf "$DEST/$APP"
ditto "$TMP/$APP" "$DEST/$APP"
xattr -cr "$DEST/$APP" # par sécurité, au cas où une quarantaine serait présente

echo "✓ Installée : $DEST/$APP"
open "$DEST/$APP"
