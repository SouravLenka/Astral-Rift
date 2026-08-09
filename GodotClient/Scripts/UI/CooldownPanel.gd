## CooldownPanel.gd
## Manages ability cooldown displays (dash, ultimate) and active power-up icons.
## Set player_id = 0 for P1, 1 for P2.
extends HBoxContainer

@export var player_id: int = 0

const POWERUP_SCENE: PackedScene = preload("res://Scenes/UI/PowerUpIcon.tscn")

@onready var dash_bar: ProgressBar    = $DashCooldown/Bar
@onready var dash_label: Label        = $DashCooldown/Label
@onready var ult_bar: ProgressBar     = $UltCooldown/Bar
@onready var ult_label: Label         = $UltCooldown/Label
@onready var powerup_container: HBoxContainer = $PowerUps

var _dash_max: float = 1.0
var _ult_max: float  = 1.0

func _ready() -> void:
	GameEvents.ability_cooldown.connect(_on_cooldown)
	GameEvents.powerup_acquired.connect(_on_powerup)

func _on_cooldown(p_id: int, ability: String, remaining: float) -> void:
	if p_id != player_id: return
	match ability:
		"dash":
			dash_bar.value = (1.0 - (remaining / _dash_max)) * 100.0
			dash_label.text = "%.1fs" % remaining if remaining > 0.0 else "READY"
		"ultimate":
			ult_bar.value = (1.0 - (remaining / _ult_max)) * 100.0
			ult_label.text = "%.1fs" % remaining if remaining > 0.0 else "READY"

func _on_powerup(p_id: int, pu_name: String, duration: float) -> void:
	if p_id != player_id: return
	var icon: Node = POWERUP_SCENE.instantiate()
	powerup_container.add_child(icon)
	if icon.has_method("setup"):
		icon.setup(pu_name, duration)
