#!/bin/bash
BASE_DIRS=(/data/data/com.termux/files/home/ACA /data/data/com.termux/files/home/ACS /data/data/com.termux/files/home/CVR_Essentials /data/data/com.termux/files/home/Mahihkan)
converter="/data/data/com.termux/files/home/Mahihkan/package/convert_with_template.sh"
log="/data/data/com.termux/files/home/md2pdf_fleet.log"
: > "$log"

for base in "${BASE_DIRS[@]}"; do
  [ -d "$base" ] || continue
  find "$base" -type f -name '*.md' | while IFS= read -r md; do
    pdf="${md%.md}.pdf"
    echo "Converting: $md -> $pdf" | tee -a "$log"
    "$converter" "$md" "$pdf" 2>&1 | tee -a "$log"
  done
done
echo "Fleet sweep complete" | tee -a "$log"
