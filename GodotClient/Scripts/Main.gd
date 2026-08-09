extends Node2D

const ARENA_SIZE: Vector2 = Vector2(1280, 720)
const PLAYER_SPEED: float = 320.0
const BULLET_SPEED: float = 680.0
const ASTEROID_IMPACT_DAMAGE: float = 30.0
const IMPACT_INVULNERABILITY: float = 0.85
const RESPAWN_INVULNERABILITY: float = 2.0
const RESPAWN_HEALTH: float = 70.0
const RESPAWN_SHIELD: float = 45.0
const HUD_SCENE: PackedScene = preload("res://Scenes/UI/HUD.tscn")

var players: Array[Dictionary] = [
	{"position": Vector2(360, 360), "color": Color("4FDFFF"), "move": [KEY_A, KEY_D, KEY_W, KEY_S],
	 "fire": KEY_SPACE, "ultimate_action": "p1_ultimate", "ultimate_name": "NOVA PULSE", "cooldown": 0.0, "name": "P1", "score": 0, "coins": 0,
	 "health": 100.0, "max_health": 100.0, "shield": 100.0, "max_shield": 100.0, "lives": 3,
	 "combo": 0, "combo_timer": 0.0, "ultimate": 0.0, "invulnerability": 0.0, "eliminated": false, "weapon": "PLASMA BEAM"},
	{"position": Vector2(920, 360), "color": Color("C85BFF"), "move": [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN],
	 "fire": KEY_ENTER, "ultimate_action": "p2_ultimate", "ultimate_name": "RIFT COLLAPSE", "cooldown": 0.0, "name": "P2", "score": 0, "coins": 0,
	 "health": 100.0, "max_health": 100.0, "shield": 100.0, "max_shield": 100.0, "lives": 3,
	 "combo": 0, "combo_timer": 0.0, "ultimate": 0.0, "invulnerability": 0.0, "eliminated": false, "weapon": "RIFT PULSE"}
]

var bullets: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var explosions: Array[Dictionary] = []
var ultimate_bursts: Array[Dictionary] = []
var wave: int = 0
var spawn_left: int = 0
var spawn_timer: float = 0.0
var next_wave_timer: float = 1.5
var boss_active: bool = false
var boss_health: float = 1000.0
var boss_max_health: float = 1000.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var game_started: bool = false
var game_paused: bool = false
var game_time: float = 0.0
var mission_failed: bool = false

func _ready() -> void:
	rng.randomize()
	# Add HUD CanvasLayer
	var hud: Node = HUD_SCENE.instantiate()
	add_child(hud)
	
	GameEvents.game_paused.connect(func(): game_paused = true)
	GameEvents.game_resumed.connect(func(): game_paused = false)
	queue_redraw()

func _process(delta: float) -> void:
	if not game_started or game_paused:
		queue_redraw()
		return
		
	game_time += delta
	update_players(delta)
	update_bullets(delta)
	update_enemies(delta)
	update_explosions(delta)
	update_ultimate_bursts(delta)
	spawn_waves(delta)
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F and not game_started:
			game_started = true
			GameEvents.game_started.emit()
			GameEvents.wave_changed.emit(wave)
			GameEvents.enemies_remaining.emit(enemies.size() + spawn_left)
			for i in range(players.size()):
				var p: Dictionary = players[i]
				GameEvents.player_health_changed.emit(i, float(p.health), float(p.max_health))
				GameEvents.player_shield_changed.emit(i, float(p.shield), float(p.max_shield))
				GameEvents.player_lives_changed.emit(i, int(p.lives))
				GameEvents.score_updated.emit(i, int(p.score))
				GameEvents.coin_updated.emit(i, int(p.coins))
				GameEvents.weapon_changed.emit(i, str(p.weapon))
				GameEvents.ultimate_charge.emit(i, float(p.ultimate))
		elif (event.keycode == KEY_P or event.keycode == KEY_ESCAPE) and game_started:
			if game_paused:
				GameEvents.game_resumed.emit()
			else:
				GameEvents.game_paused.emit()

