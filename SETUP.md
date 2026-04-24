# Jujutsu Kaisen 2D Game - Setup Guide

## Quick Start

1. **Open in Godot**
   - Launch Godot Engine
   - Click "Import Project"
   - Navigate to the `DuckVsGojo` folder
   - Select `project.godot`
   - Click "Import & Edit"

2. **Project will automatically load with:**
   - Main scene at `res://scenes/Main.tscn`
   - All assets in `res://assets/`
   - All scripts in `res://scripts/`

## Game Features

### Characters
- **Duck (Player 1)** - Blue and yellow duck character
- **Gojo (Player 2)** - White-haired anime character

### Gameplay Mechanics
- Each player has 100 HP
- Click to attack with sword
- Sword swings create slash effects
- Sword clashing creates visual effects
- HP bars display above each player
- Match ends when one player's HP reaches 0

### Controls

**Duck (Player 1):**
- `A` - Move Left
- `D` - Move Right
- `Space` - Attack/Swing Sword

**Gojo (Player 2):**
- `J` - Move Left
- `L` - Move Right
- `K` - Attack/Swing Sword

## File Structure

```
DuckVsGojo/
├── project.godot          # Main project configuration
├── scenes/
│   └── Main.tscn         # Main game scene with all nodes
├── scripts/
│   ├── Player.gd         # Player controller script
│   ├── Sword.gd          # Sword attack logic
│   ├── HPBar.gd          # Health bar management
│   ├── GameManager.gd    # Game state manager
│   └── InputSetup.gd     # Input configuration
├── assets/
│   ├── duckplayer.png    # Duck character sprite
│   ├── gojoplayer2.png   # Gojo character sprite
│   ├── sword.png         # Sword sprite
│   ├── hp_bar.png        # HP bar UI element
│   └── background.png    # Arena background
└── README.md             # Detailed documentation
```

## Scene Structure

The `Main.tscn` contains:

```
Main (Node2D)
├── Background (Sprite2D) - Shows arena
├── Duck (Area2D) - Player 1
│   ├── Sprite2D - Duck graphics
│   ├── CollisionShape2D - Duck hitbox
│   └── DuckSword (Area2D) - Duck's sword
│       ├── Sprite2D - Sword graphics
│       └── CollisionShape2D - Sword hitbox
├── Gojo (Area2D) - Player 2
│   ├── Sprite2D - Gojo graphics
│   ├── CollisionShape2D - Gojo hitbox
│   └── GojoSword (Area2D) - Gojo's sword
│       ├── Sprite2D - Sword graphics
│       └── CollisionShape2D - Sword hitbox
├── DuckHPBar (Control) - Duck's health bar
│   ├── Label - "HP" text
│   ├── BackgroundRect - Bar background
│   └── HealthRect - Health fill
└── GojoHPBar (Control) - Gojo's health bar
    ├── Label - "HP" text
    ├── BackgroundRect - Bar background
    └── HealthRect - Health fill
```

## Scripts Overview

### Player.gd
- Handles movement (left/right)
- Manages sword attacks
- Tracks position and HP
- Handles damage when hit by opponent's sword
- Manages attack cooldown

### Sword.gd
- Detects collision with opponent's sword
- Detects collision with opponent's body
- Applies damage when hitting
- Creates slash effect animation
- Tracks if it's currently attacking

### HPBar.gd
- Updates visual health bar
- Displays current HP
- Changes color based on health percentage
- Handles player death

### GameManager.gd
- Manages game state
- Checks for winner
- Resets game
- Handles game over

### InputSetup.gd
- Configures input actions
- Sets up key bindings
- Validates input configuration

## Customization

### Change Damage
In `Player.gd`, line ~95:
```gdscript
damage = 25  # Change this value
```

### Change Starting HP
In `Player.gd`, line ~20:
```gdscript
max_hp = 100  # Change this value
hp = max_hp
```

### Adjust Attack Speed
In `Player.gd`, line ~105:
```gdscript
attack_cooldown = 0.5  # Change this value (in seconds)
```

### Adjust Movement Speed
In `Player.gd`, line ~115:
```gdscript
speed = 300  # Change this value (in pixels per second)
```

## Troubleshooting

**Issue: Game doesn't start**
- Make sure all assets are in the `assets/` folder
- Check that `project.godot` is in the root folder
- Verify scene path in project settings: `run/main_scene="res://scenes/Main.tscn"`

**Issue: Characters don't appear**
- Check asset paths in Main.tscn
- Verify sprite images are in `res://assets/`
- Make sure collision shapes are properly configured

**Issue: Controls don't work**
- Check input mappings in `project.godot`
- Verify key bindings match your keyboard layout
- Test keys with Godot's Input event viewer

**Issue: No slash effect on hit**
- Slash effect is automatic when swords collide
- Make sure collision detection is enabled
- Verify Area2D nodes have proper collision shapes

## Running the Game

1. Open the project in Godot
2. Press the **Play** button (▶) at the top right
3. Game will start with both characters at their starting positions
4. Fight until one player's HP reaches 0
5. Winner is announced in the console

## Development Notes

- All sprites use 64x64 pixel base size (adjust in Sprite2D scale if needed)
- HP bars are positioned at top of screen
- Movement is bounded to game area
- Sword attacks have 0.5 second cooldown per player
- Game uses Area2D for collision detection (no physics)

Enjoy your fighting game!
