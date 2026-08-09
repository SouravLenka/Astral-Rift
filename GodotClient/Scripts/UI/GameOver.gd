## GameOver.gd
## Mission Failed screen with stats breakdown and navigation buttons.
extends CanvasLayer

@onready var enemies_lbl: Label  = $Panel/Margin/VBox/StatsGrid/EnemiesLabel
@onready var accuracy_lbl: Label = $Panel/Margin/VBox/StatsGrid/AccuracyLabel
@onready var time_lbl: Label     = $Panel/Margin/VBox/StatsGrid/TimeLabel
@onready var combo_lbl: Label    = $Panel/Margin/VBox/StatsGrid/ComboLabel
@onready var retry_btn: Button   = $Panel/Margin/VBox/Buttons/RetryBtn
@onready var menu_btn: Button    = $Panel/Margin/VBox/Buttons/MenuBtn
@onready var panel: PanelContainer = $Panel

var stats: Dictionary = {"enemies": 42, "accuracy": 88.5, "time": 184, "combo": 15}

func _ready() -> void:
	visible = false
	_style_panel()
	GameEvents.request_game_over.connect(show_screen)
	retry_btn.pressed.connect(func(): get_tree().reload_current_scene())
	menu_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn"))

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30F2")
	style.border_color = Color("#FF5252", 0.9)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.shadow_color = Color(0, 0, 0, 0.8)
	style.shadow_size = 14
	panel.add_theme_stylebox_override("panel", style)

func show_screen() -> void:
	visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	panel.pivot_offset = panel.size / 2.0
	
	enemies_lbl.text  = "ENEMIES DESTROYED: %d" % int(stats.get("enemies", 0))
	accuracy_lbl.text = "ACCURACY: %.1f%%" % float(stats.get("accuracy", 0.0))
	time_lbl.text     = "TIME SURVIVED: %ds" % int(stats.get("time", 0))
	combo_lbl.text    = "HIGHEST COMBO: x%d" % int(stats.get("combo", 1))
	
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.4)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
