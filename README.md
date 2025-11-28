# ZenPlates v2.0

**Hyperminimalist brutalist nameplates for WoW 3.3.5a**

## Features

### Visual & Aesthetics
- **Class Colors**: Health bars colored by unit class for instant recognition
- **Brutalist Design**: Sharp edges, high contrast, monochromatic with functional accent colors
- **Hidden Unit Types**: Filter out totems, critters, and other clutter
- **Elite/Rare Indicators**: Clear "+" and "R" markers on nameplates

### Health Display
- **Health Percentage**: Shows health % when not at full health
- **Health Values**: Estimated health values based on damage dealt
- **Smart Formatting**: Numbers formatted as 1.2k, 1.5M for readability

### Target Features
- **Zoom Effect**: Current target scales up for easy identification
- **Glow Effect**: Pulsing glow around target nameplate
- **Configurable**: Adjust zoom scale and glow intensity

### Debuff System
- **Debuff Display**: Shows debuffs below each nameplate
- **Duration Timers**: Built-in database of debuff durations with countdown
- **Debuff Cache**: Remembers debuffs when unit is not targeted
- **Smart Filtering**: Show all debuffs, only yours, or important ones

### Combat Features
- **Combo Points**: Display combo points on target (Rogue/Druid)
- **Cast Bars**: Clean, brutalist-styled cast bars with spell icons
- **Combat Detection**: Health tracking based on damage events

### Unit Filtering
- **Totem Hiding**: Hide all shaman totems
- **Critter Hiding**: Filter out ambient critters
- **Custom Hide List**: Add specific unit names to hide

### Vanilla QoL
- **Non-Overlapping Plates**: Nameplates stack cleanly (configurable)
- **Slash Commands**: `/zenplates` to open config, `/zenplates reset` to reset settings

## Installation

1. Extract the `ZenPlates-dev` folder to `World of Warcraft/Interface/AddOns/`
2. Rename to `ZenPlates` if desired
3. Restart WoW or `/reload` if game is running
4. Type `/zenplates` to configure

## Configuration

Open the options panel with `/zenplates` or via Interface > AddOns > ZenPlates

### Settings Categories

**General**
- Toggle class colors
- Show/hide health percentage
- Show/hide health values
- Elite indicator toggle

**Target Effects**
- Enable/disable zoom effect
- Adjust zoom scale (1.0 - 1.5)
- Enable/disable glow effect

**Debuffs**
- Show/hide debuffs
- Toggle duration timers
- Enable debuff cache
- Filter options (all/mine/important)

**Combat**
- Show/hide combo points (Rogue/Druid only)

**Unit Filters**
- Hide specific unit types
- Manage custom hide list

## Architecture

ZenPlates uses a modular architecture for maintainability:

```
ZenPlates/
  ├── ZenPlates.lua        # Namespace initialization
  ├── ZenPlates.toc        # Addon manifest
  ├── Modules/
  │   ├── Core.lua         # Main initialization & scanning
  │   ├── Config.lua       # Configuration system
  │   ├── Utils.lua        # Shared utilities
  │   ├── Health.lua       # Health bar styling & tracking
  │   ├── Debuffs.lua      # Debuff system
  │   ├── Target.lua       # Target effects
  │   ├── CastBar.lua      # Cast bar styling
  │   ├── Combat.lua       # Combo points & combat
  │   ├── Filters.lua      # Unit filtering
  │   └── Options.lua      # Configuration UI
  └── Database/
      └── Debuffs.lua      # Debuff duration database
```

## Known Limitations

- **Health Values**: Calculated from damage dealt, not 100% accurate
- **Debuff Durations**: Based on database, may not account for talents/glyphs
- **Class Detection**: Difficult on NPCs, defaults to reaction colors

## Commands

- `/zenplates` - Open configuration panel
- `/zenplates reset` - Reset all settings to defaults

## Credits

Created for WoW 3.3.5a with a focus on hyperminimalist brutalist aesthetics.

## Version History

**v2.0** - Complete rewrite with modular architecture
- Added debuff tracking system
- Added target zoom/glow effects
- Added combo point display
- Added unit filtering
- Added comprehensive options panel
- Implemented brutalist design aesthetic

**v1.0** - Initial basic nameplate skinning
