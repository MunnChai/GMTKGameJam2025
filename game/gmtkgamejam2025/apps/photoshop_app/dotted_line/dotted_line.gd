class_name DottedLine
extends Node2D

## ---
## DOTTED LINE
## Add and remove points
## Automatically manages endpoint visibility and positions

## ---

## USAGE
## - Call clear to reset the dotted line
## - Use add_point (local) or add_global_point to add points throughout the line
## - When finished (whether fully closed or not)... call close in order to finalize visual

@onready var line: Line2D = %Line
@onready var startpoint: Node2D = %Startpoint
@onready var endpoint: Node2D = %Endpoint

#region POINT MANIPULATION

## Clears points
func clear() -> void:
	line.clear_points()
	line.closed = false

## Adds a local position as a point at the End of the Line
func add_point(local_pos: Vector2) -> void:
	line.add_point(local_pos)
## Adds a global position as a point at the End of the Line
func add_global_point(global_pos: Vector2) -> void:
	line.add_point(to_local(global_pos))

## Removes the point at the given index
func remove(index: int) -> void:
	line.remove_point(index)
## Removes the point at the last index
func remove_last() -> void:
	if line.points.size() > 0: # Do we have at least one point
		line.remove_point(-1)

## Get the point at the given index
func get_point(index: int) -> Vector2:
	return line.points[index]

## Returns true if no points, false if at least one
func is_empty() -> bool:
	return line.points.is_empty()
## Returns true if at least 2 points, false otherwise
func has_line() -> bool:
	return line.points.size() >= 2
## Returns true if the line is CLOSED, false otherwise
func is_closed() -> bool:
	return line.closed

## CALL THIS WHEN THE DOTTED LINE SHOULD BE CLOSED
## Links up the startpoint and the endpoint using the line's closed property
## add_end_point_at_start puts another point at the end of the array while at the position of the start...
## preventing glitchy closed lines...
func close(add_end_point_at_start: bool = true) -> void:
	line.closed = true
	
	if is_empty():
		return
	
	add_point(get_point(0))

#endregion

func _ready() -> void:
	# clear()
	pass

func _process(delta: float) -> void:
	_update_endpoints()

## Update positions and visibility of endpoints based on number/positions of points and if we are closed...
func _update_endpoints() -> void:
	var count: int = line.points.size()
	if count == 0:
		## No points
		startpoint.hide()
		endpoint.hide()
	else:
		## At least one point
		startpoint.show()
		endpoint.show()
		startpoint.position = line.position + line.points[0] # Start point at first
		endpoint.position = line.position + line.points[-1] # End point at last
		
		if is_closed(): ## Hide one of the points if we are closed...
			startpoint.hide()
		else:
			startpoint.show()
