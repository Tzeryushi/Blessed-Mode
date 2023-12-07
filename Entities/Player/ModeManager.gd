class_name ModeManager
extends Node2D

#the first element of the swap array is the current mode.

@export var swap_array : Array[ShipMode]
@export var swap_timer : Timer
@export var swap_cooldown : float = 0.07

var can_swap : bool = true : set = set_mode_swap, get = can_mode_swap

func _process(_delta) -> void:
	pass
	#if !can_swap:
		#print(swap_timer.time_left)

func init_modes(_player:Player) -> void:
	for mode in swap_array:
		mode.player = _player

func get_ship_mode() -> ShipMode:
	return swap_array.front()

func swap_ship_mode() -> ShipMode:
	if !can_swap:
		return swap_array.front()
	can_swap = false
	
	swap_array.front().swap_out()
	swap_array.push_back(swap_array.pop_front())
	swap_array.front().swap_in()
	return swap_array.front()

func _on_swap_timer_timeout():
	can_swap = true

func can_mode_swap() -> bool:
	return can_swap
func set_mode_swap(value:bool) -> void:
	swap_timer.stop()
	can_swap = value
	if !value:
		swap_timer.wait_time = swap_cooldown
		swap_timer.start()
