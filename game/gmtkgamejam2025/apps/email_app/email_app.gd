class_name EmailApp
extends Control

@onready var email_list: VBoxContainer = %EmailList
@onready var email_details: EmailDetails = %EmailDetails

const EmailListItemScene = preload("res://apps/email_app/email_list_item.tscn")

@export var email_stats: Array[EmailStat]

func _ready() -> void:
	email_details.back_to_list.connect(on_back_button_pressed)
	populate_email_list(GameStateManager.get_emails())

func populate_email_list(emails: Array[EmailStat]) -> void:
	if not emails or emails.is_empty():
		return
	
	for child in email_list.get_children():
		child.queue_free()
	
	for email in emails:
		var email_instance: EmailListItem = EmailListItemScene.instantiate()
		email_list.add_child(email_instance)
		email_list.move_child(email_instance, 0)
		email_instance.setup(email.title, email.sender)
		email_instance.on_email_item_pressed.connect(on_email_item_pressed.bind(email))
		
func on_email_item_pressed(email: EmailStat) -> void:
	email_list.hide()
	email_details.show()
	email_details.setup(email.title, email.sender, email.message)

func on_back_button_pressed() -> void:
	email_list.show()
	email_details.hide()
	populate_email_list(GameStateManager.get_emails())
