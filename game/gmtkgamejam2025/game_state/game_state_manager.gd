extends Node

const MONEY_TO_TRUE_END: int = 180
const MONEY_TO_WIN: int = 100
var money: int = 5

var day: int = 1
var username: String

@export var email_stats: Dictionary[String, EmailStat]

var emails: Array[EmailStat]

signal submitted()
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
	SoundManager.play_global_oneshot(&"day_end")

func set_username(name: String) -> void:
	username = name
	username_changed.emit(username)

func get_username() -> String:
	return username

func get_emails() -> Array[EmailStat]:
	return emails

func add_email(email: EmailStat) -> void:
	emails.append(email)
