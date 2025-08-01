class_name CommissionsManagerGlobal
extends Node

signal feedback_added(commission_id: int, feedback: Feedback)
signal submission_added(work: File)

var feedbacks: Dictionary[int, Array] = {}
var submission: File

func add_feedback(commission_id: int, feedback: Feedback) -> void:
	if not feedbacks.has(commission_id):
		feedbacks[commission_id] = []
	feedbacks[commission_id].append(feedback)
	emit_signal("feedback_added", commission_id, feedback)

func get_feedbacks(commission_id: int) -> Array:
	return feedbacks.get(commission_id, [])

func clear_feedbacks(commission_id: int) -> void:
	feedbacks.erase(commission_id)

func add_submission(work: File) -> void:
	if work:
		submission = work
		submission_added.emit(work)
