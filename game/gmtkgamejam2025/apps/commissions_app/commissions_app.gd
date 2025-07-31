class_name CommissionApp
extends Control

@onready var id: RichTextLabel = %Id
@onready var title: RichTextLabel = %Title
@onready var desc: RichTextLabel = %Description

@onready var download_button: Button = %Download
@onready var submit_button: Button = %Submit

var commission_stat: CommissionStat

@export var commissions: Dictionary[int, CommissionStat]


func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	download_button.pressed.connect(on_download_pressed)
	submit_button.pressed.connect(on_submit_pressed)
	
func on_download_pressed() -> void:
	return

func on_submit_pressed() -> void:
	return

func update_day(day: int) -> void:
	var stat: CommissionStat = commissions[day]
	if not stat:
		return
	commission_stat = stat
