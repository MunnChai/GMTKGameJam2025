extends Node

var money: int = 5

var day: int = 1
var username: String

signal money_changed(new_money: int)
signal day_changed(new_day: int)
signal username_changed(new_username: String)

func add_money(amount: int) -> void:
	money += amount
	emit_signal("money_changed", money)
	
func spend_money(amount: int) -> bool:
	if amount > money:
		return false
	money -= amount
	emit_signal("money_changed", money)
	return true
	
func next_day() -> void:
	day += 1
	emit_signal("day_changed", day)

func set_username(name: String) -> void:
	username = name
	username_changed.emit(username)
