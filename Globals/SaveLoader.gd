extends Node

const SAVE_DIR = "res://saves/"
const SAVE_FILE_NAME = "save.json"
const SEC_KEY = "089SADFH"

@onready var level_list : Array[LevelInfo] = [
	preload("res://Scenes/Levels/LevelResources/T0SA.tres"),
	preload("res://Scenes/Levels/LevelResources/T0SB.tres"),
	preload("res://Scenes/Levels/LevelResources/T0SC.tres"),
	preload("res://Scenes/Levels/LevelResources/T0SD.tres"),
	preload("res://Scenes/Levels/LevelResources/T0SE.tres"),
	preload("res://Scenes/Levels/LevelResources/T0SF.tres")
]

func _ready() -> void:
	verify_dir(SAVE_DIR)

func verify_dir(path:String) -> void:
	DirAccess.make_dir_absolute(path)

func test_for_save(path:String=(SAVE_DIR+SAVE_FILE_NAME)) -> bool:
	return FileAccess.file_exists(path)
	pass

func file_save(path:String=(SAVE_DIR+SAVE_FILE_NAME)) -> void:
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SEC_KEY)
	if file == null:
		print(FileAccess.get_open_error())
		return
	
	var track0_levels : Dictionary
	for level in level_list:
		track0_levels[level.level_call] = level.get_value_dict()
	
	var data := {
		"track0_levels": track0_levels
	}
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()

func file_load(path:String=(SAVE_DIR+SAVE_FILE_NAME)) -> void:
	if !FileAccess.file_exists(path):
		printerr("File non-existent at ", path)
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SEC_KEY)
	if file == null:
		print(FileAccess.get_open_error())
		return
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data == null:
		printerr("Target file is unparsable at ", path, " with ", content)
		return
	
	for level in level_list:
		print(data["track0_levels"][level.level_call])
		level.set_from_dict(data["track0_levels"][level.level_call])
	
