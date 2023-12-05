class_name PlayerStateManager
extends Node

@export var first_state : PlayerState

var current_state : PlayerState

func swap_state(new_state:PlayerState) -> void:
	#swaps in new state, unless it is the same state
	#cycle out of state as long as it exists
	if current_state:
		if current_state == new_state:
			assert(current_state == new_state)  #this shouldn't ever happen#,"ERROR: Actor state swapped to itself!")
		current_state.on_exit()
	current_state = new_state
	#print("Swapped to ", current_state)
	current_state.on_enter()

func init_state(player:Player) -> void:
	#iterate through child nodes of StateManager to inject actor ref
	for state in get_children():
		if state is PlayerState:
			state.player = player
	
	#start at predesignated first state
	swap_state(first_state)

func process_input(event:InputEvent) -> void:
	#called through actor process
	#if state interpretation changes state, swap to new state
	var new_state = current_state.process_input(event)
	if new_state:
		swap_state(new_state)

func process_frame(delta:float) -> void:
	#called through actor process
	#if state interpretation changes state, swap to new state
	var new_state = current_state.process_frame(delta)
	if new_state:
		swap_state(new_state)

func process_physics(delta:float) -> void:
	#called through actor physics process
	#if state interpretation changes state, swap to new state
	var new_state = current_state.process_physics(delta)
	if new_state:
		swap_state(new_state)
