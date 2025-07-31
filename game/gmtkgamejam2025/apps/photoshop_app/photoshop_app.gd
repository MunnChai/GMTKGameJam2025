class_name PhotoshopApp
extends Control

## File tools
@onready var save_button: Button = %SaveButton
@onready var reset_button: Button = %ResetButton
@onready var export_button: Button = %ExportButton

## Editing tools
@onready var lasso_button: Button = %LassoButton
@onready var cut_button: Button = %CutButton
@onready var undo_button: Button = %UndoButton
@onready var redo_button: Button = %RedoButton

## Editing nodes
@onready var editing_panel: Control = %EditingPanel
@onready var editing_anchor: Control = %EditingAnchor
@onready var editable_image: Polygon2D = %EditableImage
@onready var pasted_selection: Polygon2D = %PastedSelection
@onready var cutter: Polygon2D = %Cutter

@onready var testbutton: Button = $PanelContainer/VBoxContainer/Body/EditingPanel/EditingAnchor/TESTBUTTON
@onready var testbutton_2: Button = $PanelContainer/VBoxContainer/Body/EditingPanel/EditingAnchor/TESTBUTTON2

var previous_mouse_position: Vector2

const ZOOM_LEVELS: Array = [
	0.5,
	1,
	2,
	3,
	4,
]

var current_zoom_index: int = 1

func _ready() -> void:
	await get_tree().process_frame
	editable_image.texture_offset = editable_image.texture.get_size() / 2
	editable_image.position = -editable_image.texture.get_size() / 2
	editing_anchor.position = editing_panel.size / 2
	
	testbutton_2.pressed.connect(_show_cutter)
	testbutton.pressed.connect(_on_test_button_pressed)

func _process(delta: float) -> void:
	var current_mouse_position: Vector2 = editing_panel.get_local_mouse_position()
	
	var diff: Vector2 = current_mouse_position - previous_mouse_position
	
	if Input.is_action_pressed("edit_panel_move") and not is_zero_approx(diff.length()):
		editing_anchor.position += diff
		
		if editing_anchor.position.x < 0:
			editing_anchor.position.x = 0
		elif editing_anchor.position.x > editing_panel.size.x:
			editing_anchor.position.x = editing_panel.size.x
		
		if editing_anchor.position.y < 0:
			editing_anchor.position.y = 0
		elif editing_anchor.position.y > editing_panel.size.y:
			editing_anchor.position.y = editing_panel.size.y
	
	if Input.is_action_just_pressed("edit_panel_zoom_out"):
		current_zoom_index += 1
		if current_zoom_index >= ZOOM_LEVELS.size():
			current_zoom_index = ZOOM_LEVELS.size() - 1
		editing_anchor.scale = Vector2(ZOOM_LEVELS[current_zoom_index], ZOOM_LEVELS[current_zoom_index])
	
	if Input.is_action_just_pressed("edit_panel_zoom_in"):
		current_zoom_index -= 1
		if current_zoom_index < 0:
			current_zoom_index = 0
		editing_anchor.scale = Vector2(ZOOM_LEVELS[current_zoom_index], ZOOM_LEVELS[current_zoom_index])
	
	previous_mouse_position = current_mouse_position

func _on_test_button_pressed() -> void:
	print(cutter.polygon)
	print(editable_image.polygon)
	var new_polygon = Geometry2D.intersect_polygons(editable_image.polygon, cutter.polygon)
	print(new_polygon)
	if new_polygon.is_empty():
		return
	
	var newnew_polygon = Geometry2D.clip_polygons(editable_image.polygon, new_polygon[0])
	print(newnew_polygon[0])
	editable_image.polygon = newnew_polygon[0]

func _show_cutter() -> void:
	cutter.visible = !cutter.visible
