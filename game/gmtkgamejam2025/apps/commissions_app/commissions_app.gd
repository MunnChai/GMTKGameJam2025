class_name CommissionApp
extends Control


@onready var id: RichTextLabel = %Id
@onready var title: RichTextLabel = %Title
@onready var desc: RichTextLabel = %Description

# commission related
@onready var download_button: Button = %Download
@onready var upload_button: Button = %Upload
@onready var submit_button: Button = %Submit
@onready var submitted_work: TextureRect = %SubmittedWork
@onready var asset_list: HBoxContainer = %AssetList

# feedback related
@onready var back_button: Button = %BackButton
@onready var feedback_list: VBoxContainer = %FeedbackList
@onready var feedback_details: MarginContainer = %FeedbackDetails
@onready var feedback_id: RichTextLabel = %FeedbackId
@onready var feedback_title: RichTextLabel = %FeedbackTitle
@onready var feedback_desc: RichTextLabel = %FeedbackDesc
@onready var feedback_rating: RichTextLabel = %FeedbackRating
@onready var feedback_submission: TextureRect = %FeedbackSubmission

@export var commissions: Dictionary

var commission_stat: CommissionStat

const FileIconScene = preload("res://apps/file_explorer_app/file_icon.tscn")
const FeedbackListItemScene = preload("res://apps/commissions_app/feedback/feedback_list_item.tscn")
const FeedbackScript = preload("res://apps/commissions_app/feedback/feedback.gd")


func _ready() -> void:
	connect_signals()
	update_comm()
	update_feedback()

func connect_signals() -> void:
	download_button.pressed.connect(on_download_pressed)
	upload_button.pressed.connect(on_upload_pressed)
	submit_button.pressed.connect(on_submit_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	CommissionsManager.submission_added.connect(_on_submission_added)
	#Desktop.instance.transition_done.connect(update_comm)

#region COMMISSION TAB

func on_download_pressed() -> void:
	var files = asset_list.get_children()
	var folder_name: String = "Client " + commission_stat.id
	var client_folder = Folder.new(folder_name)
	FileSystem.add_file_node_at("/commissions", client_folder)
	for file in files:
		FileSystem.add_file_node_at("/commissions/" + folder_name, file.file_node)

func on_upload_pressed() -> void:
	Desktop.instance.execute(&"file_explorer", {"upload": true})

func on_submit_pressed() -> void:
	add_feedback()
	GameStateManager.next_day()

func update_comm() -> void:
	var day: int = GameStateManager.day
	
	if not commissions.has(day):
		return

	var stat: CommissionStat = commissions[day]
	if not stat:
		return
	commission_stat = stat

	id.text = "User [b]" + stat.id + "[/b]"
	title.text = "[b][i]" + stat.title + "[/i][/b]"
	desc.text = stat.desc

	for child in asset_list.get_children():
		child.queue_free()

	submitted_work.hide()
	submitted_work.texture = null

	var assets: Array[FileResource] = stat.assets
	if not assets:
		return
	for file_res in assets:
		var file: File = File.create_from_resource(file_res)
		var icon_instance = FileIconScene.instantiate()
		asset_list.add_child(icon_instance)
		icon_instance.setup(file)

#endregion

#region FEEDBACK TAB

func add_feedback() -> void:
	var rating: int = ImageJudgement.compare_file_to_desired(CommissionsManager.get_submission(), null)
	var feedback: Feedback = Feedback.new(commission_stat, rating, CommissionsManager.get_submission())
	CommissionsManager.add_feedback(feedback)
	var feedback_instance = FeedbackListItemScene.instantiate()
	feedback_list.add_child(feedback_instance)
	feedback_instance.setup(feedback)
	feedback_instance.pressed.connect(on_feedback_item_pressed.bind(feedback_instance))

func on_back_button_pressed() -> void:
	feedback_details.hide()
	feedback_list.show()

func _on_submission_added(work: File) -> void:
	if not work:
		submitted_work.hide()
		return
	submitted_work.show()
	submitted_work.texture = work.texture

func on_feedback_item_pressed(item: FeedbackListItem) -> void:
	feedback_details.show()
	feedback_list.hide()
	var stat: CommissionStat = item.get_feedback().get_stat()
	feedback_id.text = stat.id
	feedback_title.text = stat.title
	feedback_desc.text = stat.desc
	var fb: Feedback = item.get_feedback()
	feedback_rating.text = str(fb.rating)
	feedback_submission.texture = fb.get_submission_texture()

# update the feedback_tab
func update_feedback() -> void:
	var feedbacks: Array[Feedback] = CommissionsManager.get_feedbacks()
	for fb in feedbacks:
		var feedback_instance = FeedbackListItemScene.instantiate()
		feedback_list.add_child(feedback_instance)
		feedback_instance.setup(fb)
		feedback_instance.pressed.connect(on_feedback_item_pressed.bind(feedback_instance))
#endregion
