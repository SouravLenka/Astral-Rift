## BossHUD.gd
## Appears at the bottom when a boss spawns.
## Shows boss portrait, name, animated health bar, phase badges, special attack warning.
extends Control

@onready var boss_name_lbl: Label     = $Panel/Margin/VBox/TopRow/BossNameLabel
@onready var phase_lbl: Label         = $Panel/Margin/VBox/TopRow/PhaseLabel
@onready var health_bar: ProgressBar   = $Panel/Margin/VBox/HealthBar
@onready var warning_banner: Control  = $WarningBanner
@onready var warning_lbl: Label       = $WarningBanner/Center/WarningLabel

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	warning_banner.visible = false
	_style_panel()
	_style_bar()
	
	GameEvents.boss_spawned.connect(_on_boss_spawned)
	GameEvents.boss_health_changed.connect(_on_health)
	GameEvents.boss_phase_changed.connect(_on_phase)
	GameEvents.boss_special_attack.connect(_on_special_attack)
	GameEvents.boss_despawned.connect(_on_boss_despawned)

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30F2")
	style.border_color = Color("#FF8C42", 0.9)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0, 0, 0, 0.7)
	style.shadow_size = 10
	$Panel.add_theme_stylebox_override("panel", style)

func _style_bar() -> void:
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = Color("#FF5252")
	fill.corner_radius_top_left = 4
	fill.corner_radius_top_right = 4
	fill.corner_radius_bottom_left = 4
	fill.corner_radius_bottom_right = 4
	health_bar.add_theme_stylebox_override("fill", fill)
	
	var bg: StyleBoxFlat = StyleBoxFlat.new()
	bg.bg_color = Color("#101C30", 0.8)
	bg.corner_radius_top_left = 4
	bg.corner_radius_top_right = 4
	bg.corner_radius_bottom_left = 4
	bg.corner_radius_bottom_right = 4
	health_bar.add_theme_stylebox_override("background", bg)

func _on_boss_spawned(boss_name: String, _max_hp: float) -> void:
	boss_name_lbl.text = boss_name.to_upper()
	phase_lbl.text = "PHASE I"
	health_bar.value = 100.0
	visible = true
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.4)

func _on_health(percent: float) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(health_bar, "value", percent * 100.0, 0.35).set_ease(Tween.EASE_OUT)
	if percent < 0.25:
		var tw2: Tween = create_tween()
		tw2.tween_property(health_bar, "modulate", Color(1, 0.2, 0.2), 0.1)
		tw2.tween_property(health_bar, "modulate", Color.WHITE, 0.2)

func _on_phase(phase: int) -> void:
	var roman: Array[String] = ["I", "II", "III", "IV", "V"]
	phase_lbl.text = "PHASE " + roman[clampi(phase - 1, 0, 4)]
	var tw: Tween = create_tween()
	tw.tween_property(phase_lbl, "modulate", Color("#FF8C42"), 0.15)
	tw.tween_property(phase_lbl, "modulate", Color.WHITE, 0.3)

func _on_special_attack(text_str: String) -> void:
	warning_lbl.text = "⚠ " + text_str.to_upper() + " ⚠"
	warning_banner.visible = true
	var tw: Tween = create_tween().set_loops(4)
	tw.tween_property(warning_banner, "modulate:a", 1.0, 0.15)
	tw.tween_property(warning_banner, "modulate:a", 0.2, 0.15)
	await tw.finished
	warning_banner.visible = false

func _on_boss_despawned() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.4)
	await tw.finished
	visible = false
