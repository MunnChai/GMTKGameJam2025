class_name CommissionApp
extends Control

# TODO for commission app
# update asset list (working with file explorer maybe)
# submit work
# generate rating

@onready var id: RichTextLabel = %Id
@onready var title: RichTextLabel = %Title
@onready var desc: RichTextLabel = %Description

@onready var download_button: Button = %Download
@onready var upload_button: Button = %Upload
@onready var submit_button: Button = %Submit
@onready var asset_list: HBoxContainer = %AssetList
@onready var back_button: Button = %BackButton
@onready var feedback_list: VBoxContainer = %FeedbackList
@onready var feedback_details: MarginContainer = %FeedbackDetails
@onready var feedback_id: RichTextLabel = %FeedbackId
@onready var feedback_title: RichTextLabel = %FeedbackTitle
@onready var feedback_desc: RichTextLabel = %FeedbackDesc
@onready var submitted_work: TextureRect = %SubmittedWork

@export var commissions: Dictionary

var commission_stat: CommissionStat

const FileIconScene = preload("res://apps/file_explorer_app/file_icon.tscn")
const FeedbackListItemScene = preload("res://apps/commissions_app/feedback_list_item.tscn")
const FeedbackScript = preload("res://apps/commissions_app/feedback.gd")


func _ready() -> void:
	connect_signals()
	update_comm()
	_load_existing_feedback()

func connect_signals() -> void:
	download_button.pressed.connect(on_download_pressed)
	upload_button.pressed.connect(on_upload_pressed)
	submit_button.pressed.connect(on_submit_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	CommissionsManager.feedback_added.connect(_on_feedback_added)
	CommissionsManager.submission_added.connect(_on_submission_added)

func on_download_pressed() -> void:
	var files = asset_list.get_children()
	var folder_name: String = "Client " + commission_stat.id
	var client_folder = Folder.new(folder_name)
	FileSystem.add_file_node_at("/Commissions", client_folder)
	for file in files:
		FileSystem.add_file_node_at("/Commissions/" + folder_name, file.file_node)

func on_upload_pressed() -> void:
#	Desktop.instance.execute(&"photoshop", {"texture": node.texture })
	Desktop.instance.execute(&"file_explorer", {"upload": true})

func on_submit_pressed() -> void:
	add_feedback()
	GameStateManager.next_day()
	update_comm()
	
	# # — placeholder
	# var placeholder_tex := ImageTexture.new()
	# var img := Image.new()
	# img.create(128, 128, false, Image.FORMAT_RGBA8)
	# img.fill(Color(0.8, 0.8, 0.8, 1.0))
	# placeholder_tex.create_from_image(img)
	# var fb = Feedback.new()
	# fb.title = "title"
	# fb.rating = 0
	# fb.submission = placeholder_tex
	# CommissionsManager.add_feedback(commission_stat.id, fb)
	# day += 1
	# update_comm()
	# emit_signal("day_changed")

func add_feedback() -> void:
	var feedback_instance: FeedbackListItem = FeedbackListItemScene.instantiate()
	feedback_list.add_child(feedback_instance)
	feedback_instance.setup(commission_stat)
	# add submission in the future
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
	var stat: CommissionStat = item.commission_stat
	feedback_id.text = stat.id
	feedback_title.text = stat.title
	feedback_desc.text = stat.desc
	#feedback_work.texture = item.submission

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

	var assets: Dictionary = stat.assets
	if not assets:
		return
	for file_name in assets.keys():
		var file: File = File.new(file_name, "image", assets[file_name])
		var icon_instance = FileIconScene.instantiate()
		asset_list.add_child(icon_instance)
		icon_instance.setup(file)

func _load_existing_feedback() -> void:
	var saved = CommissionsManager.get_feedbacks(int(commission_stat.id))
	for fb_data in saved:
		_create_feedback_item(fb_data)

func _on_feedback_added(c_id: int, fb_data) -> void:
	if c_id != int(commission_stat.id):
		return
	_create_feedback_item(fb_data)

func _create_feedback_item(fb_data) -> void:
	var item = FeedbackListItemScene.instantiate()
	item.setup_with_data(commission_stat, fb_data)
	feedback_list.add_child(item)
	item.pressed.connect(on_feedback_item_pressed.bind(item))
