#!/bin/bash

CONFIG_FILE="$HOME/.config/dotfiles"
DOTFILES_DIR=""

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then 
        source "$CONFIG_FILE"
    else
        echo "No configuration file found at $CONFIG_FILE. Please run '$0 init' first."
        exit 1
    fi
}

save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "DOTFILES_DIR=\"$1\"" > "$CONFIG_FILE"
    echo "DOTFILES_INDEX=\"$1/.dotfiles_index\"" >> "$CONFIG_FILE"
    echo "Configuration saved to $CONFIG_FILE"
}

init() {
    root=$1
    if [[ -z $root ]]; then
        root="$HOME/.local/share/dotfiles"
    fi

    if [[ -d $root ]]; then
        echo "$root already exists. If you want to reinitialize, please restore it first."
        exit 0
    fi

    echo "Initializing dotfiles storage in $root"
    mkdir -p "$root"
    save_config "$root"
}

add_file() {
    load_config
    file=$1

    if [[ -z "$file" ]]; then
        echo "Usage: $0 add <file>"
        exit 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "File $file does not exist."
        exit 1
    fi

    filename="$(basename "$file")"
    dest="$DOTFILES_DIR/$filename"
    link="$file"

    echo "Adding $file to dotfiles..."
    mv "$file" "$dest"
    ln -s "$dest" "$link"

    echo "$filename $link" >> "$DOTFILES_INDEX"
}

restore_file() {
    load_config
    file=$1

    if [[ -z "$file" ]]; then
        echo "Usage: $0 restore <file>"
        exit 1
    fi

    if [[ ! -L "$file" ]]; then
        echo "$file is not a symbolic link, cannot restore."
        exit 1
    fi

    filename="$(basename "$file")"
    source_file="$DOTFILES_DIR/$filename"

    if [[ ! -f "$source_file" ]]; then
        echo "Original file $source_file not found in dotfiles directory."
        exit 1
    fi

    echo "Restoring $file from dotfiles..."
    rm "$file"
    mv "$source_file" "$file"

    # 同步從 index 中刪除紀錄
    if [[ -f "$DOTFILES_INDEX" ]]; then
        tmpfile=$(mktemp)
        grep -v -F "$filename $file" "$DOTFILES_INDEX" > "$tmpfile"
        mv "$tmpfile" "$DOTFILES_INDEX"
        echo "removed entry for $filename from index."
    fi
}

restore_all() {
    load_config

    if [[ ! -f "$DOTFILES_INDEX" ]]; then
        echo "No index file found. Nothing to restore."
        exit 1
    fi

    echo "Restoring all dotfiles from index..."

    tmpfile=$(mktemp)

    while read -r filename path; do
        target="${path/#\~/$HOME}"
        source_file="$DOTFILES_DIR/$filename"

        if [[ -L "$target" && -f "$source_file" ]]; then
            echo "Restoring $target from dotfiles..."
            rm "$target"
            mv "$source_file" "$target"
            # 不寫入這筆資料到新的 index
        else
            echo "Skipping $target (not a symlink or missing source)"
            echo "$filename $path" >> "$tmpfile"  # 保留原本記錄
        fi
    done < "$DOTFILES_INDEX"

    mv "$tmpfile" "$DOTFILES_INDEX"
    echo "All valid entries restored and index updated."
}

install_dotfiles() {
    load_config

    if [[ ! -f "$DOTFILES_INDEX" ]]; then
        echo "No index file found. Nothing to install."
        exit 0
    fi

    echo "Installing dotfiles from index..."

    while read -r filename path; do
        target="${path/#\~/$HOME}"
        source_file="$DOTFILES_DIR/$filename"

        if [[ -e "$target" ]]; then
            echo "Skipping $target (already exists)"
        else
            mkdir -p "$(dirname "$target")"
            ln -s "$source_file" "$target"
            echo "Linked $source_file -> $target"
        fi
    done < "$DOTFILES_INDEX"
}

list_dotfiles() {
    load_config
    if [[ ! -f "$DOTFILES_INDEX" ]]; then
        echo "No index file found."
        exit 0
    fi
    cat "$DOTFILES_INDEX"
}

fix_index() {
    load_config

    echo "Rebuilding dotfiles index at $DOTFILES_INDEX ..."
    > "$DOTFILES_INDEX"  # 清空 index 檔

    find "$DOTFILES_DIR" -type f ! -path "$DOTFILES_INDEX" | while read -r file; do
        filename="$(basename "$file")"

        # 找出家目錄下指向該 dotfile 的符號連結
        link_target=$(find "$HOME" -type l -lname "$file" 2>/dev/null | head -n 1)

        if [[ -n "$link_target" ]]; then
            link_display="${link_target/#$HOME/~}"
            echo "$filename $link_display" >> "$DOTFILES_INDEX"
            echo "Indexed: $filename $link_display"
        else
            echo "Warning: No symlink found for $filename"
        fi
    done
}

case $1 in
    init)
        init "$2"
        ;;
    add)
        add_file "$2"
        ;;
    restore)
        if [[ "$2" == "-a" ]]; then
            restore_all
        else
            restore_file "$2"
        fi
        ;;
    install)
        install_dotfiles
        ;;
    list)
        list_dotfiles
        ;;
    fix)
        fix_index
        ;;
    *)
        echo "Usage: $0 <command>"
        echo "Commands:"
        echo "  init [root]     - Initialize dotfiles storage (default: $HOME/.local/share/dotfiles)"
        echo "  add <file>      - Add a file to dotfiles"
        echo "  restore <file>  - Restore specific file from dotfiles"
        echo "  restore -a      - Restore all tracked dotfiles"
        echo "  install         - Install dotfiles"
        echo "  list            - List tracked dotfiles and their target paths"
        echo "  fix             - Rebuild index file from symlinks and dotfile storage"
        ;;
esac
