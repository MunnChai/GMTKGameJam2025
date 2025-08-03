class_name BankWindow
extends DesktopWindow

@onready var bank_app: BankApp = %BankApp

func _ready() -> void:
	super._ready()

func boot(args: Dictionary = {}) -> void:
	bank_app.set_balance(GameStateManager.money)
	
	%WindowBar.set_window_title("Bank")
