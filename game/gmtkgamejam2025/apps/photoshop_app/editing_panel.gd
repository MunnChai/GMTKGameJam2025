class_name EditingPanel
extends Control

## Editing tools
@onready var lasso_button: Button = %LassoButton
@onready var cut_button: Button = %CutButton
@onready var undo_button: Button = %UndoButton
@onready var redo_button: Button = %RedoButton

## Editing nodes
@onready var editing_panel: Control = %EditingPanel
@onready var editing_anchor: Control = %EditingAnchor
@onready var editable_image: MultiPolygon = %EditableImage
@onready var pasted_selection: MultiPolygon = %PastedSelection
@onready var cutter: Polygon2D = %Cutter

@onready var button: Button = $EditingAnchor/Button

## Panel movement/zoom
var previous_mouse_position: Vector2
const ZOOM_LEVELS: Array = [
	0.5,
	1,
	2,
	3,
	4,
]
var current_zoom_index: int = 1

## Copied texture
var copied_polygons: Array[PackedVector2Array]
var copied_texture: Texture2D
var copied_offset: Vector2

## Moving pasted selection
var is_pasted_moveable: bool = false

func _ready() -> void:
	await get_tree().process_frame
	editing_anchor.position = editing_panel.size / 2
	
	button.pressed.connect(func():
		cutter.visible = !cutter.visible)

func _process(delta: float) -> void:
	handle_actions(delta)
	handle_movement(delta)
	handle_zoom(delta)

func handle_actions(delta: float) -> void:
	if Input.is_action_just_pressed("copy"):
		copy_selection()
	
	if Input.is_action_just_pressed("cut"):
		copy_selection()
		delete_selection()
	
	if Input.is_action_just_pressed("paste"):
		paste_selection()



func handle_movement(delta: float) -> void:
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
	
	if Input.is_action_just_pressed("drag_pasted_selection"):
		var local_mouse_pos: Vector2 = (current_mouse_position - editing_anchor.position) / editing_anchor.scale
		
		if pasted_selection.is_pos_in_polygons(local_mouse_pos):
			is_pasted_moveable = true
		else:
			is_pasted_moveable = false
	
	if Input.is_action_pressed("drag_pasted_selection") and is_pasted_moveable and not is_zero_approx(diff.length()):
		pasted_selection.position += diff / editing_anchor.scale
	
	previous_mouse_position = current_mouse_position




func handle_zoom(delta: float) -> void:
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



func copy_selection() -> Array[PackedVector2Array]:
	copied_offset = editable_image.texture_offset
	copied_texture = editable_image.texture
	
	copied_polygons = []
	var editable_polygons = editable_image.get_children()
	for polygon2d: Polygon2D in editable_polygons:
		var new_polygons = Geometry2D.intersect_polygons(polygon2d.polygon, cutter.polygon)
		if new_polygons.is_empty():
			return []
		
		copied_polygons.append_array(new_polygons)
	
	return copied_polygons


func delete_selection() -> void:
	editable_image.delete_from_polygon(cutter.polygon)

func paste_selection() -> void:
	pasted_selection.clear()
	pasted_selection.add_polygons(copied_polygons)
	pasted_selection.set_texture(copied_texture)
	pasted_selection.set_texture_offset(copied_offset)
