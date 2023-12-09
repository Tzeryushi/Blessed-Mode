extends Control

@onready var mode_wheel := $ModeHUD/ModeWheel
@onready var life_bar := $LifeBar
@onready var juice_bar := $JuiceBar

var player_ref : Player = null


func _ready() -> void:
	call_deferred("player_setup")

func player_setup() -> void:
	await get_tree().process_frame
	var tree = get_tree()
	if tree.has_group("player"):
		player_ref = tree.get_first_node_in_group("player")
	if player_ref:
		player_ref.health_changed.connect(_on_health_changed)
		player_ref.juice_changed.connect(_on_juice_changed)
		player_ref.mode_changed.connect(shift_mode_indicator)
		_on_health_changed(player_ref.health, player_ref.max_health)
		_on_juice_changed(player_ref.juice, player_ref.max_juice, player_ref.can_use_special)
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
