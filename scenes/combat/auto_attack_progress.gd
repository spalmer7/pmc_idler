extends ProgressBar

@export var attack_timer: Timer
@export var combat_script: Node

var elapsed_time := 0.0

func _ready() -> void:
	if attack_timer:
		max_value = attack_timer.wait_time
		value = 0
		attack_timer.timeout.connect(_on_attack_timeout)

func _process(delta: float) -> void:
	if !attack_timer or !combat_script or not attack_timer.is_stopped():
		elapsed_time += delta
		value = clamp(elapsed_time, 0.0, max_value)
	else:
		value = 0
		elapsed_time = 0

func _on_attack_timeout() -> void:
	elapsed_time = 0.0
	value = 0
