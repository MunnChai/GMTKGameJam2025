class_name CommissionApp
extends Control

const COMMISSIONS_CONTAINER = preload("res://apps/commissions_app/commissions_window/commissions_container/commissions_container.tscn")

@onready var commissions_button: Button = %CommissionsButton
@onready var review_button: Button = %ReviewButton

# feedback related
@onready var feedback_list: VBoxContainer = %FeedbackList
@onready var feedback_details: FeedbackDetails = %FeedbackDetails

@onready var commissions_list: VBoxContainer = %CommissionsList

@export var commissions: Dictionary[int, Array]

var commission_stat: CommissionStat

const FileIconScene = preload("res://apps/file_explorer_app/file_icon.tscn")
const FeedbackListItemScene = preload("res://apps/commissions_app/feedback/feedback_list_item.tscn")
const FeedbackScript = preload("res://apps/commissions_app/feedback/feedback.gd")


func _ready() -> void:
	connect_signals()
	update_comm()
	update_feedback()

func connect_signals() -> void:
	feedback_details.back_pressed.connect(on_back_button_pressed)
	
	%SleepButton.pressed.connect(_on_sleep_pressed)

func _on_sleep_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
	GameStateManager.submitted.emit()

#region COMMISSION TAB

func update_comm() -> void:
	var day: int = GameStateManager.day
	
	commissions_list.show()
	%SleepContainer.hide()
	if not commissions.has(day):
		commissions_list.hide()
		%SleepContainer.show()
		return
	
	var stats: Array = commissions[day]
	if not stats:
		return
	
	for child: Node in commissions_list.get_children():
		child.queue_free()
	
	for commission: CommissionStat in stats:
		var commission_container: CommissionsContainer = COMMISSIONS_CONTAINER.instantiate()
		commissions_list.add_child(commission_container)
		commission_container.set_commission(commission)
		print("ADDING")

#endregion

#region FEEDBACK TAB

func on_back_button_pressed() -> void:
	feedback_details.hide()
	feedback_list.show()
	SoundManager.play_global_oneshot(&"ui_basic_click")

func on_feedback_item_pressed(item: FeedbackListItem) -> void:
	feedback_details.show()
	feedback_list.hide()
	feedback_details.setup(item.get_feedback())
	SoundManager.play_global_oneshot(&"ui_basic_click")

# update the feedback_tab
func update_feedback() -> void:
	var feedbacks: Array[Feedback] = CommissionsManager.get_feedbacks()
	
	for fb in feedbacks:
		var feedback_instance = FeedbackListItemScene.instantiate()
		feedback_list.add_child(feedback_instance)
		feedback_list.move_child(feedback_instance, 0)
		feedback_instance.setup(fb)
		feedback_instance.details_pressed.connect(on_feedback_item_pressed.bind(feedback_instance))
#endregion
