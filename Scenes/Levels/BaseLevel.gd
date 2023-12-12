extends Node2D

#BaseLevels contain references to all spawnable enemy types
#each should contain a tilemap and baked navigation region, which will need to be rebaked when tilemaps change
#all levels can be front and back-ended by transitions as well as cutscene prompts
#this is done through the use of objective chain links, which specify conditions to their completion
#this allows us to put dialogue gaps between waves, and track individual objectives before level completion

#For normal stage completion, each scene MUST have combat with working spawners

##Used to instantiate the player. Very important!
@export var player_scene : PackedScene
@export var objective_chain : Array[ObjectiveLink] = []

@onready var enemy_container := $Enemies
@onready var spawner_container := $Spawners
@onready var hud := $HUDLayer/HUD
@onready var cutscene_player := $CutsceneLayer/CutscenePlayer

var player : Player
var enemy_scenes : Dictionary = {
	Globals.ENEMYTYPE.RED1 : load("res://Entities/Flock/RedFlock/EnemyRed1.tscn"),
	Globals.ENEMYTYPE.GREEN1 : load("res://Entities/Flock/GreenFlock/EnemyGreen1.tscn"),
	Globals.ENEMYTYPE.BLUE1 : load("res://Entities/Flock/BlueFlock/EnemyBlue1.tscn")
	}
##contains callables for objective links
var link_functions : Dictionary = {
	Globals.LINKTYPE.TRANSITION : transition_in,
	Globals.LINKTYPE.PSPAWN : spawn_player,
	Globals.LINKTYPE.CUTSCENE : play_cutscene,
	Globals.LINKTYPE.COMBAT : start_combat,
	Globals.LINKTYPE.RESUMECOMBAT : resume_combat
}

##monitored enemies tracks the enemies in the scene, used in level progression and win conditions
var monitored_enemies : Array[BaseEnemy] = []
var spawners : Array[Spawner]
var spawner_wait_list : Array[Spawner]
var has_combat_started : bool = false
var are_all_spawners_stopped : bool = false
var are_all_spawners_finished : bool = false
var are_all_enemies_defeated : bool = true

signal link_function_finished
signal link_finished
signal chain_finished
signal all_spawners_stopped
signal all_spawners_finished

#TODO: User all_spawners_stopped, all_spawners_finished, their bools and the monitored enemies
#to deal with continuing the chain and creating win conditions.
#TODO: Bake win conditions in with combat logic
#TODO: Other win conditions?

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	link_function_finished.connect(on_link_function_finished)
	link_finished.connect(on_link_finished)
	cutscene_player.finished.connect(on_cutscene_finished)
	
	for node in spawner_container.get_children():
		if node is Spawner:
			spawners.append(node)
	for spawner in spawners:
		spawner.spawn_requested.connect(spawn_enemy)
		spawner.reached_breakpoint.connect(on_spawner_stopped)
		spawner.reached_end_of_list.connect(on_spawner_finished)
	
	process_objective_link()
	#spawn_player()
	#spawn_enemy(Globals.ENEMYTYPE.RED1, Vector2(300,300)
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func process_objective_link() -> void:
	var link = objective_chain.pop_front()
	if link.wait_time > 0.0:
		var timer : SceneTreeTimer = get_tree().create_timer(link.wait_time)
		await timer.timeout
	if link_functions.has(link.link_type):
		link_functions[link.link_type].call(link)
	else:
		on_link_function_finished()

func on_link_function_finished() -> void:
	link_finished.emit()

func on_link_finished() -> void:
	if objective_chain.size() > 0:
		process_objective_link()
		return
	chain_finished.emit()
	print("Chain Finished!")

func transition_in(_link:ObjectiveLink):
	#run transition logic for scene, should appeal to upper layers for this
	scale = Vector2(5.0, 0.01)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.9).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	link_function_finished.emit()
	pass

