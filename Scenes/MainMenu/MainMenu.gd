extends Control

@onready var color_wheel := $MainContext/ColorWheelSplash

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_story_button_pressed():
	Globals.scene_manager.switch_scene("testing_room", Globals.AFTEREFFECT.CRT)

func _on_quit_button_pressed():
	Globals.scene_manager.quit_game()


func _on_spin_timer_timeout():
	randomize()
	var shift_tween : Tween = get_tree().create_tween()
	shift_tween.tween_property(color_wheel, "rotation", randf_range(-PI, PI), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
