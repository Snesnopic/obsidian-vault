#!/bin/bash

# Loop through all subdirectories
for dir in */; do
  # Skip hidden directories (like .git)
  if [[ "$dir" == .* ]]; then
    continue
  fi

  # Define the master file name (e.g., "Algorithm Engineering.md")
  # ${dir%/} removes the trailing slash
  master="${dir%/}.md"

  # 1. Write the YAML Header safely using a HereDoc
  # We use 'EOF' (quoted) to prevent Bash from interpreting backslashes or variables.
  # This ensures the LaTeX macros are written correctly for Pandoc.
  cat <<'EOF' > "$master"
---
geometry: margin=1in
header-includes:
  - |
    \newcommand{\sem}[1]{ [\![ #1 ]\!] }
    \newcommand{\den}[1]{\mathcal{#1}}
    \newcommand{\floor}[1]{\lfloor #1 \rfloor}
---

EOF

  # 2. Concatenate files
  # Find all .md files in the directory, sort them, and loop
  find "$dir" -maxdepth 1 -type f -name "*.md" | sort | while read file; do
    # Append the file content
    cat "$file" >> "$master"
    
    # Add spacing to prevent markdown merging
    echo "" >> "$master"
    echo "" >> "$master"
    
    # Add a clean Page Break (replaces the "---" separator)
    echo '<div style="page-break-after: always;"></div>' >> "$master"
    
    echo "" >> "$master"
  done
  
  echo "Generated master file: $master"
done