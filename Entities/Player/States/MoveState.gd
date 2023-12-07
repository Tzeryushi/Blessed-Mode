extends PlayerState

@export var idle_state : PlayerState

func on_enter() -> void:
	#execute when state is entered
	pass

func on_exit() -> void:
	#execute when when is exited into another state
	pass

func process_input(_event:InputEvent) -> PlayerState:
	if Input.is_action_just_pressed("shift_mode"):
		player.shift_mode()
	return null

func process_frame(_delta:float) -> PlayerState:
	#execute to define process loop functionality in state
	#returns the state of the actor, which may have changed
	return null

func process_physics(_delta:float) -> PlayerState:
	if Input.is_action_pressed("shoot"):
		player.shoot(get_move_direction())
	if Input.is_action_pressed("special_action"):
		player.special_action(Vector2.ZERO)
	var direction : Vector2 = get_move_direction()
	player.move(direction, _delta)
	if direction == Vector2.ZERO:
		return idle_state
	return null
