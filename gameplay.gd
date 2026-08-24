extends Node2D
class_name Gameplay

@export var painter_image_container : Node2D

#var painter_images: Array[Sprite2D]

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
		#print("gameplay: set object_with_durability_decrease to ", value)
func get_additional_durability_decrease_rate() -> float:
	return object_with_durability_decrease.additional_durability_decrease if object_with_durability_decrease else 0
func get_additional_durability_object_z_index() -> int:
	return object_with_durability_decrease.z_index if object_with_durability_decrease else -1

var object_with_slowdown_factor : PainterImage :
	set(value):
		object_with_slowdown_factor = value
		#print("gameplay: set object_with_slowdown_factor to ", value)
func get_eraser_slowdown_factor() -> float:
	return object_with_slowdown_factor.eraser_slowdown_factor if object_with_slowdown_factor else 0
func get_eraser_slowdown_factor_object_z_index() -> int:
	return object_with_slowdown_factor.z_index if object_with_slowdown_factor else -1

@export var eraser_prefab: PackedScene

@export var start_game_panel: Panel

@export var game_finish_timer: Timer
@export var game_finish_label: Label
@export var game_finish_panel: Panel

@export var bad_text_spawn_timer: RandomTimer
@export var pencil: PackedScene
@export var mark: PackedScene

@export var begin_random_event_timer: Timer
@export var monster_spawn_timer: RandomTimer
@export var danger_spawn_timer: RandomTimer

@export var teacher_cooldown_timer: Timer
@export var teacher_walk_timer: Timer
@export var teacher_look_timer: Timer

@export var begin_add_painter_image_spawn_timer: Timer
@export var add_painter_image_spawn_timer: RandomTimer
@export var final_painter_image_timer: Timer

@export var painter_image_spawn_points: Node2D
@export var additional_painter_image: PackedScene
@export var final_painter_image: PackedScene

@export var monster: PackedScene

@export var dangers: Array[PackedScene]

var pencil_case_tutorial_shown: bool = false

@export var sfx: Node2D

func _ready():
	Engine.time_scale = 0
	
	start_game_panel.show()
	start_game_panel.get_node("StartButton").button_up.connect(func():
		Engine.time_scale = 1
		start_game_panel.hide()
		)
	
	game_finish_panel.hide()
	
	game_finish_timer.timeout.connect(func():
		Engine.time_scale = 0
		game_finish_panel.show()
		game_finish_panel.get_node("Peremena").play()
		)
	
	bad_texts = get_all_bad_texts()
	
	bad_text_spawn_timer.timeout.connect(_spawn_bad_text)
	
	bad_text_spawn_timer.random_start()
	
	#bad_text_spawn_timer.timeout.emit()
	
	begin_random_event_timer.timeout.connect(func():
		monster_spawn_timer.timeout.emit()
		monster_spawn_timer.random_start()
		danger_spawn_timer.random_start()
		)
	
	monster_spawn_timer.timeout.connect(func():
		if !teacher_cooldown_timer.is_stopped():
			spawn_packed_at_random_pos(monster)
		)
	
	danger_spawn_timer.timeout.connect(_spawn_danger)
	
	begin_add_painter_image_spawn_timer.timeout.connect(func():
		add_painter_image_spawn_timer.timeout.emit()
		add_painter_image_spawn_timer.random_start()
		)
	
	add_painter_image_spawn_timer.timeout.connect(_spawn_painter_image)
	
	final_painter_image_timer.timeout.connect(func():
		var img = final_painter_image.instantiate()
		img.global_position = Vector2(576.0, 374.0)
		painter_image_container.add_child(img)
		)

func _spawn_bad_text():
	if teacher_cooldown_timer.is_stopped():
		print(teacher_cooldown_timer.is_stopped())
		bad_text_spawn_timer.random_start()
		return
	
	var bad_text = bad_texts.pick_random()
	
	var all_painter_images := get_all_painter_images()
	
	var painter_image : PainterImage = all_painter_images.pick_random()
	
	var position : Vector2
	for i in 10:
		position = Vector2(
			randf_range(0, painter_image.img_size.x - bad_text.get_width()), 
			randf_range(0, painter_image.img_size.y - bad_text.get_height()))
		
		var rect : Rect2i = Rect2i(Vector2i(position) - bad_text.get_size() / 2, bad_text.get_size())
		if get_pixel_count_of_color_in_rect(painter_image.texture, Color.BLACK, rect) < 150 or get_pixel_count_of_color_in_all_painter_images(Color.WHITE) < 1000:
			break
	
	var globalised_position = painter_image.to_global(position - Vector2(painter_image.img_size / 2) + Vector2(bad_text.get_size() / 2))
	
	var new_mark = spawn_packed_at_pos(mark, globalised_position)
	
	await get_tree().create_timer(new_mark.destroy_time).timeout
	
	bad_text_spawn_timer.random_start()
	
	spawn_packed_at_pos(pencil, globalised_position)
	
	painter_image.fill_texture(bad_text, Rect2i(Vector2.ZERO, bad_text.get_size()), position)
