extends ArcProjectile
class_name PaperBall

### Called when the node enters the scene tree for the first time.
#func _ready():
	#body_entered.connect(_on_body_entered)
	#
	##launch_projectile(global_position, Vector2(1, 1), 400, 45)

func _process(delta):
	super(delta)
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is CharacterBody2D:
			var push_force = (15 * c.get_collider_velocity().length() / 100) + 10
			velocity += (-c.get_normal() * push_force)

func _z_axis_less_than_zero():
	if !landed:
		$CollisionShape2D.disabled = false
		landed = true
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
