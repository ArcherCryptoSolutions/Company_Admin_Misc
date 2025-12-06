pandoc "$input_md" \
  --pdf-engine=pdflatex \
  --data-dir=/data/data/com.termux/files/home/Mahihkan/package \
  --template=pandoc-template.tex \
  -V watermark="$watermark" \
  -V logo="$logo" \
  -V title="Fleet Report" \
  -V author="Neil Archer" \
  -V date="$(date +%Y-%m-%d)" \
  -o "$output_pdf"
