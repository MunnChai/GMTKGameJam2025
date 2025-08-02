class_name FeedbackDetails
extends MarginContainer

@onready var back_button: Button = %BackButton
@onready var feedback_id: RichTextLabel = %FeedbackId
@onready var feedback_id_2: RichTextLabel = %FeedbackId2
@onready var feedback_title: RichTextLabel = %FeedbackTitle
@onready var feedback_desc: RichTextLabel = %FeedbackDesc
@onready var feedback_rating: RichTextLabel = %FeedbackRating
@onready var feedback_submission: TextureRect = %FeedbackSubmission
@onready var feedback_comments: RichTextLabel = %FeedbackComments

signal back_pressed

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func setup(feedback: Feedback) -> void:
	var stat: CommissionStat = feedback.get_stat()
	feedback_id.text = "User: [b]" + stat.id + "[/b]"
	feedback_title.text = stat.title
	feedback_desc.text = stat.desc
	
	feedback_submission.texture = feedback.get_submission_texture()
	
	feedback_id_2.text = "User: [b]" + stat.id + "[/b]"
	feedback_rating.text = str(feedback.rating)
	feedback_comments.text = "Comments:\n" + feedback.comments

func _on_back_pressed() -> void:
	back_pressed.emit()
