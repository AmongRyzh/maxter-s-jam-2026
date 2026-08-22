extends Area2D

var initial_speed : float
var throw_angle_degrees : float
var time : float = 0.0

var initial_position: Vector2
var throw_direction: Vector2

var z_axis = 0.0 # simulate throwing the projectile on the z-axis by adding that z-axis to the y-axis
var is_launch: bool = false
var landed: bool = false

var eraser : Eraser

## Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	
	#launch_projectile(global_position, Vector2(1, 1), 400, 45)

func _process(delta):
	time += delta
	
	if is_launch:
		z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * time - 0.5 * gravity * pow(time, 2)
		
		# If has not touched the ground yet
		if z_axis > 0:
			var x_axis: float = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * time
			global_position = initial_position + throw_direction * x_axis ## Move everything along the 'x-axis'
			
			$Projectile.position.y = -z_axis
		else:
			if !landed:
				landed = true
				if eraser:
					eraser.current_eraser_durability = 0

func launch_projectile(initial_pos: Vector2, direction: Vector2, desired_distance: float, desired_angle_deg: float):
	initial_position = initial_pos
	throw_direction = direction.normalized()
	
	throw_angle_degrees = desired_angle_deg
	initial_speed = pow(desired_distance * gravity / sin(2 * deg_to_rad(desired_angle_deg)), 0.5)
	
	global_position = initial_pos
	time = 0.0
	
	z_axis = 0
	is_launch = true

func _on_body_entered(body: Node2D):
	if body is Eraser:
		eraser = body

func _on_body_exited(body: Node2D):
	if body is Eraser:
		eraser = null
