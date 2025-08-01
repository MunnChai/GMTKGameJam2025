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
@onready var submit_button: Button = %Submit
@onready var asset_list: HBoxContainer = %AssetList
@onready var back_button: Button = %BackButton
@onready var feedback_list: VBoxContainer = %FeedbackList
@onready var feedback_details: MarginContainer = %FeedbackDetails
@onready var feedback_id: RichTextLabel = %FeedbackId
@onready var feedback_title: RichTextLabel = %FeedbackTitle
@onready var feedback_desc: RichTextLabel = %FeedbackDesc
@onready var feedback_work: TextureRect = %SubmittedWork


@export var commissions: Dictionary[int, CommissionStat]

var day: int
var commission_stat: CommissionStat

const FileIconScene = preload("res://apps/file_explorer_app/file_icon.tscn")
const FeedbackListItemScene = preload("res://apps/commissions_app/feedback_list_item.tscn")

signal day_changed

func _ready() -> void:
	if not day:
		day = 1
	connect_signals()
	update_comm()

func connect_signals() -> void:
	download_button.pressed.connect(on_download_pressed)
	submit_button.pressed.connect(on_submit_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	
func on_download_pressed() -> void:
	# Create a client folder
	#var client1_folder = Folder.new("Client_A")
	#add_file_node_at("/Commissions", client1_folder)
	#add_file_node_at("/Commissions/Client_A", file1)
	
	var files = asset_list.get_children()
	var folder_name: String = "Client " + commission_stat.id
	var client_folder = Folder.new(folder_name)
	FileSystem.add_file_node_at("/Commissions", client_folder)
	for file in files:
		FileSystem.add_file_node_at("/Commissions/" + folder_name, file.file_node)

func on_submit_pressed() -> void:
	add_feedback()
	day = day + 1
	update_comm()
	day_changed.emit()
	
func add_feedback() -> void:
	var feedback_instance: FeedbackListItem = FeedbackListItemScene.instantiate()
	feedback_list.add_child(feedback_instance)
	feedback_instance.setup(commission_stat)
	# add submission in the future
	feedback_instance.pressed.connect(on_feedback_item_pressed.bind(feedback_instance))

func on_back_button_pressed() -> void:
	feedback_details.hide()
	feedback_list.show()

func on_feedback_item_pressed(item: FeedbackListItem) -> void:
	feedback_details.show()
	feedback_list.hide()
	var stat: CommissionStat = item.commission_stat
	feedback_id.text = stat.id
	feedback_title.text = stat.title
	feedback_desc.text = stat.desc
	feedback_work.texture = item.submission

func update_comm() -> void:
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
	
	var assets: Dictionary[String, Texture2D] = stat.assets
	if not assets:
		return
	for file_name in assets.keys():
		var file: File = File.new(file_name, "image", assets[file_name])
		var icon_instance = FileIconScene.instantiate()
		asset_list.add_child(icon_instance)
		icon_instance.setup(file)
