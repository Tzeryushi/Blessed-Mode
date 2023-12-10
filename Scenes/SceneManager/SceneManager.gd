class_name SceneManager
extends Node

@export var main_scene : String = ""
@export var scenes : Dictionary = {}
@export var effects : Dictionary = {}

var current_scenes : Array[String] = []
#var scene_reference : Array[Node2D] = []
#var effect_reference : Array[Node2D] = []

func _unhandled_input(event):
	if Input.is_action_just_pressed("escape"):
		remove_all_scenes()
		add_scene("testing_room", Globals.AFTEREFFECT.NONE)

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.set_scene_manager(self)
	#assert(scenes.has(main_scene), "SceneManager: Main scene not in scene dictionary!")
	#current_scene_name = scenes.find_key(main_scene)
	pass

func add_scene_to_dictionary(scene_name:String, scene_path:String) -> void:
	scenes[scene_name] = scene_path

func add_scene(scene_name:String, effect_type:Globals.AFTEREFFECT=Globals.AFTEREFFECT.NONE) -> void:
	_load_and_instance(scene_name)
	current_scenes.append(scene_name)
	if effect_type != Globals.AFTEREFFECT.NONE:
		_load_and_instance(_get_effect_name(effect_type))
		current_scenes.append(_get_effect_name(effect_type))

func remove_scene_from_dictionary(scene_name:String) -> void:
	assert(scenes.has(scene_name), "SceneManager: Bad scene_name string! Key not in dictionary.")
	scenes.erase(scene_name)

func remove_all_scenes() -> void:
	for child in get_children():
		child.queue_free()
	current_scenes.clear()

func switch_scene(scene_name:String) -> void:
	assert(scenes.has(scene_name), "SceneManager: Bad scene_name string! Key not in dictionary.")
	var scene_instance = load(scenes[scene_name]).instantiate()
	remove_all_scenes()
	add_child(scene_instance)
	current_scenes.append(scene_name)

func restart_scene() -> void:
	for child in get_children():
		child.queue_free()
	for scene in current_scenes:
		_load_and_instance(scene)

func quit_game() -> void:
	get_tree().quit()
	
func _load_and_instance(scene_name:String) -> void:
	print(scene_name)
	assert(scenes.has(scene_name), "SceneManager: Bad scene_name string! Key not in dictionary.")
	var scene_instance = load(scenes[scene_name]).instantiate()
	add_child(scene_instance)

func _get_effect_name(type:Globals.AFTEREFFECT) -> String:
	print(effects[type])
	return effects[type]
