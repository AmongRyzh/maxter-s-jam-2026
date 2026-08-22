extends Node2D
class_name Gameplay

@export var painter_image: Sprite2D

@export_dir var bad_texts_dir : String

@export var eraser_size := 5
@export var eraser: Node2D
var durability_shrink : float :
	get():
		return 0 if eraser == null else ((eraser.current_eraser_durability - eraser.eraser_durability) / 100) * eraser_size * 2

@export var eraser_prefab: PackedScene

func _ready():
	pass

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

#func _draw():
	#if eraser:
		#draw_rect(Rect2(eraser.position, Vector2i(1, 1)).grow(eraser_size).grow_side(SIDE_TOP, durability_shrink), Color(0, 1, 0, 0.5))
	#draw_rect(Rect2(get_global_mouse_position(), Vector2i(1, 1)).grow(eraser_size), Color(0, 1, 1, 0.5))
