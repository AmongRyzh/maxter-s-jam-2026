extends Sprite2D

@export var stamp: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = ImageTexture.new() ## initialising the texture
	
	var img = Image.create_empty(256, 256, false, Image.FORMAT_RGBA8) ## creating the image
	img.fill(Color.WHITE) ## filling the entire image in white
	
	texture.set_image(img) ## setting the image to the texture for the first time
	
	
	img.fill(Color.GREEN)
	img.fill_rect(Rect2i(20, 20, 10, 10), Color.BLUE)
	
	var stamp_img = stamp.get_image()
	stamp_img.decompress() ## a required step for using Image.blit_rect() or Image.blend_rect()
	
	img.blit_rect(stamp_img, Rect2i(Vector2.ZERO, stamp.get_size()), Vector2(50, 50)) ## filling our source image with a texture INCLUDING its alpha properties
	img.blend_rect(stamp_img, Rect2i(Vector2.ZERO, stamp.get_size()), Vector2(100, 100)) ## filling our source image with a texture EXCLUDING its alpha properties
	
	texture.update(img) ## updating the texture to the changed image (do this EVERY TIME you change anything in the image!)
