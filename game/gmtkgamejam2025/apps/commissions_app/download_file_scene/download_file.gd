class_name DownloadFile
extends PanelContainer

@onready var rich_text_label: RichTextLabel = %RichTextLabel

var file: File

func setup(new_file: File) -> void:
	file = new_file
	rich_text_label.text = file.node_name

func clear() -> void:
	file = null
	rich_text_label.text = ""
