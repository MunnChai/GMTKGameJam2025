class_name SpriteBuffer
extends Sprite2D

# A 2D array that keeps track of the texture colour of each pixel
var pixel_buffer: Array[PackedColorArray]

# A 2D array that keeps track of the trait colour of each pixel
var trait_buffer: Array[PackedColorArray]

# A 2D array that keeps track of which pixels have been modified. 
var modified_buffer: Array[PackedInt32Array]

@onready var sprite_2d: Sprite2D = $Sprite2D

var thread: Thread

signal got_buffers(buffers: Dictionary)
signal finished_deletion()
signal finished_pasting()
signal finished_setting_buffers()

func _ready() -> void:
	thread = Thread.new()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("get_trait_dict") and name == "EditableImage":
		var file: File = convert_to_file()
		var file_info = ImageJudgement.get_file_info(file)
		print(file_info)

#region Initialization

func set_buffers_from_file(file: File) -> void:
	reset_modified_buffer(file.texture)
	thread.start(_set_buffers_from_file.bind(file))

func _set_buffers_from_file(file: File) -> Dictionary:
	
	pixel_buffer.clear()
	pixel_buffer.resize(file.texture.get_size().x)
	
	trait_buffer.clear()
	trait_buffer.resize(file.trait_texture.get_size().x)
	
	for i in pixel_buffer.size():
		var new_pixel_array: PackedColorArray = []
		new_pixel_array.resize(file.texture.get_size().y)
		pixel_buffer[i] = new_pixel_array
		var new_trait_array: PackedColorArray = []
		new_trait_array.resize(file.trait_texture.get_size().y)
		trait_buffer[i] = new_trait_array
	
	var given_image: Image = file.texture.get_image().duplicate()
	var given_trait_image: Image = file.trait_texture.get_image().duplicate()
	var new_image: Image = Image.create_empty(file.texture.get_size().x, file.texture.get_size().y, false, Image.FORMAT_RGBA8)
	var new_trait_image: Image = Image.create_empty(file.texture.get_size().x, file.texture.get_size().y, false, Image.FORMAT_RGBA8)
	
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			var color = given_image.get_pixel(x, y)
			pixel_buffer[x][y] = color
			new_image.set_pixel(x, y, color)
			var trait_color = given_trait_image.get_pixel(x, y)
			trait_buffer[x][y] = trait_color
			new_trait_image.set_pixel(x, y, trait_color)
	
	var textures := {
		"pixel_texture": ImageTexture.create_from_image(new_image),
		"trait_texture": ImageTexture.create_from_image(new_trait_image),
	}
	
	call_deferred("_on_buffer_set_finished")
	
	return textures

func _on_buffer_set_finished() -> void:
	var textures = thread.wait_to_finish()
	texture = textures["pixel_texture"]
	sprite_2d.texture = textures["trait_texture"]
	finished_setting_buffers.emit()

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
	var image: Image = Image.create_empty(given_trait_buffer.size(), given_trait_buffer[0].size(), false, Image.FORMAT_RGBA8)
	
	trait_buffer = given_trait_buffer.duplicate()
	
	for x in given_trait_buffer.size():
		for y in given_trait_buffer[0].size():
			image.set_pixel(x, y, trait_buffer[x][y])
	
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	sprite_2d.texture = image_texture

func clear() -> void:
	pixel_buffer.clear()
	trait_buffer.clear()
	modified_buffer.clear()
	sprite_2d.texture = null
	texture = null

#endregion



#region Modifications

#func erase_pixels_in_polygon(polygon: PackedVector2Array) -> void:
	#var translated_polygon = polygon
	#for i in translated_polygon.size():
		#translated_polygon[i] += Vector2(pixel_buffer.size() / 2, pixel_buffer[0].size() / 2)
	#
	#var image: Image = texture.get_image()
	#var trait_image: Image = sprite_2d.texture.get_image()
	#for x in pixel_buffer.size():
		#for y in pixel_buffer[0].size():
			#if Geometry2D.is_point_in_polygon(Vector2(x, y), polygon):
				#pixel_buffer[x][y].a = 0
				#trait_buffer[x][y] = ImageJudgement.NO_TRAIT_COLOR
				#image.set_pixel(x, y, pixel_buffer[x][y])
				#trait_image.set_pixel(x, y, trait_buffer[x][y])
				#modified_buffer[x][y] = 1
	#
	#var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	#texture = image_texture
	#var image_texture2: ImageTexture = ImageTexture.create_from_image(trait_image)
	#sprite_2d.texture = image_texture2


