class_name PhotoshopApp
extends Control

## File tools
@onready var save_button: Button = %SaveButton
@onready var reset_button: Button = %ResetButton
@onready var export_button: Button = %ExportButton

## Editing tools
@onready var copy_button: Button = %CopyButton
@onready var cut_button: Button = %CutButton
@onready var paste_button: Button = %PasteButton
@onready var undo_button: Button = %UndoButton
@onready var redo_button: Button = %RedoButton

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
