extends Node2D

const ARENA_SIZE := Vector2(1280, 720)
const PLAYER_SPEED := 320.0
const BULLET_SPEED := 680.0

var players := [
	{"position": Vector2(360, 360), "color": Color("55d6ff"), "move": [KEY_A, KEY_D, KEY_W, KEY_S], "fire": KEY_ENTER, "cooldown": 0.0, "name": "P1", "score": 0},
	{"position": Vector2(920, 360), "color": Color("ff74c8"), "move": [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN], "fire": KEY_SPACE, "cooldown": 0.0, "name": "P2", "score": 0}
]
var bullets: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var explosions: Array[Dictionary] = []
var wave := 0
var spawn_left := 0
var spawn_timer := 0.0
var next_wave_timer := 1.5
var rng := RandomNumberGenerator.new()
var wave_status: Label
var player_one_stats: Label
var player_two_stats: Label
var mission_label: Label
var game_started := false
var game_paused := false

func _ready() -> void:
	rng.randomize()
	build_hud()
	queue_redraw()

func _process(delta: float) -> void:
	if not game_started or game_paused:
		queue_redraw()
		return
	update_players(delta)
	update_bullets(delta)
	update_enemies(delta)
	update_explosions(delta)
	spawn_waves(delta)
	wave_status.text = "WAVE %d   •   %d HOSTILES" % [wave, enemies.size() + spawn_left]
	player_one_stats.text = "SHIELD  100%%    SCORE  %04d" % int(players[0].score)
	player_two_stats.text = "SHIELD  100%%    SCORE  %04d" % int(players[1].score)
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F and not game_started:
			game_started = true
		elif event.keycode == KEY_P and game_started:
			game_paused = not game_paused
			if game_paused:
				mission_label.text = "PAUSED   //   PRESS P TO RESUME"
			else:
				mission_label.text = "SURVIVAL PROTOCOL ACTIVE   //   ELIMINATE ALL HOSTILES"

func build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	player_one_stats = add_hud_card(hud, Vector2(24, 22), Vector2(330, 88), Color("55d6ff"), "PILOT ONE", "WASD  •  ENTER")
	player_two_stats = add_hud_card(hud, Vector2(926, 22), Vector2(330, 88), Color("ff74c8"), "PILOT TWO", "ARROWS  •  SPACE")
	var status_card := Panel.new()
	status_card.position = Vector2(404, 22)
	status_card.size = Vector2(472, 88)
	status_card.add_theme_stylebox_override("panel", make_card_style(Color("1a2b4c")))
	hud.add_child(status_card)
	var title := Label.new()
	title.text = "ASTRAL RIFT"
	title.position = Vector2(16, 8)
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color("cde4ff"))
	status_card.add_child(title)
	wave_status = Label.new()
	wave_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	wave_status.position = Vector2(112, 9)
	wave_status.size = Vector2(342, 32)
	wave_status.add_theme_font_size_override("font_size", 16)
	wave_status.add_theme_color_override("font_color", Color("ffffff"))
	status_card.add_child(wave_status)
	var subtitle := Label.new()
	subtitle.text = "DEFEND THE RIFT"
	subtitle.position = Vector2(16, 39)
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", Color("7895c2"))
	status_card.add_child(subtitle)
	mission_label = Label.new()
	mission_label.text = "PRESS F TO DEPLOY   //   P PAUSES THE MISSION"
	mission_label.position = Vector2(24, 678)
	mission_label.size = Vector2(1232, 22)
	mission_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_label.add_theme_font_size_override("font_size", 12)
	mission_label.add_theme_color_override("font_color", Color("7895c2"))
	hud.add_child(mission_label)

func add_hud_card(hud: CanvasLayer, position: Vector2, card_size: Vector2, accent: Color, pilot: String, controls: String) -> Label:
	var card := Panel.new()
	card.position = position
	card.size = card_size
	card.add_theme_stylebox_override("panel", make_card_style(accent))
	hud.add_child(card)
	var stripe := ColorRect.new()
	stripe.position = Vector2(0, 0)
	stripe.size = Vector2(5, card_size.y)
	stripe.color = accent
	card.add_child(stripe)
	var name_label := Label.new()
	name_label.text = pilot
	name_label.position = Vector2(18, 10)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", accent)
	card.add_child(name_label)
	var control_label := Label.new()
	control_label.text = controls
	control_label.position = Vector2(18, 38)
	control_label.add_theme_font_size_override("font_size", 12)
	control_label.add_theme_color_override("font_color", Color("c5d3eb"))
	card.add_child(control_label)
	var stats_label := Label.new()
	stats_label.position = Vector2(18, 60)
	stats_label.add_theme_font_size_override("font_size", 11)
	stats_label.add_theme_color_override("font_color", Color("8ca6c9"))
	card.add_child(stats_label)
	return stats_label

func make_card_style(border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0d1728e8")
	style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.55)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style

func update_players(delta: float) -> void:
	for player in players:
		var keys: Array = player.move
		var horizontal := (1.0 if Input.is_key_pressed(keys[1]) else 0.0) - (1.0 if Input.is_key_pressed(keys[0]) else 0.0)
		var vertical := (1.0 if Input.is_key_pressed(keys[3]) else 0.0) - (1.0 if Input.is_key_pressed(keys[2]) else 0.0)
		var direction := Vector2(horizontal, vertical)
		if direction.length() > 0:
			direction = direction.normalized()
		player.position = (player.position + direction * PLAYER_SPEED * delta).clamp(Vector2(24, 56), ARENA_SIZE - Vector2(24, 24))
		player.cooldown -= delta
		if Input.is_key_pressed(player.fire) and player.cooldown <= 0:
			var target: Vector2 = get_nearest_enemy(player.position)
			var aim: Vector2 = (target - player.position).normalized() if target != Vector2.ZERO else Vector2.UP
			bullets.append({"position": player.position, "velocity": aim * BULLET_SPEED, "color": player.color, "owner": players.find(player)})
			player.cooldown = 0.22

