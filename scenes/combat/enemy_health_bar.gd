extends Node

@onready var bar = $"."
@onready var label = $EnemyHealthLabel

func _ready() -> void:
	pass

func update_enemy_hp(current_hp: int, max_hp: int):
	bar.value = current_hp
	bar.max_value = max_hp
	label.text = "%d / %d HP" % [current_hp, max_hp]
