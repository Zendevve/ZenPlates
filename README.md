# ZenPlates

**Brutalist nameplate addon for World of Warcraft 3.3.5a**

## Philosophy

ZenPlates embraces a **brutalist design philosophy**: minimal, functional, and unapologetically raw. No bloat, no configuration menus, no unnecessary features. Just clean, flat nameplates that work.

**Plug and play.** Install it, forget it, focus on the game.

## Features

### Core Design
- **Flat, minimal bars** - Brutalist aesthetic with high-contrast styling
- **Threat-based coloring** - Red for enemies, green for friendlies, yellow for aggro
- **Distance-based sorting** - Closer plates render on top
- **Retail-style stacking** - Overlapping plates automatically separate vertically

### Smart Modules
- **Custom Target Glow** - Thin red border on your current target
- **Class Icons** - Automatically displays class icons for players
- **Arena/Party IDs** - Shows arena numbers (1-5) and party numbers in arenas
- **TotemPlates** - Important totems (Tremor, Grounding, etc.) show as icons instead of bars
- **Blacklist** - Automatically hides nuisance units (Army of the Dead, snakes, etc.)
- **Barless Friendly** - Friendly nameplates show only names, no health bars

### Click-Through
- Totems are click-through by default
- Blacklisted units are click-through
- Friendly click-through can be enabled via SavedVariables

## Installation

1. Download the latest release
2. Extract to `Interface\AddOns\`
3. Restart WoW
4. Done. No configuration needed.

## Configuration

ZenPlates is designed to be plug-and-play. Advanced users can modify defaults in `Core\Constants.lua` or edit `ZenPlatesDB` SavedVariables directly.

**Available options:**
- `clickThroughFriendly` - Set to `true` to disable clicking friendly nameplates (default: `false`)

## Technical Details

- **Zero external dependencies** - Pure Lua, no libraries
- **Modular architecture** - Clean separation of concerns across modules
- **Lightweight** - Minimal performance overhead
- **3.3.5a native** - Built specifically for WotLK, no retail backports

## License

MIT License - do whatever you want with it.

## Credits

Created by [Antigravity](https://github.com/Zendevve) with a focus on simplicity and performance.
