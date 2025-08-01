class_name SortUtil

## ---
## SORT UTILITY
## Various static generators for object comparison functions
## that are useful for sorting lists
## ---
## Last edited: July 30th, 2025
## ---

## Generates a callable that sorts Objects with a global_position property
## based on distance squared to a given global position
## NOTE: Requires objects being sorted to have a global_position property
static func generate_sort_distance_ascending_function(global_position: Vector2) -> Callable:
	var sort_function := func(a: Object, b: Object):
		if global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position):
			return true
		return false
	return sort_function
