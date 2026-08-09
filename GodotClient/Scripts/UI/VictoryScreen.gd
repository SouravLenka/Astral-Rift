## VictoryScreen.gd
## Mission Complete screen with XP, coins, star animation, and unlocks.
extends CanvasLayer

@onready var xp_lbl: Label       = $Panel/Margin/VBox/Rewards/XPLabel
@onready var coin_lbl: Label     = $Panel/Margin/VBox/Rewards/CoinLabel
@onready var stars_lbl: Label    = $Panel/Margin/VBox/Rewards/StarsLabel
@onready var continue_btn: Button = $Panel/Margin/VBox/ContinueBtn
@onready var panel: PanelContainer = $Panel

func _ready() -> void:
	visible = false
	_style_panel()
	GameEvents.request_victory.connect(show_screen)
	continue_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/Main.tscn"))

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30F2")
	style.border_color = Color("#5EFF7A", 0.9)
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
	
	xp_lbl.text    = "⚡ XP EARNED: +500"
	coin_lbl.text  = "🪙 COINS GAINED: +120"
	stars_lbl.text = "⭐⭐⭐"
	
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.4)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	var star_tw: Tween = create_tween().set_loops()
	star_tw.tween_property(stars_lbl, "modulate", Color("#FFD700"), 0.5)
	star_tw.tween_property(stars_lbl, "modulate", Color.WHITE, 0.5)