func impose_image(other: SpriteBuffer, pos_offset: Vector2) -> void:
	thread.start(_impose_image.bind(pixel_buffer, other.pixel_buffer, pos_offset, texture.get_image(), sprite_2d.texture.get_image(), other.texture.get_image(), other.sprite_2d.texture.get_image()))

func _impose_image(this_pixel_buffer: Array, other_pixel_buffer: Array, pos_offset: Vector2, image: Image, trait_image: Image, other_image: Image, other_trait_image: Image) -> Dictionary:
	var size_diff = Vector2(other_pixel_buffer.size(), other_pixel_buffer[0].size()) - Vector2(this_pixel_buffer.size(), this_pixel_buffer[0].size())
	
	for x in other_pixel_buffer.size():
		for y in other_pixel_buffer[0].size():
			var new_pos = Vector2i(pos_offset + Vector2(x, y)) - Vector2i(size_diff / 2)
			var new_trait_pos = Vector2i(pos_offset + Vector2(x, y)) - Vector2i(size_diff / 2)
			
			var color = other_image.get_pixel(x, y)
			var trait_color = other_trait_image.get_pixel(x, y)
			if is_zero_approx(color.a):
				continue
			
			if new_pos.x < 0 or new_pos.x >= pixel_buffer.size():
				continue
			if new_pos.y < 0 or new_pos.y >= pixel_buffer[0].size():
				continue
			
			pixel_buffer[new_pos.x][new_pos.y] = color
			trait_buffer[new_trait_pos.x][new_trait_pos.y] = trait_color
			image.set_pixel(new_pos.x, new_pos.y, color)
			trait_image.set_pixel(new_trait_pos.x, new_trait_pos.y, trait_color)
			modified_buffer[new_pos.x][new_pos.y] = 1
	
	var textures := {
		"pixel_texture": ImageTexture.create_from_image(image),
		"trait_texture": ImageTexture.create_from_image(trait_image)
	}
	
	call_deferred("_on_paste_finished")
	
	return textures

func _on_paste_finished() -> void:
	var textures: Dictionary = thread.wait_to_finish()
	texture = textures["pixel_texture"]
	sprite_2d.texture = textures["trait_texture"]
	finished_pasting.emit()

#endregion



#region Helpers

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

#region Optimized functions

func get_buffers_in_polygon_and_delete(polygon: PackedVector2Array) -> void:
	thread.start(_get_buffers_in_polygon_and_delete.bind(polygon, texture.get_image(), sprite_2d.texture.get_image()))

func _get_buffers_in_polygon_and_delete(polygon: PackedVector2Array, image: Image, trait_image: Image) -> Dictionary:
	var buffers: Dictionary = {}
	
	image = image.duplicate()
	trait_image = trait_image.duplicate()
	
	var translated_polygon = polygon.duplicate()
	for i in translated_polygon.size():
		translated_polygon[i] += Vector2(pixel_buffer.size() / 2, pixel_buffer[0].size() / 2)
	
	var new_buffer: Array[PackedColorArray] = pixel_buffer.duplicate(true)
	var new_trait_buffer: Array[PackedColorArray] = trait_buffer.duplicate(true)
	
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			# Copy pixels within the selection and return them (done in duplicate, then remove ones outside)
			if not Geometry2D.is_point_in_polygon(Vector2(x, y), translated_polygon):
				new_buffer[x][y].a = 0
				new_trait_buffer[x][y] = ImageJudgement.NO_TRAIT_COLOR
			else: # Delete pixels within the selection
				pixel_buffer[x][y] = Color(1, 1, 1, 0)
				trait_buffer[x][y] = ImageJudgement.NO_TRAIT_COLOR
				image.set_pixel(x, y, pixel_buffer[x][y])
				trait_image.set_pixel(x, y, trait_buffer[x][y])
				modified_buffer[x][y] = 1
	
	buffers["pixel"] = new_buffer
	buffers["trait"] = new_trait_buffer
	buffers["pixel_texture"] = ImageTexture.create_from_image(image)
	buffers["trait_texture"] = ImageTexture.create_from_image(trait_image)
	
	call_deferred("_finished_buffer_calc_and_deletion")
	
	return buffers

