#!/bin/bash
# scan.sh — Radar Scanner for the Project Dashboard
# Collects all project metrics in a single pass (~3 seconds)
# Output: structured format for dashboard updates
#
# Usage: ./scan.sh                (all projects)
#        ./scan.sh design-sys app      (only named projects, fuzzy match)
#
# Customize: Edit the PROJECTS array below to match your setup.

set -u
export LC_NUMERIC=C

CODE_DIR="$HOME/projects"
CLAUDE_DIR="$HOME/.claude/projects"

# === CUSTOMIZE THIS ===
# Format: shortname|directory|claude-project-suffix|color|icon-abbreviation
#
# To find your Claude project suffix, take the absolute path of your project,
# replace all "/" with "-", keep the leading "-".
# Example: /Users/jane/projects/my-app -> -Users-jane-projects-my-app
#
# Note: scan.sh writes a time-log.md into each existing project directory
# (see "Hours check" below) — point this array at your real projects first.
PROJECTS=(
  "design-sys|my-design-system|-Users-jane-projects-my-design-system|#005b8e|DS"
  "app|my-app|-Users-jane-projects-my-app|#10b981|Ma"
  "docs|my-docs|-Users-jane-projects-my-docs|#f59e0b|Md"
  "dashboard|project-dashboard|-Users-jane-projects-project-dashboard|#888|PD"
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

# --- Time-log helpers ---

# Active time of a .jsonl session in hours.
# Sums only intervals between consecutive (sorted) messages that are <30min
# apart. Longer gaps = breaks / session resumed on another day -> not counted.
# Per active burst, 2 minutes are added as tail buffer (the last message
# still runs on).
session_hours() {
  local jsonl="$1"
  local gap_threshold=1800   # 30 min
  local tail_buffer=120      # 2 min after each burst

  # Extract timestamps, dedupe, sort chronologically, convert to epoch
  local epochs
  epochs=$(grep -oE '"timestamp":"[^"]+"' "$jsonl" 2>/dev/null | \
    sed 's/"timestamp":"//;s/"$//;s/\..*Z$//;s/Z$//' | \
    sort -u | \
    while IFS= read -r t; do
      [[ -z "$t" ]] && continue
      date -ju -f "%Y-%m-%dT%H:%M:%S" "$t" +%s 2>/dev/null
    done)

  [[ -z "$epochs" ]] && echo "0.0" && return

  # Sum active time
  local total=0
  local prev=0
  local in_burst=0
  while IFS= read -r ts; do
    [[ -z "$ts" ]] && continue
    if (( prev > 0 )); then
      local diff=$((ts - prev))
      if (( diff > 0 && diff < gap_threshold )); then
        total=$((total + diff))
        in_burst=1
      elif (( diff >= gap_threshold )); then
        # Real gap -> burst finished, add tail buffer
        if (( in_burst )); then
          total=$((total + tail_buffer))
          in_burst=0
        fi
      fi
    fi
    prev=$ts
  done <<< "$epochs"
  # Close the last burst
  (( in_burst )) && total=$((total + tail_buffer))

  printf "%.1f" "$(echo "scale=2; $total / 3600" | bc)"
}

# First timestamp of a session in local format YYYY-MM-DD HH:MM
session_start() {
  local jsonl="$1" t epoch
  t=$(grep -m1 -oE '"timestamp":"[^"]+"' "$jsonl" 2>/dev/null | sed 's/"timestamp":"//;s/"$//')
  [[ -z "$t" ]] && echo "" && return
  t="${t%.*}"; t="${t%Z}"
  epoch=$(date -ju -f "%Y-%m-%dT%H:%M:%S" "$t" +%s 2>/dev/null)
  [[ -z "$epoch" ]] && echo "" && return
  date -j -r "$epoch" "+%Y-%m-%d %H:%M"
}

session_end() {
  local jsonl="$1" t epoch
  t=$(grep -oE '"timestamp":"[^"]+"' "$jsonl" 2>/dev/null | tail -1 | sed 's/"timestamp":"//;s/"$//')
  [[ -z "$t" ]] && echo "" && return
  t="${t%.*}"; t="${t%Z}"
  epoch=$(date -ju -f "%Y-%m-%dT%H:%M:%S" "$t" +%s 2>/dev/null)
  [[ -z "$epoch" ]] && echo "" && return
  date -j -r "$epoch" "+%H:%M"
}

# Last timestamp as a date (to detect multi-day sessions)
session_end_date() {
  local jsonl="$1" t epoch
  t=$(grep -oE '"timestamp":"[^"]+"' "$jsonl" 2>/dev/null | tail -1 | sed 's/"timestamp":"//;s/"$//')
  [[ -z "$t" ]] && echo "" && return
  t="${t%.*}"; t="${t%Z}"
  epoch=$(date -ju -f "%Y-%m-%dT%H:%M:%S" "$t" +%s 2>/dev/null)
  [[ -z "$epoch" ]] && echo "" && return
  date -j -r "$epoch" "+%Y-%m-%d"
}

# Sum manual hours from time-log.md (column 2 of each date row)
manual_hours_from_log() {
  local logfile="$1"
  [[ ! -f "$logfile" ]] && echo "0.0" && return
  awk -F'|' '
    /^## Claude Sessions/ {in_auto=1}
    /^## / && !/^## Manual/ && !/^## Claude Sessions/ {in_auto=0}
    /^## Manual/ {in_auto=0; in_manual=1; next}
    in_manual && /^\|/ && $2 ~ /^ *[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
      gsub(/ /,"",$3); if ($3+0>0) s+=$3
    }
  END { printf "%.1f", s+0 }
  ' "$logfile"
}

# Update a project's time-log.md (the manual section is preserved)
update_time_log() {
  local code_path="$1" claude_path="$2" project_short="$3"
  local logfile="$code_path/time-log.md"
  local tmp="$(mktemp)"
  local claude_total="0.0"
  local session_rows=""

  # Collect sessions (top-level only, no subagents)
  if [[ -d "$claude_path" ]]; then
    while IFS= read -r jsonl; do
      [[ -z "$jsonl" ]] && continue
      local sid="$(basename "$jsonl" .jsonl)"
      local short_id="${sid:0:8}"
      local start="$(session_start "$jsonl")"
      local end="$(session_end "$jsonl")"
      local end_date="$(session_end_date "$jsonl")"
      local hours="$(session_hours "$jsonl")"
      [[ -z "$start" ]] && continue
      local sdate="${start%% *}"
      local stime="${start##* }"
      # Multi-day session: show the end time with its date
      local end_display="$end"
      if [[ -n "$end_date" && "$end_date" != "$sdate" ]]; then
        end_display="$end_date $end"
      fi
      session_rows+="| $short_id | $sdate | $stime | $end_display | $hours |"$'\n'
      claude_total=$(echo "scale=2; $claude_total + $hours" | bc)
    done < <(find "$claude_path" -maxdepth 1 -name '*.jsonl' -type f 2>/dev/null | sort)
  fi
  claude_total=$(printf "%.1f" "$claude_total")

  # If time-log.md doesn't exist: create the template
  if [[ ! -f "$logfile" ]]; then
    cat > "$logfile" <<EOF
---
type: time-log
project: $project_short
---

# Time Log

Rough time orientation. Add manual entries for work outside of Claude sessions; everything else is maintained by scan.sh.

## Manual

| Date | Hours | Note |
|---|---|---|

## Claude Sessions (auto, by scan.sh)

| Session | Date | Start | End | Hours |
|---|---|---|---|---|

**Total:** 0.0h (manual: 0.0 + claude: 0.0)
EOF
  fi

  local manual_total
  manual_total=$(manual_hours_from_log "$logfile")
  local grand_total
  grand_total=$(printf "%.1f" "$(echo "scale=2; $manual_total + $claude_total" | bc)")

  # Rebuild the file: keep everything before "## Claude Sessions", then rewrite the auto section
  {
    sed -n '1,/^## Claude Sessions/p' "$logfile" | sed '$d'
    echo "## Claude Sessions (auto, by scan.sh)"
    echo ""
    echo "| Session | Date | Start | End | Hours |"
    echo "|---|---|---|---|---|"
    printf "%s" "$session_rows"
    echo ""
    printf "**Total:** %.1fh (manual: %.1f + claude: %.1f)\n" "$grand_total" "$manual_total" "$claude_total"
  } > "$tmp" && mv "$tmp" "$logfile"

  # Global output: return totals in hours
  echo "$grand_total $manual_total $claude_total"
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
        # Avoid duplicates
        dup=0
        for s in "${selected[@]+"${selected[@]}"}"; do
          [[ "$s" == "$entry" ]] && dup=1 && break
        done
        (( dup == 0 )) && selected+=("$entry")
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

  # 3. Last update (newest file; excluding time-log.md, which scan.sh itself writes)
  last_update=$(find "$code_path" \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/dist/*' \
    -not -name '.DS_Store' \
    -not -name 'time-log.md' \
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

# --- Hours check (time logs) ---

echo "=== HOURS (time logs) ==="
echo ""
printf "%-28s %8s %8s %8s\n" "PROJECT" "MANUAL" "CLAUDE" "TOTAL"
printf "%-28s %8s %8s %8s\n" "---" "---" "---" "---"

grand_manual=0
grand_claude=0
grand_total_h=0

for entry in "${selected[@]}"; do
  IFS='|' read -r short dir claude_suffix color icon <<< "$entry"
  code_path="$CODE_DIR/$dir"
  claude_path="$CLAUDE_DIR/$claude_suffix"
  [[ ! -d "$code_path" ]] && continue

  read -r total manual claude < <(update_time_log "$code_path" "$claude_path" "$dir")
  printf "%-28s %8s %8s %8s\n" "$dir" "$(printf "%.1fh" "$manual")" "$(printf "%.1fh" "$claude")" "$(printf "%.1fh" "$total")"

  grand_manual=$(echo "scale=2; $grand_manual + $manual" | bc)
  grand_claude=$(echo "scale=2; $grand_claude + $claude" | bc)
  grand_total_h=$(echo "scale=2; $grand_total_h + $total" | bc)
done

echo ""
printf -- "--- HOURS TOTAL: %.1fh (manual: %.1f + claude: %.1f) ---\n" "$grand_total_h" "$grand_manual" "$grand_claude"
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

# --- Tasks check: TODO files in Claude memory ---

echo "=== TASKS (TODO files in Claude memory) ==="
echo ""
printf "%-12s %-22s %-8s %-8s  %s\n" "STATUS" "ID" "PRIO" "PROJECT" "TITLE"
printf "%-12s %-22s %-8s %-8s  %s\n" "---" "---" "---" "---" "---"

task_total=0
task_open=0

for entry in "${selected[@]}"; do
  IFS='|' read -r short dir claude_suffix color icon <<< "$entry"
  claude_path="$CLAUDE_DIR/$claude_suffix"
  mem_path="$claude_path/memory"

  [[ ! -d "$mem_path" ]] && continue

  # Find all todo_*.md files
  while IFS= read -r todo_file; do
    [[ -z "$todo_file" ]] && continue
    task_total=$((task_total + 1))

    # Parse frontmatter (between the first two ---)
    t_id="" t_title="" t_status="" t_priority="" t_parent="" t_deadline=""
    while IFS= read -r line; do
      case "$line" in
        id:*) t_id="${line#id: }" ; t_id="${t_id#\"}" ; t_id="${t_id%\"}" ;;
        title:*) t_title="${line#title: }" ; t_title="${t_title#\"}" ; t_title="${t_title%\"}" ;;
        status:*) t_status="${line#status: }" ;;
        priority:*) t_priority="${line#priority: }" ;;
        parent:*) t_parent="${line#parent: }" ;;
        deadline:*) t_deadline="${line#deadline: }" ;;
      esac
    done < <(sed -n '2,/^---$/p' "$todo_file" | head -20)

    [[ "$t_status" == "open" || "$t_status" == "active" || "$t_status" == "blocked" ]] && task_open=$((task_open + 1))

    printf "%-12s %-22s %-8s %-8s  %s\n" \
      "${t_status:-?}" "${t_id:-?}" "${t_priority:--}" "$short" "${t_title:-$(basename "$todo_file")}"
  done < <(find "$mem_path" -maxdepth 1 -name 'todo_*.md' -type f 2>/dev/null)
done

if (( task_total == 0 )); then
  echo "  (no TODO files found)"
fi
echo ""
echo "--- TASKS: $task_total total, $task_open open ---"
echo ""

# --- Link check: dead file:// links across the whole dashboard ---

DASHBOARD="$(cd "$(dirname "$0")" && pwd)/index.html"
if [[ -f "$DASHBOARD" ]]; then
  dead_links=()
  while IFS= read -r match; do
    lineno="${match%%:*}"
    rest="${match#*:}"
    # Extract file:///path/...
    path="${rest#*file://}"
    path="${path%%\"*}"
    # Check both files and directories
    if [[ ! -e "$path" ]]; then
      # Derive the project name from the path
      proj="${path#$CODE_DIR/}"
      proj="${proj%%/*}"
      target="${path#$CODE_DIR/$proj/}"
      dead_links+=("L$lineno  $proj: $target")
    fi
  done < <(grep -n -o 'href="file:///[^"]*"' "$DASHBOARD")

  if [[ ${#dead_links[@]} -gt 0 ]]; then
    echo "=== DEAD LINKS (${#dead_links[@]} dead file:// links) ==="
    echo ""
    for dl in "${dead_links[@]}"; do
      echo "  !! $dl"
    done
    echo ""
  else
    echo "=== LINK CHECK: all file:// links OK ==="
    echo ""
  fi
fi

echo "=== SCAN DONE ==="
