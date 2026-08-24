extends CharacterBody2D
class_name Eraser

@export var speed: float = 5.0

@export var eraser_durability: float = 100.0
var current_eraser_durability: float = 1.0 :
	set(value):
		if !$InvincibilityTimer.is_stopped() or get_tree().current_scene.is_pencil_case_opened():
			current_eraser_durability = current_eraser_durability
			return
		
		current_eraser_durability = value
		$TextureProgressBar.value = current_eraser_durability
		
		if current_eraser_durability <= 30.0 and !get_tree().current_scene.pencil_case_tutorial_shown:
			create_tween().tween_property($"../CanvasLayer/PencilCaseTutorial1", "modulate", Color.WHITE, 0.15)
			get_tree().current_scene.pencil_case_tutorial_shown = true
		
		if current_eraser_durability <= 0.0:
			get_viewport().get_camera_2d().apply_shake(30, 1)
			get_tree().current_scene.play_sfx_by_name('death')
			#get_tree().current_scene.eraser = null
			queue_free()

@export var durability_decrease_rate: float = 2.0

var pixels_moved_last_frame: float = 0.0 
var last_position: Vector2

var last_direction: Vector2

@export var eraser_sounds : Array[AudioStream]
@export var velocity_to_pitch : Curve

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().current_scene.eraser = self
	
	$TextureProgressBar.max_value = eraser_durability
	current_eraser_durability = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var target_pos = get_global_mouse_position()
	
	global_position = global_position.lerp(target_pos, (speed - get_tree().current_scene.get_eraser_slowdown_factor()) * delta)
	
	var current_direction := global_position.direction_to(last_position)
	
	var direction_changed := current_direction.sign() != last_direction.sign()
	#print(direction_changed)
	
	pixels_moved_last_frame = global_position.distance_to(last_position)
	#print(pixels_moved_last_frame)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !get_tree().current_scene.is_pencil_case_opened():
		last_direction = global_position.direction_to(last_position)
		if direction_changed:
			play_random_sfx()
		
		var durability : float = (durability_decrease_rate + get_tree().current_scene.get_additional_durability_decrease_rate())
		current_eraser_durability -= durability * delta * (pixels_moved_last_frame / 15)
	
	last_position = global_position

func play_random_sfx():
	print("random sfx!")
	var sound = eraser_sounds.pick_random()
	#if !$AudioStreamPlayer2D.playing:
	$AudioStreamPlayer2D.stream = sound
	$AudioStreamPlayer2D.pitch_scale = velocity_to_pitch.sample(pixels_moved_last_frame)
	$AudioStreamPlayer2D.play()
	pass
