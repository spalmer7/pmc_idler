extends ProgressBar

@export var regen_timer: Timer
@export var combat_script: Node

func _ready():
	if regen_timer:
		max_value = regen_timer.wait_time
		value = 0
		regen_timer.timeout.connect(_on_regen_timeout)
	set_process(true)

func _process(_delta):
	if !regen_timer or !combat_script:
		return

	var current_hp = combat_script.current_player_health
	var max_hp = combat_script.max_player_health

	if current_hp >= max_hp:
		value = 0
		return

	if regen_timer.is_stopped():
		value = 0
	else:
		value = regen_timer.wait_time - regen_timer.time_left

func _on_regen_timeout():
	value = regen_timer.wait_time
	await get_tree().process_frame
	value = 0
