# Game Improvement Plan — DuckVsGojo (JJK 2D)
_Prioritized suggestions to make the game more realistic, fun, and polished._

---

## ✅ Already Done (this session)
| # | What | Why |
|---|---|---|
| 1 | `background.new.png` as battlefield (scale 1.667×) | Fills 800×600, no black bars |
| 2 | Players moved to y=520 (ground level) | Characters stand ON the ground, not floating mid-screen |
| 3 | Added 3 platforms (left y=460, right y=460, center y=385) | Vertical combat dimension, more dynamic fights |
| 4 | Ground `StaticBody2D` — players use `is_on_floor()` | Real physics collision, platforms actually work |
| 5 | Minion contact damage removed | Minions are targets — only die when HIT, never damage players on touch |

---

## 🔴 HIGH PRIORITY — Core Feel

### H1. Knockback on Hit
**What:** When a punch/special lands, push the target backward.  
**Why:** Hugely improves "game feel" — hits feel impactful, creates spacing pressure.  
**How:** In `Player.gd` → `take_damage()`, add:
```gdscript
func take_damage(amount: int, attacker: Node = null):
    health -= amount
    # Knockback
    if attacker:
        var kb_dir = sign(global_position.x - attacker.global_position.x)
        velocity.x = kb_dir * 250
        velocity.y = -120  # small upward pop
```

### H2. Attack Animations (squash & stretch)
**What:** Scale sprite during punch/special — already has a small squash, expand it.  
**Why:** Snappier feel. The current 1.15× scale barely registers.  
**How:** Change to 1.3× X-scale + 0.8× Y-scale on punch, return over 0.1 s.

### H3. Screen Shake on Ultimate/Heavy Hits
**What:** Shake the camera (Node2D position offset) for 0.2 s on ultimates.  
**Why:** Makes big moves feel powerful.  
**How:** Add a `Camera2D` to the scene, tween position ±8px rapidly on trigger.

### H4. Proper Sprite-Based Animations (AnimatedSprite2D)
**What:** Replace static sprites with sprite sheets / animation frames.  
**Why:** Characters feel alive — idle sway, walk cycle, attack windup.  
**How:** Import spritesheet, use `AnimatedSprite2D` with states: `idle`, `run`, `jump`, `attack`, `hurt`, `dead`.

---

## 🟡 MEDIUM PRIORITY — Game Depth

### M1. Health Regen Between Rounds (Survival)
**What:** Slowly restore HP (e.g., +1 HP/s) to reward staying alive.  
**Why:** Long survival mode matches feel punishing with no recovery.

### M2. Minion Variety (2 types)
**What:** Fast-weak minion (speed 90, hp 10) vs. slow-heavy minion (speed 35, hp 40).  
**Why:** Forces players to prioritise targets — more strategic.

### M3. Platform Hazards (Cursed Energy Zone)
**What:** Add a `cursed_zone` area on one platform that ticks 2 HP/s to any player standing on it.  
**Why:** Controls map flow — don't camp the high platform forever.

### M4. Wall Bounce
**What:** When player hits left/right screen boundary while moving fast, bounce back slightly.  
**Why:** Avoids corner-trapping, more dynamic movement.

### M5. Combo Counter UI
**What:** Track consecutive hits without the opponent landing a counter-hit. Display `2 HIT COMBO!`, `3 HIT!`, etc.  
**Why:** Rewards aggressive play and gives visual excitement.

### M6. Round System (Best of 3)
**What:** Track wins per player across multiple rounds, reset HP/position per round.  
**Why:** A single round is often over in <30 s. Best-of-3 adds stakes.

---

## 🟢 LOW PRIORITY — Polish & Realism

### L1. Parallax Background Layers
**What:** Add a second far-background layer moving at 50% player speed.  
**Why:** Creates depth/parallax effect — battlefield feels 3D.  
**How:** Add a CanvasLayer at layer=0 with a wide background strip; multiply x-scroll by 0.5.

### L2. Shadow Under Players
**What:** A small ellipse `ColorRect` or `Sprite2D` scaled flat at the player's feet.  
**Why:** Huge realism boost — players look grounded instead of floating.  
**How:** Add a semi-transparent dark oval child node at y=+15, scale with jump height.

### L3. Sound Effects
**What:** Punch, jump, land, special, game-over sounds.  
**Why:** Audio is 50% of game feel.  
**How:** Add `AudioStreamPlayer2D` nodes, load `.wav`/`.ogg` files, call `play()` at each event.

### L4. Particle Dust on Walk
**What:** Occasional small dust particle spawned at feet when moving.  
**Why:** Reinforces ground contact, character feels weighted.

### L5. HP Bar Color Animation
**What:** Flash HP bar red briefly when taking damage.  
**Why:** Makes damage feedback more readable.

### L6. Score Popup Numbers
**What:** When scoring points, show floating `+10`, `+25` text that drifts up and fades.  
**Why:** Satisfying feedback loop — player sees exactly what scored them points.

---

## 🔵 FUTURE FEATURES — Big Additions

### F1. Online Multiplayer (WebSocket / ENet)
**What:** Godot 4's `MultiplayerAPI` for LAN or internet play.  
**Why:** Game currently requires 2 players on same keyboard — limits audience.

### F2. More Characters (Nobara, Yuji)
**What:** Third + fourth playable character with unique move sets.  
**Why:** Replayability, character variety.

### F3. Stage Select Screen
**What:** 3+ different battlefields (Shibuya, Jujutsu High, Domain Expansion).  
**Why:** Visual variety per match.

### F4. Story / Arcade Mode
**What:** 1P vs CPU opponent with increasing difficulty.  
**Why:** Solo playability without a second human player.

### F5. Domain Expansion as Super Ultimate
**What:** When HP drops below 20%, player can activate a timed "domain" that changes the arena and buffs all attacks.  
**Why:** Epic comeback mechanic faithful to JJK lore.

---

## Implementation Order Recommendation

```
Phase 1 (Core feel, 1-2 days):
  H1 Knockback → H2 Better animations → H3 Screen shake

Phase 2 (Depth, 2-3 days):
  M6 Round system → M2 Minion variety → M5 Combo counter

Phase 3 (Polish, 1-2 days):
  L2 Player shadow → L3 Sound effects → L5 HP flash → L6 Score popups

Phase 4 (Big features, ongoing):
  F4 Arcade mode → F2 More characters → F1 Online
```
