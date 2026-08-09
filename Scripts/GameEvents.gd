extends Node

# UI‑related signals – emit from gameplay scripts as needed
signal wave_changed(wave_number)
signal enemies_remaining(count)
signal player_health_changed(p_id, health)
signal player_shield_changed(p_id, shield)
signal player_lives_changed(p_id, lives)
signal weapon_changed(p_id, weapon_name)
signal score_updated(p_id, score)
signal coin_updated(p_id, coins)
signal ultimate_charge(p_id, percent)
signal ability_cooldown(p_id, ability, remaining)
signal boss_spawned(name, max_health)
signal boss_health_changed(percent)
signal boss_phase_changed(phase)
signal notification(text, icon_path)
signal combo_multiplier(p_id, multiplier, label)
signal damage_number(p_id, value, type) # type: normal, crit, heal, shield
signal powerup_acquired(p_id, name, duration)
signal game_paused()
signal game_resumed()
