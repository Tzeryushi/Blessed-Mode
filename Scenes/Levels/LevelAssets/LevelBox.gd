class_name LevelBox
extends PanelContainer

signal level_selected()

@export var locked = true: set = set_locked

@onready var lock := $MarginContainer/Lock
@onready var level_title := $VBoxContainer/Title
@onready var score_label := $VBoxContainer/Score
@onready var time_label := $VBoxContainer/Time

var level_call : String = "level_1"

func set_locked(value:bool) -> void:
	locked = value
	if not is_inside_tree():
		await ready
	lock.visible = value
	level_title.visible = not value
	score_label.visible = not value
	time_label.visible = not value

func set_level(_name:String) -> void:
	if not is_inside_tree():
		await ready
	level_title.text = "[center]" + _name

func set_level_call(_call:String) -> void:
	if not is_inside_tree():
		await ready
	level_call = _call

func set_score(score:int) -> void:
	if not is_inside_tree():
		await ready
	score_label.text = "[center]TOP SCORE:\n[color=green]" + str(score)

func set_time(time_score:int) -> void:
	if not is_inside_tree():
		await ready
	time_label.text = "[center]FASTEST TIME:\n[color=blue]" + Globals.get_string_from_msecs(time_score)

func _on_gui_input(event):
	if locked:
		return
	if event is InputEventMouseButton and event.pressed:
		level_selected.emit()
		(Globals.scene_manager as SceneManager).switch_scene(level_call, Globals.AFTEREFFECT.CRT)
