class_name SpawnerInfo
extends Resource

#spawnerinfo dictates the behaviour of spawners
#they contain enemy type enums, spawner colors, countdowns to the spawn
#very importantly, the spawners have flags that keep them from spawning until
#they are cleared by the active level, such as for waves

##Spawner mode. Types other than Wait are executed after the wait time.
@export var spawn_type : Globals.SPAWNTYPE = Globals.SPAWNTYPE.ENEMY
##Spawner will wait for this amount of time before its action. Always used.
@export var wait_time : float = 0.0
##Utilized to spawn enemies. Non-functional if spawn type is not set to enemy.
@export var enemy_type : Globals.ENEMYTYPE = Globals.ENEMYTYPE.NONE 

signal spawn_requested(enemy_type:Globals.ENEMYTYPE, position:Vector2)
