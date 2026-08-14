#!/bin/bash

script_directory="$(cd -- "$(dirname -- "$0")" && pwd)"
project_directory="$(cd -- "$script_directory/../.." && pwd)"
source_shared="$project_directory/skills/shared/work/hierarchical-instructions.md"
all_work_types=(plan task execute)
selected_work_types=()
selected_work_rules=()

pause_and_exit() {
    local exit_code="$1"

    read -r -p 'Press Enter to close...' _
    exit "$exit_code"
}

add_selected_rule() {
    local work_type="$1"
    local candidate="$2"
    local selected_entry

    for selected_entry in "${selected_work_rules[@]}"; do
        if [[ "$selected_entry" == "$work_type|$candidate" ]]; then
            return
        fi
    done

    selected_work_rules+=("$work_type|$candidate")
}

add_rule_with_parents() {
    local work_type="$1"
    local candidate="$2"
    local source_work="$project_directory/work/$work_type"

    while [[ -n "$candidate" ]]; do
        if [[ -f "$source_work/$candidate/AGENTS.md" ]]; then
            add_selected_rule "$work_type" "$candidate"
        fi

        if [[ "$candidate" != */* ]]; then
            break
        fi

        candidate="${candidate%/*}"
    done
}

select_optional_rules() {
    local work_type="$1"
    local source_work="$project_directory/work/$work_type"
    local relative_file
    local rule_path
    local selection
    local valid_selection
    local token
    local numeric_token
    local rule_index
    local -a optional_rules=()
    local -a selection_tokens=()

    while IFS= read -r rule_file; do
        relative_file="${rule_file#"$source_work/"}"
        rule_path="${relative_file%/AGENTS.md}"

        if [[ "$rule_path" != "general" ]]; then
            optional_rules+=("$rule_path")
        fi
    done < <(find "$source_work" -type f -name 'AGENTS.md' -print | LC_ALL=C sort)

    if (( ${#optional_rules[@]} == 0 )); then
        printf 'No optional %s work rules were found. General will be installed.\n' "$work_type"
        return
    fi

    printf 'Optional %s work rules:\n' "$work_type"
    for (( index = 0; index < ${#optional_rules[@]}; index++ )); do
        printf '  %d. %s\n' "$((index + 1))" "${optional_rules[index]}"
    done

    while true; do
        read -r -p 'Select rule numbers separated by spaces, enter "all", or press Enter for general only: ' selection

        if [[ -z "$selection" ]]; then
            return
        fi

        if [[ "$selection" == "all" ]]; then
            for rule_path in "${optional_rules[@]}"; do
                add_rule_with_parents "$work_type" "$rule_path"
            done
            return
        fi

        read -r -a selection_tokens <<< "$selection"
        valid_selection=true

        for token in "${selection_tokens[@]}"; do
            if [[ ! "$token" =~ ^[0-9]+$ ]]; then
                valid_selection=false
                break
            fi

            numeric_token=$((10#$token))
            if (( numeric_token < 1 || numeric_token > ${#optional_rules[@]} )); then
                valid_selection=false
                break
            fi
        done

        if [[ "$valid_selection" != true ]]; then
            printf 'Invalid selection. Please try again.\n'
            continue
        fi

        for token in "${selection_tokens[@]}"; do
            rule_index=$((10#$token - 1))
            add_rule_with_parents "$work_type" "${optional_rules[rule_index]}"
        done
        return
    done
}

if (( $# > 1 )); then
    printf 'Error: expected no argument or one of: plan, task, execute, all.\n'
    pause_and_exit 1
fi

if (( $# == 1 )); then
    case "$1" in
        plan|task|execute)
            selected_work_types=("$1")
            ;;
        all)
            selected_work_types=("${all_work_types[@]}")
            ;;
        *)
            printf 'Error: expected no argument or one of: plan, task, execute, all.\n'
            pause_and_exit 1
            ;;
    esac
else
    while true; do
        printf 'Work types:\n'
        printf '  1. plan\n'
        printf '  2. task\n'
        printf '  3. execute\n'
        printf '  4. all\n'
        read -r -p 'Select a work type: ' selection

        case "$selection" in
            1|plan)
                selected_work_types=(plan)
                break
                ;;
            2|task)
                selected_work_types=(task)
                break
                ;;
            3|execute)
                selected_work_types=(execute)
                break
                ;;
            4|all)
                selected_work_types=("${all_work_types[@]}")
                break
                ;;
            *)
                printf 'Invalid selection. Please try again.\n'
                ;;
        esac
    done
fi

if [[ ! -f "$source_shared" ]]; then
    printf 'Error: shared work instructions not found: "%s".\n' "$source_shared"
    pause_and_exit 1
fi

for work_type in "${selected_work_types[@]}"; do
    source_skill="$project_directory/skills/$work_type"
    source_general="$project_directory/work/$work_type/general/AGENTS.md"

    if [[ ! -d "$source_skill" ]]; then
        printf 'Error: skill source directory not found: "%s".\n' "$source_skill"
        pause_and_exit 1
    fi

    if [[ ! -f "$source_general" ]]; then
        printf 'Error: general work rule not found: "%s".\n' "$source_general"
        pause_and_exit 1
    fi
done

for work_type in "${selected_work_types[@]}"; do
    select_optional_rules "$work_type"
done

while true; do
    read -r -p 'Enter the target directory: ' target_directory

    if [[ -z "$target_directory" ]]; then
        printf 'The directory cannot be empty. Please try again.\n'
        continue
    fi

    if [[ "$target_directory" == "~" ]]; then
        target_directory="$HOME"
    elif [[ "$target_directory" == "~/"* ]]; then
        target_directory="$HOME/${target_directory#~/}"
    fi

    break
done

if [[ ! -d "$target_directory" ]]; then
    read -r -p 'The directory does not exist. Create it? [y/N] ' create_directory
    if [[ ! "$create_directory" =~ ^[Yy]$ ]]; then
        printf 'Operation cancelled.\n'
        pause_and_exit 0
    fi

    if ! mkdir -p -- "$target_directory"; then
        printf 'Error: failed to create the directory "%s".\n' "$target_directory"
        pause_and_exit 1
    fi
fi

target_shared_directory="$target_directory/skills/shared/work"
target_shared="$target_shared_directory/hierarchical-instructions.md"
copy_shared=true
target_conflict=false

if [[ -e "$target_shared" ]]; then
    if [[ -f "$target_shared" ]] && cmp -s -- "$source_shared" "$target_shared"; then
        copy_shared=false
    else
        target_conflict=true
    fi
fi

for work_type in "${selected_work_types[@]}"; do
    if [[ -e "$target_directory/skills/$work_type" || -e "$target_directory/work/$work_type" ]]; then
        target_conflict=true
    fi
done

if [[ "$target_conflict" == true ]]; then
    read -r -p 'Selected work skills, shared work instructions, or work rules already exist. Merge and overwrite matching files? [y/N] ' overwrite_work
    if [[ ! "$overwrite_work" =~ ^[Yy]$ ]]; then
        printf 'Operation cancelled.\n'
        pause_and_exit 0
    fi
fi

if [[ "$copy_shared" == true ]]; then
    if ! mkdir -p -- "$target_shared_directory"; then
        printf 'Error: failed to create the shared work instructions directory.\n'
        pause_and_exit 1
    fi

    if ! cp -f -- "$source_shared" "$target_shared"; then
        printf 'Error: failed to copy the shared work instructions.\n'
        pause_and_exit 1
    fi
fi

for work_type in "${selected_work_types[@]}"; do
    source_skill="$project_directory/skills/$work_type"
    source_work="$project_directory/work/$work_type"
    target_skill="$target_directory/skills/$work_type"
    target_work="$target_directory/work/$work_type"

    if ! mkdir -p -- "$target_skill"; then
        printf 'Error: failed to create the %s skill directory.\n' "$work_type"
        pause_and_exit 1
    fi

    if ! cp -R -- "$source_skill/." "$target_skill/"; then
        printf 'Error: failed to copy the %s skill.\n' "$work_type"
        pause_and_exit 1
    fi

    if ! mkdir -p -- "$target_work/general" || ! cp -f -- "$source_work/general/AGENTS.md" "$target_work/general/AGENTS.md"; then
        printf 'Error: failed to copy the general %s work rule.\n' "$work_type"
        pause_and_exit 1
    fi

    for selected_entry in "${selected_work_rules[@]}"; do
        entry_work_type="${selected_entry%%|*}"
        rule_path="${selected_entry#*|}"

        if [[ "$entry_work_type" != "$work_type" ]]; then
            continue
        fi

        if ! mkdir -p -- "$target_work/$rule_path" || ! cp -f -- "$source_work/$rule_path/AGENTS.md" "$target_work/$rule_path/AGENTS.md"; then
            printf 'Error: failed to copy the %s work rule "%s".\n' "$work_type" "$rule_path"
            pause_and_exit 1
        fi
    done
done

printf 'Selected work skills, shared work instructions, and general work rules were installed in "%s".\n' "$target_directory"
printf 'Work types installed:\n'
for work_type in "${selected_work_types[@]}"; do
    printf '  %s\n' "$work_type"
done

if (( ${#selected_work_rules[@]} > 0 )); then
    printf 'Optional work rules installed:\n'
    for selected_entry in "${selected_work_rules[@]}"; do
        entry_work_type="${selected_entry%%|*}"
        rule_path="${selected_entry#*|}"
        printf '  %s: %s\n' "$entry_work_type" "$rule_path"
    done
fi

pause_and_exit 0
