class_name EmailListItem
extends Control

@onready var title_label: RichTextLabel = %EmailTitle
@onready var sender_label: RichTextLabel = %Sender
@onready var button: Button = %Button

signal on_email_item_pressed()

func _ready() -> void:
	button.pressed.connect(on_self_pressed)

func setup(title: String, sender: String) -> void:
	title_label.text = title
	sender_label.text = sender

func on_self_pressed() -> void:
	on_email_item_pressed.emit()
