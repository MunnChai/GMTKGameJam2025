class_name BankApp
extends Control

@onready var balance_label: RichTextLabel = %Balance
@onready var due_date_label: RichTextLabel = %DueDate
@onready var welcome_message: RichTextLabel = %WelcomeMessage

func _ready() -> void:
	GameStateManager.money_changed.connect(set_balance)
	GameStateManager.day_changed.connect(set_day)
	set_day(GameStateManager.day)
	
	welcome_message.text = "Welcome, " + GameStateManager.username

func set_balance(balance: float) -> void:
	balance_label.text = "$" + str("%0.2f" % balance)

func set_day(day: int) -> void:
	due_date_label.text = "Due in " + str(5 - day) + " days"
