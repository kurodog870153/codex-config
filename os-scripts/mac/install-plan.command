#!/bin/bash

script_directory="$(cd -- "$(dirname -- "$0")" && pwd)"
project_directory="$(cd -- "$script_directory/../.." && pwd)"
source_skill="$project_directory/skills/plan"
source_work="$project_directory/work/plan"
source_general="$source_work/general/AGENTS.md"

if [[ ! -d "$source_skill" ]]; then
    printf 'Error: skill source directory not found: "%s".\n' "$source_skill"
    read -r -p 'Press Enter to close...' _
    exit 1
fi

if [[ ! -f "$source_general" ]]; then
    printf 'Error: general work rule not found: "%s".\n' "$source_general"
    read -r -p 'Press Enter to close...' _
    exit 1
fi

optional_rules=()
while IFS= read -r rule_file; do
    relative_file="${rule_file#"$source_work/"}"
    rule_path="${relative_file%/AGENTS.md}"

    if [[ "$rule_path" != "general" ]]; then
        optional_rules+=("$rule_path")
    fi
done < <(find "$source_work" -type f -name 'AGENTS.md' -print | LC_ALL=C sort)

selected_rules=()

add_selected_rule() {
    local candidate="$1"
    local existing_rule

    for existing_rule in "${selected_rules[@]}"; do
        if [[ "$existing_rule" == "$candidate" ]]; then
            return
        fi
    done

    selected_rules+=("$candidate")
}

add_rule_with_parents() {
    local candidate="$1"

    while [[ -n "$candidate" ]]; do
        if [[ -f "$source_work/$candidate/AGENTS.md" ]]; then
            add_selected_rule "$candidate"
        fi

        if [[ "$candidate" != */* ]]; then
            break
        fi

        candidate="${candidate%/*}"
    done
}

if (( ${#optional_rules[@]} > 0 )); then
    printf 'Optional plan work rules:\n'
    for (( index = 0; index < ${#optional_rules[@]}; index++ )); do
        printf '  %d. %s\n' "$((index + 1))" "${optional_rules[index]}"
    done

    while true; do
        read -r -p 'Select rule numbers separated by spaces, enter "all", or press Enter for general only: ' selection

        if [[ -z "$selection" ]]; then
            break
        fi

        if [[ "$selection" == "all" ]]; then
            for rule_path in "${optional_rules[@]}"; do
                add_rule_with_parents "$rule_path"
            done
            break
        fi

        read -r -a selection_tokens <<< "$selection"
        valid_selection=true

        for token in "${selection_tokens[@]}"; do
            if [[ ! "$token" =~ ^[0-9]+$ ]] || (( token < 1 || token > ${#optional_rules[@]} )); then
                valid_selection=false
                break
            fi
        done

        if [[ "$valid_selection" != true ]]; then
            printf 'Invalid selection. Please try again.\n'
            continue
        fi

        for token in "${selection_tokens[@]}"; do
            add_rule_with_parents "${optional_rules[token - 1]}"
        done
        break
    done
else
    printf 'No optional plan work rules were found. General will be installed.\n'
fi

while true; do
    read -r -p 'Enter the target directory: ' target_directory

    if [[ -z "$target_directory" ]]; then
        printf 'The directory cannot be empty. Please try again.\n'
        continue
    fi

    if [[ "$target_directory" == "~" ]]; then
        target_directory="$HOME"
    elif [[ "$target_directory" == ~/* ]]; then
        target_directory="$HOME/${target_directory#~/}"
    fi

    break
done

if [[ ! -d "$target_directory" ]]; then
    read -r -p 'The directory does not exist. Create it? [y/N] ' create_directory
    if [[ ! "$create_directory" =~ ^[Yy]$ ]]; then
        printf 'Operation cancelled.\n'
        read -r -p 'Press Enter to close...' _
        exit 0
    fi

    if ! mkdir -p -- "$target_directory"; then
        printf 'Error: failed to create the directory "%s".\n' "$target_directory"
        read -r -p 'Press Enter to close...' _
        exit 1
    fi
fi

target_skill="$target_directory/skills/plan"
target_work="$target_directory/work/plan"

if [[ -e "$target_skill" || -e "$target_work" ]]; then
    read -r -p 'Plan skill or work rules already exist. Merge and overwrite matching files? [y/N] ' overwrite_plan
    if [[ ! "$overwrite_plan" =~ ^[Yy]$ ]]; then
        printf 'Operation cancelled.\n'
        read -r -p 'Press Enter to close...' _
        exit 0
    fi
fi

if ! mkdir -p -- "$target_skill"; then
    printf 'Error: failed to create the plan skill directory.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

if ! cp -R -- "$source_skill/." "$target_skill/"; then
    printf 'Error: failed to copy the plan skill.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

if ! mkdir -p -- "$target_work/general" || ! cp -f -- "$source_general" "$target_work/general/AGENTS.md"; then
    printf 'Error: failed to copy the general plan work rule.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

for rule_path in "${selected_rules[@]}"; do
    if ! mkdir -p -- "$target_work/$rule_path" || ! cp -f -- "$source_work/$rule_path/AGENTS.md" "$target_work/$rule_path/AGENTS.md"; then
        printf 'Error: failed to copy the plan work rule "%s".\n' "$rule_path"
        read -r -p 'Press Enter to close...' _
        exit 1
    fi
done

printf 'The plan skill and general work rule were installed in "%s".\n' "$target_directory"
if (( ${#selected_rules[@]} > 0 )); then
    printf 'Optional work rules installed:\n'
    for rule_path in "${selected_rules[@]}"; do
        printf '  %s\n' "$rule_path"
    done
fi
read -r -p 'Press Enter to close...' _
