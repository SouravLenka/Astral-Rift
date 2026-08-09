extends Node
## ─────────────────────────────────────────────────────
## ASTRA: RIFT – Global Event Bus
## All UI signals are defined here.
## Gameplay scripts emit; UI scenes connect.
## ─────────────────────────────────────────────────────

# ── Wave / Game Flow ─────────────────────────────────
signal wave_changed(wave_number: int)
signal enemies_remaining(count: int)
signal game_started()
signal game_paused()
signal game_resumed()

# ── Player Stats ─────────────────────────────────────
signal player_health_changed(p_id: int, health: float, max_health: float)
signal player_shield_changed(p_id: int, shield: float, max_shield: float)
signal player_lives_changed(p_id: int, lives: int)
signal weapon_changed(p_id: int, weapon_name: String)
signal score_updated(p_id: int, score: int)
signal coin_updated(p_id: int, coins: int)
signal ultimate_charge(p_id: int, percent: float)
signal ability_cooldown(p_id: int, ability: String, remaining: float)

# ── Boss ─────────────────────────────────────────────
signal boss_spawned(boss_name: String, max_health: float)
signal boss_health_changed(percent: float)
signal boss_phase_changed(phase: int)
signal boss_special_attack(warning_text: String)
signal boss_despawned()

# ── Notifications / FX ───────────────────────────────
signal notification(text: String, icon_key: String)
signal combo_multiplier(p_id: int, multiplier: int, label: String)
signal damage_number(world_pos: Vector2, value: int, type: String) # type: normal|crit|heal|shield
signal powerup_acquired(p_id: int, pu_name: String, duration: float)
signal powerup_expired(p_id: int, pu_name: String)
signal mission_progress(percent: float)

# ── Menu / Screen ────────────────────────────────────
signal request_main_menu()
signal request_pause()
signal request_resume()
signal request_game_over()
signal request_victory()
signal request_hangar()
signal request_controls()

