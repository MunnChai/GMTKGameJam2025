extends Node

var money: int = 5

var day: int = 1

signal money_changed(new_money)
signal day_changed(new_day)

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
