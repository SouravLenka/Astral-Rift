## HUD.gd
## Root HUD scene – wires all sub-panels, floating FX, and overlays together.
## Instance this as a CanvasLayer child of your main game scene.
extends CanvasLayer

const PAUSE_SCENE: PackedScene    = preload("res://Scenes/UI/PauseMenu.tscn")
const GAMEOVER_SCENE: PackedScene = preload("res://Scenes/UI/GameOver.tscn")
const VICTORY_SCENE: PackedScene  = preload("res://Scenes/UI/VictoryScreen.tscn")
const DMG_SCENE: PackedScene      = preload("res://Scenes/UI/DamageNumber.tscn")
const COMBO_SCENE: PackedScene    = preload("res://Scenes/UI/ComboDisplay.tscn")

@onready var root_control: Control = $RootControl
@onready var mission_brief: Control = $RootControl/MissionBrief

var _pause_menu: CanvasLayer
var _gameover: CanvasLayer
var _victory: CanvasLayer

func _ready() -> void:
	# Instantiate overlays
	_pause_menu = PAUSE_SCENE.instantiate() as CanvasLayer
	add_child(_pause_menu)
	_gameover = GAMEOVER_SCENE.instantiate() as CanvasLayer
	add_child(_gameover)
	_victory = VICTORY_SCENE.instantiate() as CanvasLayer
	add_child(_victory)
	
	# Connect FX signals
	GameEvents.damage_number.connect(_on_damage_number)
	GameEvents.combo_multiplier.connect(_on_combo_multiplier)
	GameEvents.game_started.connect(_dismiss_mission_brief)
	_style_mission_brief()

func _style_mission_brief() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#08111FF2")
	style.border_color = Color("#4FDFFF", 0.85)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.shadow_color = Color(0.1, 0.4, 0.8, 0.35)
	style.shadow_size = 16
	$RootControl/MissionBrief/Panel.add_theme_stylebox_override("panel", style)

func _dismiss_mission_brief() -> void:
	var tw := create_tween()
	tw.tween_property(mission_brief, "modulate:a", 0.0, 0.35)
	await tw.finished
	mission_brief.visible = false

func _on_damage_number(world_pos: Vector2, value: int, type: String) -> void:
	var dmg: Node2D = DMG_SCENE.instantiate() as Node2D
	dmg.position = world_pos
	root_control.add_child(dmg)
	if dmg.has_method("setup"):
		dmg.setup(value, type)

func _on_combo_multiplier(p_id: int, multiplier: int, label_str: String) -> void:
	var combo: Control = COMBO_SCENE.instantiate() as Control
	# Position near player side
	combo.position = Vector2(240, 260) if p_id == 0 else Vector2(1040, 260)
	root_control.add_child(combo)
	if combo.has_method("setup"):
		combo.setup(p_id, multiplier, label_str)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P or event.keycode == KEY_ESCAPE:
			if get_tree().paused:
				GameEvents.game_resumed.emit()
				get_tree().paused = false
			else:
				GameEvents.game_paused.emit()
				get_tree().paused = true
