# Game Mechanics Documentation  
_Last updated: 2026-04-25_

---

## Viewport & World Layout

| Property | Value |
|---|---|
| Viewport | 800 × 600 px |
| Ground Y | 535 px (player feet level) |
| Player spawn P1 | (200, 520) |
| Player spawn P2 | (600, 520) |
| Boundary X | 50 – 750 px |

### Platforms (jump-able)
| Name | Position | Top face Y | Reachable from |
|---|---|---|---|
| Platform1 (left) | (155, 470) | 460 | Ground — 1 jump |
| Platform2 (right) | (645, 470) | 460 | Ground — 1 jump |
| Platform3 (center-high) | (400, 395) | 385 | Ground — double jump |

---

## Movement & Jump Physics

| Property | Value |
|---|---|
| Move speed | 200 px/s |
| Gravity | 800 px/s² |
| Jump force | −350 px/s |
| Max jumps | 2 (double jump) |
| Single jump reach | ~77 px above ground |
| Double jump reach | ~153 px above ground |

Floor detection uses CharacterBody2D `is_on_floor()` — players land on Ground, Platform1, Platform2, and Platform3 via physics collision.

---

## Combat System

### Player Attacks (both modes)
| Attack | Key P1 | Key P2 | Damage | Cooldown | Range |
|---|---|---|---|---|---|
| Punch | V | I | 10 HP | 0.25 s | 45 px |
| Special | B | O | 25 HP | 1.5 s | varies |
| Ultimate | N | P | 20 HP | 10 s | 160 px |
| Cursed Burst (P1) / Blue Pull (P2) | L | M | 15–20 HP | 3 s | 90–150 px |

### Hit Detection
- All attacks use distance + facing direction checks (no physics overlap)
- Punch: checks `punch_range = 45 px` + must be facing target
- Specials/Ultimates: area-of-effect radius checks

---

## Minion System (Survival Mode only)

- Spawns every 3 s from left/right edges (max 8 on screen)
- Minions **walk toward the nearest player**
- Minions **do NOT deal contact damage** — they are targets only
- Players must **actively hit minions** to kill them (punch, special, ultimate)
- Killing a minion awards +15 score to the attacker
- Minions use manual floor tracking (floor_y = 520), stay at ground level

### Why no contact damage?
Minions serve as moving score targets. Contact damage was removed so players can focus on fighting each other while also managing the crowd — making survival mode a skill test, not a passive damage race.

---

## HP System

### Health Bar Display
- Positioned at top of screen
- Shows 100 HP maximum per player
- Color coding (set in GameManager):
  - Green: 75–100 HP (healthy)
  - Yellow: 50–74 HP (damaged)
  - Red: 0–49 HP (critical)

### Damage Application
```
On sword hit:
1. Check collision between swords
2. Check collision between sword and opponent
3. Apply damage if sword-body collision
4. Update HP bar visually
5. Check if opponent HP <= 0
6. If HP <= 0: Game Over
```

### Death Condition
- HP reaches or falls below 0
- Game displays winner
- Game state frozen (no more inputs)
- Restart available through console

## Visual Effects

### Slash Effect
- Appears when sword collides with opponent's sword
- Animated line/streak following sword motion
- Duration: 0.3 seconds
- Color: White with transparency fade

### Hit Flash
- Opponent character briefly flashes white on hit
- Duration: 0.1 seconds
- Indicates successful damage
- Used for visual feedback

### Sword Rotation
- Sword rotates 180 degrees during attack
- Smooth animation over 0.3 seconds
- Returns to idle position
- Shows attack direction

## Game States

### Active Game
- Both players can move
- Both players can attack
- HP bars update in real-time
- Music/sounds play (if implemented)

### Game Over
- No inputs accepted
- Winner declared
- Game frozen at end position
- Must restart through Godot editor

## Advanced Mechanics (Expandable)

### Potential Additions
1. **Blocking System**
   - Hold button to block attacks
   - Reduce damage taken
   - Can't attack while blocking

2. **Special Moves**
   - Charge attack for more damage
   - Area attack hitting both swords
   - Knockback on successful hit

3. **Combo System**
   - Multiple hits in sequence
   - Increasing damage multiplier
   - Reset on miss or block

4. **Stamina System**
   - Limited attacks per time period
   - Regen over time
   - Prevents spam attacks

5. **Power-ups**
   - Temporary damage boost
   - Health recovery
   - Speed increase
   - Invincibility frames

## Physics

### No Physics Engine
- Game uses Area2D collision detection only
- No gravity or realistic physics
- Simplified 2D movement
- Frame-based animation

### Collision Areas
```
Duck/Gojo (Area2D)
└── CollisionShape2D (Rectangle 64x64)

Duck/GojoSword (Area2D)
└── CollisionShape2D (Rectangle 32x128)
```

### Collision Groups
- "player1" - Duck character
- "player2" - Gojo character
- "sword1" - Duck's sword
- "sword2" - Gojo's sword

## Balance Values

### Can Be Customized
```gdscript
# In Player.gd
max_hp = 100           # Starting health
damage = 25            # Damage per hit
attack_cooldown = 0.5  # Seconds between attacks
speed = 300            # Pixels per second movement
```

### Suggested Balance Changes
- Increase `attack_cooldown` to 1.0 for slower, more tactical fights
- Decrease `damage` to 15 for longer matches (7 hits to win)
- Increase `speed` to 400 for faster, more mobile gameplay
- Add armor reduction: `damage = 25 * 0.8` = 20 damage

## Script Interaction Flow

```
Main Scene (Node2D)
    ↓
Player.gd (attached to Duck and Gojo)
    ├─→ _input() - Reads keyboard input
    ├─→ _process() - Updates position
    ├─→ attack() - Handles sword swing
    └─→ take_damage() - Receives damage
    
Sword.gd (attached to DuckSword and GojoSword)
    ├─→ _on_area_entered() - Collision detection
    ├─→ create_slash_effect() - Visual feedback
    └─→ deal_damage() - Applies damage

HPBar.gd (attached to DuckHPBar and GojoHPBar)
    ├─→ update_hp_display() - Visual update
    └─→ _on_player_damaged() - Signal response

GameManager.gd (attached to Main)
    ├─→ check_game_over() - Victory condition
    └─→ restart_game() - Reset state
```

## Networking (Not Implemented)

For multiplayer over network:
1. Use Godot's built-in MultiplayerAPI
2. Sync player positions via RPC
3. Sync HP values via networked variables
4. Use high-frequency updates (60 Hz)

## Performance Notes

- Game runs at 60 FPS target
- Minimal draw calls (5 sprites + UI)
- No complex calculations
- Suitable for low-end devices
- Can support 2+ players locally

---

For questions or modifications, refer to SETUP.md and script comments.