#
#func reposition_mark(mark: Node2D, position: Vector2):
	#mark

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	game_finish_label.text = "ПЕРЕМЕНА ЧЕРЕЗ: %d м. %02d сек." % [floori(game_finish_timer.time_left / 60), posmod(game_finish_timer.time_left, 60)]
	
	queue_redraw()

func get_all_bad_texts() -> Array[Image]:
	var output : Array[Image]
 
	var dir = ResourceLoader.list_directory(bad_texts_dir)
	for file_name in dir:
		if file_name.get_extension() == "remap":
			file_name = file_name.replace(".remap", "")
		
		if file_name.get_extension() == "import":
			file_name = file_name.replace(".import", "")

		if file_name.get_extension() == "png":
			var full_path = bad_texts_dir.path_join(file_name)
			
			var img : Image = Image.new()
			#
			#var error = img.load(full_path)
			#
			#print("Attempted loading image %s with result: %s" % [file_name, error])
			
			var texture = ResourceLoader.load(full_path)
			img = texture.get_image()
			
			print(img)
			
			#img.decompress()
			
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

func get_pixel_count_of_color(texture: Texture, color: Color) -> int:
	var img: Image = texture.get_image()
	if img.is_compressed():
		img.decompress()
		
	# Gets a bounding box enclosing only the visible parts of the image
	var used_rect: Rect2i = img.get_used_rect()
	print(used_rect)
	var color_count: int = 0
	
	# Only loop inside the bounding rectangle containing visible pixels
	for y in range(used_rect.position.y, used_rect.end.y):
		for x in range(used_rect.position.x, used_rect.end.x):
			if img.get_pixel(x, y).is_equal_approx(color):
				color_count += 1
	
	return color_count

func get_pixel_count_of_color_in_rect_in_decompressed_img(img: Image, color: Color, rect: Rect2i) -> int:
	var color_count: int = 0
	
	# Only loop inside the bounding rectangle containing visible pixels
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if x in range(0, img.get_size().x) and y in range(0, img.get_size().y):
				if img.get_pixel(x, y).is_equal_approx(color):
					color_count += 1
	
	return color_count

func get_pixel_count_of_color_in_rect(texture: Texture, color: Color, rect: Rect2i) -> int:
	var img: Image = texture.get_image()
	if img.is_compressed():
		img.decompress()
	
	var color_count: int = 0
	
	var end_x := rect.end.x
	var end_y := rect.end.y
	
	print("get_pixel_count_of_color_in_rect: ", rect)
	# Only loop inside the bounding rectangle containing visible pixels
	for y in range(rect.position.y, end_y):
		if y in range(0, img.get_size().y):
			for x in range(rect.position.x, end_x):
				if x in range(0, img.get_size().x):
					if img.get_pixel(x, y).is_equal_approx(color):
						color_count += 1
				else:
					end_x = x - 1
					continue
		else:
			end_y = y - 1
			continue
	
	return color_count

func replace_color_to_color(texture: ImageTexture, color_from: Color, color_to: Color) -> Image:
	var img: Image = texture.get_image()
	if img.is_compressed():
		img.decompress()
		
	# Gets a bounding box enclosing only the visible parts of the image
	#var used_rect: Rect2i = img.get_used_rect()
	var used_rect: Rect2i = Rect2i(0, 0, img.get_width(), img.get_height())
	var color_count: int = 0
	
	# Only loop inside the bounding rectangle containing visible pixels
	for y in range(used_rect.position.y, used_rect.end.y):
		for x in range(used_rect.position.x, used_rect.end.x):
			if img.get_pixel(x, y).is_equal_approx(color_from):
				img.set_pixel(x, y, color_to)
	
	texture.update(img)
	return img

