# Astral Rift

Astral Rift is a Windows-first local co-op roguelite space shooter. The repository contains the original Unity prototype and the actively playable Godot implementation.

## Current playable build

The playable project is in [`GodotClient/`](GodotClient/). It is a code-first Godot 4 project with a 1280x720 arena, two local pilots, enemy waves, shooting, scoring, a launch screen, pause flow, and a HUD.

The Unity files under [`Assets/`](Assets/) are retained as the migration/reference project.

## Requirements

- Godot 4.x **.NET/Mono** editor
- .NET 8 SDK
- Windows desktop

## Run the game

1. Open Godot 4 .NET.
2. Import [`GodotClient/project.godot`](GodotClient/project.godot).
3. Open the project and press **F6** or **F5**.
4. Press **F** in the game window to deploy.

## Controls

| Pilot | Move | Fire |
| --- | --- | --- |
| Pilot One | `W A S D` | `Spacebar` |
| Pilot Two | Arrow keys | `Enter` |

Pilot One releases their charged **Nova Pulse** with `X`; Pilot Two releases **Rift Collapse** with `Backspace`.

Press `P` to pause or resume the mission.

## Godot project layout

```text
GodotClient/
├── Scenes/Main.tscn       # Main playable scene
├── Scripts/Main.gd        # Active playable arena, HUD, waves, and effects
├── Scripts/*.cs            # C# migration/reference gameplay scripts
├── project.godot          # Godot project settings
└── README.md               # Godot-specific setup notes
```

## Development status

The Godot build is an early playable foundation. Planned work includes richer art and audio, power-ups, bosses, save data, additional arenas, and final polish.
