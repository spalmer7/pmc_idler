extends Node

@onready var bar: ProgressBar = $"."
@onready var label: Label = $XPLabel

func _ready() -> void:
	SkillManager.xp_changed.connect(_on_xp_changed)
	update_bar()

func _on_xp_changed(_changed_skill: String, _current_xp: int) -> void:
		update_bar()

func update_bar():
	var skill_name = SkillManager.latest_skill
	var current = SkillManager.get_xp(skill_name)
	var max_bar = SkillManager.get_max_xp(skill_name)
	bar.value = current
	bar.max_value = max_bar
	label.text = "%s %d / %d" % [skill_name, current, max_bar]
	
