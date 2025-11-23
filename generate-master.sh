#!/bin/bash

# Loop through all subdirectories
for dir in */; do
  # Skip hidden directories (like .git)
  if [[ "$dir" == .* ]]; then
    continue
  fi

  # Define the master file name (e.g., "Algorithm Engineering.md")
  # The file is created in the root directory
  master="${dir%/}.md"

  echo "Creating Master File: $master"

  # 1. Write the YAML Header safely using a HereDoc
  # We add \newpage to the preamble to ensure the command works everywhere
  cat <<'EOF' > "$master"
---
geometry: margin=1in
header-includes:
  - |
    \newcommand{\sem}[1]{ [\![ #1 ]\!] }
    \newcommand{\den}[1]{\mathcal{#1}}
    \newcommand{\floor}[1]{\lfloor #1 \rfloor}
    \newcommand{\trans}[1]{\xrightarrow{#1}}
    \newcommand{\wtrans}[1]{\stackrel{#1}{\Longrightarrow}}
    \newcommand{\nat}{\mathbb{N}}
---

EOF

  # 2. Process files
  # Using -print0 and IFS= ensures filenames with spaces are handled correctly
  find "$dir" -maxdepth 1 -type f -name "*.md" | sort | while IFS= read -r file; do
    
    echo "  -> Adding $file"

    # 3. PROCESSING PIPELINE:
    # Step A: Remove lines trying to define \mathbb (causes conflicts)
    # Step B: Convert other \newcommand to \providecommand (prevents conflicts)
    cat "$file" | \
    sed '/\\newcommand{\\mathbb}/d' | \
    sed 's/\\newcommand/\\providecommand/g' >> "$master"
    
    # Add spacing
    echo "" >> "$master"
    echo "" >> "$master"
    
    # Add LaTeX Page Break
    echo '\newpage' >> "$master"
    
    echo "" >> "$master"
  done
  
  echo "Done."
done