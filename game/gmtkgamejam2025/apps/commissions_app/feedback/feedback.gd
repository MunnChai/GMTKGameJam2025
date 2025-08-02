class_name Feedback
extends Node

var rating: int
var submission: File

func _init(_rating: int = 0, _submission: File = null) -> void:
	rating = _rating
	submission = _submission

func get_submission_texture() -> Texture:
	return submission.texture
