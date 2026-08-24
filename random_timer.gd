extends Timer
class_name RandomTimer

@export var random_range : float

@export var pick_random_wait_time_again_on_restart : bool

@export var decrease_wait_time_by : float
@export var report : bool

var initial_wait_time : float

func _ready():
	initial_wait_time = wait_time

func random_start(time := -1.0, range := -1.0) -> void:
	var normal_wait_time = time if time > 0.0 else initial_wait_time
	
	var actual_range = range if range > 0.0 else random_range
	
	var actual_wait_time = randf_range(normal_wait_time - actual_range, normal_wait_time + actual_range)
	
	if pick_random_wait_time_again_on_restart and !timeout.is_connected(random_start):
		autostart = false
		one_shot = true
		timeout.connect(random_start)
	
	start(actual_wait_time)

func _physics_process(delta):
	if report:
		prints(delta, decrease_wait_time_by * delta, initial_wait_time)
	initial_wait_time -= decrease_wait_time_by * delta * 0.001
