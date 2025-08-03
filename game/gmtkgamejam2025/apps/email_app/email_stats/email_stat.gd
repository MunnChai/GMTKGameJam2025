class_name EmailStat
extends Resource

@export var sender: String
@export var recipient: String
@export var title: String
@export_multiline var message: String

var date_string: String

func set_recipient(name: String) -> void:
	recipient = name
