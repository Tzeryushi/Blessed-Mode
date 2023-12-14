extends MenuContext

@export var level_list : Array[LevelInfo] = []
@export var level_box_scene : PackedScene

@onready var level_container := $VBoxContainer/LevelContainer

func _ready() -> void:
	var level_box : LevelBox
	for level in level_list:
		level_box = level_box_scene.instantiate()
		level_container.add_child(level_box)
		(level_box as LevelBox).set_locked(level.locked)
		(level_box as LevelBox).set_level(level.display_name)
		(level_box as LevelBox).set_level_call(level.level_call)
		(level_box as LevelBox).set_score(level.top_score)
		(level_box as LevelBox).set_time(level.fastest_time)
