@tool
extends EditorPlugin

## Fits a 2D or UI scene into the 2D view each time it's opened, the way selecting its root and
## pressing Shift+F (View > Frame Selection) does. Switching between open scenes' tabs keeps
## whatever zoom and pan each was left at; closing a scene and opening it again fits it again.
##
## Godot gives plugins no call to frame the 2D view, so this presses the View menu's own Frame
## Selection item. It's found by its shortcut, the same object the editor settings hold, since its
## label is translated. A Godot update that changes that menu stops it quietly.

const FRAME_SHORTCUT := "canvas_item_editor/frame_selection"

# The open scenes that have been framed since they were opened, by path.
var _framed := {}
# A scene that became current while the script or 3D view was up, to frame on going back to 2D.
var _pending: Node


func _enter_tree() -> void:
	scene_changed.connect(_on_scene_changed)
	scene_closed.connect(_on_scene_closed)
	main_screen_changed.connect(_on_main_screen_changed)


func _exit_tree() -> void:
	scene_changed.disconnect(_on_scene_changed)
	scene_closed.disconnect(_on_scene_closed)
	main_screen_changed.disconnect(_on_main_screen_changed)


func _on_scene_closed(path: String) -> void:
	_framed.erase(path)


# A scene opened while the script or 3D view was up is framed on going back to 2D.
func _on_main_screen_changed(screen_name: String) -> void:
	if screen_name == "2D" and is_instance_valid(_pending):
		_on_scene_changed(_pending)


func _on_scene_changed(root: Node) -> void:
	if root == null or not root is CanvasItem or root.scene_file_path.is_empty():
		return
	if _framed.has(root.scene_file_path):
		return
	_pending = null
	# The view lays the scene out over the next frames; framing before then fits nothing.
	for i in 2:
		await get_tree().process_frame
	# As the editor reopens last session's scenes it makes each current in turn, so by now
	# another may be. A scene only counts as framed once it has been; until then, the next
	# switch to its tab tries again.
	if not is_instance_valid(root) or EditorInterface.get_edited_scene_root() != root:
		return
	var editor := _get_canvas_item_editor()
	if editor == null or not editor.is_visible_in_tree():
		_pending = root
		return
	var selection := EditorInterface.get_selection()
	selection.clear()
	selection.add_node(root)
	if _press_frame_selection(editor):
		_framed[root.scene_file_path] = true


func _get_canvas_item_editor() -> Control:
	var editors := EditorInterface.get_base_control().find_children(
		"*", "CanvasItemEditor", true, false
	)
	return null if editors.is_empty() else editors[0] as Control


func _press_frame_selection(editor: Control) -> bool:
	var frame_shortcut := EditorInterface.get_editor_settings().get_shortcut(FRAME_SHORTCUT)
	if frame_shortcut == null:
		return false
	for button: MenuButton in editor.find_children("*", "MenuButton", true, false):
		var popup := button.get_popup()
		for index in popup.item_count:
			if popup.get_item_shortcut(index) == frame_shortcut:
				popup.id_pressed.emit(popup.get_item_id(index))
				return true
	return false
