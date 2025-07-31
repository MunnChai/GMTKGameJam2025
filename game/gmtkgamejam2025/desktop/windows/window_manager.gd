class_name DesktopManagerGlobal
extends Node

## ---
## DESKTOP MANAGER
## An AUTOLOAD SINGLETON that handles tracking all details about your current desktop windows
## - Your windows, and where they are
## - Your taskbar, and what there is
## - Other misc. desktop DATA DETAILS
## ---

## Your current windows, sorted with windows[0] being the topmost and active window 
## and all other windows in descending order
var windows: Array[DesktopWindow] = []

#region WINDOW MANAGEMENT

## Opens a window at the top of the "window stack"
func open_window(window: DesktopWindow) -> bool:
	if has_window(window):
		return false ## Don't open the same window twice!
	windows.push_front(window) ## Open at the front
	window.open_self()
	
	_update_windows_behind_front()
	
	return true

## Brings the given window to the front of the "window stack", pushing every other window back by 1
## If the window is not in the "window stack," direct the code to open that window instead
func bring_to_front(window: DesktopWindow) -> void:
	if not has_window(window):
		open_window(window) ## Not open, just open...
		return
	
	if windows[0] == window: ## We are already front
		return
	
	windows.erase(window)
	windows.push_front(window)
	window.bring_self_to_front()
	
	_update_windows_behind_front()

## Closes the given window by deleting it from the "window stack"
func close_window(window: DesktopWindow) -> void:
	if not has_window(window):
		return
	var index = get_index_of_window(window)
	windows.erase(window)
	window.close_self()
	
	## Update every window after this one...
	if index < windows.size():
		for i in range(index, windows.size()):
			windows[i].bring_self_forward(i)

## Returns the given DesktopWindow at the supplied index
## Returns null if index is out of bounds or invalid
func get_desktop_window(index: int) -> DesktopWindow:
	return windows.get(index)
## Returns true if the window is in the stack, false otherwise
func has_window(window: DesktopWindow) -> bool:
	return windows.has(window)
## Returns index or -1 on fail
func get_index_of_window(window: DesktopWindow) -> int:
	return windows.find(window) 

## Pushes every window behind the front window back by one index
func _update_windows_behind_front() -> void:
	## Push every other window back
	if windows.size() > 1:
		for i in range(1, windows.size()):
			windows[i].send_self_back(i)

#endregion
