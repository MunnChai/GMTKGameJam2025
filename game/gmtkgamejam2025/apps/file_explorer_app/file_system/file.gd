class_name File
extends FileNode

## ---
## FILE
## Leaf of the file-folder composite
## ---

@export var file_type: String
@export var texture: Texture
@export var trait_texture: Texture

func _init(new_name: String, new_type: String, new_texture: Texture = null, new_trait_texture: Texture = null):
	node_name = new_name
	file_type = new_type
	texture = new_texture
	trait_texture = new_trait_texture
