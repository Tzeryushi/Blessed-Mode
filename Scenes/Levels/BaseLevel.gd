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
@export var score_value : int = 1367
@export var combo_threshold : int = 5
@export var next_scene : String = "main_menu"
@export var level_info : LevelInfo
@export var next_level_info : LevelInfo

@export_category("Music")
@export var play_tutorial_music : bool = false
@export var level_music : AudioStream = MusicLibrary.playing_music
@export var tutorial_music : AudioStream = MusicLibrary.tutorial_music
@export var victory_music : AudioStream = MusicLibrary.victory_music
@export var defeat_music : AudioStream = MusicLibrary.defeat_music

@onready var enemy_container := $Enemies
@onready var spawner_container := $Spawners
@onready var hud := $HUDLayer/HUD
@onready var cutscene_player := $CutsceneLayer/CutscenePlayer
@onready var end_screen := $EndScreenLayer/EndScreen
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
	Globals.LINKTYPE.RESUMECOMBAT : resume_combat,
	Globals.LINKTYPE.STARTSTATS : start_stats,
	Globals.LINKTYPE.PAUSESTATS : pause_stats,
	Globals.LINKTYPE.ENDSCREEN : queue_end_screen
}

##monitored enemies tracks the enemies in the scene, used in level progression and win conditions
var monitored_enemies : Array[BaseEnemy] = []
var spawners : Array[Spawner]
var spawner_wait_list : Array[Spawner]

#variables for keeping track of elasped game time
#these are used with the start and pause stats events
var last_watch_start_time : int = 0
var watch_update_time: int = 0
var last_watch_end_time : int = 0
var elapsed_time_msecs : int = 0
var is_tracking_time : bool = false

#scorekeeping
var total_score : int = 0
var head_count : int = 0

#various tracker bools
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
	
	if play_tutorial_music:
		MusicManager.play(tutorial_music)
	else:
		MusicManager.play(level_music)
	
	if level_info:
		if level_info.locked:	#unlock level if locked
			level_info.locked = false
	
	process_objective_link()
	#spawn_player()
	#spawn_enemy(Globals.ENEMYTYPE.RED1, Vector2(300,300)
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_tracking_time:
		elapsed_time_msecs += Time.get_ticks_msec() - watch_update_time
		watch_update_time = Time.get_ticks_msec()
		hud.change_combat_time(elapsed_time_msecs)
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
	#intermediaries go here
	link_finished.emit()
func on_link_finished() -> void:
	#print("Link Finished!")
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
	player.defeated.connect(on_player_defeat)
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
	assert(!spawners.is_empty(), "Combat called with no spawners in scene!")
	
	are_all_spawners_stopped = false
	spawner_wait_list.clear()
	#print("There are ", spawners.size(), " spawners")
	for spawner in spawners:
		spawner_wait_list.append(spawner)
	#print("There are ", spawner_wait_list.size(), " wait spawners")
	for spawner in spawners:
		spawner.process_events()
	
func resume_combat(_link:ObjectiveLink) -> void:
	are_all_spawners_stopped = false
	spawner_wait_list.clear()
	var temp_spawners : Array[Spawner] = []
	for spawner in spawners:
		spawner_wait_list.append(spawner)
		temp_spawners.append(spawner)
	for spawner in temp_spawners:
		spawner.resume_events()
	
func on_spawner_stopped(_spawner:Spawner) -> void:
	#print(spawner_wait_list.size(), " wait spawners now, called by ", _spawner)
	var index : int = spawner_wait_list.find(_spawner)
	assert(!index < 0, "Spawner stopped outside of monitoring! Nasty!")
	#print("One spawn finished")
	spawner_wait_list.remove_at(index)
	if spawner_wait_list.is_empty():
		are_all_spawners_stopped = true
		all_spawners_stopped.emit()
		if are_all_enemies_defeated:
			link_function_finished.emit()
	
