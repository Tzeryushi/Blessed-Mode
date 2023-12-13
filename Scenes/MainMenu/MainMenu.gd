extends Control

@onready var color_wheel := $MainContext/ColorWheelSplash
@onready var main_context := $MainContext
@onready var options_context := $OptionsContext

const center_position : Vector2 = Vector2(0.0, 0.0)
const left_position : Vector2 = Vector2(-1920.0, 0.0)
const right_position : Vector2 = Vector2(1920.0, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	main_context.position = center_position
	options_context.position = right_position
	main_context.primary_focus_node.grab_focus()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	#set_focus(options_context, false)
	MusicManager.play(MusicLibrary.menu_music)
	pass # Replace with function body.

func set_focus(node:Node, value:bool) -> void:
	if node.has_method("set_focus_mode"):
		node.focus_mode = value
	for child in node.get_children():
		set_focus(child, value)

#main menu buttons
func _on_story_button_pressed():
	Globals.scene_manager.switch_scene("level_1", Globals.AFTEREFFECT.CRT)
func _on_options_button_pressed():
	#set_focus(options_context, true)
	#set_focus(main_context, false)
	options_context.primary_focus_node.grab_focus()
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(main_context, "position", left_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(options_context, "position", center_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
func _on_quit_button_pressed():
	Globals.scene_manager.quit_game()
func _on_tutorial_button_pressed():
	Globals.scene_manager.switch_scene("tutorial", Globals.AFTEREFFECT.CRT)

#options menu
func _on_return_button_pressed():
	#set_focus(options_context, false)
	#set_focus(main_context, true)
	main_context.primary_focus_node.grab_focus()
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(main_context, "position", center_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(options_context, "position", right_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

#other
func _on_spin_timer_timeout():
	randomize()
	var shift_tween : Tween = get_tree().create_tween()
	shift_tween.tween_property(color_wheel, "rotation", randf_range(-PI, PI), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