func _finished_buffer_calc_and_deletion() -> void:
	var buffers: Dictionary = thread.wait_to_finish()
	texture = buffers["pixel_texture"]
	sprite_2d.texture = buffers["trait_texture"]
	got_buffers.emit(buffers)
	finished_deletion.emit()





func get_buffers_in_polygon(polygon: PackedVector2Array) -> void:
	thread.start(_get_buffers_in_polygon.bind(polygon))

func _get_buffers_in_polygon(polygon: PackedVector2Array) -> Dictionary:
	var buffers: Dictionary = {}
	
	var translated_polygon = polygon.duplicate()
	for i in translated_polygon.size():
		translated_polygon[i] += Vector2(pixel_buffer.size() / 2, pixel_buffer[0].size() / 2)
	
	var new_buffer: Array[PackedColorArray] = pixel_buffer.duplicate(true)
	var new_trait_buffer: Array[PackedColorArray] = trait_buffer.duplicate(true)
	
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			# Copy pixels within the selection and return them (done in duplicate, then remove ones outside)
			if not Geometry2D.is_point_in_polygon(Vector2(x, y), translated_polygon):
				new_buffer[x][y].a = 0
				new_trait_buffer[x][y] = ImageJudgement.NO_TRAIT_COLOR
	
	buffers["pixel"] = new_buffer
	buffers["trait"] = new_trait_buffer
	
	call_deferred("_finished_buffer_calc")
	
	return buffers

func _finished_buffer_calc() -> void:
	var buffers: Dictionary = thread.wait_to_finish()
	got_buffers.emit(buffers)


func delete_buffers_in_polygon(polygon: PackedVector2Array) -> void:
	thread.start(_delete_buffers_in_polygon.bind(polygon, texture.get_image(), sprite_2d.texture.get_image()))

func _delete_buffers_in_polygon(polygon: PackedVector2Array, image: Image, trait_image: Image) -> Dictionary:
	var buffers: Dictionary = {}
	
	image = image.duplicate()
	trait_image = trait_image.duplicate()
	
	var translated_polygon = polygon.duplicate()
	for i in translated_polygon.size():
		translated_polygon[i] += Vector2(pixel_buffer.size() / 2, pixel_buffer[0].size() / 2)
	
	var new_buffer: Array[PackedColorArray] = pixel_buffer.duplicate(true)
	var new_trait_buffer: Array[PackedColorArray] = trait_buffer.duplicate(true)
	
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			# Copy pixels within the selection and return them (done in duplicate, then remove ones outside)
			if not Geometry2D.is_point_in_polygon(Vector2(x, y), translated_polygon):
				new_buffer[x][y].a = 0
				new_trait_buffer[x][y] = ImageJudgement.NO_TRAIT_COLOR
			else: # Delete pixels within the selection
				pixel_buffer[x][y] = Color(1, 1, 1, 0)
				trait_buffer[x][y] = ImageJudgement.NO_TRAIT_COLOR
				image.set_pixel(x, y, pixel_buffer[x][y])
				trait_image.set_pixel(x, y, trait_buffer[x][y])
				modified_buffer[x][y] = 1
	
	buffers["pixel"] = new_buffer
	buffers["trait"] = new_trait_buffer
	buffers["pixel_texture"] = ImageTexture.create_from_image(image)
	buffers["trait_texture"] = ImageTexture.create_from_image(trait_image)
	
	call_deferred("_finished_deletion")
	
	return buffers

func _finished_deletion() -> void:
	var buffers: Dictionary = thread.wait_to_finish()
	texture = buffers["pixel_texture"]
	sprite_2d.texture = buffers["trait_texture"]
	finished_deletion.emit()

#endregion





#region File Conversion

func convert_to_file() -> File:
	var texture_image: Image = texture.get_image()
	var trait_texture_image: Image = sprite_2d.texture.get_image()
	var modified_count: int = 0
	for x in pixel_buffer.size():
		for y in pixel_buffer[0].size():
			if modified_buffer[x][y] != 0:
				modified_count += 1
	
	var new_texture: ImageTexture = ImageTexture.create_from_image(texture_image)
	var new_trait_texture: ImageTexture = ImageTexture.create_from_image(trait_texture_image)
	
	sprite_2d.texture = new_trait_texture
	
	var file: File = File.create_from_data("test_image.png", new_texture, new_trait_texture, modified_count)	
	return file

#endregion
