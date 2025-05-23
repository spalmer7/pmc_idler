extends Node

var current_save_path := ""
var save_data := {}

func save_game():
	if current_save_path == "":
		printerr("No save path")
		return

	print("Saving to: ", current_save_path)
	
	var file = FileAccess.open(current_save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
	else:
		printerr("Failed to open save file for writing")


func load_game(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			save_data = data
			current_save_path = path
			print("Loaded save from %s" % path)

		# Loads skills
			SkillManager.load_skills_from_save(save_data.get("skills", {}))
			return true

	return false

func create_new_character(save_name: String) -> void:
	# Create directory for saves
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
		var success = dir.make_dir("saves")
		print("Creating 'saves' directory: ", success)

	var save = {
		"name": save_name,
		"skills": {
				"Accuracy": { "xp": 0, "level": 1  },
				"Firepower": { "xp": 0, "level": 1  },
				"Resilience": { "xp": 0, "level": 1 }, 
				"Vitality": { "xp": 0, "level": 10 }
		}
	}

	var filename = "user://saves/%s.json" % save_name
	print("Creating new save file at: ", filename)
	var file = FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(JSON.stringify(save))
	file.close()
	
	current_save_path = filename
	save_data = save
