#!/bin/bash
# When the Apple theme's background changes, update the accent color to match

THEME_NAME=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null)
[[ "$THEME_NAME" == "apple" ]] || exit 0

BG=$(readlink -f "$HOME/.local/state/omarchy/current/background" 2>/dev/null)
[[ -f "$BG" ]] || exit 0

# Extract dominant color from the background
HEX=$(/usr/bin/python3 -c "
from PIL import Image
import colorsys
img = Image.open('$BG').convert('RGB').resize((50, 50))
best = None
best_score = 0
for y in range(img.height):
    for x in range(img.width):
        r, g, b = img.getpixel((x, y))
        h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
        if s > 0.15 and v > 0.2:
            score = s * v
            if score > best_score:
                best_score = score
                best = (r, g, b)
if best is None:
    best = img.resize((1, 1)).getpixel((0, 0))
r, g, b = best
print(f'{r:02X}{g:02X}{b:02X}')
" 2>/dev/null)

[[ "$HEX" =~ ^[0-9A-Fa-f]{6}$ ]] || exit 0

# Get the old accent BEFORE updating, so we know what to replace in shell.toml
COLORS="$HOME/.local/state/omarchy/current/theme/colors.toml"
OLD_ACCENT=$(grep "^accent" "$COLORS" 2>/dev/null | sed 's/.*= *"#\([0-9A-Fa-f]*\)".*/\1/')

# Update accent in staged colors.toml
if [[ -f "$COLORS" ]]; then
  sed -i "s/^accent = \".*\"/accent = \"#$HEX\"/" "$COLORS"
fi

# Update keyboard.rgb
echo "#$HEX" > "$HOME/.local/state/omarchy/current/theme/keyboard.rgb"

# Update hyprland borders (only active border, preserve inactive border #2C2C2E)
HYPR="$HOME/.local/state/omarchy/current/theme/hyprland.lua"
if [[ -f "$HYPR" ]]; then
  sed -i -E "s/^local active_border_color = .*/local active_border_color = \"#$HEX\"/" "$HYPR"
  sed -i -E "s/active_border = \"rgb\([0-9A-Fa-f]+\)\"/active_border = \"rgb($HEX)\"/" "$HYPR"
  sed -i -E "s/border_active = \"rgb\([0-9A-Fa-f]+\)\"/border_active = \"rgb($HEX)\"/" "$HYPR"
  sed -i -E "s/active = \"rgba\([0-9A-Fa-f]+99\)\"/active = \"rgba(${HEX}99)\"/" "$HYPR"
fi

# Update shell.toml - only replace old accent with new accent, NOT bar background/text
SHELL="$HOME/.local/state/omarchy/current/theme/shell.toml"
if [[ -f "$SHELL" ]] && [[ "$OLD_ACCENT" =~ ^[0-9A-Fa-f]{6}$ ]]; then
  sed -i "s/#$OLD_ACCENT/#$HEX/g" "$SHELL"
fi

# Optional hardware/cursor sync hooks if present
if [[ -f "$HOME/.config/omarchy/hooks/theme-set.d/asus-tuf-kbd-sync.sh" ]]; then
  bash "$HOME/.config/omarchy/hooks/theme-set.d/asus-tuf-kbd-sync.sh" 2>/dev/null &
fi

BG_IDX=$(basename "$BG" | sed 's/\..*//')
if [[ -f "$HOME/.config/omarchy/hooks/theme-set.d/cursor-theme-reflect.sh" ]]; then
  bash "$HOME/.config/omarchy/hooks/theme-set.d/cursor-theme-reflect.sh" "apple-$BG_IDX" 2>/dev/null &
fi

# Push updated colors to the running shell via IPC
if [[ -f "$COLORS" && -f "$SHELL" ]]; then
  colors_payload=$(base64 -w 0 "$COLORS")
  shell_payload=$(base64 -w 0 "$SHELL")
  timeout 2 omarchy-shell shell applyTheme "$colors_payload" "$shell_payload" >/dev/null 2>&1 &
fi

# Reload hyprland
hyprctl reload 2>/dev/null &
