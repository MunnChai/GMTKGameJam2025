class_name FeedbackListItem
extends Button

@onready var item_title: RichTextLabel = %ItemTitle
@onready var client_id: RichTextLabel = %ClientId

var commission_stat: CommissionStat
var submission: Texture2D


func setup(stat: CommissionStat, work: Texture2D = null) -> void:
	commission_stat = stat
	submission = work
	item_title.text = stat.title
	client_id.text = stat.id
