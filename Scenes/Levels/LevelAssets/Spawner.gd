extends Node2D

#Spawners run down a list of spawner info, spawning mobs, setting colors and waiting in correspondence to each timer
#Levels can choose to pause the spawn timers they contain, and resume them whenever
#Spawners technically ask the level to spawn an enemy at their location.
@export var spawn_list : Array[SpawnerInfo]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func next_event() -> void:
	#moves spawner to next event in chain, if there is one
	pass
