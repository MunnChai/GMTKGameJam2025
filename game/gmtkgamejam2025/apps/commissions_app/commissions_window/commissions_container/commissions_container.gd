class_name CommissionsContainer
extends MarginContainer

const DOWNLOAD_FILE = preload("res://apps/commissions_app/download_file_scene/download_file.tscn")

@onready var title: RichTextLabel = %Title
@onready var id: RichTextLabel = %Id
@onready var description: RichTextLabel = %Description
@onready var asset_list: VBoxContainer = %AssetList
@onready var download_button: Button = %Download
@onready var submitted_work: DownloadFile = %SubmittedWork
@onready var upload_button: Button = %Upload
@onready var submit_button: Button = %Submit

var commission_stat: CommissionStat

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	download_button.pressed.connect(on_download_pressed)
	upload_button.pressed.connect(on_upload_pressed)
	submit_button.pressed.connect(on_submit_pressed)
	
	CommissionsManager.submission_added.connect(_on_submission_added)


func set_commission(commission: CommissionStat) -> void:
	commission_stat = commission
	
	id.text = "User: [b]" + commission.id + "[/b]"
	title.text = "[b][i]" + commission.title + "[/i][/b]"
	description.text = commission.desc
	
	for child in asset_list.get_children():
		child.queue_free()
	
	submitted_work.hide()
	submitted_work.clear()
	
	var assets: Array[FileResource] = commission.assets
	if not assets:
		return
	
	for file_res in assets:
		var download_file: DownloadFile = DOWNLOAD_FILE.instantiate()
		var file: File = File.create_from_resource(file_res)
		asset_list.add_child(download_file)
		download_file.setup(file)



func on_download_pressed() -> void:
	var files = asset_list.get_children()
	var folder_name: String = "User " + commission_stat.id
	
	for download_file: DownloadFile in files:
		var success: bool = FileSystem.add_file_node_at("/commissions/" + folder_name, download_file.file)
		if not success:
			var client_folder = Folder.new(folder_name)
			FileSystem.add_file_node_at("/commissions", client_folder)
			FileSystem.add_file_node_at("/commissions/" + folder_name, download_file.file)
	
	var args := {
		"title": "Download Success",
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
	var window: FileExplorerWindow = Desktop.instance.execute(&"file_explorer", {"upload": true})
	window.upload_done.connect(_on_upload_finished)

func _on_upload_finished(file_node: FileNode) -> void:
	CommissionsManager.add_submission(commission_stat, file_node)

func _on_submission_added(commission: CommissionStat, work: File) -> void:
	if commission != commission_stat:
		return
	
	if not work:
		submitted_work.hide()
		return
	submitted_work.show()
	submitted_work.setup(work)
	submit_button.disabled = false

func on_submit_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_basic_click")
	add_feedback()
	GameStateManager.submitted.emit()
	submit_button.disabled = true



func add_feedback() -> void:
	var submission = CommissionsManager.get_submission(commission_stat)
	var result: Dictionary = ImageJudgement.compare_file_to_desired(submission, commission_stat.desired_judgement)
	var feedback: Feedback = Feedback.new(commission_stat, result, submission)
	CommissionsManager.add_feedback(feedback)
