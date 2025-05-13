extends Node

@export var skill_name: String  # "firearms_training"

@onready var bar: ProgressBar = $"."
@onready var label: Label = $XPLabel

func _ready() -> void:
	SkillManager.xp_changed.connect(_on_xp_changed)
	update_bar()

func _on_xp_changed(changed_skill: String, _current_xp: int) -> void:
	if changed_skill == skill_name:
		update_bar()

func update_bar():
	var current = SkillManager.get_xp(skill_name)
	var max_bar = SkillManager.get_max_xp(skill_name)
	bar.value = current
	bar.max_value = max_bar
	label.text = "%s %d / %d" % [skill_name, current, max_bar]
	
