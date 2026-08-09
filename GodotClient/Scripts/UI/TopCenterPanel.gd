## TopCenterPanel.gd
## Displays current wave, enemy count, objective, mission progress bar.
## Displays animated boss warning banner when boss_spawned fires.
extends Control

@onready var wave_label: Label         = $Panel/VBox/TopRow/WaveLabel
@onready var enemy_label: Label        = $Panel/VBox/TopRow/EnemyLabel
@onready var obj_label: Label          = $Panel/VBox/ObjLabel
@onready var progress_bar: ProgressBar = $Panel/VBox/ProgressBar
@onready var boss_banner: Control      = $BossBanner
@onready var boss_name_lbl: Label      = $BossBanner/CenterBox/BossNameLabel

var total_enemies_wave: int = 1

func _ready() -> void:
	boss_banner.visible = false
	boss_banner.modulate.a = 0.0
	_style_panel()
	_style_progress_bar()
	
	GameEvents.wave_changed.connect(_on_wave)
	GameEvents.enemies_remaining.connect(_on_enemies)
	GameEvents.boss_spawned.connect(_on_boss_spawned)
	GameEvents.boss_despawned.connect(_on_boss_despawned)
	GameEvents.mission_progress.connect(_on_progress)

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30E6")
	style.border_color = Color("#4FDFFF", 0.7)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 6
	$Panel.add_theme_stylebox_override("panel", style)

func _style_progress_bar() -> void:
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = Color("#4FDFFF")
	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_left = 3
	fill.corner_radius_bottom_right = 3
	progress_bar.add_theme_stylebox_override("fill", fill)
	
	var bg: StyleBoxFlat = StyleBoxFlat.new()
	bg.bg_color = Color("#101C30", 0.8)
	bg.corner_radius_top_left = 3
	bg.corner_radius_top_right = 3
	bg.corner_radius_bottom_left = 3
	bg.corner_radius_bottom_right = 3
	progress_bar.add_theme_stylebox_override("background", bg)

func _on_wave(n: int) -> void:
	wave_label.text = "⚡ WAVE %02d" % n
	_flash(wave_label)

func _on_enemies(count: int) -> void:
	enemy_label.text = "👾 %02d" % count

func _on_progress(pct: float) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(progress_bar, "value", pct * 100.0, 0.2)

func _flash(node: Control) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(node, "modulate:v", 2.0, 0.08)
	tw.tween_property(node, "modulate:v", 1.0, 0.25)

func _on_boss_spawned(boss_name: String, _max_hp: float) -> void:
	boss_name_lbl.text = "⚠  " + boss_name.to_upper() + "  ⚠"
	boss_banner.visible = true
	var tw: Tween = create_tween().set_loops(6)
	tw.tween_property(boss_banner, "modulate:a", 1.0, 0.18)
	tw.tween_property(boss_banner, "modulate:a", 0.2, 0.18)
	await tw.finished
	var tw2: Tween = create_tween().set_loops()
	tw2.tween_property(boss_banner, "modulate:a", 1.0, 0.5)
	tw2.tween_property(boss_banner, "modulate:a", 0.7, 0.5)

func _on_boss_despawned() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(boss_banner, "modulate:a", 0.0, 0.4)
	await tw.finished
	boss_banner.visible = false
