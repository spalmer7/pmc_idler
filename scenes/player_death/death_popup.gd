extends PopupPanel

signal player_respawned

func _ready() -> void:
	$DeathContainer/RespawnButton.pressed.connect(_on_respawn_pressed)
	print("Button Connected test")

func _on_respawn_pressed() -> void:
	print("button pressed test")
	emit_signal("player_respawned")
