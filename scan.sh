#!/bin/bash
# scan.sh — Radar Scanner for the Project Dashboard
# Collects all project metrics in a single pass (~3 seconds)
# Output: structured format for dashboard updates
#
# Usage: ./scan.sh                (all projects)
#        ./scan.sh kern tipi      (only named projects, fuzzy match)
#
# Customize: Edit the PROJECTS array below to match your setup.

set -u
export LC_NUMERIC=C

CODE_DIR="$HOME/Documents/code"
CLAUDE_DIR="$HOME/.claude/projects"

# === CUSTOMIZE THIS ===
# Format: shortname|directory|claude-project-suffix|color|icon-abbreviation
#
# To find your Claude project suffix, take the absolute path of your project,
# replace all "/" with "-", keep the leading "-".
# Example: /Users/jane/code/my-app -> -Users-jane-code-my-app
#
PROJECTS=(
  "design-sys|my-design-system|-Users-jane-code-my-design-system|#005b8e|DS"
  "app|my-app|-Users-jane-code-my-app|#10b981|Ma"
  "docs|my-docs|-Users-jane-code-my-docs|#f59e0b|Md"
  "dashboard|_project-dashboard|-Users-jane-code--project-dashboard|#888|PD"
)

# Code file extensions (for line counting)
CODE_EXTS=( ts tsx js jsx css scss html kt java )

# --- Helper functions ---

fuzzy_match() {
  local query="$1" entry="$2"
  local short="${entry%%|*}"
  local dir
  dir="$(echo "$entry" | cut -d'|' -f2)"
  [[ "$dir" == *"$query"* || "$short" == *"$query"* ]]
}

format_lines() {
  local n="$1"
  if (( n >= 1000000 )); then
    printf "~%.1fM" "$(echo "scale=1; $n / 1000000" | bc)"
  elif (( n >= 1000 )); then
    printf "~%.1fk" "$(echo "scale=1; $n / 1000" | bc)"
  else
    printf "~%d" "$n"
  fi
}

format_kb() {
  local bytes="$1"
  if (( bytes >= 1048576 )); then
    printf "%.1f MB" "$(echo "scale=1; $bytes / 1048576" | bc)"
  elif (( bytes >= 1024 )); then
    printf "%.1f KB" "$(echo "scale=1; $bytes / 1024" | bc)"
  else
    printf "%d B" "$bytes"
  fi
}

# --- Filter: which projects to scan? ---