func update_players(delta: float) -> void:
	for i in range(players.size()):
		var player: Dictionary = players[i]
		if bool(player.eliminated):
			continue
		player.invulnerability = max(0.0, float(player.invulnerability) - delta)
		
		# Combo Decay
		if int(player.combo) > 0:
			player.combo_timer = float(player.combo_timer) - delta
			if float(player.combo_timer) <= 0.0:
				player.combo = 0
		
		var keys: Array = player.move
		var horizontal: float = (1.0 if Input.is_key_pressed(keys[1]) else 0.0) - (1.0 if Input.is_key_pressed(keys[0]) else 0.0)
		var vertical: float = (1.0 if Input.is_key_pressed(keys[3]) else 0.0) - (1.0 if Input.is_key_pressed(keys[2]) else 0.0)
		var direction: Vector2 = Vector2(horizontal, vertical)
		if direction.length() > 0:
			direction = direction.normalized()
		var pos: Vector2 = player.position
		player.position = (pos + direction * PLAYER_SPEED * delta).clamp(Vector2(24, 56), ARENA_SIZE - Vector2(24, 24))
		
		player.cooldown = float(player.cooldown) - delta
		if Input.is_key_pressed(player.fire) and float(player.cooldown) <= 0.0:
			var target: Vector2 = get_nearest_enemy(player.position)
			var aim: Vector2 = (target - Vector2(player.position)).normalized() if target != Vector2.ZERO else Vector2.UP
			bullets.append({"position": player.position, "velocity": aim * BULLET_SPEED, "color": player.color, "owner": i})
			player.cooldown = 0.20
		if Input.is_action_just_pressed(str(player.ultimate_action)):
			_activate_ultimate(i, player)
		players[i] = player

func _activate_ultimate(player_id: int, player: Dictionary) -> void:
	if float(player.ultimate) < 1.0:
		GameEvents.notification.emit("%s CHARGING — %d%%" % [str(player.ultimate_name), int(float(player.ultimate) * 100.0)], "ult")
		return
	var radius := 265.0 if player_id == 0 else 315.0
	var burst_color: Color = Color("4FDFFF") if player_id == 0 else Color("C85BFF")
	ultimate_bursts.append({"position": player.position, "age": 0.0, "radius": radius, "color": burst_color})
	var defeated := 0
	for enemy in enemies.duplicate():
		if (enemy.position as Vector2).distance_to(player.position) > radius:
			continue
		defeated += 1
		enemies.erase(enemy)
		explosions.append({"position": enemy.position, "age": 0.0})
	player.ultimate = 0.0
	player.score = int(player.score) + defeated * 450
	player.coins = int(player.coins) + defeated * 15
	GameEvents.ultimate_charge.emit(player_id, 0.0)
	GameEvents.score_updated.emit(player_id, int(player.score))
	GameEvents.coin_updated.emit(player_id, int(player.coins))
	GameEvents.enemies_remaining.emit(enemies.size() + spawn_left)
	GameEvents.notification.emit("%s RELEASED — %d HOSTILES PURGED" % [str(player.ultimate_name), defeated], "ult")
	GameEvents.combo_multiplier.emit(player_id, max(1, defeated), str(player.ultimate_name))

