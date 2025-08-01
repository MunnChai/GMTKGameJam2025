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

func set_file(file: File) -> void:
	editing_panel.set_file(file)

func set_texture(texture: Texture2D) -> void:
	editing_panel.set_original_texture(texture)

func _on_reset_pressed() -> void:
	editing_panel.reset_texture()
