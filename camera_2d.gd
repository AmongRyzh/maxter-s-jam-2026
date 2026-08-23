extends Camera2D

@export var SHAKE_FADE : float = 5.0

var shake_strength : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func apply_shake(strength : float = 30.0, shake_fade : float = 0.5):
	shake_strength = strength
	if shake_fade > 0.0:
		SHAKE_FADE = shake_fade

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, SHAKE_FADE * 0.17)
		
		offset = rand_offset()

func rand_offset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
