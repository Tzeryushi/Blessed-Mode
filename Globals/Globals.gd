extends Node

enum MODECOLOR {RED=0, GREEN=1, BLUE=2}

func is_mode_color_effective(attacking_mode:MODECOLOR, defending_mode:MODECOLOR) -> bool:
	return (defending_mode-attacking_mode)%3 == 1
func get_mode_color_effectiveness(attacking_mode:MODECOLOR, defending_mode:MODECOLOR) -> int:
	#0 is even, 1 is effective, 2 is ineffective
	return (3+defending_mode-attacking_mode)%3
func multiply_by_mode(value:int, attacking_mode:MODECOLOR, defending_mode:MODECOLOR) -> int:
	var damage_to_take : int = value
	#augment damage based on modes
	match get_mode_color_effectiveness(attacking_mode, defending_mode):
			0: pass
			1: damage_to_take = damage_to_take * 2
			2: 
				@warning_ignore("integer_division")
				damage_to_take = max(int(damage_to_take/2), 1)
	return damage_to_take
