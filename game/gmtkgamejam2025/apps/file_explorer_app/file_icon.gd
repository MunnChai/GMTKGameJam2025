extends Button

@onready var texture_rect = %TextureRect
@onready var name_label = %NameLabel

var file_node: FileNode

var folder_icon = load("res://assets/ui/file_explorer/folder_icon_high_res.png")
#var unknown_file_icon = load("res://game/assets/icons/file_icon.png")
var missing_icon = load("res://assets/ui/icons/netscape_missing.png")

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
				#name_label.add_theme_color_override("font_color", Color.WHITE)
				texture_rect.texture = missing_icon
				texture_rect.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_CENTERED
			elif file.texture:
				# It's an image, so use its texture
				texture_rect.texture = file.texture
				texture_rect.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED
			else:
				# It's some other file type, use the generic icon
				texture_rect.texture = missing_icon
				texture_rect.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_CENTERED

@onready var base_pos: Vector2 = %TextureRect.position

func _on_mouse_entered() -> void:
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
	if is_instance_valid(%TextureRect):
		TweenUtil.whoosh(%TextureRect, base_pos + Vector2.UP * 8.0, 0.3)
		TweenUtil.pop_delta(%TexturePivot, Vector2(0.2, 0.2), 0.35)

func _on_mouse_exited() -> void:
	if GameSettings.get_setting("reduced_motion", false, "graphics"):
		return
	if is_instance_valid(%TextureRect):
		TweenUtil.whoosh(%TextureRect, base_pos, 0.3)
