#!/bin/bash

script_directory="$(cd -- "$(dirname -- "$0")" && pwd)"
project_directory="$(cd -- "$script_directory/../.." && pwd)"
source_plugin="$project_directory/plugins/marketing"
source_manifest="$source_plugin/.codex-plugin/plugin.json"

if [[ ! -d "$source_plugin" || ! -f "$source_manifest" ]]; then
    printf 'Error: marketing plugin source not found: "%s".\n' "$source_plugin"
    read -r -p 'Press Enter to close...' _
    exit 1
fi

if [[ ! -x /usr/bin/osascript ]]; then
    printf 'Error: osascript is required to manage plugin metadata.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

if ! manifest_info="$(/usr/bin/osascript -l JavaScript -e "function run(argv) { ObjC.import('Foundation'); var data = $.NSFileManager.defaultManager.contentsAtPath(argv[0]); var text = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js; var manifest = JSON.parse(text); if (!manifest.name || !manifest.version) { throw new Error('Required manifest fields are missing.'); } return manifest.name + '|' + manifest.version; }" -- "$source_manifest")"; then
    printf 'Error: the marketing plugin manifest is not valid.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

if [[ "${manifest_info%%|*}" != "marketing" ]]; then
    printf 'Error: the plugin manifest name must be "marketing".\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

while true; do
    printf 'Install scope:\n'
    printf '  1. Personal\n'
    printf '  2. Project\n'
    read -r -p 'Select the install scope: ' install_scope

    case "$install_scope" in
        1)
            scope_name="personal"
            target_plugin="$HOME/.codex/plugins/marketing"
            marketplace_file="$HOME/.agents/plugins/marketplace.json"
            marketplace_name="personal"
            marketplace_display_name="Personal"
            marketplace_source_path="./.codex/plugins/marketing"
            break
            ;;
        2)
            scope_name="project"

            while true; do
                read -r -p 'Enter the project root directory: ' target_directory

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

            target_directory="$(cd -- "$target_directory" && pwd)"
            project_name="$(basename -- "$target_directory")"
            marketplace_name="$(printf '%s' "$project_name" | LC_ALL=C tr '[:upper:]_' '[:lower:]-' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
            marketplace_display_name="$(printf '%s' "$project_name" | tr '_-' '  ' | awk '{ for (field_number = 1; field_number <= NF; field_number++) { $field_number = toupper(substr($field_number, 1, 1)) tolower(substr($field_number, 2)) } print }')"

            if [[ -z "$marketplace_name" || -z "$marketplace_display_name" ]]; then
                printf 'Error: the project directory name cannot be converted to marketplace metadata.\n'
                read -r -p 'Press Enter to close...' _
                exit 1
            fi

            target_plugin="$target_directory/plugins/marketing"
            marketplace_file="$target_directory/.agents/plugins/marketplace.json"
            marketplace_source_path="./plugins/marketing"
            break
            ;;
        *)
            printf 'Invalid selection. Please try again.\n'
            ;;
    esac
done

existing_entry_index=""
if [[ -f "$marketplace_file" ]]; then
    if ! marketplace_info="$(/usr/bin/osascript -l JavaScript -e "function run(argv) { ObjC.import('Foundation'); var data = $.NSFileManager.defaultManager.contentsAtPath(argv[0]); var text = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js; var marketplace = JSON.parse(text); if (!marketplace.name) { throw new Error('Marketplace name is missing.'); } var plugins = Array.isArray(marketplace.plugins) ? marketplace.plugins : []; var index = plugins.findIndex(function(plugin) { return plugin.name === 'marketing'; }); return marketplace.name + '|' + index; }" -- "$marketplace_file")"; then
        printf 'Error: marketplace file is not valid: "%s".\n' "$marketplace_file"
        read -r -p 'Press Enter to close...' _
        exit 1
    fi

    marketplace_name="${marketplace_info%%|*}"
    detected_entry_index="${marketplace_info#*|}"
    if [[ "$detected_entry_index" != "-1" ]]; then
        existing_entry_index="$detected_entry_index"
    fi
fi

if [[ -e "$target_plugin" || -n "$existing_entry_index" ]]; then
    read -r -p 'The marketing plugin or marketplace entry already exists. Merge and overwrite matching content? [y/N] ' overwrite_plugin
    if [[ ! "$overwrite_plugin" =~ ^[Yy]$ ]]; then
        printf 'Operation cancelled.\n'
        read -r -p 'Press Enter to close...' _
        exit 0
    fi
