class_name GenButton
extends Button



func _on_mouse_entered():
	SoundManager.play(GlobalSfx.button_hover_sfx)

func _on_focus_entered():
	SoundManager.play(GlobalSfx.button_hover_sfx)

func _on_pressed():
	SoundManager.play(GlobalSfx.button_select_sfx)
