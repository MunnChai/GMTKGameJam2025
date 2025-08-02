class_name FeedbackListItem
extends Button

@onready var item_title: RichTextLabel = %ItemTitle
@onready var client_id: RichTextLabel = %ClientId


# List item only contains a Feedback object and commission_stat
var commission_stat: CommissionStat
var feedback: Feedback

func setup(stat: CommissionStat, fb: Feedback) -> void:
	commission_stat = stat
	feedback = fb
	item_title.text = stat.title
	client_id.text = stat.id

func get_feedback() -> Feedback:
	return feedback

func setup_with_data(stat: CommissionStat, fb: Feedback) -> void:
	#commission_stat = stat
	#feedback = fb
	#submission = fb.submission
	#item_title.text = fb.title
	#client_id.text = stat.id
	return
