class_name PhotoshopApp
extends Control

## File tools
@onready var save_button: Button = %SaveButton
@onready var reset_button: Button = %ResetButton
@onready var export_button: Button = %ExportButton

## Editing tools
@onready var copy_button: TextureButton = %CopyButton
@onready var cut_button: TextureButton = %CutButton
@onready var paste_button: TextureButton = %PasteButton
@onready var undo_button: TextureButton = %UndoButton
@onready var redo_button: TextureButton = %RedoButton

## Editing panel
@onready var editing_panel: EditingPanel = %EditingPanel

func _ready() -> void:
	reset_button.pressed.connect(_on_reset_pressed)
	export_button.pressed.connect(_on_export_pressed)

func set_file(file: File) -> void:
	editing_panel.set_file(file)

func _on_reset_pressed() -> void:
	editing_panel.reset_texture()

func _on_export_pressed() -> void:
	var file: File = editing_panel.get_current_file()
	
	FileSystem.add_file_node_at("/exports/", file) 
	Desktop.instance.execute("export_success", {"text": "files/exports/" + file.node_name})
