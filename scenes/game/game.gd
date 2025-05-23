extends Node

@onready var death_popup = $DeathPopup
@onready var combat = $Combat

func _ready() -> void:
	$SaveSelect.show()
	$Combat.hide()
	$DeathPopup.hide()
	death_popup.player_respawned.connect(respawn_player)

func handle_player_death() -> void:
	death_popup.show()
	get_tree().paused = true

func respawn_player() -> void:
	get_tree().paused = false
	death_popup.hide()
	combat.player_respawn()
