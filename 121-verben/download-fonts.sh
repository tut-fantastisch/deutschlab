#!/bin/bash
# ============================================================
# Verb-Café — Fonts selbst hosten (statt Google-Fonts-CDN)
# ------------------------------------------------------------
# Einmal lokal auf deinem Rechner ausführen (braucht Internet + curl).
# Lädt via google-webfonts-helper (gwfh.mranftl.com) die richtigen
# Schnitte in latin + cyrillic (wichtig für die ukrainischen Texte!)
# und benennt sie so, wie index.html sie erwartet.
#
# Ergebnis: ein Ordner "fonts/" mit allen .woff2-Dateien.
# Diesen Ordner danach neben index.html ins GitHub-Repo legen:
#
#   101-verben/
#   ├── index.html
#   ├── manifest.json
#   ├── service-worker.js
#   ├── icon-192.png
#   ├── icon-512.png
#   └── fonts/
#       ├── BarlowCondensed-Medium.woff2
#       ├── ... usw.
# ============================================================
set -e
mkdir -p fonts
cd fonts

API="https://gwfh.mranftl.com/api/fonts"
SUBSETS="latin,cyrillic"

# Holt die woff2-URL für eine bestimmte Family + Variante aus der gwfh-API
# und speichert sie direkt unter dem gewünschten Zielnamen.
fetch_variant () {
  local family="$1"      # z.B. "barlow-condensed"
  local variant="$2"     # z.B. "500" oder "600italic"
  local outfile="$3"     # z.B. "BarlowCondensed-Medium.woff2"

  echo "→ $outfile"
  local url
  url=$(curl -s "${API}/${family}?subsets=${SUBSETS}" \
    | python3 -c "
import json,sys
data = json.load(sys.stdin)
for v in data.get('variants', []):
    if v.get('id') == '${variant}':
        print(v.get('woff2') or v.get('woff') or '')
        break
")
  if [ -z "$url" ]; then
    echo "  ⚠️  Variante ${variant} für ${family} nicht gefunden — bitte manuell prüfen."
    return
  fi
  curl -sL "$url" -o "$outfile"
}

# --- Barlow Condensed ---
fetch_variant "barlow-condensed" "500"     "BarlowCondensed-Medium.woff2"
fetch_variant "barlow-condensed" "600"     "BarlowCondensed-SemiBold.woff2"
fetch_variant "barlow-condensed" "700"     "BarlowCondensed-Bold.woff2"
fetch_variant "barlow-condensed" "800"     "BarlowCondensed-ExtraBold.woff2"

# --- Nunito Sans ---
fetch_variant "nunito-sans" "regular"      "NunitoSans-Regular.woff2"
fetch_variant "nunito-sans" "italic"       "NunitoSans-Italic.woff2"
fetch_variant "nunito-sans" "500"          "NunitoSans-Medium.woff2"
fetch_variant "nunito-sans" "600"          "NunitoSans-SemiBold.woff2"
fetch_variant "nunito-sans" "700"          "NunitoSans-Bold.woff2"

# --- Caveat ---
fetch_variant "caveat" "600"               "Caveat-SemiBold.woff2"
fetch_variant "caveat" "700"               "Caveat-Bold.woff2"

# --- JetBrains Mono ---
fetch_variant "jetbrains-mono" "regular"   "JetBrainsMono-Regular.woff2"
fetch_variant "jetbrains-mono" "600"       "JetBrainsMono-SemiBold.woff2"
fetch_variant "jetbrains-mono" "700"       "JetBrainsMono-Bold.woff2"

# --- Kalam ---
fetch_variant "kalam" "regular"            "Kalam-Regular.woff2"
fetch_variant "kalam" "700"                "Kalam-Bold.woff2"

cd ..
echo ""
echo "Fertig. Prüfe den fonts/-Ordner — jede Datei sollte > 0 Bytes sein."
echo "Falls eine Datei fehlt/leer ist: Family-Slug oder Variant-ID bei"
echo "https://gwfh.mranftl.com manuell nachschauen und einzeln nachladen."
