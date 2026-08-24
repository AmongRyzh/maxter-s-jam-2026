extends Sprite2D

@export var x_pos_start : float = 1253.0
@export var x_pos_end : float = -109.0

@export var y_pos_up : float
@export var y_pos_looking : float = 152.0
@export var y_pos_down : float

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
	
	position = Vector2(x_pos_start, y_pos_down)
	
	gameplay.teacher_cooldown_timer.timeout.connect(func():
		if tween:
			tween.kill()
		
		tween = create_tween()
		tween.tween_property(self, "position:x", x_pos_end, walking_duration)
		tween.parallel().tween_subtween(_up_down_subtween())
		
		gameplay.teacher_walk_timer.start(randf_range(min_stop_time, max_stop_time))
		
		if !gameplay.pencil_case_tutorial_shown:
			await get_tree().create_timer(1.25).timeout
			create_tween().tween_property($"../CanvasLayer/PencilCaseTutorial1", "modulate", Color.WHITE, 0.15)
			gameplay.pencil_case_tutorial_shown = true
		)
	
	gameplay.teacher_walk_timer.timeout.connect(func():
		tween_elapsed_time = tween.get_total_elapsed_time()
		if tween:
			tween.kill()
		
		tween = create_tween()
		tween.tween_property(self, "position:y", y_pos_looking, 0.05)
		
		is_looking = true
		
		var black_pixel_count = gameplay.get_pixel_count_of_color_in_all_painter_images(Color.BLACK, false)
		print(black_pixel_count)
		
		var monsters := get_tree().get_nodes_in_group('monster')
		print(monsters)
		
		if black_pixel_count > max_black_pixel_count or monsters.size() != 0:
			Engine.time_scale = 0
			
			gameplay.replace_color_to_color_in_all_painter_images(Color.BLACK, Color.RED)
			
			await get_tree().create_timer(0.7, true, false, true).timeout
			Engine.time_scale = 1
			get_tree().reload_current_scene()
		else:
			gameplay.teacher_look_timer.start()
		)
	
	gameplay.teacher_look_timer.timeout.connect(func():
		if tween:
			tween.kill()
		
		is_looking = false
		
		tween = create_tween()
		tween.tween_property(self, "position:x", x_pos_end, walking_duration - tween_elapsed_time)
		tween.parallel().tween_subtween(_up_down_subtween(ceil((walking_duration - tween_elapsed_time) / 0.8)))
		
		tween.tween_callback(func():
			position = Vector2(x_pos_start, y_pos_down)
			
			print(gameplay.game_finish_timer.time_left)
			var wait_time = -1 if gameplay.game_finish_timer.time_left > 35 else gameplay.game_finish_timer.time_left - walking_duration + gameplay.teacher_look_timer.wait_time
			print(wait_time)
			
			gameplay.teacher_cooldown_timer.start(wait_time)
			)
		)

func _up_down_subtween(loops: int = 0) -> Tween:
	var up_down_subtween := create_tween().set_loops(loops)
	up_down_subtween.tween_property(self, "position:y", y_pos_up, 0.4)
	up_down_subtween.tween_property(self, "position:y", y_pos_down, 0.4)
	
	return up_down_subtween

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
