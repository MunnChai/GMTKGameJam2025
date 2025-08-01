extends Control

@onready var back_button = $VBoxContainer/TopBar/BackButton
@onready var path_label = $VBoxContainer/TopBar/PathLabel
@onready var file_grid = $VBoxContainer/FileView/FileGrid
@onready var file_system = $FileSystemNode

const FileIconScene = preload("res://apps/file_explorer_app/file_icon.tscn")

func _ready():
	# Connect signals
	back_button.pressed.connect(file_system.go_back)
	file_system.directory_changed.connect(self._on_directory_changed)
	
	# Initial population
	_on_directory_changed(file_system.get_current_contents())

func _on_directory_changed(contents: Array[FileNode]):
	# Clear existing icons
	for child in file_grid.get_children():
		child.queue_free()

	# Populate with new icons
	for file_node in contents:
		var icon_instance = FileIconScene.instantiate()
		file_grid.add_child(icon_instance)
		icon_instance.setup(file_node)
		
		# Connect the icon's pressed signal to the file system
		icon_instance.pressed.connect(file_system.open_file.bind(file_node))
	
	# Update the path label
	var path_string = "root"
	for folder in file_system.directory_history:
		if folder != file_system.root:
			path_string += "/" + folder.node_name
	path_label.text = path_string