func update_bullets(delta: float) -> void:
	for bullet in bullets.duplicate():
		var b_pos: Vector2 = bullet.position
		var b_vel: Vector2 = bullet.velocity
		bullet.position = b_pos + b_vel * delta
		for enemy in enemies.duplicate():
			var e_pos: Vector2 = enemy.position
			if (bullet.position as Vector2).distance_to(e_pos) < 22.0:
				var owner_idx: int = bullet.owner
				var p: Dictionary = players[owner_idx]
				
				p.score = int(p.score) + 150
				p.coins = int(p.coins) + 5
				p.combo = int(p.combo) + 1
				p.combo_timer = 2.5
				
				# Ultimate charge
				p.ultimate = min(1.0, float(p.ultimate) + 0.05)
				GameEvents.ultimate_charge.emit(owner_idx, float(p.ultimate))
				if float(p.ultimate) >= 1.0:
					GameEvents.notification.emit("⚡ PILOT %d ULTIMATE READY!" % (owner_idx + 1), "ult")
				
				# Emit score & coins
				GameEvents.score_updated.emit(owner_idx, int(p.score))
				GameEvents.coin_updated.emit(owner_idx, int(p.coins))
				
				# Damage number & Combo callouts
				var current_combo: int = p.combo
				var is_crit: bool = (current_combo % 5 == 0 or rng.randf() < 0.2)
				var dmg_val: int = rng.randi_range(45, 85) if is_crit else rng.randi_range(20, 35)
				var dmg_type: String = "crit" if is_crit else "normal"
				GameEvents.damage_number.emit(e_pos + Vector2(rng.randf_range(-10, 10), -10), dmg_val, dmg_type)
				
				if current_combo >= 5 and current_combo % 5 == 0:
					var combo_label: String = "COMBO x%d" % current_combo
					if current_combo >= 15: combo_label = "DOMINATING x%d" % current_combo
					elif current_combo >= 25: combo_label = "UNSTOPPABLE x%d" % current_combo
					GameEvents.combo_multiplier.emit(owner_idx, current_combo, combo_label)
					
				explosions.append({"position": e_pos, "age": 0.0})
				enemies.erase(enemy)
				bullets.erase(bullet)
				
				GameEvents.enemies_remaining.emit(enemies.size() + spawn_left)
				break
	bullets = bullets.filter(func(b: Dictionary) -> bool: return Rect2(Vector2.ZERO, ARENA_SIZE).grow(30).has_point(b.position))

func update_explosions(delta: float) -> void:
	for explosion in explosions:
		explosion.age = float(explosion.age) + delta
	explosions = explosions.filter(func(explosion: Dictionary) -> bool: return float(explosion.age) < 0.38)

func update_ultimate_bursts(delta: float) -> void:
	for burst in ultimate_bursts:
		burst.age = float(burst.age) + delta
	ultimate_bursts = ultimate_bursts.filter(func(burst: Dictionary) -> bool: return float(burst.age) < 0.72)

func update_enemies(delta: float) -> void:
	for enemy in enemies.duplicate():
		var target_id := _closest_active_pilot(enemy.position as Vector2)
		if target_id < 0:
			return
		var target: Dictionary = players[target_id]
		var e_position: Vector2 = enemy.position
		var target_position: Vector2 = target.position
		enemy.position = e_position + e_position.direction_to(target_position) * (75.0 + wave * 4.0) * delta
		if (enemy.position as Vector2).distance_to(target_position) > 28.0:
			continue
		enemies.erase(enemy)
		explosions.append({"position": enemy.position, "age": 0.0})
		_damage_pilot(target_id, ASTEROID_IMPACT_DAMAGE)
		GameEvents.enemies_remaining.emit(enemies.size() + spawn_left)

func _closest_active_pilot(from: Vector2) -> int:
	var closest_id := -1
	var closest_distance := INF
	for i in range(players.size()):
		var player: Dictionary = players[i]
		if bool(player.eliminated):
			continue
		var distance := from.distance_to(player.position as Vector2)
		if distance < closest_distance:
			closest_id = i
			closest_distance = distance
	return closest_id

