extends Button

@onready var texture_rect = $VBoxContainer/TextureRect
@onready var name_label = $VBoxContainer/NameLabel

var file_node: FileNode

var folder_icon = load("res://game/assets/icons/folder_icon.png")
var unknown_file_icon = load("res://game/assets/icons/file_icon.png")

# Preload the stylebox resource we created in the FileSystem.
var document_stylebox = preload("res://apps/file_explorer_app/document_style.tres")


func setup(node: FileNode):
	self.file_node = node
	name_label.text = file_node.node_name

	if file_node.is_folder():
		texture_rect.texture = folder_icon
	else:
		var file = file_node as File
		if file:
			# --- Logic for Shaped Icons ---
			if file.file_type == "text":
				# Apply the document style and hide the texture
				#add_theme_stylebox_override("normal", document_stylebox)
				#texture_rect.hide()
				# Change font color for better visibility on the light background
				name_label.add_theme_color_override("font_color", Color.WHITE)
			elif file.texture:
				# It's an image, so use its texture
				texture_rect.texture = file.texture
				texture_rect.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED
			else:
				# It's some other file type, use the generic icon
				texture_rect.texture = unknown_file_icon
