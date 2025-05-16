extends Node

signal level_up(skill_name: String, new_level: int)
signal xp_changed(skill_name: String, current_xp: int)

var skills := {
	"Accuracy": { "level": 1, "xp": 0, "max_xp": 85 }, # Attack (accuracy)
	"Firepower": { "level": 1, "xp": 0, "max_xp": 85 }, # Strength (max damage)
	"Resilience": { "level": 1, "xp": 0, "max_xp": 85 }, # Defense
	"Vitality": { "level": 10, "xp": 0, "max_xp": 1100 } # Health, level up based on other skills xp
}

func add_xp(skill_name: String, amount: int) -> void:
	if not skills.has(skill_name):
		push_error("Skill '%s' does not exist." % skill_name)
		return

	var skill = skills[skill_name]
	skill["xp"] += amount
	emit_signal("xp_changed", skill_name, skill["xp"])

	while skill["xp"] >= skill["max_xp"]:
		skill["xp"] -= skill["max_xp"]
		skill["level"] += 1
		skill["max_xp"] = int(skill["max_xp"] * 1.25)
		emit_signal("level_up", skill_name, skill["level"])

	# Vitality gains 33% XP from combat skills
	if skill_name in ["Accuracy", "Firepower", "Resilience"]:
		_add_vitality_xp(int(amount * 0.33))

func _add_vitality_xp(amount: int) -> void:
	var skill = skills["Vitality"]
	skill["xp"] += amount
	emit_signal("xp_changed", "Vitality", skill["xp"])

	while skill["xp"] >= skill["max_xp"]:
		skill["xp"] -= skill["max_xp"]
		skill["level"] += 1
		skill["max_xp"] = int(skill["max_xp"] * 1.25)
		emit_signal("level_up", "Vitality", skill["level"])

# Retrieves the XP for a specific skill
func get_xp(skill_name: String) -> int:
	if skills.has(skill_name):
		return skills[skill_name]["xp"]
	return 0

# Retrieves the max XP for a specific skill
func get_max_xp(skill_name: String) -> int:
	if skills.has(skill_name):
		return skills[skill_name]["max_xp"]
	return 100


# Get the level of a specific skill
func get_level(skill_name: String) -> int:
	if skills.has(skill_name):
		return skills[skill_name]["level"]
	return 1  # Default to level 1 if skill doesn't exist
