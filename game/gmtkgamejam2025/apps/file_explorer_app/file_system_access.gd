class_name FileSystemAccess
extends Node

# Signal to notify the UI that the directory has changed
signal directory_changed(new_directory_contents)

## ---
## FILE SYSTEM ACCESS
## Access the file system, track state of where you are in the fs
## ---

var current_directory: Folder
var directory_history: Array[Folder]

func _ready() -> void:
	current_directory = FileSystem.root
	directory_history.append(FileSystem.root)
	
	# Emit the initial state
	emit_signal("directory_changed", get_current_contents())

func change_directory(folder_name: String) -> bool:
	var target_folder = current_directory.get_child(folder_name)
	if target_folder and target_folder.is_folder():
		current_directory = target_folder
		directory_history.append(current_directory)
		emit_signal("directory_changed", get_current_contents())
		return true
	return false

func go_back() -> bool:
	if directory_history.size() > 1:
		directory_history.pop_back()
		current_directory = directory_history.back()
		emit_signal("directory_changed", get_current_contents())
		return true
	return false

func get_current_contents() -> Array[FileNode]:
	return current_directory.children

func open_file(file_node: FileNode):
	if file_node.is_folder():
		change_directory(file_node.node_name)
	else:
		# This is where you would add logic to open a file.
		# For now, we'll just print it.
		print("Attempting to open file: ", file_node.node_name)
		FileSystem.open_file(file_node)
		# If you re-add the photoshop app, you would connect its 'open_file' method here.
