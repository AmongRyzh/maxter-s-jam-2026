extends Node2D

@export var destroy_time : float

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(destroy_time).timeout
	queue_free()
