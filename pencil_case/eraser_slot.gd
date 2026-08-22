extends Area2D
class_name EraserSlot

var is_mouse_entered : bool

signal slot_selected

func _ready():
	$TextureProgressBar.max_value = $Cooldown.wait_time

func _process(delta):
	$TextureProgressBar.value = $Cooldown.time_left

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and is_mouse_entered:
			if $Cooldown.is_stopped() and get_parent().opened:
				$Cooldown.start()
				slot_selected.emit()


func _on_mouse_entered():
	is_mouse_entered = true

func _on_mouse_exited():
	is_mouse_entered = false
