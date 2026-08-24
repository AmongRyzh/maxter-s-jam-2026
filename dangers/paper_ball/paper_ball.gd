extends ArcProjectile
class_name PaperBall

var eraser : Eraser

var out_of_desk_area : bool = false :
	set(value):
		out_of_desk_area = value
		print(name, "out_of_desk_area = ", value)

### Called when the node enters the scene tree for the first time.
#func _ready():
	#body_entered.connect(_on_body_entered)
	#
	##launch_projectile(global_position, Vector2(1, 1), 400, 45)

func _process(delta):
	super(delta)
	
	if !out_of_desk_area:
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			eraser = null
			if c.get_collider() is CharacterBody2D:
				if c.get_collider() is Eraser:
					eraser = c.get_collider()
				var push_force = (15 * c.get_collider_velocity().length() / 100) + 10
				velocity += (-c.get_normal() * push_force)
	else:
		if velocity.y < -500:
			velocity.y += -velocity.y
		velocity += get_gravity() * delta
		z_index = -2

func _z_axis_less_than_zero():
	if !landed:
		$CollisionShape2D.disabled = false
		landed = true
		await get_tree().process_frame
		if eraser and !get_tree().current_scene.is_pencil_case_opened():
			eraser.current_eraser_durability = 0
	else:
		$CollisionShape2D.disabled = true
		$CollisionShape2D2.disabled = false

#func _on_body_entered(body: Node2D):
	#if body is Eraser:
		#eraser = body
#
#func _on_body_exited(body: Node2D):
	#if body is Eraser:
		#eraser = null