func get_pixel_count_of_color_in_all_painter_images(color: Color, include_monster: bool = false) -> int:
	var color_count: int = 0
	
	for image in get_all_painter_images(include_monster):
		color_count += get_pixel_count_of_color(image.texture, color)
	
	return color_count

func replace_color_to_color_in_all_painter_images(color_from: Color, color_to: Color, include_monster: bool = false):
	for image in get_all_painter_images(include_monster):
		replace_color_to_color(image.texture, color_from, color_to)

func spawn_packed_at_random_pos(packed: PackedScene) -> Node2D:
	var pos = get_random_pos_in_viewport_with_offset(100)
	return spawn_packed_at_pos(packed, pos)

func spawn_packed_at_pos(packed: PackedScene, pos: Vector2) -> Node2D:
	if packed.can_instantiate():
		var new_packed = packed.instantiate()
		new_packed.global_position = pos
		add_child(new_packed)
		return new_packed
	else:
		print("failed to instantiate ", packed, "!")
		return null

func get_all_painter_images(include_monster: bool = false) -> Array[Node]:
	var painter_images : Array[Node]
	
	if include_monster:
		painter_images = get_tree().get_nodes_in_group('painter_image')
	else:
		painter_images = get_tree().get_nodes_in_group('painter_image').filter(
			func(node):
				prints(node, is_ancestor_of(painter_image_container))
				
				#var arc_projectile_condition : bool
				#
				#if node.get_parent() is ArcProjectile:
					#arc_projectile_condition = node.get_parent().landed
				#else:
					#arc_projectile_condition = true
				
				return is_ancestor_of(painter_image_container) and !node.get_parent().is_in_group('monster') #and arc_projectile_condition
		)
	
	return painter_images

func get_random_pos_in_viewport_with_offset(offset: float) -> Vector2:
	return Vector2(randf_range(offset, get_viewport().get_visible_rect().size.x - offset), randf_range(offset, get_viewport().get_visible_rect().size.y - offset))

func _spawn_danger():
	var danger = dangers.pick_random().instantiate()
	
	var initial_pos : Vector2
	
	var target_pos = eraser.position if eraser != null else get_random_pos_in_viewport_with_offset(100)
	
	if danger is PaperBall:
		initial_pos.x = -100 if randi_range(0, 1) == 0 else get_viewport().get_visible_rect().size.x + 100
		initial_pos.y = randf_range(0, get_viewport().get_visible_rect().size.y)
		
		var direction : Vector2 = initial_pos.direction_to(target_pos)
		var dist : float = initial_pos.distance_to(target_pos)
		
		danger.launch_projectile(initial_pos, direction, dist, 45)
	elif danger is PaperPlane:
		var rand_1 = randi_range(0, 1)
		var rand_2 = randi_range(0, 1)
		
		match rand_1:
			0:
				initial_pos.x = -100 if rand_2 == 0 else get_viewport().get_visible_rect().size.x + 100
				initial_pos.y = randf_range(0, get_viewport().get_visible_rect().size.y)
			1:
				initial_pos.x = randf_range(0, get_viewport().get_visible_rect().size.x)
				initial_pos.y = -100 if rand_2 == 0 else get_viewport().get_visible_rect().size.y + 100
		
		danger.global_position = initial_pos
		danger.target_direction = initial_pos.direction_to(target_pos)
	
	add_child(danger)

func _spawn_painter_image():
	var img = additional_painter_image.instantiate()
	var spawn_point = painter_image_spawn_points.get_children().pick_random()
	
	var initial_pos : Vector2
	initial_pos.x = -100 if randi_range(0, 1) == 0 else get_viewport().get_visible_rect().size.x + 100
	initial_pos.y = randf_range(0, get_viewport().get_visible_rect().size.y)
	
	var target_pos : Vector2 = spawn_point.global_position
	
	var direction : Vector2 = initial_pos.direction_to(target_pos)
	var dist : float = initial_pos.distance_to(target_pos)
	
	img.launch_projectile(initial_pos, direction, dist, 45)
	
	painter_image_container.add_child(img)
	
	spawn_point.queue_free()

func play_sfx_by_name(name: String):
	sfx.get_node(name).play()

#func _draw():
	#if eraser:
		#draw_rect(Rect2(eraser.position, Vector2i(1, 1)).grow(eraser_size).grow_side(SIDE_TOP, durability_shrink), Color(0, 1, 0, 0.5))
	#draw_rect(Rect2(get_global_mouse_position(), Vector2i(1, 1)).grow(eraser_size), Color(0, 1, 1, 0.5))
