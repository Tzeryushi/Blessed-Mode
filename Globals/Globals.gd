extends Node

enum MODECOLOR {RED=0, GREEN=1, BLUE=2}

func is_mode_color_effective(attacking_mode:MODECOLOR, defending_mode:MODECOLOR) -> bool:
	return (defending_mode-attacking_mode)%3 == 1
func get_mode_color_effectiveness(attacking_mode:MODECOLOR, defending_mode:MODECOLOR) -> int:
	#0 is even, 1 is effective, 2 is ineffective
	return (defending_mode-attacking_mode)%3