func on_spawner_finished(_spawner:Spawner) -> void:
	var index : int = spawners.find(_spawner)
	assert(!index < 0, "Spawner finished outside of monitoring! Nasty!")
	spawners.remove_at(index)
	if spawner_wait_list.has(_spawner):
		on_spawner_stopped(_spawner)
	if spawners.is_empty():
		are_all_spawners_finished = true
		all_spawners_finished.emit()
		if are_all_enemies_defeated:
			print("WIN CONDITION!")
	
##monitor_enemy adds a node to the monitored enemies array
func monitor_enemy(enemy:BaseEnemy) -> void:
	if are_all_enemies_defeated:
		are_all_enemies_defeated = false
	monitored_enemies.append(enemy)
	#print("Enemy added! " + str(monitored_enemies.size()) + " enemies monitored.")
	enemy.defeated.connect(on_monitored_enemy_defeat)
	#print("Enemy " + str(enemy) + " connected.")
func on_monitored_enemy_defeat(enemy:BaseEnemy) -> void:
	#print("Attempting to remove ", enemy, "; There are ", monitored_enemies.size(), " monitored enemies.")
	head_count += 1
	set_score(enemy.get_score_value())
	var index = monitored_enemies.find(enemy)
	if index < 0:
		print("Enemy removed from list elsewise...scary! Size is ", monitored_enemies.size(), " enemy is ", enemy)
	else:
		monitored_enemies.remove_at(index)
		#print("Enemy ", enemy, " removed; There are now ", monitored_enemies.size(), " monitored enemies.")
	
	if monitored_enemies.is_empty():
		are_all_enemies_defeated = true
		if are_all_spawners_stopped:
			link_function_finished.emit()
		if are_all_spawners_finished:
			print("WIN CONDITION! In Enemy Defeat")

func set_score(value:int) -> void:
	var score_to_add : int = value*score_value*((player.get_combo_count()/combo_threshold)+1)
	total_score += score_to_add
	hud.change_score(total_score)

##spawn_enemy is used after receiving signals from spawners to create enemies at global locations
func spawn_enemy(enemy_type:Globals.ENEMYTYPE, enemy_position:Vector2) -> void:
	#spawn enemy and add to list of enemies
	var new_enemy : BaseEnemy = enemy_scenes[enemy_type].instantiate()
	new_enemy.global_position = enemy_position
	enemy_container.add_child(new_enemy)
	new_enemy.play_spawn_particles()
	monitor_enemy(new_enemy)

func start_stats(_link:ObjectiveLink) -> void:
	last_watch_start_time = Time.get_ticks_msec()
	watch_update_time = Time.get_ticks_msec()
	is_tracking_time = true
	link_function_finished.emit()
	pass

func pause_stats(_link:ObjectiveLink) -> void:
	is_tracking_time = false
	last_watch_end_time = Time.get_ticks_msec()
	#elapsed_time_msecs += (last_watch_end_time-last_watch_start_time)
	link_function_finished.emit()
	pass

func on_player_defeat() -> void:
	show_end_screen(false)

func queue_end_screen(_link:ObjectiveLink) -> void:
	show_end_screen(are_all_enemies_defeated)

func show_end_screen(value:bool) -> void:
	MusicManager.stop()
	if is_tracking_time:
		is_tracking_time = false
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	end_screen.set_results(elapsed_time_msecs, head_count, total_score, value)
	if level_info:
		if total_score > level_info.top_score:
			level_info.top_score = total_score
		if elapsed_time_msecs < level_info.fastest_time:
			level_info.fastest_time = elapsed_time_msecs
	if value:
		end_screen.animate_results(victory_music)
	else:
		end_screen.animate_results(defeat_music)

func _on_main_menu_pressed():
	Globals.scene_manager.switch_scene("main_menu")

func _on_replay_pressed():
	Globals.scene_manager.restart_scene()

func _on_next_level_pressed():
	var next : String = ""
	if next_level_info:
		next = next_level_info.level_call
	elif level_info:
		next = level_info.next_level_call
	else:
		next = next_scene
	Globals.scene_manager.switch_scene(next, Globals.AFTEREFFECT.CRT)
