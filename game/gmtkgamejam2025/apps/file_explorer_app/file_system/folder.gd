class_name Folder
extends FileNode

@export var children: Array[FileNode]

func _init(new_name: String, new_children: Array[FileNode] = []):
	node_name = new_name
	children = new_children

func is_folder() -> bool:
	return true

func add_child(child: FileNode):
	children.append(child)

func get_child(child_name: String) -> FileNode:
	for child in children:
		if child.node_name == child_name:
			return child
	return null

func rename(new_name: String) -> void:
	node_name = new_name
