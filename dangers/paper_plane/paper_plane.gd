extends Area2D
class_name PaperPlane

@export var speed : float

var target_direction : Vector2 :
	set(value):
		target_direction = value
		rotation_degrees = rad_to_deg(target_direction.angle()) + 90

# Called when the node enters the scene tree for the first time.
func _ready():
	$QueueFreeTimer.timeout.connect(queue_free)
	
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position += target_direction * speed * delta

func _on_body_entered(body: Node2D):
	if body is Eraser and !get_tree().current_scene.is_pencil_case_opened():
		body.current_eraser_durability = 0
