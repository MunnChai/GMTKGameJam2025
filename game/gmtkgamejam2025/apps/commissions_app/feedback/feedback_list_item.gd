class_name FeedbackListItem
extends Button

@onready var item_title: RichTextLabel = %ItemTitle
@onready var client_id: RichTextLabel = %ClientId


var feedback: Feedback

func setup(fb: Feedback) -> void:
	feedback = fb
	var stat: CommissionStat = fb.get_stat()
	item_title.text = stat.title
	client_id.text = stat.id

func get_feedback() -> Feedback:
	return feedback
