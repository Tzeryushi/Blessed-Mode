extends PlayerState

@export var idle_state : PlayerState

func on_enter() -> void:
	#execute when state is entered
	pass

func on_exit() -> void:
	#execute when when is exited into another state
	pass

func process_input(_event:InputEvent) -> PlayerState:
	#execute when actor receives input
	#returns the state of the actor, which may have changed
	return null

func process_frame(_delta:float) -> PlayerState:
	#execute to define process loop functionality in state
	#returns the state of the actor, which may have changed
	return null

func process_physics(_delta:float) -> PlayerState:
	var direction : Vector2 = get_move_direction()
	player.move(direction, _delta)
	if direction == Vector2.ZERO:
		return idle_state
	return null
