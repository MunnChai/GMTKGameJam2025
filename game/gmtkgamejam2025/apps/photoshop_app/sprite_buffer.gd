class_name SpriteBuffer
extends Sprite2D

var pixel_buffer: Array[PackedColorArray]

func set_pixel_buffer(given_pixel_buffer: Array[PackedColorArray]) -> void:
	var image: Image = Image.create_empty(given_pixel_buffer.size(), given_pixel_buffer[0].size(), false, Image.FORMAT_RGBA8)
	
	pixel_buffer = given_pixel_buffer.duplicate()
	
	for x in given_pixel_buffer.size():
		for y in given_pixel_buffer[0].size():
			image.set_pixel(x, y, pixel_buffer[x][y])
	
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	texture = image_texture

func set_pixel_buffer_from_texture(given_texture: Texture2D) -> void:
	var image: Image = Image.create_empty(given_texture.get_size().x, given_texture.get_size().y, false, Image.FORMAT_RGBA8)
	
	pixel_buffer.resize(given_texture.get_size().x)
	for i in pixel_buffer.size():
		var new_pixel_array: PackedColorArray = []
		new_pixel_array.resize(given_texture.get_size().y)
		pixel_buffer[i] = new_pixel_array
	
	var given_image: Image = given_texture.get_image()
	
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			var color = given_image.get_pixel(x, y)
			pixel_buffer[x][y] = color
			image.set_pixel(x, y, color)
	
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	texture = image_texture

func erase_pixels_in_polygon(polygon: PackedVector2Array) -> void:
	var translated_polygon = polygon
	for i in translated_polygon.size():
		translated_polygon[i] += Vector2(pixel_buffer.size() / 2, pixel_buffer[0].size() / 2)
	
	var image: Image = texture.get_image()
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			if Geometry2D.is_point_in_polygon(Vector2(x, y), polygon):
				pixel_buffer[x][y].a = 0
				image.set_pixel(x, y, pixel_buffer[x][y])
	
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	texture = image_texture

func impose_image(other: SpriteBuffer, pos_offset: Vector2) -> void:
	var image: Image = texture.get_image()
	
	var other_image: Image = other.texture.get_image()
	for x in other.pixel_buffer.size():
		for y in other.pixel_buffer[0].size():
			var new_pos = Vector2i(pos_offset + Vector2(x, y))
			
			var color = other_image.get_pixel(x, y)
			if is_zero_approx(color.a):
				continue
			
			pixel_buffer[new_pos.x][new_pos.y] = color
			image.set_pixel(new_pos.x, new_pos.y, color)
	
	texture = ImageTexture.create_from_image(image)

func get_pixel_buffer_in_polygon(polygon: PackedVector2Array) -> Array[PackedColorArray]:
	var translated_polygon = polygon
	for i in translated_polygon.size():
		translated_polygon[i] += Vector2(pixel_buffer.size() / 2, pixel_buffer[0].size() / 2)
	
	var new_buffer: Array[PackedColorArray] = pixel_buffer.duplicate()
	
	var image: Image = texture.get_image()
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			new_buffer[x][y] = image.get_pixel(x, y)
			
			if not Geometry2D.is_point_in_polygon(Vector2(x, y), polygon):
				new_buffer[x][y].a = 0
	
	return new_buffer

func is_pos_in_pixel_buffer(pos: Vector2) -> bool:
	if pos.x < 0 or pos.x >= pixel_buffer.size():
		return false
	if pos.y < 0 or pos.y >= pixel_buffer[0].size():
		return false
	pos = Vector2i(pos)
	return pixel_buffer[pos.x][pos.y].a != 0
