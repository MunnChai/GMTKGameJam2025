class_name File
extends FileNode

## ---
## FILE
## Leaf of the file-folder composite
## ---

@export var file_type: String
@export var texture: Texture
@export var trait_texture: Texture
@export var modified_count: int = 0

static func create_from_resource(file_resource: FileResource) -> File:
	var file = File.new(file_resource.file_name, "image")
	file.texture = file_resource.texture
	file.trait_texture = file_resource.trait_texture
	return file

static func create_from_data(file_name: String, texture: Texture, trait_texture: Texture, modified_count: int, file_type: String = "image") -> File:
	var file = File.new(file_name, file_type)
	file.texture = texture
	file.trait_texture = trait_texture
	file.modified_count = modified_count
	return file

func _init(new_name: String, new_type: String, new_texture: Texture = null, new_trait_texture: Texture = null):
	node_name = new_name
	file_type = new_type
	texture = new_texture
	trait_texture = new_trait_texture

func get_file_resource() -> FileResource:
	var res = FileResource.new()
	res.file_name = node_name
	res.texture = texture
	res.trait_texture = trait_texture
	return res
