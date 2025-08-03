class_name EmailStat
extends Resource

@export var sender: String
@export var recipient: String = GameStateManager.get_username()
@export var title: String
@export var message: String

func set_recipient(name: String) -> void:
	recipient = name
