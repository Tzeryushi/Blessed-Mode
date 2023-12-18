class_name LevelInfo
extends Resource

@export var level_call : String = "level_1"
@export var next_level_call : String = "level_1"
@export var display_name : String = "Level 1"
@export var top_score : int = 100 : set = set_top_score
@export var fastest_time : int = 5999999 : set = set_fastest_time
@export var locked : bool = true : set = set_locked

func set_top_score(value:int) -> void:
	top_score = value
	#print("Changed top score of ", display_name, " to ", top_score)

func set_fastest_time(value:int) -> void:
	fastest_time = value
	#print("Changed fastest time of ", display_name, " to ", fastest_time)

func set_locked(value:bool) -> void:
	locked = value
	#print("Changed locked of ", display_name, " to ", (locked))

func get_value_dict() -> Dictionary:
	return {"top_score":top_score, "fastest_time":fastest_time, "locked":locked}

func set_from_dict(value_dict:Dictionary) -> void:
	top_score = value_dict["top_score"]
	fastest_time = value_dict["fastest_time"]
	locked = value_dict["locked"]
