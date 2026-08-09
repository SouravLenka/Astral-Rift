## ComboDisplay.gd
## Animated floating combo banner (COMBO x8, DOMINATING, UNSTOPPABLE).
extends Control

@onready var label: Label = $Panel/Label
@onready var panel: PanelContainer = $Panel

const CYAN: Color   = Color("#4FDFFF")
const PURPLE: Color = Color("#C85BFF")
const GOLD: Color   = Color("#FFD700")

func setup(p_id: int, multiplier: int, text_str: String) -> void:
	label.text = text_str.to_upper()
	
	var accent: Color = CYAN if p_id == 0 else PURPLE
	if multiplier >= 20: accent = GOLD
	
	label.add_theme_color_override("font_color", accent)
	
	# Panel background
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30E6")
	style.border_color = accent
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	
	panel.scale = Vector2(0.5, 0.5)
	panel.pivot_offset = panel.size / 2.0
	modulate.a = 1.0
	
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE * 1.2, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "position:y", position.y - 30.0, 0.9).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.6)
	
	await tw.finished
	queue_free()
