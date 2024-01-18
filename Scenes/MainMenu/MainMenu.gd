extends Control

@export var master_slider : HSlider
@export var music_slider : HSlider
@export var sfx_slider : HSlider
@export var voice_slider : HSlider
@export var intensity_slider : HSlider
@export var roll_button : CheckButton

@export var crt_resource : CRT_Settings

@onready var color_wheel := $MainContext/ColorWheelSplash
@onready var main_context := $MainContext
@onready var options_context := $OptionsContext
@onready var level_select_context := $LevelSelectContext

const center_position : Vector2 = Vector2(0.0, 0.0)
const left_position : Vector2 = Vector2(-1920.0, 0.0)
const right_position : Vector2 = Vector2(1920.0, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	main_context.position = center_position
	options_context.position = right_position
	level_select_context.position = left_position
	main_context.primary_focus_node.grab_focus()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	
	#load settings
	if !SaveLoader.test_for_settings_save():
		master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
		voice_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Voice")))
		intensity_slider.value = 1.0
		roll_button.button_pressed = true
		crt_resource.intensity = 1.0
		crt_resource.is_roll_on = true
		Events.update_effects.emit()
		save_options()
	load_options()
	
	options_context.hide()
	level_select_context.hide()
	main_context.show()
	
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
func _on_level_select_pressed():
	level_select_context.show()
	level_select_context.primary_focus_node.grab_focus()
	
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(main_context, "position", right_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(level_select_context, "position", center_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(main_context.hide)

func _on_options_button_pressed():
	#set_focus(options_context, true)
	#set_focus(main_context, false)
	options_context.show()
	options_context.primary_focus_node.grab_focus()
	
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(main_context, "position", left_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(options_context, "position", center_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(main_context.hide)
func _on_quit_button_pressed():
	Globals.scene_manager.quit_game()
func _on_tutorial_button_pressed():
	Globals.scene_manager.switch_scene("tutorial", Globals.AFTEREFFECT.CRT)

#options menu
func _on_return_button_pressed():
	#set_focus(options_context, false)
	#set_focus(main_context, true)
	save_options()
	main_context.show()
	main_context.primary_focus_node.grab_focus()
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(main_context, "position", center_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(options_context, "position", right_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(options_context.hide)

func save_options() -> void:
	var options_data : Dictionary = {"master_vol":master_slider.value, "music_vol":music_slider.value,
	"sfx_vol":sfx_slider.value, "voice_vol":voice_slider.value, "intensity":crt_resource.intensity, "roll_on":crt_resource.is_roll_on}
	SaveLoader.settings_save(options_data)

func load_options() -> void:
	#save structure in save_options function
	var options_data : Dictionary = SaveLoader.settings_load()
	master_slider.value = options_data["master_vol"]
	music_slider.value = options_data["music_vol"]
	sfx_slider.value = options_data["sfx_vol"]
	voice_slider.value = options_data["voice_vol"]
	intensity_slider.value = options_data["intensity"]
	crt_resource.intensity = options_data["intensity"]
	roll_button.button_pressed = options_data["roll_on"]
	crt_resource.is_roll_on = options_data["roll_on"]
	Events.update_effects.emit()

#level select menu
func _on_level_return_button_pressed():
	main_context.show()
	main_context.primary_focus_node.grab_focus()
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(main_context, "position", center_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(level_select_context, "position", left_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(level_select_context.hide)
	pass # Replace with function body.

#other
func _on_spin_timer_timeout():
	randomize()
	var shift_tween : Tween = get_tree().create_tween()
	shift_tween.tween_property(color_wheel, "rotation", randf_range(-PI, PI), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

#options receivers
func _on_master_vol_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(value))
func _on_music_vol_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(value))
func _on_sfx_vol_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear_to_db(value))
func _on_voice_vol_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"),linear_to_db(value))
func _on_intensity_value_changed(value):
	crt_resource.intensity = value
	Events.update_effects.emit()
func _on_screen_roll_button_toggled(toggled_on):
	crt_resource.is_roll_on = toggled_on
	Events.update_effects.emit()

func _on_full_screen_button_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