fi

target_plugin_parent="${target_plugin%/marketing}"
if ! mkdir -p -- "$target_plugin_parent"; then
    printf 'Error: failed to create the plugin directory.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

if ! cp -R -- "$source_plugin" "$target_plugin_parent/"; then
    printf 'Error: failed to copy the marketing plugin.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

target_manifest="$target_plugin/.codex-plugin/plugin.json"
target_version="${manifest_info#*|}"
if [[ -z "$target_version" ]]; then
    printf 'Error: the installed plugin manifest has no version.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

base_version="${target_version%%+*}"
cachebuster="local-$(date -u '+%Y%m%d-%H%M%S')"
if ! /usr/bin/osascript -l JavaScript -e "function run(argv) { ObjC.import('Foundation'); var data = $.NSFileManager.defaultManager.contentsAtPath(argv[0]); var text = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js; var manifest = JSON.parse(text); manifest.version = argv[1]; var output = JSON.stringify(manifest, null, 2) + '\\n'; if (!\$(output).writeToFileAtomicallyEncodingError(argv[0], true, $.NSUTF8StringEncoding, null)) { throw new Error('Failed to write manifest.'); } }" -- "$target_manifest" "$base_version+codex.$cachebuster"; then
    printf 'Error: failed to update the plugin cachebuster.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

marketplace_directory="${marketplace_file%/marketplace.json}"
if ! mkdir -p -- "$marketplace_directory"; then
    printf 'Error: failed to create the marketplace directory.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

if ! /usr/bin/osascript -l JavaScript -e "function run(argv) { ObjC.import('Foundation'); var manager = $.NSFileManager.defaultManager; var marketplace; if (manager.fileExistsAtPath(argv[0])) { var data = manager.contentsAtPath(argv[0]); var text = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding).js; marketplace = JSON.parse(text); if (!marketplace.name) { throw new Error('Marketplace name is missing.'); } if (!Array.isArray(marketplace.plugins)) { marketplace.plugins = []; } } else { marketplace = { name: argv[1], interface: { displayName: argv[2] }, plugins: [] }; } var entry = { name: 'marketing', source: { source: 'local', path: argv[3] }, policy: { installation: 'AVAILABLE', authentication: 'ON_INSTALL' }, category: 'Productivity' }; var index = marketplace.plugins.findIndex(function(plugin) { return plugin.name === 'marketing'; }); if (index === -1) { marketplace.plugins.push(entry); } else { marketplace.plugins[index] = entry; } var output = JSON.stringify(marketplace, null, 2) + '\\n'; if (!\$(output).writeToFileAtomicallyEncodingError(argv[0], true, $.NSUTF8StringEncoding, null)) { throw new Error('Failed to write marketplace.'); } }" -- "$marketplace_file" "$marketplace_name" "$marketplace_display_name" "$marketplace_source_path"; then
    printf 'Error: failed to create or update the marketplace file.\n'
    read -r -p 'Press Enter to close...' _
    exit 1
fi

printf 'The marketing plugin and marketplace entry were prepared.\n'
printf 'Plugin: "%s"\n' "$target_plugin"
printf 'Marketplace: "%s"\n' "$marketplace_file"

read -r -p 'Install or reinstall the marketing plugin now? [y/N] ' install_plugin
if [[ "$install_plugin" =~ ^[Yy]$ ]]; then
    if ! command -v codex >/dev/null 2>&1; then
        printf 'Error: Codex CLI was not found. Files were prepared, but the plugin was not installed.\n'
        read -r -p 'Press Enter to close...' _
        exit 1
    fi

    if [[ "$scope_name" == "project" ]]; then
        if ! codex plugin marketplace add "$target_directory"; then
            printf 'Error: failed to register the project marketplace. Files were prepared.\n'
            read -r -p 'Press Enter to close...' _
            exit 1
        fi
    fi

    if ! codex plugin add "marketing@$marketplace_name"; then
        printf 'Error: failed to install the marketing plugin. Files were prepared.\n'
        read -r -p 'Press Enter to close...' _
        exit 1
    fi

    printf 'The marketing plugin was installed. Start a new conversation to use the updated plugin.\n'
else
    printf 'Plugin installation was skipped. Install it later from the Plugins Directory or Codex CLI.\n'
fi

read -r -p 'Press Enter to close...' _
