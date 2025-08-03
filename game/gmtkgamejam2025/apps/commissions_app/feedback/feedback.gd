class_name Feedback
extends Node

var stat: CommissionStat
var rating: int
var submission: File
var comments: String
var amount_paid: float
var date: String

var is_money_collected: bool = false

func _init(_stat: CommissionStat, _result: Dictionary, _submission: File = null) -> void:
	stat = _stat
	rating = _result["rating"]
	comments = _result["comments"]
	amount_paid = _result["amount_paid"]
	submission = _submission
	date = GameStateManager.get_date_string(GameStateManager.day)

func get_stat() -> CommissionStat:
	return stat

func get_submission_texture() -> Texture:
	return submission.texture

func get_date() -> String:
	return date
