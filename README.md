# Project-Rebirth

A game project developed with LÖVE2D (Lua framework).

## Description

Project-Rebirth is a game created as part of the IPSSI first-year curriculum. You control a character in an action-oriented environment, moving freely and casting spells against enemies.

### Gameplay

Project-Rebirth is a top-down action roguelike where you control a character with magical abilities. Navigate through procedurally generated levels, defeat enemies using spells and melee attacks, and progress through increasingly challenging stages.

**Game Features:**
- **Procedural Level Generation**: 8 different map layouts randomly selected each level
- **Resource Management**: Balance HP (Health Points) and MP (Mana Points)
- **Spell Casting System**: Two distinct spells with different properties
- **Enemy AI**: Intelligent pathfinding using A* algorithm
- **Progressive Difficulty**: Levels get harder as you advance (3-6 enemies per level)

### Spells

- **Fireball** (`E` key)
  - Damage: 30
  - Mana Cost: 10
  - High damage, moderate speed projectile
  - Perfect for dealing with tough enemies

- **Ice Shard** (`A` key)
  - Damage: 15
  - Mana Cost: 10
  - Fast, precise projectile
  - Ideal for quick, agile enemies

### Enemies

- **Monster A** (Red): 30 HP, 10 damage
- **Monster B** (Green): 50 HP, 15 damage - tougher variant

### Game Mechanics

- **Mana Regeneration**: Automatically regenerates at 10 MP/second
- **Maximum HP**: 256
- **Maximum MP**: 256
- **Melee Attack**: Close-range attack in aimed direction
- **Victory Condition**: Defeat all enemies to progress to the next level

### Controls

- **Movement**: `Z`, `Q`, `S`, `D` (WASD)
- **Aim**: Arrow keys (UP, DOWN, LEFT, RIGHT)
- **Cast Spells**: 
  - `E` - Fireball (Primary spell)
  - `A` - Ice Shard (Secondary spell)
- **Melee Attack**: `Space` - Close-range attack
- **Quit Game**: `Escape`

## Requirements

- [LÖVE2D](https://love2d.org/) framework (version 11.5 or higher)
- Recommended window resolution: 1344 x 840 pixels

## Installation

1. Clone this repository
2. Install LÖVE2D from [https://love2d.org/](https://love2d.org/)
3. Run the game using LÖVE

## How to Run

### Windows
```bash
love "path/to/Project-Rebirth"
```

Or drag the project folder onto the LÖVE executable.

### macOS/Linux
```bash
love .
```

(Run from within the project directory)

## Project Structure

- [main.lua](main.lua) - Entry point, game loop (load, update, draw)
- [conf.lua](conf.lua) - LÖVE2D configuration (window size, title, version)
- [game_state.lua](game_state.lua) - Global state variables (player, enemies, projectiles, HP/MP)
- [game_logic.lua](game_logic.lua) - Game mechanics (collision, pathfinding, spell casting, level generation)
- [game_render.lua](game_render.lua) - All rendering functions (entities, UI, menus)
- [game_data.lua](game_data.lua) - Game constants and definitions (spells, enemies, maps)
- `assets/` - Game assets (currently empty - ready for images, sounds, etc.)

## Development

This project was developed as part of the IPSSI first-year curriculum by a collaborative team of 7 developers.

### Key Features Implemented

- Modular code architecture (separated logic, rendering, state, and data)
- Procedural level generation with 8 unique map layouts
- A* pathfinding algorithm for enemy AI
- Dual spell system with projectile physics
- Resource management (HP/MP) with regeneration
- Game over and restart menu system

### Contributors

- [Truyên Duc](https://github.com/letruyenduc)
- [Ariel](https://github.com/Orora667)
- [Alexandru](https://github.com/idleCyrex)
- Clément
- [Daria](https://github.com/dd0306)
- David
- Alexandre

## License

All rights reserved.
