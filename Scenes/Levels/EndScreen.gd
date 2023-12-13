extends ColorRect

@export var combat_pre : String = ""
@export var enemies_pre : String = ""
@export var score_pre : String = ""
@export var outcome_pre : String = ""
@export var good_messages : Array[String] = []
@export var bad_messages : Array[String] = []
@export var message_pre : String = ""
@export var menu_stab : AudioStream

@onready var results_title := $PanelContainer/VBoxContainer/ResultsTitle
@onready var combat_time := $PanelContainer/VBoxContainer/CombatTime
@onready var enemies_killed := $PanelContainer/VBoxContainer/Enemies
@onready var final_score := $PanelContainer/VBoxContainer/FinalScore
@onready var outcome := $PanelContainer/VBoxContainer/Outcome
@onready var message := $PanelContainer/VBoxContainer/FinalMessage

@onready var menu_button_container := $PanelContainer/VBoxContainer/Buttons/VBoxContainer
@onready var replay_button_container := $PanelContainer/VBoxContainer/Buttons/VBoxContainer2
@onready var next_level_button_container := $PanelContainer/VBoxContainer/Buttons/VBoxContainer3

var victory : bool = false

func _ready() -> void:
	combat_time.hide()
	enemies_killed.hide()
	final_score.hide()
	outcome.hide()
	message.hide()
	menu_button_container.hide()
	replay_button_container.hide()
	next_level_button_container.hide()

func set_results(_time:int, _slain:int, _score:int, _victorious:bool) -> void:
	combat_time.text = combat_pre + get_string_from_msecs(_time)
	enemies_killed.text = enemies_pre + str(_slain)
	final_score.text = score_pre + str(_score)
	var _outcome : String = ""
	var temp_msg : String = ""
	victory = _victorious
	randomize()
	if _victorious:
		_outcome = "[color=green]Victory"
		temp_msg = good_messages.pick_random()
	else:
		_outcome = "[color=darkgray]Defeat"
		temp_msg = bad_messages.pick_random()
	outcome.text = outcome_pre + _outcome
	message.text = message_pre+temp_msg

func animate_results() -> void:	
	var tween : Tween = create_tween()
	tween.tween_callback(show)
	tween.tween_callback(SoundManager.play.bind(menu_stab))
	tween.tween_method(shake, 0.7, 0.0, 1.0)
	tween.tween_callback(combat_time.show)
	tween.tween_callback(SoundManager.play.bind(menu_stab))
	tween.tween_method(shake, 0.6, 0.0, 0.7)
	tween.tween_callback(enemies_killed.show)
	tween.tween_callback(SoundManager.play.bind(menu_stab))
	tween.tween_method(shake, 0.6, 0.0, 0.7)
	tween.tween_callback(final_score.show)
	tween.tween_callback(SoundManager.play.bind(menu_stab))
	tween.tween_method(shake, 0.6, 0.0, 0.7)
	tween.tween_callback(outcome.show).set_delay(0.5)
	tween.tween_callback(SoundManager.play.bind(menu_stab))
	tween.tween_method(shake, 0.6, 0.0, 0.4)
	tween.tween_callback(message.show)
	tween.tween_callback(SoundManager.play.bind(menu_stab))
	tween.tween_method(shake, 0.6, 0.0, 1.0)
	tween.tween_callback(menu_button_container.show)
	tween.tween_callback(SoundManager.play.bind(menu_stab))
	tween.tween_method(shake, 0.6, 0.0, 0.4)
	tween.tween_callback(replay_button_container.show)
	tween.tween_callback(SoundManager.play.bind(menu_stab))
	tween.tween_method(shake, 0.6, 0.0, 0.4)
	
	await tween.finished
	
	if victory:
		tween = create_tween()
		tween.tween_callback(next_level_button_container.show)
		tween.tween_callback(SoundManager.play.bind(menu_stab))
		tween.tween_method(shake, 0.6, 0.0, 0.4)
	
	$PanelContainer/VBoxContainer/Buttons/VBoxContainer/MainMenu.grab_focus()
	
	pass

func shake(_trauma) -> void:
	var amount = pow(_trauma, 2)
	var max_offset : Vector2 = Vector2(100, 75)
	var max_roll = 0.1
	rotation = max_roll * amount * randf_range(-1, 1)
	position.x = max_offset.x * amount * randf_range(-1, 1)
	position.y = max_offset.y * amount * randf_range(-1, 1)

func get_string_from_msecs(value:int) -> String:
	if value >= 5999999:
		return "99:59:999"
	var total : String
	var msecs = value%1000
	var secs = (value%(60*1000))/1000
	var mins = (value/(60*1000))%100
	total = "%02d:%02d:%03d" % [mins, secs, msecs]
	return total
