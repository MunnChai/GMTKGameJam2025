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
@onready var amount_paid_label: RichTextLabel = %AmountPaid
@onready var collect_payment_button: Button = %CollectPaymentButton

var current_feedback: Feedback

signal back_pressed

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	collect_payment_button.pressed.connect(_on_collect_payment_pressed)

func setup(feedback: Feedback) -> void:
	var stat: CommissionStat = feedback.get_stat()
	feedback_id.text = "User: [b]" + stat.id + "[/b]"
	feedback_title.text = stat.title
	feedback_desc.text = stat.desc
	
	feedback_submission.texture = feedback.get_submission_texture()
	
	feedback_id_2.text = "User: [b]" + stat.id + "[/b]"
	feedback_rating.text = "Overall Rating:" + str(feedback.rating) + "/10"
	feedback_comments.text = "Comments:\n" + feedback.comments
	amount_paid_label.text = "Amount Paid: $" + str("%0.2f" % feedback.amount_paid)
	current_feedback = feedback
	
	collect_payment_button.disabled = current_feedback.is_money_collected
	if current_feedback.is_money_collected:
		collect_payment_button.text = "Already Collected!"
	if is_zero_approx(current_feedback.amount_paid):
		collect_payment_button.text = "No payment..."

func _on_back_pressed() -> void:
	back_pressed.emit()

func _on_collect_payment_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
	GameStateManager.add_money(current_feedback.amount_paid)
	current_feedback.is_money_collected = true
	collect_payment_button.disabled = true
