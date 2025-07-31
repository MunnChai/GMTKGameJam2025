extends Button

@onready var texture_rect = $VBoxContainer/TextureRect
@onready var name_label = $VBoxContainer/NameLabel

var file_node: FileNode

# Preload default icons for folders and unknown file types
var folder_icon = load("res://path/to/your/folder_icon.png")
var unknown_file_icon = load("res://path/to/your/unknown_file_icon.png")

func setup(node: FileNode):
	self.file_node = node
	name_label.text = file_node.node_name

	if file_node.is_folder():
		texture_rect.texture = folder_icon
	else:
		# It's a file, check if it has a texture
		if file_node.texture:
			texture_rect.texture = file_node.texture
		else:
			texture_rect.texture = unknown_file_icon
