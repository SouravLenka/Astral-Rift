## PauseMenu.gd
## Polished pause overlay with glowing buttons.
## Activated by GameEvents.game_paused signal or ESC/P key.
extends CanvasLayer

@onready var overlay: ColorRect    = $Overlay
@onready var panel: PanelContainer = $CenterContainer/Panel
@onready var resume_btn: Button    = $CenterContainer/Panel/Margin/VBox/ResumeBtn
@onready var restart_btn: Button   = $CenterContainer/Panel/Margin/VBox/RestartBtn
@onready var settings_btn: Button  = $CenterContainer/Panel/Margin/VBox/SettingsBtn
@onready var quit_btn: Button      = $CenterContainer/Panel/Margin/VBox/QuitBtn

func _ready() -> void:
	visible = false
	_style_panel()
	_style_buttons()
	
	GameEvents.game_paused.connect(show_menu)
	GameEvents.game_resumed.connect(hide_menu)
	
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30F2")
	style.border_color = Color("#4FDFFF", 0.8)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.shadow_color = Color(0, 0, 0, 0.7)
	style.shadow_size = 12
	panel.add_theme_stylebox_override("panel", style)

func _style_buttons() -> void:
	for btn in [resume_btn, restart_btn, settings_btn, quit_btn]:
		_wire_hover(btn)
		var btn_style: StyleBoxFlat = StyleBoxFlat.new()
		btn_style.bg_color = Color("#101C30")
		btn_style.border_color = Color("#4FDFFF", 0.5)
		btn_style.set_border_width_all(1)
		btn_style.corner_radius_top_left = 6
		btn_style.corner_radius_top_right = 6
		btn_style.corner_radius_bottom_left = 6
		btn_style.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", btn_style)
		
		var hover_style: StyleBoxFlat = btn_style.duplicate() as StyleBoxFlat
		hover_style.bg_color = Color("#1A2D4D")
		hover_style.border_color = Color("#4FDFFF", 1.0)
		btn.add_theme_stylebox_override("hover", hover_style)

func show_menu() -> void:
	visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.85, 0.85)
	panel.pivot_offset = panel.size / 2.0
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.3)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func hide_menu() -> void:
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(panel, "modulate:a", 0.0, 0.2)
	tw.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.2)
	await tw.finished
	visible = false

func _wire_hover(btn: Button) -> void:
	btn.mouse_entered.connect(func(): _glow_on(btn))
	btn.mouse_exited.connect(func(): _glow_off(btn))

func _glow_on(btn: Button) -> void:
	create_tween().tween_property(btn, "scale", Vector2(1.05, 1.05), 0.12).set_ease(Tween.EASE_OUT)

func _glow_off(btn: Button) -> void:
	create_tween().tween_property(btn, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)

func _on_resume() -> void:
	GameEvents.game_resumed.emit()

func _on_restart() -> void:
	hide_menu()
	get_tree().reload_current_scene()

func _on_settings() -> void:
	pass

func _on_quit() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
