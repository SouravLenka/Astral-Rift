# ASTRA: RIFT – UI System

## Folder Structure
```
GodotClient/
├─ Scenes/
│   ├─ Main.tscn                   ← game scene (already exists)
│   ├─ MainMenuScene.tscn          ← standalone main menu entry
│   └─ UI/
│       ├─ HUD.tscn                ← root HUD (add as child of Main)
│       ├─ PlayerHUD.tscn          ← reusable player panel (player_id=0/1)
│       ├─ TopCenterPanel.tscn     ← wave / enemies / boss banner
│       ├─ BottomCenterPanel.tscn  ← notification toast queue
│       ├─ BottomLeftPanel.tscn    ← P1 cooldowns + power-ups
│       ├─ BottomRightPanel.tscn   ← P2 cooldowns + power-ups
│       ├─ BossHUD.tscn            ← boss health bar (auto-shows on boss_spawned)
│       ├─ Notification.tscn       ← single toast prefab
│       ├─ PowerUpIcon.tscn        ← active power-up icon + countdown
│       ├─ PauseMenu.tscn          ← pause overlay
│       ├─ MainMenu.tscn           ← main menu with starfield
│       ├─ GameOver.tscn           ← mission failed screen
│       ├─ VictoryScreen.tscn      ← mission complete screen
│       └─ SettingsMenu.tscn       ← settings tabs
├─ Scripts/
│   ├─ Main.gd                     ← gameplay (emits GameEvents signals)
│   ├─ GameEvents.gd               ← autoload singleton (signal bus)
│   └─ UI/
│       ├─ HUD.gd
│       ├─ PlayerHUD.gd
│       ├─ TopCenterPanel.gd
│       ├─ BottomCenterPanel.gd
│       ├─ CooldownPanel.gd
│       ├─ BossHUD.gd
│       ├─ Notification.gd
│       ├─ PowerUpIcon.gd
│       ├─ PauseMenu.gd
│       ├─ MainMenu.gd
│       ├─ GameOver.gd
│       ├─ VictoryScreen.gd
│       └─ SettingsMenu.gd
└─ project.godot                   ← GameEvents registered as Autoload
```

## How to Add a New HUD Element
1. Create `Scenes/UI/MyElement.tscn` using Control nodes.
2. Add a script `Scripts/UI/MyElement.gd` that connects to the signals it needs:
   ```gdscript
   func _ready() -> void:
       GameEvents.some_signal.connect(_on_some_signal)
   ```
3. Instance the scene inside `HUD.tscn` as a child of `RootControl`.
4. Emit the signal from gameplay code as needed.

## Color Reference
| Token     | Hex       | Usage                  |
|-----------|-----------|------------------------|
| Background| `#08111F` | Full-screen bg         |
| Panel     | `#101C30` | Panel backgrounds      |
| Cyan      | `#4FDFFF` | Player 1 accent        |
| Purple    | `#C85BFF` | Player 2 accent        |
| Orange    | `#FF8C42` | Warnings / ultimates   |
| Green     | `#5EFF7A` | Healing / victory      |
| Red       | `#FF5252` | Damage / health        |

## Fonts (Recommended)
- **Inter Regular** – body text (16 pt)
- **Orbitron Bold** – titles / headings (28 pt)
- Download from Google Fonts, place in `Assets/UI/Fonts/`

## GameEvents Signal Reference
See `Scripts/GameEvents.gd` for the full list of signals.
Key signals:
- `wave_changed(n)` – emit on wave start
- `enemies_remaining(count)` – emit after each kill
- `player_health_changed(id, hp, max)` – emit on damage
- `boss_spawned(name, max_hp)` – emit when boss enters
- `notification(text, icon_key)` – emit for any toast message
- `damage_number(pos, value, type)` – emit on each hit
