class_name FeedbackListItem
extends Button

@onready var item_title: RichTextLabel = %ItemTitle
@onready var client_id: RichTextLabel = %ClientId

var commission_stat: CommissionStat
var submission: Texture2D
var feedback: Feedback

func setup(stat: CommissionStat, work: Texture2D = null) -> void:
	commission_stat = stat
	submission = work
	item_title.text = stat.title
	client_id.text = stat.id

func setup_with_data(stat: CommissionStat, fb: Feedback) -> void:
	commission_stat = stat
	feedback = fb
	submission = fb.submission
	item_title.text = fb.title
	client_id.text = stat.id
