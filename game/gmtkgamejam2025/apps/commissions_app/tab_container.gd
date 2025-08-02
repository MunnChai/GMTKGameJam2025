extends HBoxContainer

@export var tab_buttons: Array[Button]
@export var tab_panels: Array[Container]

func _ready() -> void:
	for i in tab_buttons.size():
		var button: Button = tab_buttons[i]
		var panel: Container = tab_panels[i]
		
		button.toggled.connect(_on_button_toggled.bind(button, panel))

func _on_button_toggled(toggled_on: bool, pressed_button: Button, panel: Container) -> void:
	if not toggled_on:
		pressed_button.set_pressed_no_signal(true)
		return
	
	for tab_button: Button in tab_buttons:
		tab_button.set_pressed_no_signal(tab_button == pressed_button)
	
	for tab_panel: Container in tab_panels:
		tab_panel.visible = tab_panel == panel
	
	SoundManager.play_global_oneshot(&"ui_basic_click")