func update_bullets(delta: float) -> void:
	for bullet in bullets:
		bullet.position += bullet.velocity * delta
		for enemy in enemies.duplicate():
			if bullet.position.distance_to(enemy.position) < 20:
				var owner_index: int = bullet.owner
				var shooter: Dictionary = players[owner_index]
				shooter.score = int(shooter.score) + 1
				players[owner_index] = shooter
				explosions.append({"position": enemy.position, "age": 0.0})
				enemies.erase(enemy)
				bullets.erase(bullet)
				break
	bullets = bullets.filter(func(b): return Rect2(Vector2.ZERO, ARENA_SIZE).grow(30).has_point(b.position))

func update_explosions(delta: float) -> void:
	for explosion in explosions:
		explosion.age += delta
	explosions = explosions.filter(func(explosion): return explosion.age < 0.38)

func update_enemies(delta: float) -> void:
	for enemy in enemies:
		var closest: Vector2 = players[0].position
		for player in players:
			if enemy.position.distance_to(player.position) < enemy.position.distance_to(closest): closest = player.position
		enemy.position += enemy.position.direction_to(closest) * (72.0 + wave * 3.0) * delta

func spawn_waves(delta: float) -> void:
	if spawn_left > 0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_enemy()
			spawn_left -= 1
			spawn_timer = 0.55
	elif enemies.is_empty():
		next_wave_timer -= delta
		if next_wave_timer <= 0:
			wave += 1
			spawn_left = 4 + wave * 2
			next_wave_timer = 2.0

func spawn_enemy() -> void:
	var side := rng.randi_range(0, 3)
	var pos := Vector2(rng.randf_range(30, ARENA_SIZE.x - 30), 30)
	if side == 1: pos = Vector2(ARENA_SIZE.x - 30, rng.randf_range(60, ARENA_SIZE.y - 30))
	elif side == 2: pos = Vector2(rng.randf_range(30, ARENA_SIZE.x - 30), ARENA_SIZE.y - 30)
	elif side == 3: pos = Vector2(30, rng.randf_range(60, ARENA_SIZE.y - 30))
	enemies.append({"position": pos})

func get_nearest_enemy(from: Vector2) -> Vector2:
	if enemies.is_empty(): return Vector2.ZERO
	var nearest: Vector2 = enemies[0].position
	for enemy in enemies:
		if from.distance_to(enemy.position) < from.distance_to(nearest): nearest = enemy.position
	return nearest

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color("07101f"))
	for x in range(0, int(ARENA_SIZE.x), 64): draw_line(Vector2(x, 0), Vector2(x, ARENA_SIZE.y), Color("10213d"))
	for y in range(0, int(ARENA_SIZE.y), 64): draw_line(Vector2(0, y), Vector2(ARENA_SIZE.x, y), Color("10213d"))
	draw_rect(Rect2(8, 8, ARENA_SIZE.x - 16, ARENA_SIZE.y - 16), Color("2b568c"), false, 2)
	for player in players:
		var ship_points := PackedVector2Array([player.position + Vector2(0, -18), player.position + Vector2(13, 14), player.position, player.position + Vector2(-13, 14)])
		draw_circle(player.position, 22, Color(player.color.r, player.color.g, player.color.b, 0.12))
		draw_colored_polygon(ship_points, player.color)
		draw_polyline(PackedVector2Array([ship_points[0], ship_points[1], ship_points[2], ship_points[3], ship_points[0]]), Color.WHITE, 1.5)
		draw_circle(player.position + Vector2(0, 2), 3, Color("06101f"))
	for enemy in enemies:
		var drone_color := Color("ffb84d")
		draw_circle(enemy.position, 15, Color(drone_color.r, drone_color.g, drone_color.b, 0.14))
		draw_circle(enemy.position, 11, drone_color)
		draw_line(enemy.position + Vector2(-16, 0), enemy.position + Vector2(16, 0), Color("ffdd8a"), 2)
		draw_circle(enemy.position, 4, Color("241326"))
	for bullet in bullets: draw_circle(bullet.position, 4, bullet.color)
	for explosion in explosions:
		var progress: float = explosion.age / 0.38
		var burst_color := Color("ffdb72", 1.0 - progress)
		draw_circle(explosion.position, 8 + progress * 28, burst_color, false, 2)
		draw_circle(explosion.position, 5 + progress * 12, Color("ff6e4a", 0.7 - progress * 0.7))
	if not game_started:
		draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color("020815", 0.78))
		draw_string(ThemeDB.fallback_font, Vector2(428, 308), "ASTRAL RIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 54, Color("d8ecff"))
		draw_string(ThemeDB.fallback_font, Vector2(468, 350), "LOCAL CO-OP SURVIVAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("7895c2"))
		draw_string(ThemeDB.fallback_font, Vector2(498, 418), "PRESS F TO DEPLOY", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("55d6ff"))
	elif game_paused:
		draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color("020815", 0.68))
		draw_string(ThemeDB.fallback_font, Vector2(545, 345), "PAUSED", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color("ffffff"))
		draw_string(ThemeDB.fallback_font, Vector2(526, 380), "PRESS P TO RESUME", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("7895c2"))
