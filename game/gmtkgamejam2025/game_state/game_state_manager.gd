extends Node

var money: int = 0
var day: int = 1
var username: String

var emails: Array[EmailStat]

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

func set_username(name: String) -> void:
	username = name

func get_username() -> String:
	return username

func get_emails() -> Array[EmailStat]:
	return emails

func add_email(email: EmailStat) -> void:
	emails.append(email)
