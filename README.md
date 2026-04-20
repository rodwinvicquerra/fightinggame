# Duck vs Gojo - Fighting Game

A 2D pixel art fighting game built with Godot 4.2 featuring Duck and Gojo characters with sword combat mechanics.

## Features

✅ Two-player local fighting game
✅ Sword combat with slash effects
✅ Real-time HP bar system
✅ Character collision and damage system
✅ Smooth animations and visual feedback
✅ Game over detection and restart functionality

## Game Controls

### Player 1 (Duck)
- **Move Left**: Arrow Key ← or A
- **Move Right**: Arrow Key → or D
- **Attack**: SPACE

### Player 2 (Gojo)
- **Move Left**: J Key
- **Move Right**: L Key
- **Attack**: K Key

## Project Structure

```
DuckVsGojo/
├── assets/
│   ├── background.png      # Game arena background
│   ├── duckplayer.png      # Duck character sprite
│   ├── gojoplayer2.png     # Gojo character sprite
│   ├── hp_bar.png          # HP bar UI element
│   └── sword.png           # Sword weapon sprite
├── scripts/
│   ├── Player.gd           # Player character script
│   ├── Sword.gd            # Sword attack mechanics
│   ├── GameManager.gd      # Game state management
│   └── HPBar.gd            # HP bar UI management
├── scenes/
│   └── Main.tscn           # Main game scene
├── project.godot           # Godot project configuration
└── README.md               # This file
```

## Game Mechanics

### Combat System
- Each player has 100 HP
- Sword attacks deal 15 damage
- Attack cooldown is 0.5 seconds
- Attacks are only effective when the opponent is in range

### Visual Effects
- **Slash Effects**: Yellow star-burst pattern when sword connects
- **Hit Flash**: Red flash on the character when taking damage
- **Sword Animation**: Sword swings during attacks
- **Death Animation**: Character fades and shrinks when defeated

### Win Condition
- First player to reduce opponent's HP to 0 wins
- Game displays winner message
- Press SPACE to restart

## How to Run in Godot

1. Open Godot Engine 4.2 or later
2. Click "Open Project" and select this folder
3. The project will load automatically
4. Click "Run" or press F5 to start the game
5. Open scenes/Main.tscn to edit the game scene

## Customization

You can adjust game balance by editing these values in `scripts/Player.gd`:

```gdscript
@export var max_health: int = 100
@export var move_speed: float = 200.0
@export var attack_damage: int = 15
@export var attack_cooldown: float = 0.5
```

## Technical Details

- **Engine**: Godot 4.2
- **Language**: GDScript
- **Physics**: Godot Physics 2D
- **Resolution**: 800x600 pixels
- **Pixel Art Sprites**: Scaled 2x for visibility

## Future Enhancements

- [ ] Special attack abilities
- [ ] Character cooldown visual indicators
- [ ] Sound effects and music
- [ ] Combo system
- [ ] Additional characters
- [ ] Network multiplayer support
- [ ] AI opponent mode

## Credits

- Game developed with Godot Engine
- Character and asset design
- Sword combat mechanics inspired by classic fighting games

---

**Ready to play? Open this project in Godot and press F5 to start!**
