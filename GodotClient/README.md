# Astral Rift — Godot Edition

This folder contains the active Godot 4 implementation of Astral Rift. The Unity project in the repository remains available as the migration/reference project.

## Requirements

- Godot 4.x **.NET/Mono** editor
- .NET 8 SDK
- Windows desktop

## Run

1. Open Godot 4 .NET.
2. Import this folder by selecting `project.godot`.
3. Press **F6** or **F5** to run the main scene.
4. Press **F** in the game window to deploy.

If you change the C# reference scripts, build them from PowerShell with:

```powershell
dotnet build .\AstralRift.GodotClient.csproj
```

## Controls

| Pilot | Move | Fire |
| --- | --- | --- |
| Pilot One | `W A S D` | `Enter` |
| Pilot Two | Arrow keys | `Spacebar` |

Press `P` to pause or resume.

## Included gameplay

- Local two-player movement and firing
- Escalating enemy waves
- Enemy pursuit and projectile collisions
- Pilot scores and live enemy counts
- Launch screen, pause screen, HUD cards, and hit effects

The active scene is `Scenes/Main.tscn`, powered by `Scripts/Main.gd`. The C# scripts remain in `Scripts/` as the ongoing migration/reference implementation.
