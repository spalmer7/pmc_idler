extends Control

@onready var save_buttons = {
	"SaveSlot1": "Save1",
	"SaveSlot2": "Save2",
	"SaveSlot3": "Save3"
}

func _ready() -> void:
	for button_name in save_buttons.keys():
		var button = get_node("SaveMarginContainer/SaveContainer/" + button_name)
		button.pressed.connect(_on_save_slot_pressed.bind(button_name))

func _on_save_slot_pressed(slot_name: String) -> void:
	var save_name = save_buttons[slot_name]
	var path = "user://saves/%s.json" % save_name
	
	if SaveManager.load_game(path):
		print("Loaded existing save: ", save_name)
	else:
		print("Creating new save: ", save_name)
		SaveManager.create_new_character(save_name)

	var game_node = get_tree().root.get_node("game")
	game_node.get_node("Combat").show()
	game_node.get_node("SaveSelect").hide()
	game_node.get_node("Combat").player_respawn()
