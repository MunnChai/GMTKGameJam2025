class_name FileExplorer
extends Control

@onready var back_button = $VBoxContainer/Header/TopBar/BackButton
@onready var path_label = %PathLabel
@onready var file_grid = %FileGrid
@onready var file_system = $FileSystemAccess
@onready var header = $VBoxContainer/Header
#@onready var close_button = $VBoxContainer/Header/TopBar/WindowControls/CloseButton
#@onready var min_button = $VBoxContainer/Header/TopBar/WindowControls/MinButton
#@onready var max_button = $VBoxContainer/Header/TopBar/WindowControls/MaxButton

const FileIconScene = preload("res://apps/file_explorer_app/file_icon.tscn")

func _ready():
	# Connect signals
	back_button.pressed.connect(file_system.go_back)
	file_system.directory_changed.connect(self._on_directory_changed)
	
	_on_directory_changed(file_system.get_current_contents())

func _on_directory_changed(contents: Array[FileNode]):
	for child in file_grid.get_children():
		child.queue_free()
	
	var counter = 0
	for file_node in contents:
		var icon_instance = FileIconScene.instantiate()
		file_grid.add_child(icon_instance)
		icon_instance.setup(file_node)
		icon_instance.pressed.connect(file_system.open_file.bind(file_node))
		
		icon_instance.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(icon_instance, "modulate:a", 1.0, 0.2).set_delay(0.05 * counter)
		counter += 1

	var path_string = ""
	for i in range(file_system.directory_history.size()):
		var folder = file_system.directory_history[i]
		path_string += ("/" if i > 0 else "") + folder.node_name
	path_label.text = path_string + "/"
	
	if file_system.directory_history.size() <= 1:
		back_button.disabled = true
	else: 
		back_button.disabled = false

func set_upload_mode(upload: bool) -> void:
	file_system.upload_mode = upload

func get_file_system_access() -> FileSystemAccess:
	return file_system
