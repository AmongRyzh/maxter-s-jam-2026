extends Sprite2D

@export var pos_down : Vector2
@export var pos_looking : Vector2
@export var pos_up : Vector2

@export var walking_duration : float = 7

@export var min_stop_time : float = 3
@export var max_stop_time : float = 5

@export var gameplay: Gameplay

var tween : Tween
var tween_elapsed_time : float

@export var teacher_looking: CompressedTexture2D
@export var teacher_not_looking: CompressedTexture2D

@export var max_black_pixel_count: int

var is_looking : bool = false :
	set(value):
		is_looking = value
		if value:
			texture = teacher_looking
		else:
			texture = teacher_not_looking

var blinking : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	is_looking = false
	
	position = pos_down
	
	gameplay.teacher_cooldown_timer.timeout.connect(func():
		if tween:
			tween.kill()
		
		tween = create_tween()
		tween.tween_property(self, "position", pos_up, walking_duration)
		
		gameplay.teacher_walk_timer.start(randf_range(min_stop_time, max_stop_time))
		)
	
	gameplay.teacher_walk_timer.timeout.connect(func():
		tween_elapsed_time = tween.get_total_elapsed_time()
		if tween:
			tween.kill()
		
		is_looking = true
		
		var black_pixel_count = gameplay.get_pixel_count_of_color(gameplay.painter_image.texture, Color.BLACK)
		print(black_pixel_count)
		
		var monster_count := get_tree().get_node_count_in_group('monster')
		print(monster_count)
		
		if black_pixel_count > max_black_pixel_count and monster_count != 0:
			Engine.time_scale = 0
			await get_tree().create_timer(0.3, true, false, true)
			Engine.time_scale = 1
			get_tree().reload_current_scene()
		
		gameplay.teacher_look_timer.start()
		)
	
	gameplay.teacher_look_timer.timeout.connect(func():
		if tween:
			tween.kill()
		
		is_looking = false
		
		tween = create_tween()
		tween.tween_property(self, "position", pos_up, walking_duration - tween_elapsed_time)
		
		tween.tween_callback(func():
			position = pos_down
			gameplay.teacher_cooldown_timer.start()
			)
		)

func _process(delta):
	if gameplay.teacher_walk_timer.time_left <= 0.5 and !gameplay.teacher_walk_timer.is_stopped() and !blinking:
		_blink()

func _blink():
	blinking = true
	var tween := create_tween()
	tween.set_parallel(false)
	for i in 5:
		tween.tween_property(self, "modulate", Color.RED, 0.05)
		tween.tween_property(self, "modulate", Color.WHITE, 0.05)
	tween.tween_callback(func(): blinking = false)
