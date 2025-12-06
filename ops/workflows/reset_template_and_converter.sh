#!/usr/bin/env bash
# reset_template_and_converter.sh
PKG_DIR="${HOME}/Mahihkan/package"
mkdir -p "$PKG_DIR"

cat > "${PKG_DIR}/pandoc-template.tex" <<'EOF'
\documentclass[11pt]{article}
\usepackage[utf8]{inputenc}
\usepackage{graphicx}
\usepackage{fancyhdr}
\usepackage{geometry}
\usepackage{color}
\usepackage{eso-pic}
\usepackage{transparent}
\usepackage{titling}
\usepackage{hyperref}
\usepackage{lastpage}

\geometry{margin=1in}
\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0.4pt}

\fancyhead[L]{\small \textbf{Archer Crypto Solutions Incorporated}}
\fancyhead[C]{\small $title$}
\fancyfoot[R]{\small Page \thepage\ of \pageref{LastPage}}
\fancyfoot[L]{\small Snapshot: $snapshot$}
\fancyfoot[C]{\small Generated: $date$}

\newcommand\WatermarkText{$watermark$}
\AddToShipoutPictureBG*{%
  \AtPageCenter{%
    \makebox(0,0){\transparent{0.12}\fontsize{48}{48}\selectfont\textsf{\WatermarkText}}%
  }%
}

\newcommand{\coverlogo}{%
  \begin{center}
    \vspace*{2cm}
    \includegraphics[width=0.35\textwidth}{$logo$}
    \vspace{1cm}
  \end{center}
}

\pretitle{\begin{center}\LARGE\bfseries}
\posttitle{\par\end{center}\vskip 0.5em}
\preauthor{\begin{center}\large}
\postauthor{\par\end{center}}
\predate{\begin{center}\small}
\postdate{\par\end{center}}

\begin{document}

\begin{titlepage}
  \coverlogo
  \vfill
  {\centering
    \Huge \textbf{$title$}\par
    \vspace{1em}
    \Large $subtitle$\par
    \vspace{2em}
    \large Prepared by: $author$\par
    \vspace{1em}
    \large Date: $date$\par
  }
  \vfill
\end{titlepage}

$body$

\end{document}
EOF

cat > "${PKG_DIR}/convert_with_template.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

MD="$1"
OUT="${2:-${MD%.md}.pdf}"
TEMPLATE="${3:-$(pwd)/pandoc-template.tex}"
LOGO="${4:-$(pwd)/../assets/logo.png}"
WATERMARK="${5:-Sovereign Proclamation — Archer Crypto Solutions Incorporated}"

SNAPSHOT="$(git -C "${HOME}/Mahihkan" describe --tags --always 2>/dev/null || echo 'unsnapped')"
DATE="$(date -u +"%Y-%m-%d %H:%M UTC")"

pandoc "$MD" \
  --from markdown \
  --template="$TEMPLATE" \
  -V logo="$LOGO" \
  -V watermark="$WATERMARK" \
  -V snapshot="$SNAPSHOT" \
  -V date="$DATE" \
  -o "$OUT" \
  --pdf-engine=pdflatex
EOF

chmod +x "${PKG_DIR}/convert_with_template.sh"
echo "[*] Reset complete. Files saved in ${PKG_DIR}"
