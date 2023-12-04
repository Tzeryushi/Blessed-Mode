class_name ModeManager
extends Node

@export var swap_array : Array[ShipMode]

func get_ship_mode() -> ShipMode:
	return swap_array.front()

func swap_ship_mode() -> ShipMode:
	swap_array.push_back(swap_array.pop_front())
	return swap_array.front()
