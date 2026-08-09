## MainMenu.gd
## Animated main menu with moving starfield, nebula, glowing buttons, and modal overlays.
extends Control

@onready var play_btn: Button     = $Center/Panel/Margin/VBox/PlayBtn
@onready var hangar_btn: Button   = $Center/Panel/Margin/VBox/HangarBtn
@onready var settings_btn: Button = $Center/Panel/Margin/VBox/SettingsBtn
@onready var credits_btn: Button  = $Center/Panel/Margin/VBox/CreditsBtn
@onready var exit_btn: Button     = $Center/Panel/Margin/VBox/ExitBtn

@onready var logo_label: Label    = $LogoArea/LogoLabel
@onready var sub_label: Label     = $LogoArea/SubLabel
@onready var nebula: ColorRect    = $Nebula
@onready var panel: PanelContainer = $Center/Panel

@onready var hangar_modal: PanelContainer  = $HangarModal
@onready var credits_modal: PanelContainer = $CreditsModal

var _time: float = 0.0

func _ready() -> void:
	hangar_modal.visible = false
	credits_modal.visible = false
	
	_style_panel()
	_style_buttons()
	_animate_logo()
	
	play_btn.pressed.connect(_on_play)
	hangar_btn.pressed.connect(_on_hangar)
	settings_btn.pressed.connect(_on_settings)
	credits_btn.pressed.connect(_on_credits)
	exit_btn.pressed.connect(func(): get_tree().quit())
	
	$HangarModal/Margin/VBox/CloseHangarBtn.pressed.connect(func(): hangar_modal.visible = false)
	$CreditsModal/Margin/VBox/CloseCreditsBtn.pressed.connect(func(): credits_modal.visible = false)

func _process(delta: float) -> void:
	_time += delta
	nebula.modulate = Color.from_hsv(fmod(_time * 0.02, 1.0), 0.5, 0.22, 0.45)

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30E6")
	style.border_color = Color("#4FDFFF", 0.8)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.shadow_color = Color(0, 0, 0, 0.8)
	style.shadow_size = 14
	panel.add_theme_stylebox_override("panel", style)
	
	hangar_modal.add_theme_stylebox_override("panel", style.duplicate() as StyleBoxFlat)
	credits_modal.add_theme_stylebox_override("panel", style.duplicate() as StyleBoxFlat)

func _style_buttons() -> void:
	for btn in [play_btn, hangar_btn, settings_btn, credits_btn, exit_btn]:
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

func _animate_logo() -> void:
	logo_label.modulate.a = 0.0
	logo_label.position.y -= 20
	sub_label.modulate.a = 0.0
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(logo_label, "modulate:a", 1.0, 0.8)
	tw.tween_property(logo_label, "position:y", logo_label.position.y + 20, 0.8).set_ease(Tween.EASE_OUT)
	tw.tween_property(sub_label, "modulate:a", 1.0, 1.2).set_delay(0.5)
	
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(logo_label, "modulate:v", 1.2, 1.5).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(logo_label, "modulate:v", 1.0, 1.5).set_ease(Tween.EASE_IN_OUT)

func _wire_hover(btn: Button) -> void:
	btn.mouse_entered.connect(func(): _glow_on(btn))
	btn.mouse_exited.connect(func(): _glow_off(btn))

func _glow_on(btn: Button) -> void:
	create_tween().tween_property(btn, "scale", Vector2(1.05, 1.05), 0.12).set_ease(Tween.EASE_OUT)

func _glow_off(btn: Button) -> void:
	create_tween().tween_property(btn, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)

func _on_play() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	await tw.finished
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_hangar() -> void:
	hangar_modal.visible = true

func _on_settings() -> void:
	pass

func _on_credits() -> void:
	credits_modal.visible = true
