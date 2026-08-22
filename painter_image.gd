extends Sprite2D
class_name PainterImage

@export var img_size := Vector2i(1024, 512)

var bad_texts : Array[Image]

var img : Image

@export var gameplay: Node2D

func _ready():
	gameplay = get_tree().current_scene
	
	bad_texts = gameplay.get_all_bad_texts()
	
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
	#print(Rect2i(pos, Vector2i(1, 1)).grow(eraser_size))
	img.fill_rect(Rect2i(pos, Vector2i(1, 1)).grow(gameplay.eraser_size).grow_side(SIDE_TOP, gameplay.durability_shrink), Color.WHITE)

func _input(event: InputEvent):
	if gameplay.eraser == null or get_tree().current_scene.is_pencil_case_opened():
		return
	
	if event is InputEventMouseButton:
		if event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
			var local_pos = to_local(gameplay.eraser.position)
			var local_image_pos = local_pos - offset + get_rect().size / 2.0
			
			_paint_tex(local_image_pos)
			texture.update(img)
	elif event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			#var local_pos = to_local(event.position)
			var local_pos = to_local(gameplay.eraser.position)
			var local_image_pos = local_pos - offset + get_rect().size / 2.0
			
			#if event.relative.length_squared() > 0:
				#var num := ceili(event.relative.length())
				#var target_pos = local_image_pos - (event.relative)
				#for i in num:
					#local_image_pos = local_image_pos.move_toward(target_pos, 1.0)
					#_paint_tex(local_image_pos)
			
			if gameplay.eraser.pixels_moved_last_frame > 0:
				var num := ceili(gameplay.eraser.pixels_moved_last_frame)
				var target_pos = local_image_pos - gameplay.eraser.position
				for i in num:
					local_image_pos = local_image_pos.move_toward(target_pos, 1.0)
					_paint_tex(local_image_pos)
			
			_paint_tex(local_image_pos)
			
			texture.update(img)
