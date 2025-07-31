class_name CommissionApp
extends DesktopWindow

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

@export var commissions: Dictionary[int, CommissionStat]

var day: int
var commission_stat: CommissionStat

signal day_changed

func _ready() -> void:
	if not day:
		day = 1
	connect_signals()
	update_comm()

func connect_signals() -> void:
	download_button.pressed.connect(on_download_pressed)
	submit_button.pressed.connect(on_submit_pressed)
	
func on_download_pressed() -> void:
	return

func on_submit_pressed() -> void:
	day = day + 1
	update_comm()
	day_changed.emit()

func update_comm() -> void:
	var stat: CommissionStat = commissions[day]
	if not stat:
		return
	commission_stat = stat
	
	id.text = "User [b]" + stat.id + "[/b]"
	title.text = "[b][i]" + stat.title + "[/i][/b]"
	desc.text = stat.desc
	
	var assets: Array[Texture2D] = stat.assets
	if not assets:
		return
