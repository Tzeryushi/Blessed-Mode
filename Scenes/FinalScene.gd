extends BaseLevel

@export var death_array : Array[CutsceneInfo]

func on_player_defeat() -> void:
	cutscene_player.play_cutscene(death_array)
	await cutscene_player.finished
	show_end_screen(false)
