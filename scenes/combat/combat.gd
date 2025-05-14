class_name Combat
extends Control

@export var enemy_data: EnemyData
@onready var xp_bar = $XPBar
@onready var vitality_bar = $VitalityBar
@onready var enemy_hp_bar = $EnemyHealthBar
@onready var player_hp_bar = $VBoxContainer/PlayerHealthBar
@onready var hp_regen_timer = $HPRegenTimer


var current_player_health: int
var max_player_health: int
var enemy_health: int
var combat_logs: Array[String] = []

#  Initialization 
func _ready() -> void:
	(%AttackButton as Button).pressed.connect(_on_button_pressed)
	SkillManager.level_up.connect(_on_level_up)
	SkillManager.xp_changed.connect(_on_xp_changed)

	_update_health_from_vitality()
	enemy_health = enemy_data.max_health
	enemy_hp_bar.update_enemy_hp(enemy_health, enemy_data.max_health)
	player_hp_bar.update_player_hp(current_player_health, max_player_health)
	_update_stats()
	
	# Setting up HP regen
	hp_regen_timer.timeout.connect(_on_regen_tick)

#  Vitality-Based HP Setup 
func _update_health_from_vitality() -> void:
	var vit_level = SkillManager.get_level("Vitality")
	max_player_health = vit_level
	
	if current_player_health == 0:
		current_player_health = max_player_health
	
	player_hp_bar.update_player_hp(current_player_health, max_player_health)

# 60 second HP regeneration
func _on_regen_tick() -> void:
	if current_player_health < max_player_health:
		current_player_health += 1
		player_hp_bar.update_player_hp(current_player_health, max_player_health)
		print("Health regenerated, new health: %d" % current_player_health)



#  XP bar updates 
func _on_xp_changed(skill_name: String, _current_xp: int) -> void:
	if skill_name == "Firearms Training": 
		xp_bar.value = SkillManager.get_xp(skill_name)
		xp_bar.max_value = SkillManager.get_max_xp(skill_name)
	elif skill_name == "Vitality":
		player_hp_bar.update_player_hp(current_player_health, max_player_health)

#  UI stats display 
func _update_stats() -> void:
	(%CombatInfo as Label).text = "Firearms Training %d\nVIT %d\nHP: %d/%d\nEnemy HP: %d" % [
		SkillManager.get_level("Firearms Training"),
		SkillManager.get_level("Vitality"),
		current_player_health,
		max_player_health,
		enemy_health
	]

# Respawn enemy 
func _respawn_enemy() -> void:
	enemy_health = enemy_data.max_health
	enemy_hp_bar.update_enemy_hp(enemy_health, enemy_data.max_health)
	_update_stats()
	combat_logs.append("A new enemy has appeared.")
	_update_combat_logs()

#  Button press triggers combat 
func _on_button_pressed() -> void:
	if enemy_health > 0:
		var damage = _calculate_damage()
		enemy_health = max(enemy_health - damage, 0)

		# Main XP gain
		var main_skill := "Firearms Training"
		var xp_gain = int(damage * 1.2)
		SkillManager.add_xp(main_skill, xp_gain)

		# Vitality XP gain
		var vitality_xp = int(xp_gain * 0.33)

		# Log XP
		if damage > 0:
			combat_logs.append("You hit for %d damage." % damage)
			combat_logs.append("%d XP to %s" % [xp_gain, main_skill.capitalize()])
			combat_logs.append("%d XP to Vitality" % vitality_xp)
		elif damage == 0:
			combat_logs.append("You missed!")


		# UI updates
		vitality_bar.update_bar()
		xp_bar.update_bar()
		player_hp_bar.update_player_hp(current_player_health, max_player_health)
		enemy_hp_bar.update_enemy_hp(enemy_health, enemy_data.max_health)

		if enemy_health > 0:
			_enemy_attack()

		_update_stats()
		_update_combat_logs()

	if enemy_health == 0:
		print("No damage done, enemy killed")
		combat_logs.append("%s neutralized... respawning" % enemy_data.name)
		await get_tree().create_timer(0.5).timeout
		print("Respawning")
		_update_combat_logs()
		await get_tree().create_timer(0.5).timeout
		print("Enemy respawned")
		_respawn_enemy()
	
	if current_player_health < max_player_health and hp_regen_timer.is_stopped():
		hp_regen_timer.start()

# Damage formula based on firearm + handling 
func _calculate_damage() -> int:
	var accuracy = SkillManager.get_level("Firearms Training")
	var max_hit = int(5 + SkillManager.get_level("Weapon Handling") - enemy_data.enemy_defence)
	var hit_chance = get_hit_chance(accuracy)
	var roll = randi() % 100
	
	print("Roll: %d | Chance: %d%% | Max Hit: %d" % [roll, hit_chance, max_hit])
	
	if roll < hit_chance:
		return randi_range(1, max_hit)
	else:
		return 0

func get_hit_chance(accuracy: int) -> float:
	var base_accuracy : float = 2
	return (accuracy / (accuracy + base_accuracy)) * 100



# Enemy attacks back 
func _enemy_attack() -> void:
	var enemy_damage = randi_range(enemy_data.enemy_min_damage, enemy_data.enemy_max_damage)
	if current_player_health > 0:
		current_player_health -= enemy_damage
		current_player_health = max(current_player_health, 0)
		player_hp_bar.update_player_hp(current_player_health, max_player_health)
		print("Damage done %d, current hp %d" % [enemy_damage, current_player_health])
	
	combat_logs.append("%s did %d damage" % [enemy_data.name, enemy_damage])
	if current_player_health < max_player_health and hp_regen_timer.is_stopped():
		hp_regen_timer.start()

# Logging levels
func _on_level_up(skill_name: String, new_level: int) -> void:
	if skill_name == "Vitality":
		_update_health_from_vitality()
		_update_stats()
		player_hp_bar.update_player_hp(current_player_health, max_player_health)
	combat_logs.append("%s leveled up to %d!" % [skill_name.capitalize(), new_level])
	_update_combat_logs()
	_update_stats()

#  Update combat log UI 
func _update_combat_logs() -> void:
	(%CombatLog as Label).text = "\n".join(combat_logs)
	await get_tree().process_frame
	var scroll = %CombatLogScroll as ScrollContainer
	scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value
