class_name DataUtil

## ---
## DATA UTILITY
## A collection of common static methods for loading resource files 
## dynamically at boot time. For use in other scripts.
## ---
## Last edited: July 30th, 2025
## ---
## TODO
## - Implement some utility for async resource loading
## ---

const LEVEL_CHAR := "-" # Character used in print statements to indicate subdirectory access
const HALT_ALL_LOGS := false # Stop printing in console on load...

## RECURSIVELY loads all Resources of type resource_type in path and returns the list
## NOTE: This method is synchronous
static func load_all_resources_in_folder(path: String, resource_type: String, log_loading: bool = true, level: int = 1) -> Array[Resource]:
	var result: Array[Resource] = []
	
	if log_loading:
		log_message(LEVEL_CHAR.repeat(level) + " Loading resources of type {type} from {path}...".format({ "type": resource_type, "path": path }))
	
	## CHECKS
	if not DirAccess.dir_exists_absolute(path):
		if log_loading:
			log_message(LEVEL_CHAR.repeat(level) + " WARNING! Attempting to load from {path}, but it does not exist".format({ "path": path }))
		return []
	
	## FIX
	## - Allows the engine to use editor paths at build runtime
	## NOTE: Builds will only load resources correctly if ProjectSettings/Editor/Export convert_text_resources_to_binary is set to FALSE 
	var file_names: PackedStringArray = ResourceLoader.list_directory(path + "/")
	
	for file_name: String in file_names:
		var file_path = path + file_name
		
		if file_name.ends_with("/"): ## Is a directory
			result.append_array(load_all_resources_in_folder(file_path, resource_type, log_loading, level + 1))
		else:
			if log_loading:
				log_message(LEVEL_CHAR.repeat(level + 1) + " Loading {file_name} ({path})...".format({ "file_name": file_name, "path": file_path }))
			
			var resource: Resource = ResourceLoader.load(file_path, resource_type)
			if resource:
				result.append(resource)
	
	return result

## RECURSIVELY loads all PackedScenes in path and returns the list
## NOTE: This method is synchronous
static func load_all_scenes_in_folder(path: String, log_loading: bool = true, level: int = 1) -> Array[PackedScene]:
	var result: Array[PackedScene] = []
	
	if log_loading:
		log_message(LEVEL_CHAR.repeat(level) + " Loading scenes from {path}...".format({ "path": path }))
	
	## CHECKS
	if not DirAccess.dir_exists_absolute(path):
		if log_loading:
			log_message(LEVEL_CHAR.repeat(level) + " WARNING! Attempting to load from {path}, but it does not exist".format({ "path": path }))
		return []
	
	## FIX
	## - Allows the engine to use editor paths at build runtime
	## NOTE: Builds will only load resources correctly if ProjectSettings/Editor/Export convert_text_resources_to_binary is set to FALSE 
	var file_names: PackedStringArray = ResourceLoader.list_directory(path + "/")
	
	for file_name: String in file_names:
		var file_path = path + file_name
		
		if file_name.ends_with("/"): ## Is a directory
			result.append_array(load_all_scenes_in_folder(file_path, log_loading, level + 1))
		else:
			if log_loading:
				log_message(LEVEL_CHAR.repeat(level + 1) + " Loading {file_name} ({path})...".format({ "file_name": file_name, "path": file_path }))
			
			var scene: PackedScene = load(file_path)
			if scene:
				result.append(scene)
	
	return result

static func log_message(msg: String) -> void:
	if not HALT_ALL_LOGS:
		print(msg)
