class_name FeedbackListItem
extends Button

@onready var item_title: RichTextLabel = %ItemTitle
@onready var client_id: RichTextLabel = %ClientId

var commission_stat: CommissionStat


func setup(stat: CommissionStat) -> void:
	commission_stat = stat
	item_title.text = stat.title
	client_id.text = stat.id
