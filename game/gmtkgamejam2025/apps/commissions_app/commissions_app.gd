class_name CommissionApp
extends Control

const DOWNLOAD_FILE = preload("res://apps/commissions_app/download_file_scene/download_file.tscn")

@onready var id: RichTextLabel = %Id
@onready var title: RichTextLabel = %Title
@onready var desc: RichTextLabel = %Description

# commission related
@onready var download_button: Button = %Download
@onready var upload_button: Button = %Upload
@onready var submit_button: Button = %Submit
@onready var submitted_work: DownloadFile = %SubmittedWork
@onready var asset_list: Container = %AssetList

# feedback related
@onready var feedback_list: VBoxContainer = %FeedbackList
@onready var feedback_details: FeedbackDetails = %FeedbackDetails


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
	feedback_details.back_pressed.connect(on_back_button_pressed)
	CommissionsManager.submission_added.connect(_on_submission_added)
	#Desktop.instance.transition_done.connect(update_comm)

#region COMMISSION TAB

func on_download_pressed() -> void:
	var files = asset_list.get_children()
	var folder_name: String = "User " + commission_stat.id
	var client_folder = Folder.new(folder_name)
	FileSystem.add_file_node_at("/commissions", client_folder)
	for download_file: DownloadFile in files:
		FileSystem.add_file_node_at("/commissions/" + folder_name, download_file.file)
	
	var args := {
		"title": "DOWNLOAD SUCCESS",
		"text": "Downloaded files to \"/commissions/" + folder_name + "\"!",
		"confirm_label": "Open in File Explorer",
	}
	
	var window: InfoPopup = Desktop.instance.execute(&"info", args)
	window.confirmed.connect(func():
		var file_explorer_args := {
			"upload": false,
			"folder_path": ["commissions", folder_name]
		}
		Desktop.instance.execute(&"file_explorer", file_explorer_args)
		)

func on_upload_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
	Desktop.instance.execute(&"file_explorer", {"upload": true})

func on_submit_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
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

	id.text = "User: [b]" + stat.id + "[/b]"
	title.text = "[b][i]" + stat.title + "[/i][/b]"
	desc.text = stat.desc

	for child in asset_list.get_children():
		child.queue_free()

	submitted_work.hide()
	submitted_work.clear()

	var assets: Array[FileResource] = stat.assets
	if not assets:
		return
	for file_res in assets:
		var download_file: DownloadFile = DOWNLOAD_FILE.instantiate()
		var file: File = File.create_from_resource(file_res)
		asset_list.add_child(download_file)
		download_file.setup(file)

#endregion

#region FEEDBACK TAB

func add_feedback() -> void:
	var submission = CommissionsManager.get_submission()
	var result: Dictionary = ImageJudgement.compare_file_to_desired(submission, commission_stat.desired_judgement)
	var feedback: Feedback = Feedback.new(commission_stat, result, submission)
	CommissionsManager.add_feedback(feedback)
	var feedback_instance: FeedbackListItem = FeedbackListItemScene.instantiate()
	feedback_list.add_child(feedback_instance)
	feedback_instance.setup(feedback)
	feedback_instance.details_pressed.connect(on_feedback_item_pressed.bind(feedback_instance))

func on_back_button_pressed() -> void:
	feedback_details.hide()
	feedback_list.show()

func _on_submission_added(work: File) -> void:
	if not work:
		submitted_work.hide()
		return
	submitted_work.show()
	submitted_work.setup(work)
	submit_button.disabled = false

func on_feedback_item_pressed(item: FeedbackListItem) -> void:
	feedback_details.show()
	feedback_list.hide()
	feedback_details.setup(item.get_feedback())

# update the feedback_tab
func update_feedback() -> void:
	var feedbacks: Array[Feedback] = CommissionsManager.get_feedbacks()
	feedbacks.reverse()
	for fb in feedbacks:
		var feedback_instance = FeedbackListItemScene.instantiate()
		feedback_list.add_child(feedback_instance)
		feedback_instance.setup(fb)
		feedback_instance.details_pressed.connect(on_feedback_item_pressed.bind(feedback_instance))
#endregion
