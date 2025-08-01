class_name SpriteBuffer
extends Sprite2D

# A 2D array that keeps track of the texture colour of each pixel
var pixel_buffer: Array[PackedColorArray]

# A 2D array that keeps track of the trait colour of each pixel
var trait_buffer: Array[PackedColorArray]

# A 2D array that keeps track of which pixels have been modified. 
var modified_buffer: Array[PackedInt32Array]


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and name == "EditableImage":
		var file: File = convert_to_file()
		var info = ImageJudgement.get_file_info(file)
		print(info)

#region Initialization

func set_buffers_from_file(file: File) -> void:
	set_pixel_buffer_from_texture(file.texture)
	set_trait_buffer_from_texture(file.trait_texture)
	reset_modified_buffer(file.texture)

func set_pixel_buffer_from_texture(given_texture: Texture2D) -> void:
	var image: Image = Image.create_empty(given_texture.get_size().x, given_texture.get_size().y, false, Image.FORMAT_RGBA8)
	
	pixel_buffer.clear()
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

func set_trait_buffer_from_texture(given_trait_texture: Texture2D) -> void:
	trait_buffer.clear()
	trait_buffer.resize(given_trait_texture.get_size().x)
	
	for i in trait_buffer.size():
		var new_trait_array: PackedColorArray = []
		new_trait_array.resize(given_trait_texture.get_size().y)
		trait_buffer[i] = new_trait_array
	
	var given_trait_image: Image = given_trait_texture.get_image()
	
	for x in trait_buffer.size():
		for y in trait_buffer[0].size():
			var color = given_trait_image.get_pixel(x, y)
			trait_buffer[x][y] = color

func reset_modified_buffer(given_texture: Texture2D) -> void:
	modified_buffer.clear()
	modified_buffer.resize(given_texture.get_size().x)
	for i in modified_buffer.size():
		var new_modified_array: PackedInt32Array = []
		new_modified_array.resize(given_texture.get_size().y)
		modified_buffer[i] = new_modified_array

func set_pixel_buffer(given_pixel_buffer: Array[PackedColorArray]) -> void:
	var image: Image = Image.create_empty(given_pixel_buffer.size(), given_pixel_buffer[0].size(), false, Image.FORMAT_RGBA8)
	
	pixel_buffer = given_pixel_buffer.duplicate()
	
	for x in given_pixel_buffer.size():
		for y in given_pixel_buffer[0].size():
			image.set_pixel(x, y, pixel_buffer[x][y])
	
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	texture = image_texture

func set_trait_buffer(given_trait_buffer: Array[PackedColorArray]) -> void:
	trait_buffer = given_trait_buffer.duplicate()

func clear() -> void:
	pixel_buffer.clear()
	trait_buffer.clear()
	modified_buffer.clear()
	texture = null

#endregion



#region Modifications

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
				modified_buffer[x][y] = 1
	
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	texture = image_texture

func impose_image(other: SpriteBuffer, pos_offset: Vector2) -> void:
	var image: Image = texture.get_image()
	
	var other_image: Image = other.texture.get_image()
	
	var size_diff = Vector2(other.pixel_buffer.size(), other.pixel_buffer[0].size()) - Vector2(pixel_buffer.size(), pixel_buffer[0].size())
	
	for x in other.pixel_buffer.size():
		for y in other.pixel_buffer[0].size():
			var new_pos = Vector2i(pos_offset + Vector2(x, y)) - Vector2i(size_diff / 2)
			
			var color = other_image.get_pixel(x, y)
			if is_zero_approx(color.a):
				continue
			
			if new_pos.x < 0 or new_pos.x >= pixel_buffer.size():
				continue
			if new_pos.y < 0 or new_pos.y >= pixel_buffer[0].size():
				continue
			
			pixel_buffer[new_pos.x][new_pos.y] = color
			image.set_pixel(new_pos.x, new_pos.y, color)
			modified_buffer[new_pos.x][new_pos.y] = 1
	
	texture = ImageTexture.create_from_image(image)

#endregion




#region Helpers

func get_pixel_buffer_in_polygon(polygon: PackedVector2Array) -> Array[PackedColorArray]:
	var translated_polygon = polygon
	for i in translated_polygon.size():
		translated_polygon[i] += Vector2(pixel_buffer.size() / 2, pixel_buffer[0].size() / 2)
	
	var new_buffer: Array[PackedColorArray] = pixel_buffer.duplicate(true)
	
	var image: Image = texture.get_image()
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			new_buffer[x][y] = image.get_pixel(x, y)
			
			if not Geometry2D.is_point_in_polygon(Vector2(x, y), polygon):
				new_buffer[x][y].a = 0
	
	return new_buffer

func is_pos_in_pixel_buffer(pos: Vector2) -> bool:
	if pixel_buffer.is_empty():
		return false
	
	pos += Vector2(pixel_buffer.size() / 2, pixel_buffer[0].size() / 2) - self.position
	
	if pos.x < 0 or pos.x >= pixel_buffer.size():
		return false
	if pos.y < 0 or pos.y >= pixel_buffer[0].size():
		return false
	pos = Vector2i(pos)
	return pixel_buffer[pos.x][pos.y].a != 0

#endregion


#region File Conversion

func convert_to_file() -> File:
	var texture_image: Image = Image.create_empty(pixel_buffer.size(), pixel_buffer[0].size(), false, Image.FORMAT_RG8)
	var trait_texture_image: Image = Image.create_empty(pixel_buffer.size(), pixel_buffer[0].size(), false, Image.FORMAT_RG8)
	var modified_count: int = 0
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			texture_image.set_pixel(x, y, pixel_buffer[x][y])
			trait_texture_image.set_pixel(x, y, trait_buffer[x][y])
			if modified_buffer[x][y] != 0:
				modified_count += 1
	
	var new_texture: ImageTexture = ImageTexture.create_from_image(texture_image)
	var new_trait_texture: ImageTexture = ImageTexture.create_from_image(trait_texture_image)
	
	var file: File = File.create_from_data("test_image.png", new_texture, new_trait_texture, modified_count)	
	return file

#endregion
