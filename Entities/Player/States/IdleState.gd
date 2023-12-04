extends PlayerState

@export var move_state : PlayerState
@export var hurt_state : PlayerState
@export var stasis_state : PlayerState

func process_input(_event:InputEvent) -> PlayerState:
	if Input.is_action_just_pressed("shoot"):
		player.shoot(Vector2.ZERO)
	if Input.is_action_pressed("shift_mode"):
		player.shift_mode()
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		return move_state
	return null

func process_physics(_delta:float) -> PlayerState:
	player.idle(_delta)
	return null
