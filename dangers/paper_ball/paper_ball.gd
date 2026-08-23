extends CharacterBody2D
class_name PaperBall

var initial_speed : float
var throw_angle_degrees : float
var time : float = 0.0

var initial_position: Vector2
var throw_direction: Vector2

var z_axis = 0.0 # simulate throwing the projectile on the z-axis by adding that z-axis to the y-axis
var is_launch: bool = false
var landed: bool = false

var eraser : Eraser

@export var time_multiplier : float = 6.0

### Called when the node enters the scene tree for the first time.
#func _ready():
	#body_entered.connect(_on_body_entered)
	#
	##launch_projectile(global_position, Vector2(1, 1), 400, 45)

func _process(delta):
	time += delta * time_multiplier
	
	if is_launch:
		z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * time - 0.5 * get_gravity().y * pow(time, 2)
		
		# If has not touched the ground yet
		if z_axis > 0:
			var x_axis: float = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * time
			global_position = initial_position + throw_direction * x_axis ## Move everything along the 'x-axis'
			
			$Projectile.position.y = -z_axis
		else:
			if !landed:
				$CollisionShape2D.disabled = false
				landed = true
				if eraser and !get_tree().current_scene.is_pencil_case_opened():
					eraser.current_eraser_durability = 0
			else:
				$CollisionShape2D.disabled = true
				$CollisionShape2D2.disabled = false
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is CharacterBody2D:
			var push_force = (15 * c.get_collider_velocity().length() / 100) + 10
			velocity += (-c.get_normal() * push_force)

func launch_projectile(initial_pos: Vector2, direction: Vector2, desired_distance: float, desired_angle_deg: float):
	initial_position = initial_pos
	throw_direction = direction.normalized()
	
	throw_angle_degrees = desired_angle_deg
	initial_speed = pow(desired_distance * 980 / sin(2 * deg_to_rad(desired_angle_deg)), 0.5)
	
	global_position = initial_pos
	time = 0.0
	
	z_axis = 0
	is_launch = true

#func _on_body_entered(body: Node2D):
	#if body is Eraser:
		#eraser = body
#
#func _on_body_exited(body: Node2D):
	#if body is Eraser:
		#eraser = null
