class_name Feedback
extends Node

var stat: CommissionStat
var rating: int
var submission: File
var comments: String

func _init(_stat: CommissionStat, _result: Dictionary, _submission: File = null) -> void:
	stat = _stat
	rating = _result["rating"]
	comments = _result["comments"]
	submission = _submission

func get_stat() -> CommissionStat:
	return stat

func get_submission_texture() -> Texture:
	return submission.texture
