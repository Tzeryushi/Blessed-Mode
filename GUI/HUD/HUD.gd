extends Control

@export var score_length : int = 12

@onready var mode_wheel := $ModeHUD/ModeWheel
@onready var life_bar := $LifeBar
@onready var juice_bar := $JuiceBar
@onready var combo_text := $ComboText
@onready var score := $Score/Count
@onready var combat_time := $CombatTime

var player_ref : Player = null

func _ready() -> void:
	#call_deferred("player_setup")
	pass

func connect_player(player:Player) -> void:
	await get_tree().process_frame
	var _tree = get_tree()
	player_ref = player
	assert(player_ref, "Did not successfully pass player info to the HUD!")
	player_ref.health_changed.connect(_on_health_changed)
	player_ref.juice_changed.connect(_on_juice_changed)
	player_ref.mode_changed.connect(shift_mode_indicator)
	player_ref.blessed_mode_engaged.connect(_on_blessed_mode_changed)
	player_ref.combo_changed.connect(_on_combo_changed)
	_on_health_changed(player_ref.health, player_ref.max_health)
	_on_juice_changed(player_ref.juice, player_ref.max_juice, player_ref.can_use_special)
	(juice_bar.material as ShaderMaterial).set_shader_parameter("strength", 0.0) 
	pass

func shift_mode_indicator(mode:Globals.MODECOLOR) -> void:
	var mode_rotation : float = 0.0
	match mode:
		0: mode_rotation = 0.0
		1: mode_rotation = -2*PI/3
		2: mode_rotation = 2*PI/3
	var shift_tween : Tween = get_tree().create_tween()
	shift_tween.tween_property(mode_wheel, "rotation", mode_rotation, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_health_changed(value:int, max_health:int) -> void:
	#change HUD value here
	var ratio = (float(value)/float(max_health))*life_bar.max_value
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(life_bar, "value", ratio, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_juice_changed(value:float, max_juice:float, is_recharging:bool) -> void:
	if is_recharging:
		juice_bar.modulate = Color(0.2, 0.2, 0.2)
	else:
		juice_bar.modulate = Color(1, 1, 1)
	var ratio = (float(value)/float(max_juice))*juice_bar.max_value
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(juice_bar, "value", ratio, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_blessed_mode_changed(value:bool) -> void:
	(juice_bar.material as ShaderMaterial).set_shader_parameter("strength", float(value)*0.6) 

func _on_combo_changed(combo_value:int) -> void:
	combo_text.set_combo(combo_value)

func change_score(value:int) -> void:
	var zeros_to_add : int = score_length - str(value).length()
	var output_score : String = ""
	if zeros_to_add > 0:
		for i in range(zeros_to_add):
			output_score += "0"
	score.text = output_score + str(value)

func change_combat_time(time_msecs:int) -> void:
	combat_time.text = "[center] CTIME: " + get_string_from_msecs(time_msecs)

func get_string_from_msecs(value:int) -> String:
	if value >= 5999999:
		return "99:59:999"
	var total : String
	var msecs = value%1000
	var secs = (value%(60*1000))/1000
	var mins = (value/(60*1000))%100
	total = "%02d:%02d:%03d" % [mins, secs, msecs]
	return total
