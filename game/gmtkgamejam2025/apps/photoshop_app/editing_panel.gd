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

@onready var copy_button: TextureButton = %CopyButton
@onready var cut_button: TextureButton = %CutButton
@onready var paste_button: TextureButton = %PasteButton
@onready var redo_button: TextureButton = %RedoButton
@onready var undo_button: TextureButton = %UndoButton

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
var original_file: File

## Copied texture

## Moving pasted selection
var is_pasted_moveable: bool = false
var is_paste_confirmable: bool = false
var is_pasted_locked: bool = false

var true_image: Image
var canvas_size: Vector2

var is_hovered: bool = false

var is_waiting_for_thread: bool = false


var undo_redo: UndoRedo

func _ready() -> void:
	await get_tree().process_frame
	#editing_anchor.position = editing_node.size / 2
	editing_anchor.position = Vector2(757.0, 440.0) / 2
	
	editing_node.mouse_entered.connect(func():
		is_hovered = true)
	editing_node.mouse_exited.connect(func():
		is_hovered = false)
	
	editable_image.got_buffers.connect(_set_copied_buffers)
	editable_image.finished_deletion.connect(_on_deletion_finished)
	editable_image.finished_pasting.connect(_on_paste_confirm_finished)
	editable_image.finished_setting_buffers.connect(_on_buffer_set_finished)
	
	copy_button.pressed.connect(_on_copy_pressed)
	cut_button.pressed.connect(_on_cut_pressed)
	paste_button.pressed.connect(_on_paste_pressed)
	redo_button.pressed.connect(_on_redo_pressed)
	undo_button.pressed.connect(_on_undo_pressed)
	
	undo_redo = UndoRedo.new()

func _on_copy_pressed() -> void:
	try_copy_action()

func _on_cut_pressed() -> void:
	try_cut_action()

func _on_paste_pressed() -> void:
	try_paste_action()

func _on_redo_pressed() -> void:
	try_redo_action()

func _on_undo_pressed() -> void:
	try_undo_action()

func _process(delta: float) -> void:
	if not is_hovered:
		return
	
	handle_actions(delta)
	handle_movement(delta)
	handle_zoom(delta)
	handle_boundaries()

func handle_actions(delta: float) -> void:
	if is_waiting_for_thread:
		return
	
	if Input.is_action_just_pressed("copy"):
		try_copy_action()
	
	if Input.is_action_just_pressed("cut"):
		try_cut_action()
	
	if Input.is_action_just_pressed("paste"):
		try_paste_action()
	
	if Input.is_action_just_pressed("delete"):
		try_delete_action()
	
	if Input.is_action_just_pressed("undo"):
		try_undo_action()
	
	if Input.is_action_just_pressed("redo"):
		try_redo_action()

func handle_movement(delta: float) -> void:
	var current_mouse_position: Vector2 = editing_node.get_local_mouse_position()
	var diff: Vector2 = current_mouse_position - previous_mouse_position
	
	if Input.is_action_pressed("edit_panel_move") and not is_zero_approx(diff.length()):
		editing_anchor.position += diff
	
	if Input.is_action_just_pressed("drag_pasted_selection"):
		var local_mouse_pos: Vector2 = (current_mouse_position - editing_anchor.position) / editing_anchor.scale
		
		if pasted_selection.is_pos_in_pixel_buffer(local_mouse_pos):
			is_pasted_moveable = true
		else:
			if is_paste_confirmable and not is_waiting_for_thread:
				paste_selection_to_image()
			
			is_pasted_moveable = false
	
	if Input.is_action_pressed("drag_pasted_selection") and is_pasted_moveable and not is_pasted_locked and not is_zero_approx(diff.length()):
		pasted_selection.position += diff / editing_anchor.scale
		lasso_controller.position = pasted_selection.position + PhotoshopManager.copied_lasso_pos
	
	previous_mouse_position = current_mouse_position

func handle_boundaries() -> void:
	var texture_size: Vector2 = original_file.texture.get_size()
	var left = 0 - (texture_size.x / 3) * ZOOM_LEVELS[current_zoom_index]
	var right = editing_node.size.x + (texture_size.x / 3) * ZOOM_LEVELS[current_zoom_index]
	var top = 0 - (texture_size.y / 3) * ZOOM_LEVELS[current_zoom_index]
	var bottom = editing_node.size.y + (texture_size.y / 3) * ZOOM_LEVELS[current_zoom_index]
	
	if editing_anchor.position.x < left:
		editing_anchor.position.x = left
	elif editing_anchor.position.x > right:
		editing_anchor.position.x = right
	
	if editing_anchor.position.y < top:
		editing_anchor.position.y = top
	elif editing_anchor.position.y > bottom:
		editing_anchor.position.y = bottom