func spawn_player(_link:ObjectiveLink) -> void:
	player = player_scene.instantiate()
	add_child(player)
	hud.connect_player(player)
	link_function_finished.emit()

func play_cutscene(link:ObjectiveLink) -> void:
	#ask the cutscene player to play, return
	cutscene_player.play_cutscene(link.cutscene_list)
	await cutscene_player.finished
	link_function_finished.emit()
	pass

func on_cutscene_finished() -> void:
	pass

func start_combat(_link:ObjectiveLink) -> void:
	#start combat, wait for spawners to finish
	if has_combat_started:
		print("This should never appear!")
		link_function_finished.emit()
		return
	has_combat_started = true
	print("combat!")
	assert(!spawners.is_empty(), "Combat called with no spawners in scene!")
	
	are_all_spawners_stopped = false
	spawner_wait_list.clear()
	for spawner in spawners:
		spawner_wait_list.append(spawner)
	for spawner in spawners:
		spawner.process_events()

func resume_combat(_link:ObjectiveLink) -> void:
	print("Resuming with ", spawners.size(), " spawners")
	are_all_spawners_stopped = false
	spawner_wait_list.clear()
	var temp_spawners : Array[Spawner] = []
	for spawner in spawners:
		spawner_wait_list.append(spawner)
		temp_spawners.append(spawner)
	for spawner in temp_spawners:
		print("One resume")
		spawner.resume_events()

func on_spawner_stopped(_spawner:Spawner) -> void:
	print("Spawner stopped!")
	var index : int = spawner_wait_list.find(_spawner)
	assert(!index < 0, "Spawner stopped outside of monitoring! Nasty!")
	print("Removing ", spawner_wait_list[index], " from spawner_wait_list")
	spawner_wait_list.remove_at(index)
	print(spawner_wait_list.size())
	print(spawners.size())
	if spawner_wait_list.is_empty():
		print("All spawners stopped!")
		are_all_spawners_stopped = true
		all_spawners_stopped.emit()
		if are_all_enemies_defeated:
			link_function_finished.emit()

func on_spawner_finished(_spawner:Spawner) -> void:
	print("Spawner finished!")
	var index : int = spawners.find(_spawner)
	assert(!index < 0, "Spawner finished outside of monitoring! Nasty!")
	print("Removing ", spawners[index], " from spawners")
	spawners.remove_at(index)
	if spawner_wait_list.has(_spawner):
		on_spawner_stopped(_spawner)
	if spawners.is_empty():
		print("All spawners finished!")
		are_all_spawners_finished = true
		all_spawners_finished.emit()
		if are_all_enemies_defeated:
			print("WIN CONDITION!")
	
##monitor_enemy adds a node to the monitored enemies array
func monitor_enemy(enemy:BaseEnemy) -> void:
	if are_all_enemies_defeated:
		are_all_enemies_defeated = false
	enemy.defeated.connect(on_monitored_enemy_defeat)
	monitored_enemies.append(enemy)

func on_monitored_enemy_defeat(enemy:BaseEnemy) -> void:
	var index = monitored_enemies.find(enemy)
	if index < 0:
		print("Enemy removed from list elsewise...scary!")
	monitored_enemies.remove_at(index)
	if monitored_enemies.is_empty():
		are_all_enemies_defeated = true
		if are_all_spawners_stopped:
			link_function_finished.emit()
		if are_all_spawners_finished:
			print("WIN CONDITION! In Enemy Defeat")

##spawn_enemy is used after receiving signals from spawners to create enemies at global locations
func spawn_enemy(enemy_type:Globals.ENEMYTYPE, enemy_position:Vector2) -> void:
	#spawn enemy and add to list of enemies
	var new_enemy : BaseEnemy = enemy_scenes[enemy_type].instantiate()
	new_enemy.global_position = enemy_position
	enemy_container.add_child(new_enemy)
	monitor_enemy(new_enemy)
