extends Node2D

@export var painter_image: Sprite2D

@export_dir var bad_texts_dir : String

@export var eraser_size := 5
@export var eraser: Node2D

@export var draw_eraser_rect : bool = false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draw_eraser_rect:
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

func _draw():
	draw_rect(Rect2i(get_global_mouse_position(), Vector2i(1, 1)).grow(eraser_size), Color.AQUA)
