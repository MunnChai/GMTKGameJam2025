class_name File
extends FileNode

@export var file_type: String
@export var texture: Texture

func _init(new_name: String, new_type: String, new_texture: Texture = null):
	node_name = new_name
	file_type = new_type
	texture = new_texture
