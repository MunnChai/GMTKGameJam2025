class_name FileSystem
extends Node

var root: Folder
var current_directory: Folder
var directory_history: Array[Folder]

# Signal to notify the UI that the directory has changed
signal directory_changed(new_directory_contents)

func _ready():
	# Create the root directory
	root = Folder.new("root")
	current_directory = root
	directory_history.append(root)

	# --- Create a sample file structure ---
	# NOTE: You must have these images in the specified path for them to load.
	var cat_image = load("res://game/assets/images/cat.png") 
	var dog_image = load("res://game/assets/images/dog.png")

	var file1 = File.new("cat_photo.png", "image", cat_image)
	var file2 = File.new("dog_picture.jpg", "image", dog_image)
	var file3 = File.new("important_document.txt", "text")

	# Create a "commissions" folder
	var commissions_folder = Folder.new("Commissions")
	root.add_child(commissions_folder)

	# Create a client folder
	var client1_folder = Folder.new("Client_A")
	commissions_folder.add_child(client1_folder)
	client1_folder.add_child(file1)

	# Create another client folder
	var client2_folder = Folder.new("Client_B")
	commissions_folder.add_child(client2_folder)
	client2_folder.add_child(file2)
	
	root.add_child(file3)
	
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
		# If you re-add the photoshop app, you would connect its 'open_file' method here.
