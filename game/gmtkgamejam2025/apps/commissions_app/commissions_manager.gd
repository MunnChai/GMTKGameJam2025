class_name CommissionsManagerGlobal
extends Node

signal feedback_added(commission_id: int, feedback: Feedback)
signal submission_added(work: File)

var feedbacks: Array[Feedback]
var submission: File

func add_feedback(fb: Feedback) -> void:
	feedbacks.append(fb)

func get_feedbacks() -> Array[Feedback]:
	return feedbacks

func add_submission(work: File) -> void:
	if work:
		submission = work
		submission_added.emit(work)

func get_submission() -> File:
	return submission
