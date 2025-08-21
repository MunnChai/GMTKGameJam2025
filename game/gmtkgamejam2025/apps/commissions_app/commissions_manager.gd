class_name CommissionsManagerGlobal
extends Node

signal submission_added(commission: CommissionStat, work: File)

var feedbacks: Array[Feedback]
var submissions: Dictionary[CommissionStat, File]

func add_feedback(fb: Feedback) -> void:
	feedbacks.append(fb)

func get_feedbacks() -> Array[Feedback]:
	return feedbacks

func add_submission(commission: CommissionStat, work: File) -> void:
	if work:
		submissions[commission] = work
		submission_added.emit(commission, work)

func get_submission(commission: CommissionStat) -> File:
	return submissions[commission]

func clear_feedbacks() -> void:
	feedbacks.clear()
	submissions.clear()
