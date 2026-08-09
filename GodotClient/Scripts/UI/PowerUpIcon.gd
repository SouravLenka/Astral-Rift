## PowerUpIcon.gd
## Displays an active power-up with name, icon, countdown timer bar, and pulsing glow.
extends PanelContainer

@onready var name_label: Label   = $Margin/VBox/NameLabel
@onready var timer_label: Label  = $Margin/VBox/TimerLabel
@onready var progress: ProgressBar = $Margin/VBox/Progress

var _duration: float = 0.0
var _elapsed: float  = 0.0
var _pu_name: String = ""

func setup(pu_name: String, duration: float) -> void:
	_pu_name = pu_name
	_duration = duration
	_elapsed = 0.0
	name_label.text = pu_name.to_upper()
	timer_label.text = "%.1fs" % duration
	progress.max_value = duration
	progress.value = duration
	
	_style_panel()
	_pulse()

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#101C30E6")
	style.border_color = Color("#FF8C42", 0.8)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	add_theme_stylebox_override("panel", style)
	
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = Color("#FF8C42")
	fill.corner_radius_top_left = 2
	fill.corner_radius_top_right = 2
	fill.corner_radius_bottom_left = 2
	fill.corner_radius_bottom_right = 2
	progress.add_theme_stylebox_override("fill", fill)

func _process(delta: float) -> void:
	if _duration <= 0.0:
		return
	_elapsed += delta
	var remaining: float = max(0.0, _duration - _elapsed)
	timer_label.text = "%.1fs" % remaining
	progress.value = remaining
	if remaining <= 0.0:
		queue_free()

func _pulse() -> void:
	var tw: Tween = create_tween().set_loops()
	tw.tween_property(self, "modulate:a", 0.7, 0.4)
	tw.tween_property(self, "modulate:a", 1.0, 0.4)
