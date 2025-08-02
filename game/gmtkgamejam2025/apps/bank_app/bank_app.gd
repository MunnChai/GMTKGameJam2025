class_name BankApp
extends Control

@onready var balance_label: RichTextLabel = %Balance

func _ready() -> void:
	GameStateManager.money_changed.connect(set_balance)

func set_balance(balance: float) -> void:
	balance_label.text = "$" + str("%0.2f" % balance)
