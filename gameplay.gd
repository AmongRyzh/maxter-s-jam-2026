extends Node2D
class_name Gameplay

@export var painter_image: Sprite2D

@export_dir var bad_texts_dir : String
var bad_texts : Array[Image]

@export var eraser_size := 5
@export var eraser: Node2D
var durability_shrink : float :
	get():
		return 0 if eraser == null else ((eraser.current_eraser_durability - eraser.eraser_durability) / 100) * eraser_size * 2

#var additional_durability_decrease : float
var object_with_durability_decrease : PainterImage :
	set(value):
		object_with_durability_decrease = value
		print("gameplay: set object_with_durability_decrease to ", value)
func get_additional_durability_decrease_rate() -> float:
	return object_with_durability_decrease.additional_durability_decrease if object_with_durability_decrease else 0
func get_additional_durability_object_z_index() -> int:
	return object_with_durability_decrease.z_index if object_with_durability_decrease else -1

var object_with_slowdown_factor : PainterImage :
	set(value):
		object_with_slowdown_factor = value
		print("gameplay: set object_with_slowdown_factor to ", value)
func get_eraser_slowdown_factor() -> float:
	return object_with_slowdown_factor.eraser_slowdown_factor if object_with_slowdown_factor else 0
func get_eraser_slowdown_factor_object_z_index() -> int:
	return object_with_slowdown_factor.z_index if object_with_slowdown_factor else -1

@export var eraser_prefab: PackedScene

@export var bad_text_spawn_timer: Timer
@export var begin_random_event_timer: Timer
@export var monster_spawn_timer: RandomTimer
@export var danger_spawn_timer: RandomTimer

@export var monster: PackedScene

@export var dangers: Array[PackedScene]

func _ready():
	bad_texts = get_all_bad_texts()
	
	bad_text_spawn_timer.timeout.connect(_spawn_bad_text)
	bad_text_spawn_timer.timeout.emit()
	
	begin_random_event_timer.timeout.connect(func():
		monster_spawn_timer.timeout.emit()
		monster_spawn_timer.random_start()
		danger_spawn_timer.random_start()
		)
	
	monster_spawn_timer.timeout.connect(func():
		spawn_packed_at_random_pos(monster)
		)
	
	danger_spawn_timer.timeout.connect(func():
		_spawn_danger()
		)

func _spawn_bad_text():
	var bad_text = bad_texts.pick_random()
	
	painter_image.fill_texture(bad_text, Rect2i(Vector2.ZERO, bad_text.get_size()),
		Vector2(randf_range(0, painter_image.img_size.x - bad_text.get_width()), randf_range(0, painter_image.img_size.y - bad_text.get_height())))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func get_all_bad_texts() -> Array[Image]:
	var output : Array[Image]
 
	var dir = DirAccess.open(bad_texts_dir)
	if dir:
		for file_name in dir.get_files():
			if file_name.get_extension() == "remap":
				file_name = file_name.replace(".remap", "")
   
			if file_name.get_extension() == "png":
				var full_path = bad_texts_dir.path_join(file_name)
				
				var img : Image = load(full_path).get_image()
				img.decompress()
				
				output.append(img)
	
	return output

func on_pencil_case_eraser_slot_selected():
	if eraser:
		eraser.queue_free()
	
	var new_eraser = eraser_prefab.instantiate()
	add_child(new_eraser)

func is_pencil_case_opened() -> bool:
	return $PencilCase.opened

func get_opaque_pixel_count(texture: Texture2D) -> int:
	var img: Image = texture.get_image()
	if img.is_compressed():
		img.decompress()
		
	# Gets a bounding box enclosing only the visible parts of the image
	var used_rect: Rect2i = img.get_used_rect()
	var opaque_count: int = 0
	
	# Only loop inside the bounding rectangle containing visible pixels
	for y in range(used_rect.position.y, used_rect.end.y):
		for x in range(used_rect.position.x, used_rect.end.x):
			if img.get_pixel(x, y).a > 0.0:
				opaque_count += 1
	
	return opaque_count

func spawn_packed_at_random_pos(packed: PackedScene):
	var pos = Vector2(randf_range(100, 1052), randf_range(100, 548))
	spawn_packed_at_pos(packed, pos)

func spawn_packed_at_pos(packed: PackedScene, pos: Vector2):
	if packed.can_instantiate():
		var new_packed = packed.instantiate()
		new_packed.global_position = pos
		add_child(new_packed)
	else:
		print("failed to instantiate ", packed, "!")

func _spawn_danger():
	var danger = dangers.pick_random()
	

#func _draw():
	#if eraser:
		#draw_rect(Rect2(eraser.position, Vector2i(1, 1)).grow(eraser_size).grow_side(SIDE_TOP, durability_shrink), Color(0, 1, 0, 0.5))
	#draw_rect(Rect2(get_global_mouse_position(), Vector2i(1, 1)).grow(eraser_size), Color(0, 1, 1, 0.5))