selected=()
if [[ $# -eq 0 ]]; then
  selected=("${PROJECTS[@]}")
else
  for arg in "$@"; do
    arg_lower="$(echo "$arg" | tr '[:upper:]' '[:lower:]')"
    for entry in "${PROJECTS[@]}"; do
      if fuzzy_match "$arg_lower" "$entry"; then
        selected+=("$entry")
      fi
    done
  done
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "No projects found for: $*"
  exit 1
fi

# --- Header ---

echo "=== RADAR SCAN $(date '+%Y-%m-%d %H:%M') ==="
echo ""
printf "%-28s %7s %10s  %-19s  %3s %3s  %s\n" \
  "PROJECT" "FILES" "LINES" "LAST UPDATE" "MEM" "SES" "CHECKS"
printf "%-28s %7s %10s  %-19s  %3s %3s  %s\n" \
  "---" "---" "---" "---" "---" "---" "---"

# --- Scan each project ---

total_files=0
total_lines=0

for entry in "${selected[@]}"; do
  IFS='|' read -r short dir claude_suffix color icon <<< "$entry"

  code_path="$CODE_DIR/$dir"
  claude_path="$CLAUDE_DIR/$claude_suffix"

  # Skip if directory doesn't exist
  if [[ ! -d "$code_path" ]]; then
    printf "%-28s  !! DIRECTORY MISSING\n" "$dir"
    continue
  fi

  # 1. File count (excluding node_modules, .git, dist, .DS_Store)
  file_count=$(find "$code_path" \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/dist/*' \
    -not -name '.DS_Store' \
    -type f 2>/dev/null | wc -l | tr -d ' ')

  # 2. Lines of code
  find_ext_args=()
  for ext in "${CODE_EXTS[@]}"; do
    if [[ ${#find_ext_args[@]} -gt 0 ]]; then
      find_ext_args+=("-o")
    fi
    find_ext_args+=("-name" "*.${ext}")
  done

  line_count=$(find "$code_path" \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/dist/*' \
    -type f \( "${find_ext_args[@]}" \) \
    -exec wc -l {} + 2>/dev/null | grep -v ' total$' | awk '{s+=$1} END{print s+0}')

  # 3. Last update (newest file, excluding node_modules/.git/dist)
  last_update=$(find "$code_path" \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/dist/*' \
    -not -name '.DS_Store' \
    -type f \
    -exec stat -f '%m %Sm' -t '%Y-%m-%d %H:%M' {} + 2>/dev/null \
    | sort -rn | head -1 | cut -d' ' -f2-)

  # 4. Memory files
  mem_count=0
  if [[ -d "$claude_path/memory" ]]; then
    mem_count=$(find "$claude_path/memory" -name '*.md' -not -name 'MEMORY.md' -type f 2>/dev/null | wc -l | tr -d ' ')
  fi

  # 5. Sessions (.jsonl)
  ses_count=0
  if [[ -d "$claude_path" ]]; then
    ses_count=$(find "$claude_path" -name '*.jsonl' -type f 2>/dev/null | wc -l | tr -d ' ')
  fi

  # 6. Health checks
  checks=""

  # CLAUDE.md present?
  if [[ -f "$code_path/CLAUDE.md" ]]; then
    checks+="C"
  else
    checks+="c"
  fi

  # Favicon present?
  if [[ -f "$code_path/favicon.svg" ]]; then
    checks+="F"
  else
    checks+="f"
  fi

  # Memory index present?
  if [[ -f "$claude_path/memory/MEMORY.md" ]]; then
    checks+="M"
  else
    checks+="m"
  fi

  # Root docs count (md/html excluding CLAUDE.md/README.md/CHANGELOG)
  doc_count=$(find "$code_path" -maxdepth 1 \( -name '*.md' -o -name '*.html' \) \
    -not -name 'CLAUDE.md' -not -name 'README.md' -not -name 'CHANGELOG*' \
    -type f 2>/dev/null | wc -l | tr -d ' ')
  if (( doc_count > 0 )); then
    checks+=" ${doc_count}docs"
  fi

  # Totals
  total_files=$((total_files + file_count))
  total_lines=$((total_lines + line_count))

  # Output
  lines_fmt=$(format_lines "$line_count")
  printf "%-28s %7d %10s  %-19s  %3d %3d  %s\n" \
    "$dir" "$file_count" "$lines_fmt" "$last_update" "$mem_count" "$ses_count" "$checks"
done

echo ""
echo "--- TOTAL: $total_files files, $(format_lines $total_lines) lines ---"
echo ""

# --- Docs table check ---

echo "=== DOCS CHECK (root files vs. dashboard) ==="
echo ""

for entry in "${selected[@]}"; do
  IFS='|' read -r short dir claude_suffix color icon <<< "$entry"
  code_path="$CODE_DIR/$dir"

  [[ ! -d "$code_path" ]] && continue

  # All relevant files in project root
  root_docs=$(find "$code_path" -maxdepth 1 -type f \( \
    -name '*.md' -o -name '*.html' -o -name '*.json' \
  \) -not -name 'package*.json' -not -name 'tsconfig*.json' \
    -not -name '.prettierrc*' -not -name 'vite.config*' \
    -not -name 'playwright*' -not -name 'vitest*' \
    2>/dev/null | sort)

  if [[ -n "$root_docs" ]]; then
    echo "$dir:"
    while IFS= read -r f; do
      fname=$(basename "$f")
      fsize=$(stat -f '%z' "$f" 2>/dev/null || echo 0)
      fdate=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$f" 2>/dev/null || echo "?")
      printf "  %-40s %10s  %s\n" "$fname" "$(format_kb "$fsize")" "$fdate"
    done <<< "$root_docs"
    echo ""
  fi
done

echo "=== SCAN DONE ==="
