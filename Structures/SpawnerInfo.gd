class_name SpawnerInfo
extends Resource

#spawnerinfo dictates the behaviour of spawners
#they contain enemy type enums, spawner colors, countdowns to the spawn
#very importantly, the spawners have flags that keep them from spawning until
#they are cleared by the active level, such as for waves

@export var spawn_title : String = "Basic Spawn"
@export var spawn_type : Globals.SPAWNTYPE = Globals.SPAWNTYPE.WAIT
