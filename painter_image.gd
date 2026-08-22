extends Sprite2D

@export var img_size := Vector2i(1024, 512)

@export_dir var bad_texts_dir : String

var bad_texts : Array[Image]

var img : Image

func _ready():
	bad_texts = get_all_bad_texts(bad_texts_dir)
	
	img = Image.create_empty(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	
	texture = ImageTexture.create_from_image(img)
	
	var bad_text = bad_texts.pick_random()
	
	print(randf_range(0, img_size.x - bad_text.get_width()))
	print(randf_range(0, img_size.y - bad_text.get_height()))
	
	img.blend_rect(bad_text, Rect2i(Vector2.ZERO, bad_text.get_size()), Vector2(randf_range(0, img_size.x - bad_text.get_width()), randf_range(0, img_size.y - bad_text.get_height())))
	
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
