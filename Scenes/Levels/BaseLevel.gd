extends Node2D

#BaseLevels contain references to all spawnable enemy types
#each should contain a tilemap and baked navigation region, which will need to be rebaked when tilemaps change
#all levels can be front and back-ended by transitions as well as cutscene prompts

##Used to instantiate the player. Very important!
@export var player_scene : PackedScene

@onready var enemy_container := $Enemies
@onready var hud := $HUDLayer/HUD

var player : Player
var enemy_scenes : Dictionary = {
	Globals.ENEMYTYPE.RED1 : load("res://Entities/Flock/RedFlock/EnemyRed1.tscn"),
	Globals.ENEMYTYPE.GREEN1 : load("res://Entities/Flock/GreenFlock/EnemyGreen1.tscn"),
	Globals.ENEMYTYPE.BLUE1 : load("res://Entities/Flock/BlueFlock/EnemyBlue1.tscn")
	}

##monitored enemies tracks the enemies in the scene, used in level progression and win conditions
var monitored_enemies : Array[BaseEnemy] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	spawn_enemy(Globals.ENEMYTYPE.RED1, Vector2(300,300))
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_player() -> void:
	player = player_scene.instantiate()
	add_child(player)
	hud.connect_player(player)

##monitor_enemy adds a node to the monitored enemies array
func monitor_enemy(enemy:BaseEnemy) -> void:
	monitored_enemies.append(enemy)
	
##spawn_enemy is used after receiving signals from spawners to create enemies at global locations
func spawn_enemy(enemy_type:Globals.ENEMYTYPE, enemy_position:Vector2) -> void:
	#spawn enemy and add to list of enemies
	var new_enemy : BaseEnemy = enemy_scenes[enemy_type].instantiate()
	new_enemy.global_position = enemy_position
	enemy_container.add_child(new_enemy)
	monitor_enemy(new_enemy)
