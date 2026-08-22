extends Sprite2D

@export var img_size := Vector2i(1024, 512)

@export_dir var bad_texts_dir : String

@export var eraser_size := 5

var bad_texts : Array[Image]

var img : Image

func _ready():
	bad_texts = get_all_bad_texts(bad_texts_dir)
	
	img = Image.create_empty(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	
	texture = ImageTexture.create_from_image(img)
	
	$"../BadTextSpawnTimer".timeout.connect(_spawn_bad_text)
	
	$"../BadTextSpawnTimer".timeout.emit()

func _spawn_bad_text():
	var bad_text = bad_texts.pick_random()
	
	img.blend_rect(bad_text, Rect2i(Vector2.ZERO, bad_text.get_size()), Vector2(randf_range(0, img_size.x - bad_text.get_width()), randf_range(0, img_size.y - bad_text.get_height())))
	
	texture.update(img)

func _paint_tex(pos):
	img.fill_rect(Rect2i(pos, Vector2i(1, 1)).grow(eraser_size), Color.WHITE)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
			var local_pos = to_local(event.position)
			var local_image_pos = local_pos - offset + get_rect().size / 2.0
			
			_paint_tex(local_image_pos)
			texture.update(img)
	elif event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			var local_pos = to_local(event.position)
			var local_image_pos = local_pos - offset + get_rect().size / 2.0
			
			if event.relative.length_squared() > 0:
				var num := ceili(event.relative.length())
				var target_pos = local_image_pos - (event.relative)
				for i in num:
					local_image_pos = local_image_pos.move_toward(target_pos, 1.0)
					_paint_tex(local_image_pos)
			
			texture.update(img)

func get_all_bad_texts(directory_path: String) -> Array[Image]:
	var output : Array[Image]
 
	var dir = DirAccess.open(directory_path)
	if dir:
		for file_name in dir.get_files():
			if file_name.get_extension() == "remap":
				file_name = file_name.replace(".remap", "")
   
			if file_name.get_extension() == "png":
				var full_path = directory_path.path_join(file_name)
				
				var img : Image = load(full_path).get_image()
				img.decompress()
				
				output.append(img)
	
	return output
