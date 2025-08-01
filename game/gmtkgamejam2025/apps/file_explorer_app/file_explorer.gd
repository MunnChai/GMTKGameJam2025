extends Window

@onready var back_button = $VBoxContainer/Header/TopBar/BackButton
@onready var path_label = $VBoxContainer/Header/TopBar/PathLabel
@onready var file_grid = $VBoxContainer/FileView/FileGrid
@onready var file_system = $FileSystemNode
@onready var header = $VBoxContainer/Header
@onready var close_button = $VBoxContainer/Header/TopBar/WindowControls/CloseButton
@onready var min_button = $VBoxContainer/Header/TopBar/WindowControls/MinButton
@onready var max_button = $VBoxContainer/Header/TopBar/WindowControls/MaxButton

const FileIconScene = preload("res://apps/file_explorer_app/file_icon.tscn")

var dragging = false
var last_window_size = Vector2i()

func _ready():
	# Connect signals
	back_button.pressed.connect(file_system.go_back)
	close_button.pressed.connect(self._on_close_pressed)
	min_button.pressed.connect(self._on_min_pressed)
	max_button.pressed.connect(self._on_max_pressed)
	file_system.directory_changed.connect(self._on_directory_changed)
	
	_on_directory_changed(file_system.get_current_contents())

# This function handles the custom window dragging
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if header.get_global_rect().has_point(event.position):
			if event.pressed:
				dragging = true
			else:
				dragging = false
	if event is InputEventMouseMotion and dragging:
		position += Vector2i(event.relative)

func _on_directory_changed(contents: Array[FileNode]):
	for child in file_grid.get_children():
		child.queue_free()

	for file_node in contents:
		var icon_instance = FileIconScene.instantiate()
		file_grid.add_child(icon_instance)
		icon_instance.setup(file_node)
		icon_instance.pressed.connect(file_system.open_file.bind(file_node))
		
		icon_instance.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(icon_instance, "modulate:a", 1.0, 0.2).set_delay(0.05 * file_grid.get_child_count())

	var path_string = ""
	for i in range(file_system.directory_history.size()):
		var folder = file_system.directory_history[i]
		path_string += ("/" if i > 0 else "") + folder.node_name
	path_label.text = path_string + "/"

func _on_close_pressed():
	hide()

func _on_min_pressed():
	mode = Window.MODE_MINIMIZED

func _on_max_pressed():
	if mode == Window.MODE_WINDOWED:
		# Store current size before maximizing
		last_window_size = size
		mode = Window.MODE_MAXIMIZED
	else:
		# Restore to previous size
		mode = Window.MODE_WINDOWED
		size = last_window_size
