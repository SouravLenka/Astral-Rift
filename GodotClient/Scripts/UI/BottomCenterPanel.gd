## BottomCenterPanel.gd
## Manages the notification queue – instances Notification scenes and stacks them.
extends Control

const NOTIF_SCENE: PackedScene = preload("res://Scenes/UI/Notification.tscn")

@onready var vbox: VBoxContainer = $VBox

func _ready() -> void:
	GameEvents.notification.connect(_on_notification)

func _on_notification(text: String, icon_key: String) -> void:
	var notif: Node = NOTIF_SCENE.instantiate()
	vbox.add_child(notif)
	if notif.has_method("setup"):
		notif.setup(text, icon_key)
