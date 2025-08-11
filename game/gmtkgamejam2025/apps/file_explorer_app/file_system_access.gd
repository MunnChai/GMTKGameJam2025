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
var upload_mode: bool = false

signal upload_done(file_node: FileNode)

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
	SoundManager.play_global_oneshot(&"ui_basic_click")

	if directory_history.size() > 1:
		directory_history.pop_back()
		current_directory = directory_history.back()
		emit_signal("directory_changed", get_current_contents())
		return true
	return false

func get_current_contents() -> Array[FileNode]:
	return current_directory.children

## Interact with a file node
func open_file(file_node: FileNode):
	SoundManager.play_global_oneshot(&"ui_basic_click")
	
	if file_node.is_folder(): ## Node is folder, navigate and terminate
		change_directory(file_node.node_name)
	else: ## Node is file, try and open...
		print("Attempting to open file: ", file_node.node_name)
		
		if upload_mode: ## We are doing uploading, so emit the upload
			upload_done.emit(file_node)
			return
		
		## We are not uploading, so open the file as expected
		FileSystem.open_file(file_node)
