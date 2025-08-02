class_name FeedbackListItem
extends Container

@onready var item_title: RichTextLabel = %ItemTitle
@onready var client_id: RichTextLabel = %ClientId
@onready var details_button: Button = %DetailsButton

var feedback: Feedback

signal details_pressed

func _ready() -> void:
	details_button.pressed.connect(_on_details_pressed)

func setup(fb: Feedback) -> void:
	feedback = fb
	var stat: CommissionStat = fb.get_stat()
	item_title.text = stat.title
	client_id.text = stat.id

func get_feedback() -> Feedback:
	return feedback

func _on_details_pressed() -> void:
	details_pressed.emit()
