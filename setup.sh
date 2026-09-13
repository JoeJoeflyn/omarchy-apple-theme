#!/bin/bash
# Setup script for Omarchy Apple Theme
# Automatically installs dynamic accent hooks, background switcher integration, and fonts.

set -e

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONTS_DIR="$HOME/.local/share/fonts"
HOOKS_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$FONTS_DIR" "$HOOKS_DIR" "$BIN_DIR"

echo "==> Setting up Apple theme assets & dynamic accent..."

# 1. Install custom Apple-bitten logo font
if [[ -f "$THEME_DIR/omarchy-oligarchy.ttf" ]]; then
  cp "$THEME_DIR/omarchy-oligarchy.ttf" "$FONTS_DIR/omarchy.ttf"
  fc-cache -f "$FONTS_DIR" >/dev/null 2>&1 || true
  echo "✓ Custom Apple-bitten Omarchy logo font installed"
fi

# 2. Install dynamic accent hook for theme-set
if [[ -f "$THEME_DIR/apple-bg-accent.sh" ]]; then
  cp "$THEME_DIR/apple-bg-accent.sh" "$HOOKS_DIR/apple-bg-accent.sh"
  chmod +x "$HOOKS_DIR/apple-bg-accent.sh"
  echo "✓ Dynamic wallpaper accent hook installed"
fi

# 3. Install background switcher wrapper so bg-set triggers accent updates
cat << 'EOF' > "$BIN_DIR/omarchy-theme-bg-set"
#!/bin/bash
# Wrapper: call original bg-set then update Apple accent
/usr/share/omarchy/bin/omarchy-theme-bg-set "$@"
RET=$?

THEME_NAME=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null)
if [[ "$THEME_NAME" == "apple" ]]; then
  HOOK="$HOME/.config/omarchy/hooks/theme-set.d/apple-bg-accent.sh"
  if [[ -f "$HOOK" ]]; then
    bash "$HOOK" 2>/dev/null &
  fi
fi

exit $RET
EOF
chmod +x "$BIN_DIR/omarchy-theme-bg-set"
echo "✓ Background switcher auto-accent integration installed"

# 4. Restart shell to apply font and theme changes
omarchy-restart-shell >/dev/null 2>&1 || true

echo "✓ Apple theme installed and configured successfully!"
echo "Apply anytime with: omarchy theme set apple"
