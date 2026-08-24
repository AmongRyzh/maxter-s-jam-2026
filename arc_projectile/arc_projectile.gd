extends CharacterBody2D
class_name ArcProjectile

var initial_speed : float
var throw_angle_degrees : float
var time : float = 0.0

var initial_position: Vector2
var throw_direction: Vector2

var z_axis = 0.0 # simulate throwing the projectile on the z-axis by adding that z-axis to the y-axis
var is_launch: bool = false
var landed: bool = false

var eraser : Eraser

@export var time_multiplier : float = 1.5

@export var rotation_speed : float = 0

func _process(delta):
	time += delta * time_multiplier
	
	if is_launch:
		z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * time - 0.5 * get_gravity().y * pow(time, 2)
		
		# If has not touched the ground yet
		if z_axis > 0:
			var x_axis: float = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * time
			global_position = initial_position + throw_direction * x_axis ## Move everything along the 'x-axis'
			
			$Projectile.position.y = -z_axis
			
			rotation_degrees += rotation_speed * delta * time_multiplier
		else:
			_z_axis_less_than_zero()
	
	move_and_slide()

func _z_axis_less_than_zero():
	landed = true

func launch_projectile(initial_pos: Vector2, direction: Vector2, desired_distance: float, desired_angle_deg: float):
	initial_position = initial_pos
	throw_direction = direction.normalized()
	
	throw_angle_degrees = desired_angle_deg
	initial_speed = pow(desired_distance * 980 / sin(2 * deg_to_rad(desired_angle_deg)), 0.5)
	
	global_position = initial_pos
	time = 0.0
	
	rotation_speed = rotation_speed * -1 if randi_range(0, 1) == 0 else rotation_speed
	
	z_axis = 0
	is_launch = true
