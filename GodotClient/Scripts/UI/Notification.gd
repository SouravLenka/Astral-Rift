## Notification.gd
## Slide-in / fade-out notification toast.
## Instanced by BottomCenterPanel.gd when GameEvents.notification fires.
extends PanelContainer

@onready var msg_label: Label = $Margin/HBox/MsgLabel

func setup(text: String, _icon_key: String) -> void:
	msg_label.text = text.to_upper()
	
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30E6")
	style.border_color = Color("#4FDFFF", 0.8)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 6
	add_theme_stylebox_override("panel", style)
	
	modulate.a = 0.0
	position.y += 35
	
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.25)
	tw.tween_property(self, "position:y", position.y - 35, 0.25).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(2.2).timeout
	
	var tw2: Tween = create_tween()
	tw2.tween_property(self, "modulate:a", 0.0, 0.35)
	await tw2.finished
	queue_free()
