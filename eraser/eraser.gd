extends Node2D

@export var speed: float = 5.0

var pixels_moved_last_frame: float = 0.0 
var last_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var target_pos = get_global_mouse_position()
	
	global_position = global_position.lerp(target_pos, speed * delta)
	
	pixels_moved_last_frame = global_position.distance_to(last_position)
	
	last_position = global_position
