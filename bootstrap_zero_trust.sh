#!/bin/sh
set -euo pipefail

# 0) Paths
ROOT="$(pwd)"
echo "Bootstrapping Zero Trust in: $ROOT"

# 1) Git config: safe directories, signed commits, main default
git config --global safe.directory "$ROOT"
git config --global init.defaultBranch main
git config --local commit.gpgSign true || true
git config --local user.signingkey auto || true   # replace with your key if using GPG
git config --local core.autocrlf input
git config --local pull.rebase true

# 2) .gitignore (deny secrets, build outputs, keys by default)
mkdir -p package/templates package/scripts site .github/workflows keys chain/metadata
cat > .gitignore <<'GIT'
# Build outputs
package/output/
site/.cache/
*.aux
*.log
*.out
*.toc

# Node & Python
node_modules/
venv/
.env
.env.*
*.pyc

# Keys & secrets
keys/
*.key
*.pem
*.p12
*.json
*.kdbx
*.secret
secrets/
.rsa
id_ed25519
id_rsa
GIT

# 3) .gitattributes (text normalization & PDF treated as binary)
cat > .gitattributes <<'ATTR'
* text=auto eol=lf
*.pdf binary
*.png binary
*.jpg binary
*.jpeg binary
*.svg text
*.tex text
*.md text
*.sh text
ATTR

# 4) Secret denylist & patterns (used by hooks and CI)
cat > .secret-denylist <<'DENY'
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AZURE_SUBSCRIPTION_KEY
GOOGLE_APPLICATION_CREDENTIALS
PRIVATE_KEY
MNEMONIC
SEED
PASSWORD
TOKEN=
API_KEY=
CLOUDFLARE_API_TOKEN
GITHUB_TOKEN
SOLANA_PRIVATE_KEY
phantom seed
BEGIN PRIVATE KEY
END PRIVATE KEY
DENY

cat > .secret-patterns.regex <<'REG'
# High‑risk patterns
(?i)aws[_-]?secret[_-]?access[_-]?key
(?i)aws[_-]?access[_-]?key[_-]?id
(?i)api[_-]?key
(?i)authorization:\s*bearer\s+[A-Za-z0-9._-]+
(?i)password\s*[:=]\s*.+?
(?i)token\s*[:=]\s*[A-Za-z0-9._-]{20,}
(?i)(?:BEGIN|END)\s+(?:RSA|OPENSSH|EC)\s+PRIVATE\s+KEY
[1-9A-HJ-NP-Za-km-z]{32,} # generic base58-ish
REG

# 5) Ignition constants (edit timestamp as required)
cat > ignition.env <<'ENV'
IGNITION_ISO=2025-12-04T00:00:00-06:00
ENTITY=ArcherCryptoSolutionsInc
ENV

# 6) Offset calculator script (single source of truth)
cat > package/scripts/stamp_offset.sh <<'STAMP'
#!/bin/sh
set -e
IGNITION="2025-12-04 00:00:00"
now=$(date +%s)
start=$(date -d "$IGNITION" +%s)
o=$((now-start))
D=$(printf "%03d" $((o/86400)))
H=$(printf "%02d" $(( (o%86400)/3600 )))
M=$(printf "%02d" $(( (o%3600)/60 )))
S=$(printf "%02d" $(( o%60 )))
printf "%s:%s:%s:%s" "$D" "$H" "$M" "$S"
STAMP
chmod +x package/scripts/stamp_offset.sh

