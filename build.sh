#!/usr/bin/env bash
# Regenerate every guide artifact from book/ (the self-contained Quarto source).
#
# Workflow from here on (public repo only):
#   1. edit book/*.qmd
#   2. ./build.sh
#   3. git add -A && git commit && git push
#
# Produces: the whole-book PDF at the repo root, and for each chapter a
# per-chapter README.md (GFM, links remapped to sibling folders, with a banner)
# and a standalone PDF, in its NN-name/ folder.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOK="$ROOT/book"
command -v quarto >/dev/null || { echo "quarto not found"; exit 1; }

# chapter/appendix source (without .qmd)  :  destination folder
MAP="chapter-1-foundation:01-foundation
chapter-2-audiobookshelf:02-audiobookshelf
chapter-3-pihole:03-pihole
chapter-4-pretty-urls:04-pretty-urls
chapter-5-dashboard:05-dashboard
chapter-6-remoting-phone:06-remoting-phone
chapter-7-vpn:07-vpn
chapter-8-away-from-home:08-away-from-home
chapter-9-phone-linux:09-phone-linux
appendix-a-compose-explained:appendix-a-compose
appendix-b-verify:appendix-b-verify"

# folders that ship helper scripts (these get the "scripts" banner)
HAS_SCRIPTS="01-foundation 02-audiobookshelf 03-pihole 04-pretty-urls 05-dashboard 07-vpn 09-phone-linux"

echo "==> Rendering the whole book (PDF) from book/"
( cd "$BOOK" && quarto render --to pdf >/dev/null )
cp "$BOOK/_book/Beginner-Homelab-on-a-Raspberry-Pi.pdf" "$ROOT/"

echo "==> Rendering each chapter standalone (README + PDF)"
TMP="$(mktemp -d)"
cp "$BOOK"/*.qmd "$TMP/"
cat > "$TMP/_quarto.yml" <<'YAML'
project:
  type: default
format:
  pdf:
    documentclass: scrartcl
    papersize: letter
    geometry: [margin=1in]
    toc: true
    toc-depth: 3
    colorlinks: true
    fontsize: 11pt
    highlight-style: github
    code-block-bg: true
    code-block-border-left: "#268bd2"
    include-in-header:
      text: |
        \usepackage{fvextra}
        \DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,breakanywhere,breaksymbolleft={},breaksymbolright={},commandchars=\\\{\}}
        \fvset{breaklines,breakanywhere,breaksymbolleft={},breaksymbolright={}}
  gfm: default
YAML

# Build the link-remap sed program: (chapter-N.qmd) -> (../NN-folder/README.md)
SEDPROG=""
while IFS=: read -r qmd dir; do [ -z "$qmd" ] && continue
  SEDPROG="${SEDPROG}s#](${qmd}\.qmd)#](../${dir}/README.md)#g;"
done <<EOF
$MAP
EOF

read -r -d '' BANNER <<'EOF' || true
> [!NOTE]
> Part of my personal homelab guide. The scripts in this folder are small, generic
> helpers (update, install, make folders, start containers); the use-case-specific
> steps live in the text below, not in a script. They reflect my own setup, so read
> them before running and adapt as needed. See the [main README](../README.md).

EOF
read -r -d '' BANNER_NONE <<'EOF' || true
> [!NOTE]
> Part of my personal homelab guide, written around my own use case. This chapter
> is mostly reading / app setup (no scripts here). See the [main README](../README.md)
> for the full picture.

EOF

while IFS=: read -r qmd dir; do [ -z "$qmd" ] && continue
  ( cd "$TMP" && quarto render "$qmd.qmd" --to gfm >/dev/null 2>&1 && quarto render "$qmd.qmd" --to pdf >/dev/null 2>&1 )
  mkdir -p "$ROOT/$dir"
  cp "$TMP/$qmd.pdf" "$ROOT/$dir/$dir.pdf"
  body="$(sed -e "$SEDPROG" "$TMP/$qmd.md")"
  case "$dir" in
    appendix-*) printf '%s' "$body" > "$ROOT/$dir/README.md" ;;
    *) case " $HAS_SCRIPTS " in
         *" $dir "*) printf '%s\n%s' "$BANNER" "$body" > "$ROOT/$dir/README.md" ;;
         *)          printf '%s\n%s' "$BANNER_NONE" "$body" > "$ROOT/$dir/README.md" ;;
       esac ;;
  esac
  echo "    $dir"
done <<EOF
$MAP
EOF
rm -rf "$TMP"

echo "==> Done. Review with 'git status' / 'git diff', then commit + push."
