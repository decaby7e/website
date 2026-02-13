#!/bin/bash

# TODO: remove all machine-specific config from here

# 1. Environment & Paths
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"

if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    notify-send "Error" ".env not found"
    exit 1
fi

# 2. Get existing post names for autocomplete
EXISTING_POSTS=$(ls content/blog/*.md 2>/dev/null | xargs -n 1 basename | sed 's/\.md$//')

# 3. Rofi Interface
RAW_INPUT=$(echo "$EXISTING_POSTS" | rofi -dmenu \
    -p "📝 Post Title" \
    -theme "$HOME/.config/polybar/scripts/rofi/launcher.rasi" \
    -theme-str 'window {width: 450px;} listview {lines: 5;} entry {font: inherit; text-color: inherit;}' \
    -no-config \
    -mesg "Type a new name or select existing to edit")

[ -z "$RAW_INPUT" ] && exit 0

# 4. Sluggify input
POST_NAME=$(echo "$RAW_INPUT" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')

# 5. Path Setup
FILE_REL="content/blog/${POST_NAME}.md"
ABS_POST_PATH="$SCRIPT_DIR/$FILE_REL"

# 6. Logic: Create if new, just open if exists
if [ ! -f "$ABS_POST_PATH" ]; then
    ./hugo.sh new "$FILE_REL"
    IMG_DIR="$POST_IMAGE_DIRECTORIES_ROOT/$POST_NAME"
    mkdir -p "$IMG_DIR"
    notify-send "Created New Post" "$POST_NAME"
else
    notify-send "Opening Existing Post" "$POST_NAME"
fi

# 7. Clipboard: Public URL Link
FULL_IMG_URL="${IMAGE_WEB_ACCESS}${POST_NAME}/"
echo -n "![]($FULL_IMG_URL)" | xclip -selection clipboard

# 8. Launch Hugo Server & Browsers
if ! pgrep -f "hugo server" > /dev/null; then
    kitty --detach ./serve.sh
    sleep 1.5 # Wait for Hugo to initialize before opening browser
fi

# Open Localhost Preview
xdg-open "http://localhost:1313/blog/${POST_NAME}/"

# Open the files.lan gallery for this post
xdg-open "$FULL_IMG_URL"

# 9. Open Obsidian
ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$ABS_POST_PATH', safe=''))")
xdg-open "obsidian://open?path=$ENCODED_PATH"
