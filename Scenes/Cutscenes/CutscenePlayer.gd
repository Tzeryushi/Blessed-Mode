class_name CutscenePlayer
extends Node2D

@export var fadein_time : float = 0.3
@export var fadeout_time : float = 0.2

@onready var box := $BoxControl
@onready var scene_text := $BoxControl/VBoxContainer/CutsceneText
@onready var stream_player := $AudioStreamPlayer
signal finished



func play_cutscene(info_array:Array[CutsceneInfo]) -> void:
	show()
	box.modulate.a = 0.0
	for line in info_array:
		scene_text.text = "[center]" + line.line_text
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(box, "modulate:a", 1.0, fadein_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		#stream_player.stream = line.sound
		#stream_player.play()
		#var streamer : AudioStreamPlayer = SoundManager.play_and_get(line.sound)
		#await streamer.finished
		VoiceManager.play(line.sound)
		await VoiceManager.finished
		var timer : SceneTreeTimer = get_tree().create_timer(line.wait_time-fadeout_time)
		await timer.timeout
		tween = get_tree().create_tween()
		tween.tween_property(box, "modulate:a", 0.0, fadeout_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
	hide()
	finished.emit()
