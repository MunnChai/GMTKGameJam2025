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