func _damage_pilot(player_id: int, damage: float) -> void:
	var player: Dictionary = players[player_id]
	if float(player.invulnerability) > 0.0 or bool(player.eliminated):
		return
	var shield_damage: float = minf(float(player.shield), damage)
	player.shield = max(0.0, float(player.shield) - shield_damage)
	var hull_damage: float = damage - shield_damage
	if hull_damage > 0.0:
		player.health = max(0.0, float(player.health) - hull_damage)
	GameEvents.damage_number.emit(player.position + Vector2(0, -24), int(damage), "shield" if shield_damage > 0.0 else "normal")
	player.invulnerability = IMPACT_INVULNERABILITY
	GameEvents.player_shield_changed.emit(player_id, float(player.shield), float(player.max_shield))
	GameEvents.player_health_changed.emit(player_id, float(player.health), float(player.max_health))
	if float(player.health) > 0.0:
		GameEvents.notification.emit("PILOT %d IMPACT — SHIELDS %d%%" % [player_id + 1, int(float(player.shield))], "warning")
		players[player_id] = player
		return
	player.lives = max(0, int(player.lives) - 1)
	GameEvents.player_lives_changed.emit(player_id, int(player.lives))
	if int(player.lives) > 0:
		player.health = RESPAWN_HEALTH
		player.shield = RESPAWN_SHIELD
		player.position = Vector2(360, 360) if player_id == 0 else Vector2(920, 360)
		player.invulnerability = RESPAWN_INVULNERABILITY
		GameEvents.player_health_changed.emit(player_id, float(player.health), float(player.max_health))
		GameEvents.player_shield_changed.emit(player_id, float(player.shield), float(player.max_shield))
		GameEvents.notification.emit("PILOT %d RE-DEPLOYED — %d LIVES REMAIN" % [player_id + 1, int(player.lives)], "warning")
	else:
		player.eliminated = true
		GameEvents.notification.emit("PILOT %d LOST" % (player_id + 1), "warning")
	players[player_id] = player
	if _all_pilots_eliminated():
		mission_failed = true
		game_paused = true
		GameEvents.request_game_over.emit()

func _all_pilots_eliminated() -> bool:
	for player_item in players:
		var player: Dictionary = player_item
		if not bool(player.eliminated):
			return false
	return true

func spawn_waves(delta: float) -> void:
	if spawn_left > 0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_enemy()
			spawn_left -= 1
			spawn_timer = 0.50
			GameEvents.enemies_remaining.emit(enemies.size() + spawn_left)
	elif enemies.is_empty() and not boss_active:
		next_wave_timer -= delta
		if next_wave_timer <= 0:
			wave += 1
			if wave % 5 == 0:
				trigger_boss()
			else:
				spawn_left = 5 + wave * 3
				next_wave_timer = 2.0
				GameEvents.wave_changed.emit(wave)
				GameEvents.notification.emit("⚡ WAVE %d INCOMING" % wave, "wave")
				# Occasional powerup trigger broadcast
				if wave % 2 == 0:
					var pu_types: Array[String] = ["TRIPLE SHOTS", "SHIELD RECHARGE", "OVERCLOCK", "PLASMA BOMB"]
					var pu: String = pu_types[rng.randi_range(0, pu_types.size() - 1)]
					GameEvents.powerup_acquired.emit(0, pu, 10.0)
					GameEvents.notification.emit("POWER-UP ACQUIRED: " + pu, "pu")

func trigger_boss() -> void:
	boss_active = true
	GameEvents.wave_changed.emit(wave)
	GameEvents.boss_spawned.emit("MINDWORM PRIMEVANCE", 1000.0)
	GameEvents.notification.emit("⚠ WARNING: BOSS APPROACHING", "boss")

func spawn_enemy() -> void:
	var side: int = rng.randi_range(0, 3)
	var pos: Vector2 = Vector2(rng.randf_range(30, ARENA_SIZE.x - 30), 30)
	if side == 1: pos = Vector2(ARENA_SIZE.x - 30, rng.randf_range(60, ARENA_SIZE.y - 30))
	elif side == 2: pos = Vector2(rng.randf_range(30, ARENA_SIZE.x - 30), ARENA_SIZE.y - 30)
	elif side == 3: pos = Vector2(30, rng.randf_range(60, ARENA_SIZE.y - 30))
	enemies.append({"position": pos})

