class_name FileSystemGlobal
extends Node

signal changed
signal file_added
signal folder_added
signal file_removed
signal folder_removed

## ---
## FILE SYSTEM
## The file system logic, for what files are where
## ---

var root: Folder

func _ready():
	# Create the root directory
	root = Folder.new("root")

	# --- Create a sample file structure ---
	# NOTE: You must have these images in the specified path for them to load.
	var cat_image = load("res://game/assets/images/cat.png") 
	var dog_image = load("res://game/assets/images/dog.png")

	var file1 = File.new("cat_photo.png", "image", cat_image)
	var file2 = File.new("dog_picture.jpg", "image", dog_image)
	var file3 = File.new("important_document.txt", "text")

	# Create a "commissions" folder
	var commissions_folder = Folder.new("Commissions")
	add_file_node_at("/", commissions_folder)

	# Create a client folder
	var client1_folder = Folder.new("Client_A")
	add_file_node_at("/Commissions", client1_folder)
	add_file_node_at("/Commissions/Client_A", file1)

	# Create another client folder
	var client2_folder = Folder.new("Client_B")
	add_file_node_at("/Commissions", client2_folder)
	add_file_node_at("/Commissions/Client_B", file2)
	
	add_file_node_at("/", file3)

func open_file_at(path: String) -> bool:
	var node: FileNode = parse_path(path)
	return open_file(node)

func open_file(node: FileNode) -> bool:
	if node == null:
		return false
	if node is Folder:
		return false
	Desktop.instance.execute(&"error", {})
	return true

func add_file_node_at(path: String, file_node: FileNode) -> bool:
	var folder: Folder = parse_path(path)
	if not folder:
		return false
	folder.add_child(file_node)
	file_node.path = path
	return true

func parse_path(path: String) -> FileNode:
	var names := path.split("/", false)
	var current_folder := root
	var current_file: File = null
	for name: String in names:
		var traversed := false
		var file_found := false
		print(current_folder.children)
		for child: FileNode in current_folder.children:
			if child.node_name == name:
				if child is Folder:
					current_folder = child
					traversed = true
				elif child is File:
					current_file = child
					file_found = true
				break
		if file_found: ## File found
			return current_file
		if not traversed: ## Didn't find any... and no more folders...
			return null
	
	return current_folder