func handle_zoom(delta: float) -> void:
	if Input.is_action_just_pressed("edit_panel_zoom_out"):
		var current_mouse_position = editing_node.get_local_mouse_position()
		var old_mouse_pos: Vector2 = (current_mouse_position - editing_anchor.position) / editing_anchor.scale
		current_zoom_index += 1
		if current_zoom_index >= ZOOM_LEVELS.size():
			current_zoom_index = ZOOM_LEVELS.size() - 1
		editing_anchor.scale = Vector2(ZOOM_LEVELS[current_zoom_index], ZOOM_LEVELS[current_zoom_index])
		var new_mouse_pos: Vector2 = (current_mouse_position - editing_anchor.position) / editing_anchor.scale
		editing_anchor.position += (new_mouse_pos - old_mouse_pos) * editing_anchor.scale
	
	if Input.is_action_just_pressed("edit_panel_zoom_in"):
		var current_mouse_position = editing_node.get_local_mouse_position()
		var old_mouse_pos: Vector2 = (current_mouse_position - editing_anchor.position) / editing_anchor.scale
		current_zoom_index -= 1
		if current_zoom_index < 0:
			current_zoom_index = 0
		editing_anchor.scale = Vector2(ZOOM_LEVELS[current_zoom_index], ZOOM_LEVELS[current_zoom_index])
		var new_mouse_pos: Vector2 = (current_mouse_position - editing_anchor.position) / editing_anchor.scale
		editing_anchor.position += (new_mouse_pos - old_mouse_pos) * editing_anchor.scale

func reset_texture() -> void:
	init_canvas(original_file)

func init_canvas(file: File) -> void:
	original_file = file
	
	canvas_background.region_rect.size = file.texture.get_size()
	editable_image.set_buffers_from_file(file)
	is_waiting_for_thread = true

func set_file(file: File) -> void:
	init_canvas(file)




func try_copy_action() -> void:
	copy_selection()
	SoundManager.play_global_oneshot(&"cut")
	dotted_line.clear()

func try_cut_action() -> void:
	cut_selection()
	SoundManager.play_global_oneshot(&"cut")

func try_paste_action() -> void:
	if is_paste_confirmable:
		paste_selection_to_image()
		await editable_image.finished_pasting
	paste_selection()
	SoundManager.play_global_oneshot(&"paste")

func try_delete_action() -> void:
	delete_selection()

func try_undo_action() -> void:
	print_undo_redo()
	if undo_redo.has_undo():
		undo_redo.undo()

func try_redo_action() -> void:
	print_undo_redo()
	if undo_redo.has_redo():
		undo_redo.redo()

func print_undo_redo() -> void:
	print("Undo Redo History: ")
	for i in undo_redo.get_history_count():
		print(i, ". ", undo_redo.get_action_name(i))


func copy_selection() -> void:
	var translated_polygon: PackedVector2Array = dotted_line.get_points()
	for i in translated_polygon.size():
		translated_polygon[i] += lasso_controller.position
	
	editable_image.get_buffers_in_polygon(translated_polygon)
	is_waiting_for_thread = true
	
	PhotoshopManager.copied_lasso = dotted_line.get_points()
	PhotoshopManager.copied_lasso_pos = lasso_controller.position
	PhotoshopManager.copied_paste_pos = Vector2(0, 0)

func cut_selection() -> void:
	var translated_polygon: PackedVector2Array = dotted_line.get_points()
	for i in translated_polygon.size():
		translated_polygon[i] += lasso_controller.position
	
	editable_image.get_buffers_in_polygon_and_delete(translated_polygon)
	is_waiting_for_thread = true
	
	PhotoshopManager.copied_lasso = dotted_line.get_points()
	PhotoshopManager.copied_lasso_pos = lasso_controller.position
	PhotoshopManager.copied_paste_pos = Vector2(0, 0)

func delete_selection(polygon: PackedVector2Array = dotted_line.get_points(), untranslate: bool = false) -> void:
	var translated_polygon: PackedVector2Array = polygon
	if untranslate:
		for i in translated_polygon.size():
			translated_polygon[i] -= lasso_controller.position
	else:
		for i in translated_polygon.size():
			translated_polygon[i] += lasso_controller.position
	
	editable_image.delete_buffers_in_polygon(translated_polygon)
	is_waiting_for_thread = true

