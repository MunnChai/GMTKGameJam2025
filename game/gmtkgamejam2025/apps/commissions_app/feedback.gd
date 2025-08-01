class_name Feedback
extends Node

var title: String
var rating: int
var submission: Texture2D

func _init(_title: String = "", _rating: int = 0, _submission: Texture2D = null) -> void:
	title = _title
	rating = _rating
	submission = _submission
