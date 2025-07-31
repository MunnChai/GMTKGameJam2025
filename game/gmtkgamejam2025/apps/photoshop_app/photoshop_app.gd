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
var copied_vertices: PackedVector2Array
var copied_texture: Texture2D
var copied_offset: Vector2

## Moving pasted selection
var is_pasted_moveable: bool = false

func _ready() -> void:
	await get_tree().process_frame
	editable_image.texture_offset = editable_image.texture.get_size() / 2
	editing_anchor.position = editing_panel.size / 2

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
		var local_mouse_pos: Vector2 = current_mouse_position - editing_anchor.position
		var translated_selection_polygon: PackedVector2Array = pasted_selection.polygon
		for i in translated_selection_polygon.size():
			translated_selection_polygon[i] += pasted_selection.position
		if Geometry2D.is_point_in_polygon(local_mouse_pos, translated_selection_polygon):
			is_pasted_moveable = true
			print("Yes")
		else:
			is_pasted_moveable = false
			## TODO: MERGE THE SELECTION WITH THE BASE IMAGE
	
	if Input.is_action_pressed("drag_pasted_selection") and is_pasted_moveable and not is_zero_approx(diff.length()):
		#for i in pasted_selection.polygon.size():
			#pasted_selection.polygon[i] += diff
		pasted_selection.position += diff
	
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

func copy_selection() -> PackedVector2Array:
	var new_polygon = Geometry2D.intersect_polygons(editable_image.polygon, cutter.polygon)
	if new_polygon.is_empty():
		return []
	
	copied_offset = editable_image.texture_offset
	copied_vertices = new_polygon[0]
	copied_texture = editable_image.texture
	
	return new_polygon[0]

func delete_selection() -> void:
	var new_polygon = Geometry2D.intersect_polygons(editable_image.polygon, cutter.polygon)
	if new_polygon.is_empty():
		return
	
	var newnew_polygon = Geometry2D.clip_polygons(editable_image.polygon, new_polygon[0])
	if newnew_polygon.is_empty():
		return
	
	editable_image.polygon = newnew_polygon[0]

func paste_selection() -> void:
	pasted_selection.texture_offset = copied_offset
	pasted_selection.polygon = copied_vertices
	pasted_selection.texture = copied_texture
