class_name Spawner
extends Node2D

#Spawners run down a list of spawner info, spawning mobs, setting colors and waiting in correspondence to each timer
#Levels can choose to pause the spawn timers they contain, and resume them whenever
#Spawners technically ask the level to spawn an enemy at their location.
@export var spawn_list : Array[SpawnerInfo]

var event_functions : Dictionary = {
	Globals.SPAWNTYPE.WAIT : wait,
	Globals.SPAWNTYPE.ENEMY : spawn,
	Globals.SPAWNTYPE.STOP : stop
}

signal spawn_requested(enemy_type:Globals.ENEMYTYPE, spawn_position:Vector2)
signal event_ended
signal reached_breakpoint(spawner:Spawner)
signal reached_end_of_list(spawner:Spawner)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func process_events() -> void:
	for event in spawn_list:
		event_functions[event.spawn_type].call(event)
		if event.spawn_type != Globals.SPAWNTYPE.ENEMY:
			await event_ended
	reached_end_of_list.emit(self)

func wait(event:SpawnerInfo) -> void:
	#TODO: Show timer visually on spawn node, show color? requires restructure.
	var timer : SceneTreeTimer = get_tree().create_timer(event.wait_time)
	await timer.timeout
	event_ended.emit()

#signals 
func spawn(event:SpawnerInfo) -> void:
	#TODO: visual flair!
	spawn_requested.emit(event.enemy_type, global_position)

##stop simply does nothing (other than visuals) so the  
func stop(event:SpawnerInfo) -> void:
	#TODO: visual flair!
	#ideally we want to stop until a function is called by the parent
	#so, we do nothing. could probably just take this out of the dictionary
	#whatever.
	reached_breakpoint.emit(self)
	pass
	
func resume_events() -> void:
	print(self)
	event_ended.emit()
