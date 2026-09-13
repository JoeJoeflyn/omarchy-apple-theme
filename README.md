# Apple — Omarchy Theme

An Apple-inspired theme for [Omarchy](https://omarchy.org/). Graphite surfaces with Apple system colors, a custom apple-bitten Omarchy logo, and dynamic accent colors that match each of 26 Apple product/finish wallpapers.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/e9eade81-a171-4d5a-92c0-c17ca448f798" />

## Features

- **Graphite accent** (`#A8A8AA`) by default — Apple's signature neutral
- **26 Apple wallpapers** — Black, Space Gray, Silver, Starlight, White, Gold, Rose Gold, Midnight, Blue, Sky Blue, Purple, Pink, Product Red, Orange, Yellow, Green, Mint, Teal, Graphite, Deep Purple, Sierra Blue, Alpine Blue, Natural, Titanium, and more
- **Dynamic accent** — cycling backgrounds automatically updates the accent color, cursor, keyboard, mouse, and bar logo to match the wallpaper's dominant color
- **Apple-bitten Omarchy logo** — custom TTF font (`omarchy-oligarchy.ttf`) with the Omarchy square + apple bite + leaf at `\ue900`
- **Rounded borders** — 10px window rounding for a macOS feel
- **Apple system colors** — magenta, cyan, blue, green, red, yellow, orange, brown

## Install

### Option 1: Via Omarchy CLI
```bash
omarchy theme install https://github.com/JoeJoeflyn/omarchy-apple-theme
```

### Option 2: Apply Manually
```bash
omarchy theme set apple
```

## Wallpapers

Includes 26 Apple product and finish wallpapers out of the box. Cycle backgrounds with `omarchy theme bg next` or press `Ctrl + Super + Space` to open the background switcher — the accent color updates automatically.

To add your own custom wallpapers, place them in `~/.config/omarchy/backgrounds/apple/`.
