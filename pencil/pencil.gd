extends Area2D

var annihilated: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween := create_tween()
	
	var subtween_rotation : Tween = create_tween()
	subtween_rotation.set_parallel(false)
	subtween_rotation.tween_property($Sprite2D, "rotation_degrees", -30, 0.04)
	subtween_rotation.tween_property($Sprite2D, "rotation_degrees", 30, 0.04)
	
	var subtween_position : Tween = create_tween()
	subtween_position.set_parallel(false)
	subtween_position.tween_property($Sprite2D, "position", Vector2(-26, 0), 0.04)
	subtween_position.tween_property($Sprite2D, "position", Vector2(26, 0), 0.04)
	
	for i in 2:
		tween.tween_subtween(subtween_rotation)
		tween.parallel().tween_subtween(subtween_position)
	
	tween.tween_callback(func():
		$CPUParticles2D.emitting = false
		
		tween.kill()
		tween = create_tween()
		
		tween.tween_property($Sprite2D, "modulate", Color.TRANSPARENT, 0.05)
		
		$CollisionShape2D.disabled = true
		
		await $CPUParticles2D.finished
		queue_free()
		)


func _on_body_entered(body):
	if body is Eraser:
		body.current_eraser_durability = 0
		annihilated = true
