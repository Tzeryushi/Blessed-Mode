class_name Spawner
extends Node2D

#Spawners run down a list of spawner info, spawning mobs, setting colors and waiting in correspondence to each timer
#Levels can choose to pause the spawn timers they contain, and resume them whenever
#Spawners technically ask the level to spawn an enemy at their location.
@export var spawn_list : Array[SpawnerInfo]
@onready var spawn_radius : float = $SpawnRadius.shape.radius

var should_event_wait : bool = true
var spawn_vector : Vector2 = Vector2.RIGHT
var turn_angle : float = 5*PI/7

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
func _process(_delta):
	pass

func process_events() -> void:
	#var index : int = 0
	for event in spawn_list:
		#print("Event is ", event.spawn_type, " index = ", index)
		#index += 1
		should_event_wait = !(event.spawn_type == Globals.SPAWNTYPE.ENEMY and !event.enemy_count>1)
		event_functions[event.spawn_type].call(event)
		if should_event_wait:
			await event_ended
	reached_end_of_list.emit(self)

func wait(event:SpawnerInfo) -> void:
	#TODO: Show timer visually on spawn node, show color? requires restructure.
	var timer : SceneTreeTimer = get_tree().create_timer(event.wait_time)
	await timer.timeout
	event_ended.emit()

func get_random_coords(radius:float) -> Vector2:
	#var rad = radius * sqrt(randf())
	spawn_vector = spawn_vector.rotated(turn_angle)
	var theta = randf() * 2 * PI
	var length : Vector2 = Vector2.RIGHT*radius
	length = length.rotated(theta)
	return spawn_vector*radius

#signals 
func spawn(event:SpawnerInfo) -> void:
	#TODO: visual flair!
	var timer : SceneTreeTimer
	if should_event_wait:
		for i in range(0, event.enemy_count-1):
			
			spawn_requested.emit(event.enemy_type, global_position+get_random_coords(spawn_radius))
			timer = get_tree().create_timer(event.wait_time)
			await timer.timeout
	spawn_requested.emit(event.enemy_type, global_position+get_random_coords(spawn_radius))
	if should_event_wait:
		event_ended.emit()

##stop simply does nothing (other than visuals) so the  
func stop(_event:SpawnerInfo) -> void:
	#TODO: visual flair!
	#ideally we want to stop until a function is called by the parent
	#so, we do nothing. could probably just take this out of the dictionary
	#whatever.
	reached_breakpoint.emit(self)
	pass
	
func resume_events() -> void:
	#print(self)
	event_ended.emit()
