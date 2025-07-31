class_name CommissionApp
extends DesktopWindow

@onready var id: RichTextLabel = %Id
@onready var title: RichTextLabel = %Title
@onready var desc: RichTextLabel = %Description

@onready var download_button: Button = %Download
@onready var submit_button: Button = %Submit

var day: int
var commission_stat: CommissionStat

@export var commissions: Dictionary[int, CommissionStat]


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

func update_comm() -> void:
	var stat: CommissionStat = commissions[day]
	if not stat:
		return
	commission_stat = stat
	
	id.text = "User " + stat.id + "\n "
	title.text = stat.title + "\n "
	desc.text = stat.desc + "\n "
