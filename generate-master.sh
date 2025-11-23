#!/bin/bash

for dir in */; do
  if [ "$dir" == ".git/" ]; then
    continue
  fi

  master="${dir%/}.md"

  echo "---" > "$master"
  echo "geometry: margin=1in" >> "$master"
  echo "header-includes:" >> "$master"
  echo "  - \\providecommand{\\sem}[1]{ [\\![ #1 ]\\!] }" >> "$master"
  echo "  - \\providecommand{\\den}[1]{\\mathcal{#1}}" >> "$master"
  echo "  - \\providecommand{\\floor}[1]{\\lfloor #1 \\rfloor}" >> "$master"
  echo "---" >> "$master"
  echo "" >> "$master"

  find "$dir" -maxdepth 1 -type f -name "*.md" | sort | while read file; do
    cat "$file" >> "$master"
    
    echo "" >> "$master"
    echo "" >> "$master"
    
    echo '<div style="page-break-after: always;"></div>' >> "$master"
    
    echo "" >> "$master"
  done
done