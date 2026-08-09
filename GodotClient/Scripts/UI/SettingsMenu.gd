## SettingsMenu.gd
## Professional settings overlay with tabs: Graphics, Audio, Controls, Gameplay, Accessibility.
extends CanvasLayer

@onready var close_btn: Button     = $Panel/Margin/VBox/CloseBtn
@onready var panel: PanelContainer = $Panel

@onready var master_slider: HSlider = $Panel/Margin/VBox/Tabs/Audio/Margin/VBox/MasterRow/MasterSlider
@onready var music_slider: HSlider  = $Panel/Margin/VBox/Tabs/Audio/Margin/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider    = $Panel/Margin/VBox/Tabs/Audio/Margin/VBox/SFXRow/SFXSlider

func _ready() -> void:
	visible = false
	_style_panel()
	close_btn.pressed.connect(hide_menu)
	
	if master_slider:
		master_slider.value_changed.connect(func(v: float): _set_vol("Master", v))
	if music_slider:
		music_slider.value_changed.connect(func(v: float): _set_vol("Music", v))
	if sfx_slider:
		sfx_slider.value_changed.connect(func(v: float): _set_vol("SFX", v))

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30F2")
	style.border_color = Color("#4FDFFF", 0.8)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.shadow_color = Color(0, 0, 0, 0.8)
	style.shadow_size = 14
	panel.add_theme_stylebox_override("panel", style)

func _set_vol(bus_name: String, val: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(val / 100.0))

func show_screen() -> void:
	visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.88, 0.88)
	panel.pivot_offset = panel.size / 2.0
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.3)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func hide_menu() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(panel, "modulate:a", 0.0, 0.2)
	await tw.finished
	visible = false
