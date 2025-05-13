extends Node

@onready var bar: ProgressBar = $"."
@onready var label: Label = $VitalityXPLabel

func _ready() -> void:
	SkillManager.xp_changed.connect(_on_xp_changed)
	update_bar()

func _on_xp_changed(changed_skill: String, _current_xp: int) -> void:
	if changed_skill == "Vitality":
		update_bar()

func update_bar():
	var current = SkillManager.get_xp("Vitality")
	var max_xp = SkillManager.get_max_xp("Vitality")
	bar.value = current
	bar.max_value = max_xp
	label.text = "Vitality %d / %d" % [current, max_xp]
