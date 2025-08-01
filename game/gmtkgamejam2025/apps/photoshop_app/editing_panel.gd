class_name EditingPanel
extends Control

## Editing nodes
@onready var editing_node: Control = %EditingNode
@onready var editing_anchor: Control = %EditingAnchor
@onready var canvas_background: Sprite2D = %CanvasBackground
@onready var editable_image: SpriteBuffer = %EditableImage
@onready var pasted_selection: SpriteBuffer = %PastedSelection
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

var original_texture: Texture2D

## Copied texture
var copied_buffer: Array[PackedColorArray]
var copied_texture: Texture2D
var copied_lasso: PackedVector2Array
var copied_lasso_pos: Vector2

## Moving pasted selection
var is_pasted_moveable: bool = false
var is_paste_confirmable: bool = false

var true_image: Image
var canvas_size: Vector2

var is_hovered: bool = false

func _ready() -> void:
	await get_tree().process_frame
	editing_anchor.position = editing_node.size / 2
	
	editing_node.mouse_entered.connect(func():
		is_hovered = true)
	editing_node.mouse_exited.connect(func():
		is_hovered = false)
	
	#true_image = editable_image.texture.get_image()
	
	#set_original_texture(test_texture)

func _process(delta: float) -> void:
	if not is_hovered:
		return
	
	handle_actions(delta)
	handle_movement(delta)
	handle_zoom(delta)

func handle_actions(delta: float) -> void:
	if Input.is_action_just_pressed("copy"):
		copy_selection()
		dotted_line.clear()
	
	if Input.is_action_just_pressed("cut"):
		copy_selection()
		delete_selection()
		dotted_line.clear()
	
	if Input.is_action_just_pressed("paste"):
		paste_selection()

func handle_movement(delta: float) -> void:
	var current_mouse_position: Vector2 = editing_node.get_local_mouse_position()
	var diff: Vector2 = current_mouse_position - previous_mouse_position
	
	if Input.is_action_pressed("edit_panel_move") and not is_zero_approx(diff.length()):
		editing_anchor.position += diff
		
		if editing_anchor.position.x < 0:
			editing_anchor.position.x = 0
		elif editing_anchor.position.x > editing_node.size.x:
			editing_anchor.position.x = editing_node.size.x
		
		if editing_anchor.position.y < 0:
			editing_anchor.position.y = 0
		elif editing_anchor.position.y > editing_node.size.y:
			editing_anchor.position.y = editing_node.size.y
	
	if Input.is_action_just_pressed("drag_pasted_selection"):
		var local_mouse_pos: Vector2 = (current_mouse_position - editing_anchor.position) / editing_anchor.scale
		
		if pasted_selection.is_pos_in_pixel_buffer(local_mouse_pos):
			is_pasted_moveable = true
		else:
			if is_paste_confirmable:
				paste_selection_to_image()
			
			is_pasted_moveable = false
	
	if Input.is_action_pressed("drag_pasted_selection") and is_pasted_moveable and not is_zero_approx(diff.length()):
		pasted_selection.position += diff / editing_anchor.scale
		lasso_controller.position = pasted_selection.position + copied_lasso_pos
	
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

func reset_texture() -> void:
	set_original_texture(original_texture)

func set_original_texture(texture: Texture2D) -> void:
	original_texture = texture
	true_image = texture.get_image()
	
	canvas_background.region_rect.size = texture.get_size()
	
	editable_image.set_pixel_buffer_from_texture(texture)

func copy_selection() -> void:
	var translated_polygon: PackedVector2Array = dotted_line.get_points()
	for i in translated_polygon.size():
		translated_polygon[i] += lasso_controller.position
	
	copied_buffer = editable_image.get_pixel_buffer_in_polygon(translated_polygon)
	copied_lasso = dotted_line.get_points()
	copied_lasso_pos = lasso_controller.position

func delete_selection() -> void:
	var translated_polygon: PackedVector2Array = dotted_line.get_points()
	for i in translated_polygon.size():
		translated_polygon[i] += lasso_controller.position
	
	editable_image.erase_pixels_in_polygon(translated_polygon)

func paste_selection() -> void:
	if copied_buffer.is_empty():
		return
	pasted_selection.position = Vector2.ZERO
	lasso_controller.position = Vector2.ZERO
	pasted_selection.set_pixel_buffer(copied_buffer)
	
	is_paste_confirmable = true
	
	dotted_line.set_points(copied_lasso)
	lasso_controller.position = copied_lasso_pos
	lasso_controller.disable()

func paste_selection_to_image() -> void:
	editable_image.impose_image(pasted_selection, pasted_selection.position)
	
	is_paste_confirmable = false
	
	pasted_selection.clear()
	dotted_line.clear()
	lasso_controller.enable()
