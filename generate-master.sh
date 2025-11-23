#!/bin/bash

for dir in */; do
  if [ "$dir" == ".git/" ]; then continue; fi

  master="${dir%/}.md"

  # 1. Create master file with YAML header
  cat <<'EOF' > "$master"
---
geometry: margin=1in
header-includes:
  - |
    \newcommand{\sem}[1]{ [\![ #1 ]\!] }
    \newcommand{\den}[1]{\mathcal{#1}}
    \newcommand{\floor}[1]{\lfloor #1 \rfloor}
    \newcommand{\trans}[1]{\xrightarrow{#1}}
---

EOF

  # 2. Process files
  find "$dir" -maxdepth 1 -type f -name "*.md" | sort | while read file; do
    
    # 3. Convert local commands to providecommand to avoid conflict
    sed 's/\\newcommand/\\providecommand/g' "$file" >> "$master"
    
    echo "" >> "$master"
    echo "" >> "$master"
    
    echo '<div style="page-break-after: always;"></div>' >> "$master"
    
    echo "" >> "$master"
  done
  
  echo "Generated: $master"
done