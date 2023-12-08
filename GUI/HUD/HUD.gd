extends Control

@onready var mode_wheel := $ModeHUD/ModeWheel

var shift_tween : Tween



func shift_mode_indicator(mode:Globals.MODECOLOR) -> void:
	var mode_rotation : float = 0.0
	match mode:
		0: mode_rotation = 0.0
		1: mode_rotation = -2*PI/3
		2: mode_rotation = 2*PI/3
	if shift_tween and shift_tween.is_running():
		shift_tween.kill
	shift_tween = get_tree().create_tween()
	shift_tween.tween_property(mode_wheel, "rotation", mode_rotation, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
