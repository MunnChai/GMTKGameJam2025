class_name EmailDetails
extends Control

@onready var title_label: RichTextLabel = %Title
@onready var sender_label: RichTextLabel = %Sender
@onready var recipient_label: RichTextLabel = %Recipient
@onready var message_label: RichTextLabel = %Message

@onready var back_button: Button = %BackButton

signal back_to_list()

func _ready() -> void:
	back_button.pressed.connect(on_back_button_pressed)

func setup(title: String, sender: String, message: String) -> void:
	title_label.text = title
	sender_label.text = "From: " + sender
	recipient_label.text = "To: " + GameStateManager.get_username()
	message_label.text = message

func on_back_button_pressed() -> void:
	back_to_list.emit()
