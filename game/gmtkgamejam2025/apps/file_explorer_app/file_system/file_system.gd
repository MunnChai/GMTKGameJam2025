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
	root = Folder.new("user")

	# --- Create a sample file structure ---
	# NOTE: You must have these images in the specified path for them to load.
	#var nutreents_image = load("res://assets/images/nutreents_logo.png") 

	#var file1 = File.new("nutreents.png", "image", nutreents_image)
	var file_2 = File.new("passwords.txt", "text", null)

	add_file_node_at("/", file_2)

	# Create a "commissions" folder
	var commissions_folder = Folder.new("commissions")
	add_file_node_at("/", commissions_folder)
	
	# Create a "images" folder
	var images_folder = Folder.new("images")
	add_file_node_at("/", images_folder)
	#add_file_node_at("/images", file1)
	
	var file3 = File.create_from_resource(load("res://assets/file_resources/commissions/sad_birthday.tres"))
	add_file_node_at("/", file3)
	
	var exports_folder = Folder.new("exports")
	add_file_node_at("/", exports_folder)

func open_file_at(path: String) -> bool:
	var node: FileNode = parse_path(path)
	return open_file(node)

func open_file(node: FileNode) -> bool:
	if node == null:
		return false
	if node is Folder:
		return false
	
	var file: File = node
	
	match file.file_type:
		"image":
			Desktop.instance.execute(&"photoshop", {"file": file.get_file_resource() })
		_:
			Desktop.instance.execute(&"error", {"text": "Unsupported file type. Please update to OS 96."})
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
