extends Sprite2D
class_name PainterImage

@export var generate_img_on_ready : bool
@export var img_size := Vector2i(1024, 512)

var img : Image

@export var gameplay: Gameplay

@export var additional_durability_decrease : float

@export var eraser_slowdown_factor : float

@export var erase_color : Color = Color.WHITE

var is_hovered : bool

func _ready():
	gameplay = get_tree().current_scene
	
	if generate_img_on_ready:
		img = Image.create_empty(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
		img.fill(erase_color)
		
		texture = ImageTexture.create_from_image(img)
	else:
		if texture:
			img = texture.get_image()
			if texture is CompressedTexture2D:
				texture = ImageTexture.create_from_image(img)

func _process(_delta):
	var eraser_pos = to_local(gameplay.eraser.global_position) if gameplay.eraser else Vector2.INF
	
	if get_rect().has_point(eraser_pos):
		if not is_hovered:
			is_hovered = true
	else:
		if is_hovered:
			is_hovered = false

func _paint_tex(pos):
	#print(Rect2i(pos, Vector2i(1, 1)).grow(eraser_size))
	if !gameplay.teacher_look_timer.is_stopped() or (!gameplay.teacher_walk_timer.is_stopped() and gameplay.teacher_walk_timer.time_left < 0.1) or Engine.time_scale == 0:
		return
	
	img.fill_rect(Rect2i(pos, Vector2i(1, 1)).grow(gameplay.eraser_size).grow_side(SIDE_TOP, gameplay.durability_shrink), erase_color)
	texture.update(img)

func fill_texture(src: Image, src_rect: Rect2i, dst: Vector2i):
	img.blend_rect(src, src_rect, dst)
	texture.update(img)

func _input(event: InputEvent):
	if gameplay.eraser == null or get_tree().current_scene.is_pencil_case_opened():
		return
	
	if gameplay.get_eraser_slowdown_factor_object_z_index() <= z_index and is_hovered:
		gameplay.object_with_slowdown_factor = self
	else:
		if gameplay.object_with_slowdown_factor == self:
			gameplay.object_with_slowdown_factor = null
	
	if event is InputEventMouseButton:
		if event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
			var local_pos = to_local(gameplay.eraser.position)
			var local_image_pos = local_pos - offset + get_rect().size / 2.0
			
			if gameplay.get_additional_durability_object_z_index() <= z_index and is_hovered:
				gameplay.object_with_durability_decrease = self
			
			_paint_tex(local_image_pos)
			texture.update(img)
		else:
			if gameplay.object_with_durability_decrease == self:
				gameplay.object_with_durability_decrease = null
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
			
			if gameplay.get_additional_durability_object_z_index() <= z_index and is_hovered:
				gameplay.object_with_durability_decrease = self
			
			_paint_tex(local_image_pos)
