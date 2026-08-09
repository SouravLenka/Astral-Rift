## DamageNumber.gd
## Floating damage indicator (normal, crit, heal, shield) with animated float & scale.
extends Node2D

@onready var label: Label = $Label

func setup(value: int, type: String) -> void:
	label.text = str(value)
	
	var col: Color = Color.WHITE
	var font_scale: Vector2 = Vector2.ONE
	
	match type:
		"crit":
			col = Color("#FF8C42")
			label.text = "CRIT " + str(value)
			font_scale = Vector2(1.4, 1.4)
		"heal":
			col = Color("#5EFF7A")
			label.text = "+" + str(value)
		"shield":
			col = Color("#4FDFFF")
		_:
			col = Color.WHITE
			
	label.add_theme_color_override("font_color", col)
	scale = font_scale * 0.7
	modulate.a = 1.0
	
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(self, "position:y", position.y - 45.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(self, "scale", font_scale, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "modulate:a", 0.0, 0.35).set_delay(0.4)
	
	await tw.finished
	queue_free()
