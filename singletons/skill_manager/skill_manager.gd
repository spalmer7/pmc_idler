extends Node

signal level_up(skill_name: String, new_level: int)
signal xp_changed(skill_name: String, current_xp: int)

var latest_skill : String = "Accuracy"

var skills := {
	"Accuracy": { "level": 1, "xp": 0, "max_xp": 85 }, # Attack (accuracy)
	"Firepower": { "level": 1, "xp": 0, "max_xp": 85 }, # Strength (max damage)
	"Resilience": { "level": 1, "xp": 0, "max_xp": 85 }, # Defense
	"Vitality": { "level": 10, "xp": 0, "max_xp": 626 } # Health, level up based on other skills xp
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
	
	latest_skill = skill_name

	save_skill_data()
	SaveManager.save_game()

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

func calculate_max_xp(_skill_name: String, level: int) -> int:
	var base_xp := 85
	var max_xp := base_xp
	for i in range(1, level):
		max_xp = int(max_xp * 1.25)
	
	return max_xp

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

# Loads previous skill levels
func load_skills_from_save(saved_skills: Dictionary) -> void:
	for skill_name in skills.keys():
		if saved_skills.has(skill_name):
			var saved = saved_skills[skill_name]
			var level = saved.get("level", 1)
			var xp = saved.get("xp", 0)
			skills[skill_name]["level"] = level
			skills[skill_name]["xp"] = xp
			skills[skill_name]["max_xp"] = calculate_max_xp(skill_name, level)

			emit_signal("xp_changed", skill_name, xp)
			emit_signal("level_up", skill_name, level)

func save_skill_data() -> void:
	if not SaveManager.save_data.has("skills"):
		SaveManager.save_data["skills"] = {}
	for skill in skills.keys():
		var data = {
			"xp": skills[skill]["xp"],
			"level": skills[skill]["level"]
		}
		SaveManager.save_data["skills"][skill] = data