func paste_selection() -> void:
	if PhotoshopManager.copied_buffer.is_empty():
		return
	
	undo_redo.create_action("Paste Selection")
	undo_redo.add_do_method(_set_pasted_selection.bind(PhotoshopManager.copied_paste_pos, PhotoshopManager.copied_lasso_pos, PhotoshopManager.copied_buffer, PhotoshopManager.copied_trait_buffer, PhotoshopManager.copied_lasso))
	undo_redo.add_undo_method(_unset_pasted_selection)
	undo_redo.commit_action(true)

func _set_pasted_selection(paste_pos: Vector2, lasso_pos: Vector2, pixel_buffer: Array[PackedColorArray], trait_buffer: Array[PackedColorArray], lasso_points: PackedVector2Array):
	pasted_selection.position = paste_pos
	lasso_controller.position = Vector2.ZERO
	pasted_selection.set_pixel_buffer(pixel_buffer)
	pasted_selection.set_trait_buffer(trait_buffer)
	
	is_paste_confirmable = true
	is_pasted_locked = false
	
	dotted_line.set_points(lasso_points)
	lasso_controller.position = lasso_pos + paste_pos
	lasso_controller.disable()
	PhotoshopManager.copied_paste_pos += Vector2(5, 5)

func _unset_pasted_selection() -> void:
	pasted_selection.position = Vector2.ZERO
	lasso_controller.position = Vector2.ZERO
	pasted_selection.clear()
	
	is_paste_confirmable = false
	is_pasted_locked = true
	
	dotted_line.clear()
	lasso_controller.position = Vector2.ZERO
	lasso_controller.enable()
	PhotoshopManager.copied_paste_pos -= Vector2(5, 5)

func paste_selection_to_image() -> void:
	editable_image.impose_image(pasted_selection, pasted_selection.position)
	is_waiting_for_thread = true
	is_pasted_moveable = false
	is_pasted_locked = true
	dotted_line.clear()

func set_pixel_and_trait_buffers(pixel_buffer: Array[PackedColorArray], trait_buffer: Array[PackedColorArray]) -> void:
	editable_image.set_pixel_buffer(pixel_buffer)
	editable_image.set_trait_buffer(trait_buffer)



#region Thread Return

func _on_paste_confirm_finished(new_pixel_buffer: Array[PackedColorArray], new_trait_buffer: Array[PackedColorArray], previous_pixel_buffer: Array[PackedColorArray], previous_trait_buffer: Array[PackedColorArray]) -> void:
	pasted_selection.clear()
	lasso_controller.enable()
	is_paste_confirmable = false
	is_waiting_for_thread = false
	
	undo_redo.undo()
	undo_redo.create_action("Paste Selection")
	undo_redo.add_do_method(set_pixel_and_trait_buffers.bind(new_pixel_buffer, new_trait_buffer))
	undo_redo.add_undo_method(set_pixel_and_trait_buffers.bind(previous_pixel_buffer, previous_trait_buffer))
	undo_redo.commit_action(false)

func _on_deletion_finished(new_pixel_buffer: Array[PackedColorArray], new_trait_buffer: Array[PackedColorArray], previous_pixel_buffer: Array[PackedColorArray], previous_trait_buffer: Array[PackedColorArray]) -> void:
	undo_redo.create_action("Delete Selection")
	undo_redo.add_do_method(set_pixel_and_trait_buffers.bind(new_pixel_buffer, new_trait_buffer))
	undo_redo.add_undo_method(set_pixel_and_trait_buffers.bind(previous_pixel_buffer, previous_trait_buffer))
	undo_redo.commit_action(false)
	
	dotted_line.clear()
	is_waiting_for_thread = false

func _set_copied_buffers(buffers: Dictionary, set_clipboard: bool) -> void:
	if set_clipboard:
		PhotoshopManager.copied_buffer = buffers["pixel"]
		PhotoshopManager.copied_trait_buffer = buffers["trait"]
	is_waiting_for_thread = false

func _on_buffer_set_finished() -> void:
	is_waiting_for_thread = false


func get_current_file() -> File:
	var file: File = editable_image.convert_to_file()
	file.node_name = original_file.node_name
	return file

#endregion
