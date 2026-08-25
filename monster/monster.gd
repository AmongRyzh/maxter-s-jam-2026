extends AnimatableBody2D

@export var x_min : int = 100
@export var x_max : int = 1052
@export var y_min : int = 100
@export var y_max : int = 548

var current_destination : Vector2
@export var speed : float = 10

@export var min_opaque_pixel_count : int = 100

func _ready():
	$CooldownTimer.timeout.connect(_cooldown_timer_timeout)
	
	$CooldownTimer.timeout.emit()
	
	$CheckOpaquePixelTimer.timeout.connect(func():
		var opaque_pixel_count : int = get_tree().current_scene.get_opaque_pixel_count($Sprite2D.texture)
		if opaque_pixel_count <= min_opaque_pixel_count:
			get_tree().current_scene.play_sfx_by_name('monster_death')
			queue_free())

func _physics_process(delta):
	if global_position.distance_squared_to(current_destination) > 1200:
		global_position += global_position.direction_to(current_destination) * speed * delta
	else:
		if $CooldownTimer.is_stopped():
			$CooldownTimer.start()
	
	#print(get_tree().current_scene.get_opaque_pixel_count($Sprite2D.texture))

func _cooldown_timer_timeout():
	current_destination = Vector2(randf_range(x_min, x_max), randf_range(y_min, y_max))