func get_nearest_enemy(from: Vector2) -> Vector2:
	if enemies.is_empty(): return Vector2.ZERO
	var e0: Dictionary = enemies[0]
	var nearest: Vector2 = e0.position
	for enemy in enemies:
		var e_pos: Vector2 = enemy.position
		if from.distance_to(e_pos) < from.distance_to(nearest):
			nearest = e_pos
	return nearest

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color("08111F"))
	for x in range(0, int(ARENA_SIZE.x), 64): draw_line(Vector2(x, 0), Vector2(x, ARENA_SIZE.y), Color("101C30"))
	for y in range(0, int(ARENA_SIZE.y), 64): draw_line(Vector2(0, y), Vector2(ARENA_SIZE.x, y), Color("101C30"))
	draw_rect(Rect2(8, 8, ARENA_SIZE.x - 16, ARENA_SIZE.y - 16), Color("2B568C", 0.4), false, 2)
	for player_item in players:
		var player: Dictionary = player_item
		if bool(player.eliminated):
			continue
		var p_pos: Vector2 = player.position
		var p_col: Color = player.color
		var impact_flash := float(player.invulnerability) > 0.0 and sin(game_time * 24.0) > 0.0
		if impact_flash:
			p_col = Color.WHITE
		var ship_points: PackedVector2Array = PackedVector2Array([p_pos + Vector2(0, -18), p_pos + Vector2(13, 14), p_pos, p_pos + Vector2(-13, 14)])
		draw_circle(p_pos, 22, Color(p_col.r, p_col.g, p_col.b, 0.15))
		draw_colored_polygon(ship_points, p_col)
		draw_polyline(PackedVector2Array([ship_points[0], ship_points[1], ship_points[2], ship_points[3], ship_points[0]]), Color.WHITE, 1.5)
		draw_circle(p_pos + Vector2(0, 2), 3, Color("08111F"))
	for enemy in enemies:
		var e_pos: Vector2 = enemy.position
		var drone_color: Color = Color("FF8C42")
		draw_circle(e_pos, 15, Color(drone_color.r, drone_color.g, drone_color.b, 0.18))
		draw_circle(e_pos, 11, drone_color)
		draw_line(e_pos + Vector2(-16, 0), e_pos + Vector2(16, 0), Color("FFDC8A"), 2)
		draw_circle(e_pos, 4, Color("101C30"))
	for bullet in bullets: draw_circle(bullet.position, 4, bullet.color)
	for explosion in explosions:
		var progress: float = float(explosion.age) / 0.38
		var burst_color: Color = Color("4FDFFF", 1.0 - progress)
		var ex_pos: Vector2 = explosion.position
		draw_circle(ex_pos, 8 + progress * 28, burst_color, false, 2)
		draw_circle(ex_pos, 5 + progress * 12, Color("C85BFF", 0.7 - progress * 0.7))
	for burst in ultimate_bursts:
		var burst_progress: float = float(burst.age) / 0.72
		var burst_pos: Vector2 = burst.position
		var burst_radius: float = float(burst.radius) * burst_progress
		var burst_color: Color = burst.color
		var burst_alpha := 1.0 - burst_progress
		draw_circle(burst_pos, burst_radius, Color(burst_color.r, burst_color.g, burst_color.b, burst_alpha * 0.14))
		draw_arc(burst_pos, burst_radius, 0.0, TAU, 48, Color(burst_color.r, burst_color.g, burst_color.b, burst_alpha), 3.0)
		for ray in 8:
			var angle := TAU * float(ray) / 8.0 + burst_progress * 2.4
			var direction := Vector2.RIGHT.rotated(angle)
			draw_line(burst_pos + direction * burst_radius * 0.48, burst_pos + direction * burst_radius, Color(burst_color.r, burst_color.g, burst_color.b, burst_alpha * 0.75), 2.0)
	if not game_started:
		draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color("08111F", 0.85))
