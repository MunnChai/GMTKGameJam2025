extends Node

const MONEY_TO_TRUE_END: int = 170
const MONEY_TO_WIN: int = 100

@export var ending_scenes: Dictionary[String, PackedScene]
@export var commission_ending_scenes: Dictionary[CommissionStat, PackedScene]

@export var email_stats: Dictionary[String, EmailStat]
@export var unique_email_stats: Dictionary[CommissionStat, EmailStat]

func get_ending_scene() -> PackedScene:
	
	var completed_commissions: Array = CommissionsManager.feedbacks.map(func(feedback: Feedback):
		return feedback.stat
	)
	
	for commission: CommissionStat in commission_ending_scenes.keys():
		if completed_commissions.has(commission):
			return commission_ending_scenes[commission]
	
	if GameStateManager.money > MONEY_TO_TRUE_END:
		return ending_scenes["true_ending"]
	elif GameStateManager.money > MONEY_TO_WIN:
		return ending_scenes["good_ending"]
	else:
		return ending_scenes["bad_ending"]
	
	return ending_scenes[""]
