class_name EditingPanel
extends Control

## Editing nodes
@onready var editing_panel: Control = %EditingPanel
@onready var editing_anchor: Control = %EditingAnchor
@onready var canvas_border: Polygon2D = %CanvasBorder
@onready var canvas_background: Sprite2D = %CanvasBackground
@onready var editable_image: MultiPolygon = %EditableImage
@onready var pasted_selection: MultiPolygon = %PastedSelection
@onready var lasso_controller: Node2D = %LassoController
@onready var dotted_line: DottedLine = %DottedLine

@export var test_texture: Texture2D

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
var is_paste_confirmable: bool = false

var true_image: Image
var canvas_size: Vector2


func _ready() -> void:
	await get_tree().process_frame
	editing_anchor.position = editing_panel.size / 2
	
	true_image = editable_image.texture.get_image()
	
	set_original_texture(test_texture)

func _process(delta: float) -> void:
	handle_actions(delta)
	handle_movement(delta)
	handle_zoom(delta)
	
	if is_pasted_moveable:
		lasso_controller.disable()
	else:
		lasso_controller.enable()

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
			if is_paste_confirmable:
				paste_selection_to_image()
			
			is_pasted_moveable = false
	
	if Input.is_action_pressed("drag_pasted_selection") and is_pasted_moveable and not is_zero_approx(diff.length()):
		pasted_selection.position += diff / editing_anchor.scale
		lasso_controller.position = pasted_selection.position
	
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



func set_original_texture(texture: Texture2D) -> void:
	true_image = texture.get_image()
	
	canvas_background.region_rect.size = texture.get_size()
	print(texture.get_size())
	var border_polygons: PackedVector2Array = []
	border_polygons.append(Vector2(-texture.get_size().x / 2, -texture.get_size().y / 2))
	border_polygons.append(Vector2(texture.get_size().x / 2, -texture.get_size().y / 2))
	border_polygons.append(Vector2(texture.get_size().x / 2, texture.get_size().y / 2))
	border_polygons.append(Vector2(-texture.get_size().x / 2, texture.get_size().y / 2))
	
	
	editable_image.clear_polygons()
	editable_image.set_texture(texture)
	editable_image.add_polygon(border_polygons)
	
	border_polygons.append(Vector2(-texture.get_size().x / 2, -texture.get_size().y / 2))
	border_polygons.append(Vector2(-texture.get_size().x, -texture.get_size().y))
	border_polygons.append(Vector2(-texture.get_size().x, texture.get_size().y))
	border_polygons.append(Vector2(texture.get_size().x, texture.get_size().y))
	border_polygons.append(Vector2(texture.get_size().x, -texture.get_size().y))
	border_polygons.append(Vector2(-texture.get_size().x, -texture.get_size().y))
	canvas_border.polygon = border_polygons
	
	reset_paste_selection()




func copy_selection() -> Array[PackedVector2Array]:
	copied_offset = editable_image.texture_offset
	copied_texture = editable_image.texture
	
	copied_polygons = []
	var editable_polygons = editable_image.get_children()
	for polygon2d: Polygon2D in editable_polygons:
		var translated_lasso_points = dotted_line.get_points()
		for i in translated_lasso_points.size():
			translated_lasso_points[i] += lasso_controller.position
		var new_polygons = Geometry2D.intersect_polygons(polygon2d.polygon, translated_lasso_points)
		if new_polygons.is_empty():
			continue
		
		copied_polygons.append_array(new_polygons)
	
	return copied_polygons

func delete_selection() -> void:
	var translated_lasso_points = dotted_line.get_points()
	for i in translated_lasso_points.size():
		translated_lasso_points[i] += lasso_controller.position
	editable_image.delete_from_polygon(translated_lasso_points)

func paste_selection() -> void:
	if copied_polygons.is_empty():
		return
	pasted_selection.clear()
	pasted_selection.position = Vector2.ZERO
	pasted_selection.add_polygons(copied_polygons)
	pasted_selection.set_texture(copied_texture)
	pasted_selection.set_texture_offset(copied_offset)
	
	is_paste_confirmable = true
	#print("Confirmable!")

func reset_paste_selection() -> void:
	pasted_selection.clear()
	pasted_selection.position = Vector2.ZERO
	copied_polygons.clear()
	copied_texture = null
	copied_offset = Vector2.ZERO
	is_paste_confirmable = false
	#print("No longer confirmable!")

func paste_selection_to_image() -> void:
	var image: Image = true_image.duplicate()
	var pasted_selection_image: Image = pasted_selection.texture.get_image()
	for x: int in pasted_selection_image.get_size().x:
		for y: int in pasted_selection_image.get_size().y:
			var coord := Vector2i(x, y)
			var translated_coord: Vector2i = coord + Vector2i(pasted_selection.position)
			
			if not pasted_selection.is_pos_in_polygons(translated_coord - pasted_selection_image.get_size() / 2):
				continue
			if translated_coord.x < 0 or translated_coord.x >= image.get_size().x:
				continue
			if translated_coord.y < 0 or translated_coord.y >= image.get_size().y:
				continue
			
			var color: Color = pasted_selection_image.get_pixelv(coord)
			if is_zero_approx(color.a):
				continue
			image.set_pixelv(translated_coord, color)
	
	# Merged pasted polygon into editable image polygons
	# WARNING: ASSUMES PASTED SELECTION ONLY HAS ONE POLYGON... should be true without figure 8 shapes
	for polygon2d: Polygon2D in pasted_selection.get_children():
		var pasted_polygon_translated: PackedVector2Array = polygon2d.polygon.duplicate()
		for i in pasted_polygon_translated.size():
			pasted_polygon_translated[i] += pasted_selection.position
		
		editable_image.merge_polygon(pasted_polygon_translated)
	
	#editable_image.delete_from_polygon(canvas_border.polygon)
	
	var image_texture := ImageTexture.create_from_image(image)
	true_image = image
	editable_image.set_texture(image_texture)
	
	reset_paste_selection()
