#!/usr/bin/env bash
# Script to quickly disable/enable Neovim plugins for debugging

PLUGIN_DIR="/Users/wm/nix-config/home/programs/editors/neovim/lua/plugins"

usage() {
    echo "Usage: $0 [disable|enable|list|status] [plugin-name]"
    echo ""
    echo "Commands:"
    echo "  disable <name>  - Disable a plugin (rename to .disabled)"
    echo "  enable <name>   - Enable a plugin (remove .disabled)"
    echo "  list            - List all plugins"
    echo "  status          - Show disabled plugins"
    echo "  disable-all     - Disable all non-essential plugins"
    echo "  enable-all      - Enable all plugins"
    echo ""
    echo "Examples:"
    echo "  $0 disable treesitter"
    echo "  $0 enable treesitter"
    echo "  $0 disable-all"
    exit 1
}

list_plugins() {
    echo "Available plugins:"
    cd "$PLUGIN_DIR" || exit 1
    find . -name "*.lua" -not -path "*/colorschemes/*" | sed 's|^\./||' | sed 's|\.lua$||' | sort
}

show_status() {
    echo "Disabled plugins:"
    cd "$PLUGIN_DIR" || exit 1
    find . -name "*.disabled" | sed 's|^\./||' | sed 's|\.disabled$||' | sort
    
    echo ""
    echo "Active plugins:"
    find . -name "*.lua" -not -path "*/colorschemes/*" | sed 's|^\./||' | sed 's|\.lua$||' | sort
}

disable_plugin() {
    local plugin="$1"
    local file="$PLUGIN_DIR/${plugin}.lua"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: Plugin '$plugin' not found at $file"
        exit 1
    fi
    
    if [[ -f "${file}.disabled" ]]; then
        echo "Plugin '$plugin' is already disabled"
        exit 0
    fi
    
    mv "$file" "${file}.disabled"
    echo "✓ Disabled: $plugin"
}

enable_plugin() {
    local plugin="$1"
    local file="$PLUGIN_DIR/${plugin}.lua.disabled"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: Plugin '$plugin' is not disabled or doesn't exist"
        exit 1
    fi
    
    mv "$file" "${file%.disabled}"
    echo "✓ Enabled: $plugin"
}

disable_all() {
    # Essential plugins to keep enabled
    local essential=(
        "colorscheme"
        "lsp"
        "mason"
        "which-key"
    )
    
    echo "Disabling all non-essential plugins..."
    cd "$PLUGIN_DIR" || exit 1
    
    for file in *.lua; do
        [[ "$file" == "*.lua" ]] && continue
        plugin="${file%.lua}"
        
        # Skip if essential
        if printf '%s\n' "${essential[@]}" | grep -q "^${plugin}$"; then
            echo "  Keeping: $plugin (essential)"
            continue
        fi
        
        # Skip if already disabled
        [[ -f "${file}.disabled" ]] && continue
        
        mv "$file" "${file}.disabled"
        echo "  Disabled: $plugin"
    done
    
    echo ""
    echo "✓ Done! Only essential plugins remain."
    echo "Start nvim and test. If it works, enable plugins one by one."
}

enable_all() {
    echo "Enabling all plugins..."
    cd "$PLUGIN_DIR" || exit 1
    
    for file in *.disabled; do
        [[ "$file" == "*.disabled" ]] && continue
        plugin="${file%.lua.disabled}"
        mv "$file" "${file%.disabled}"
        echo "  Enabled: $plugin"
    done
    
    echo "✓ All plugins enabled"
}

# Main
case "${1:-}" in
    disable)
        [[ -z "$2" ]] && usage
        disable_plugin "$2"
        ;;
    enable)
        [[ -z "$2" ]] && usage
        enable_plugin "$2"
        ;;
    list)
        list_plugins
        ;;
    status)
        show_status
        ;;
    disable-all)
        disable_all
        ;;
    enable-all)
        enable_all
        ;;
    *)
        usage
        ;;
esac
