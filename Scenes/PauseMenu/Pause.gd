extends Control

@export var default_focus_node : Control

var was_mouse_visible : bool = false

func _input(event) -> void:
	if event.is_action_pressed("pause"):
		pause_unpause()

func pause_unpause() -> void:
	var new_state = not get_tree().paused
	get_tree().paused = new_state
	visible = new_state
	if new_state:
		was_mouse_visible = DisplayServer.mouse_get_mode() == DisplayServer.MOUSE_MODE_VISIBLE
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		default_focus_node.grab_focus()
	else:
		if !was_mouse_visible:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
		default_focus_node.release_focus()

func _on_resume_pressed():
	pause_unpause()

func _on_main_menu_pressed():
	pause_unpause()
	Globals.scene_manager.switch_scene("main_menu")

func _on_quit_pressed():
	Globals.scene_manager.quit_game()
