extends Node

enum MODECOLOR {RED=0, GREEN=1, BLUE=2}
enum AFTEREFFECT {NONE=0, CRT=1}
enum SPAWNTYPE {WAIT, ENEMY, STOP}
enum ENEMYTYPE {NONE, RED1, GREEN1, BLUE1, RED2, GREEN2, BLUE2}
enum LINKTYPE {WAIT, CUTSCENE, COMBAT, TRANSITION, PSPAWN, RESUMECOMBAT, STARTSTATS, PAUSESTATS, ENDSCREEN}
enum COMBATTYPE {NONE, ELIMINATION}
var scene_manager : SceneManager

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
			2: damage_to_take = max(int(damage_to_take/2), 1)
	return damage_to_take

func get_center_scene() -> Node:
	return scene_manager.scene_references[0]

func set_scene_manager(manager:SceneManager) -> void:
	scene_manager = manager

func get_string_from_msecs(value:int) -> String:
	if value >= 5999999:
		return "99:59:999"
	var total : String
	var msecs = value%1000
	var secs = (value%(60*1000))/1000
	var mins = (value/(60*1000))%100
	total = "%02d:%02d:%03d" % [mins, secs, msecs]
	return total