# 7) Pandoc LaTeX template (polished, with ignition footer)
cat > package/templates/pandoc-template.tex <<'TEX'
\documentclass[11pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[margin=1in]{geometry}
\usepackage{lmodern}
\usepackage[T1]{fontenc}
\usepackage{microtype}
\usepackage{fancyhdr}
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\fancyhf{}
\fancyfoot[C]{ACSI\textregistered{} + $offset$ \textbullet{} ArcherCryptoSolutionsInc}

\setlength{\parskip}{0.6em}
\setlength{\parindent}{0pt}

\begin{document}
$body$
\end{document}
TEX

# 8) Minimal site with live ignition stamp & strict CSP
cat > site/index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Mahihkan • ACSI</title>
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; upgrade-insecure-requests">
<meta http-equiv="Referrer-Policy" content="no-referrer">
<meta http-equiv="X-Content-Type-Options" content="nosniff">
<meta http-equiv="X-Frame-Options" content="DENY">
<style>body{font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial;margin:2rem}#stamp{opacity:.7;font-size:.9em}</style>
</head>
<body>
<h1>Archer Crypto Solutions Incorporated</h1>
<div id="stamp">[ACSI® + 000:00:00:00 • Mahihkan.com]</div>
<script>
const ignition=new Date("2025-12-04T06:00:00Z"); // CST offset
function stamp(){
  const now=new Date();const d=Math.floor((now-ignition)/1000);
  const D=Math.floor(d/86400),H=Math.floor((d%86400)/3600),M=Math.floor((d%3600)/60),S=d%60;
  document.getElementById("stamp").textContent=`[ACSI® + ${String(D).padStart(3,'0')}:${String(H).padStart(2,'0')}:${String(M).padStart(2,'0')}:${String(S).padStart(2,'0')} • Mahihkan.com]`;
}
stamp();setInterval(stamp,1000);
</script>
</body>
</html>
HTML

# 9) Git hooks
mkdir -p .git/hooks

# 9a) prepare-commit-msg: append ignition stamp and block empty messages
cat > .git/hooks/prepare-commit-msg <<'PCM'
#!/bin/sh
set -e
msgfile="$1"

# Block auto-merge boilerplate from polluting history
[ -f "$msgfile" ] || exit 0

IGNITION="2025-12-04 00:00:00"
now=$(date +%s)
start=$(date -d "$IGNITION" +%s)
offset=$((now - start))
days=$((offset / 86400))
hours=$(( (offset % 86400) / 3600 ))
mins=$(( (offset % 3600) / 60 ))
secs=$((offset % 60))
printf "\n[ACSI® + %03d:%02d:%02d:%02d • GitHub]\n" "$days" "$hours" "$mins" "$secs" >> "$msgfile"
PCM
chmod +x .git/hooks/prepare-commit-msg

# 9b) pre-commit: block secrets, large binaries, missing signoff
cat > .git/hooks/pre-commit <<'PRE'
#!/bin/sh
set -e

# Require Signed-off-by (Developer Certificate of Origin)
if ! git log -1 --pretty=%B | grep -qi 'Signed-off-by:'; then
  echo "ERROR: Commit must include 'Signed-off-by: Name <email>' (DCO)."
  echo "Add with: git commit --amend -s"
  exit 1
fi

# Secret denylist & regex scan
denylist=".secret-denylist"
patterns=".secret-patterns.regex"
files=$(git diff --cached --name-only | tr '\n' ' ')
[ -z "$files" ] && exit 0

fail=0
if [ -f "$denylist" ]; then
  for d in $(cat "$denylist"); do
    if grep -I -n -E "$d" $files >/dev/null 2>&1; then
      echo "ERROR: Found denylisted token '$d' in staged files."
      fail=1
    fi
  done
fi

if [ -f "$patterns" ]; then
  if grep -I -n -E -f "$patterns" $files >/dev/null 2>&1; then
    echo "ERROR: Found high‑risk secret patterns in staged files."
    fail=1
  fi
fi

# Block huge files (>5MB) unless in package/output or assets
for f in $files; do
  [ -f "$f" ] || continue
  size=$(wc -c <"$f")
  case "$f" in
    package/output/*|assets/*) continue ;;
  esac
  if [ "$size" -gt 5242880 ]; then
    echo "ERROR: File $f exceeds 5MB. Place large outputs in package/output or assets."
    fail=1
  fi
done

[ "$fail" -eq 0 ] || exit 1
exit 0
PRE
chmod +x .git/hooks/pre-commit

# 9c) commit-msg: enforce conventional messages & maximum length
cat > .git/hooks/commit-msg <<'CM'
#!/bin/sh
set -e
msgfile="$1"
msg="$(cat "$msgfile")"

# Enforce concise subject line
first="$(printf "%s" "$msg" | head -n1)"
len=${#first}
if [ "$len" -gt 72 ]; then
  echo "ERROR: Commit subject exceeds 72 chars."
  exit 1
fi

# Enforce Conventional Commits prefix
case "$first" in
  feat:*|fix:*|docs:*|style:*|refactor:*|perf:*|test:*|chore:*|ci:* )
    ;;
  *)
    echo "ERROR: Commit subject must start with a Conventional Commit type (e.g., 'feat:', 'fix:', 'docs:')."
    exit 1
    ;;
esac
exit 0
CM
chmod +x .git/hooks/commit-msg

# 10) Makefile for reproducible builds (PDF + site)
cat > Makefile <<'MK'
SHELL := /bin/sh
OFFSET := $(shell package/scripts/stamp_offset.sh)
MD_SRC := $(wildcard docs/*.md)
PDF_OUT := $(patsubst docs/%.md,package/output/%.pdf,$(MD_SRC))

all: pdf site

pdf: $(PDF_OUT)

package/output/%.pdf: docs/%.md package/templates/pandoc-template.tex
	@mkdir -p package/output
	pandoc $< --pdf-engine=pdflatex --template=package/templates/pandoc-template.tex -V offset="$(OFFSET)" -o $@

site:
	@mkdir -p site
	@touch site/index.html

clean:
	rm -rf package/output

.PHONY: all pdf site clean
MK

# 11) GitHub Actions: CI checks + artifact build
cat > .github/workflows/ci.yml <<'YML'
name: Zero Trust CI
on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Secret scan (denylist)
        run: |
          if [ -f .secret-denylist ]; then
            grep -I -R -n -E -f .secret-patterns.regex . || true
          fi
      - name: Build PDFs
        run: |
          sudo apt-get update
          sudo apt-get install -y pandoc texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
          mkdir -p package/output
          OFFSET=$(./package/scripts/stamp_offset.sh)
          for md in docs/*.md; do
            [ -f "$md" ] || continue
            out="package/output/$(basename "${md%.md}").pdf"
            pandoc "$md" --pdf-engine=pdflatex --template=package/templates/pandoc-template.tex -V offset="$OFFSET" -o "$out"
          done
      - name: Upload PDFs
        uses: actions/upload-artifact@v4
        with:
          name: pdfs
          path: package/output
YML

# 12) Cloudflare Pages headers (hardened security)
cat > site/_headers <<'HDR'
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: no-referrer
  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; upgrade-insecure-requests
HDR

# 13) .editorconfig (consistent whitespace)
cat > .editorconfig <<'EC'
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true
EC

echo "Zero Trust bootstrap complete."
echo "Next: add 'Signed-off-by: Your Name <you@example.com>' to commits (git commit -s)."
