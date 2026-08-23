extends Node2D
class_name PencilCase

@export var closed_position : Vector2
@export var opened_position : Vector2

var mouse_entered : bool

var opened : bool = false :
	set(value):
		opened = value
		
		if tween:
			tween.kill()
		tween = create_tween()
		
		if opened:
			if $"../CanvasLayer/PencilCaseTutorial1".visible:
				$"../CanvasLayer/PencilCaseTutorial1".hide()
				#$"../CanvasLayer/PencilCaseTutorial2".show()
			tween.tween_property(self, "global_position", opened_position, open_time).set_trans(transition_type).set_ease(ease_type)
		else:
			#if $"../CanvasLayer/PencilCaseTutorial2".visible:
				#$"../CanvasLayer/PencilCaseTutorial2".hide()
			tween.tween_property(self, "global_position", closed_position, open_time).set_trans(transition_type).set_ease(ease_type)

var tween : Tween
@export var transition_type : Tween.TransitionType
@export var ease_type : Tween.EaseType
@export var open_time : float = 0.4

@export var eraser_slots : Array[EraserSlot]

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = closed_position
	
	for slot in eraser_slots:
		slot.slot_selected.connect(func():
			if opened:
				opened = false
			$"..".on_pencil_case_eraser_slot_selected()
			)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and mouse_entered:
			opened = !opened

func _on_switcher_area_2d_mouse_entered():
	mouse_entered = true

func _on_switcher_area_2d_mouse_exited():
	mouse_entered = false
