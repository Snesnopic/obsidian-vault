#!/bin/bash

for dir in */; do
  if [ "$dir" == ".git/" ]; then
    continue
  fi

  master="${dir%/}.md"

  echo "" > "$master"

  find "$dir" -maxdepth 1 -type f -name "*.md" | sort | while read file; do
    echo "" >> "$master"
    echo "---" >> "$master"
    echo "" >> "$master"
    cat "$file" >> "$master"
    echo "" >> "$master"
  done
done