extends Node

const MONEY_TO_TRUE_END: int = 170
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

#var arrow = load("res://arrow.png")
#var beam = load("res://beam.png")

func _ready():
	pass
	#day = 5
	#Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW)
	#Input.set_custom_mouse_cursor(beam, Input.CURSOR_POINTING_HAND)
	#Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)

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
	email = email.duplicate()
	email.date_string = get_date_string(day)
	emails.append(email)

static func get_date_string(day: int) -> String:
	var text: String = ""
	match day:
		1:
			text = "30/7/2025"
		2:
			text = "31/7/2025"
		3:
			text = "1/8/2025"
		4:
			text = "2/8/2025"
		5:
			text = "3/8/2025"
		6:
			text = "3/8/2025"
		7:
			text = "4/8/2025"
	return text

func reset_game_state() -> void:
	money = 5
	day = 1
	emails.clear()
	#CommissionsManager.clear_feedbacks()
