extends Node2D

@export var speed: float = 5.0

@export var eraser_durability: float = 100.0
var current_eraser_durability: float = 1.0 :
	set(value):
		current_eraser_durability = value
		$TextureProgressBar.value = current_eraser_durability
		if current_eraser_durability <= 0.0:
			queue_free()
@export var durability_decrease_rate: float = 2.0

var pixels_moved_last_frame: float = 0.0 
var last_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureProgressBar.max_value = eraser_durability
	current_eraser_durability = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var target_pos = get_global_mouse_position()
	
	global_position = global_position.lerp(target_pos, speed * delta)
	
	pixels_moved_last_frame = global_position.distance_to(last_position)
	
	last_position = global_position
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_eraser_durability -= durability_decrease_rate * delta * (pixels_moved_last_frame / 15)
