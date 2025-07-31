class_name MultiPolygon
extends Node2D

@export var texture: Texture2D
var texture_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if not is_instance_valid(texture):
		return
	set_texture(texture)
	set_texture_offset(texture.get_size() / 2)



func add_polygon(polygon: PackedVector2Array) -> void:
	var new_polygon := Polygon2D.new()
	new_polygon.polygon = polygon
	new_polygon.texture = texture
	new_polygon.texture_offset = texture_offset
	add_child(new_polygon)

func add_polygons(polygons: Array[PackedVector2Array]) -> void:
	for polygon: PackedVector2Array in polygons:
		add_polygon(polygon)

func merge_polygon(polygon: PackedVector2Array) -> void:
	for polygon2d: Polygon2D in get_children():
		var intersect = Geometry2D.intersect_polygons(polygon2d.polygon, polygon)
		if intersect.is_empty():
			continue
		
		for intersected_polygon: PackedVector2Array in intersect:
			var merged = Geometry2D.merge_polygons(polygon2d.polygon, intersected_polygon)
			print("Merged: ", merged)
			polygon2d.polygon = merged[0]

func set_polygons(polygons: Array[PackedVector2Array]) -> void:
	for child in get_children():
		child.queue_free()
	add_polygons(polygons)

func clear_polygons() -> void:
	for child in get_children():
		child.queue_free()

func clip_polygon(clip_polygon: PackedVector2Array) -> void:
	for polygon2d: Polygon2D in get_children():
		var intersecting_polygons = Geometry2D.intersect_polygons(polygon2d.polygon, clip_polygon)
		if intersecting_polygons.is_empty():
			print("NO INTERSECTIONS")
			continue
		
		for intersecting_polygon in intersecting_polygons:
			print("Intersecting: ", intersecting_polygon)
			var clipped_polygons = Geometry2D.clip_polygons(polygon2d.polygon, intersecting_polygon)
			print("Clipped: ", clipped_polygons)
			if clipped_polygons.is_empty():
				print("NO CLIPS")
				break
			
			if clipped_polygons.size() == 1:
				polygon2d.polygon = clipped_polygons[0]
				print("YA")
				break

func set_texture(texture: Texture2D) -> void:
	self.texture = texture
	for polygon: Polygon2D in get_children():
		polygon.texture = texture

func set_texture_offset(offset: Vector2) -> void:
	texture_offset = offset
	for polygon: Polygon2D in get_children():
		polygon.texture_offset = offset

func clear() -> void:
	texture = null
	for child in get_children():
		child.queue_free()


func delete_from_polygon(cut_polygon: PackedVector2Array) -> void:
	for polygon2d: Polygon2D in get_children():
		
		var original_polygon: PackedVector2Array = polygon2d.polygon
		var polygon_edited: bool = false
		
		var intersecting_polygons = Geometry2D.intersect_polygons(polygon2d.polygon, cut_polygon)
		if intersecting_polygons.is_empty():
			continue
		
		for intersecting_polygon in intersecting_polygons:
			#print("Intersecting: ", intersecting_polygon)
			var clipped_polygons = Geometry2D.clip_polygons(polygon2d.polygon, intersecting_polygon)
			#print("Clipped: ", clipped_polygons)
			if clipped_polygons.is_empty():
				break
			
			if clipped_polygons.size() == 1:
				polygon2d.polygon = clipped_polygons[0]
				break
			
			var inner_polygons: Array[PackedVector2Array] = []
			var outer_polygons: Array[PackedVector2Array] = []
			
			for clipped_polygon: PackedVector2Array in clipped_polygons:
				if Geometry2D.is_polygon_clockwise(clipped_polygon):
					inner_polygons.append(clipped_polygon)
				else:
					outer_polygons.append(clipped_polygon)
			
			if inner_polygons.is_empty():
				for outer_polygon: PackedVector2Array in outer_polygons:
					if not polygon_edited:
						var original_polygon_copy: PackedVector2Array = original_polygon.duplicate()
						var outer_polygon_copy: PackedVector2Array = outer_polygon.duplicate()
						
						outer_polygon_copy.sort()
						original_polygon_copy.sort()
						if outer_polygon_copy != original_polygon_copy:
							polygon2d.polygon = outer_polygon
							polygon_edited = true
							#print("Changed original polygon: ", polygon2d.polygon)
					else:
						var original_polygon_copy: PackedVector2Array = original_polygon.duplicate()
						var outer_polygon_copy: PackedVector2Array = outer_polygon.duplicate()
						
						outer_polygon_copy.sort()
						original_polygon_copy.sort()
						if outer_polygon != original_polygon_copy:
							call_deferred("add_polygon", outer_polygon)
							#print("Added new polygon: ", outer_polygon)
				# Dont do anything with inner polygons
				continue
			
			var new_polygon: PackedVector2Array = []
			
			var original_polygon_copy: PackedVector2Array = original_polygon.duplicate()
			# O1, O2, ..., On, O1
			original_polygon_copy.reverse()
			new_polygon.append_array(original_polygon_copy)
			new_polygon.append(original_polygon_copy[0])
			
			for inner_polygon: PackedVector2Array in inner_polygons:
				var inner_polygon_copy: PackedVector2Array = inner_polygon.duplicate()
				# I1, I2, ..., Im, I1
				inner_polygon_copy.reverse()
				new_polygon.append_array(inner_polygon_copy)
				new_polygon.append(inner_polygon_copy[0])
				new_polygon.append(original_polygon_copy[0])
			
			polygon2d.polygon = new_polygon
			polygon_edited = true
			#print("Created new polygon with hole: ", new_polygon)


func is_pos_in_polygons(pos: Vector2) -> bool:
	for polygon2d: Polygon2D in get_children():
		var translated_selection_polygon: PackedVector2Array = polygon2d.polygon
		for i in translated_selection_polygon.size():
			translated_selection_polygon[i] += self.position
		
		if Geometry2D.is_point_in_polygon(pos, translated_selection_polygon):
			return true
	
	return false
