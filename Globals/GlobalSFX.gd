extends Node

@export_category("UI")
@export var button_hover_sfx : AudioStream
@export var button_select_sfx : AudioStream
@export var transition_start_sfx : AudioStream
@export var transition_end_sfx : AudioStream
@export var pause_sfx : AudioStream
@export var menu_stab_sfx : AudioStream

@export_category("Player Sounds")
@export var player_ship_hit : AudioStream
@export var player_ship_destroyed : AudioStream
@export var player_ship_swap_red : AudioStream
@export var player_ship_swap_blue : AudioStream
@export var player_ship_swap_green : AudioStream
@export var player_low_health : AudioStream
@export var player_blessed_mode : AudioStream
@export var player_red_dash_collision : AudioStream

@export_category("Bullet Sounds")
@export var bullet_fire_red : AudioStream
@export var bullet_hit_red : AudioStream
@export var bullet_fire_blue : AudioStream
@export var bullet_hit_blue : AudioStream
@export var bullet_fire_blue_missile : AudioStream
@export var bullet_fire_green : AudioStream
@export var bullet_hit : AudioStream

@export_category("Enemy Sounds")
#probably ok to leave this blank
@export var enemy_ship_hit : AudioStream
@export var enemy_ship_destroyed : AudioStream
@export var ship_on_ship_collision : AudioStream
@export var enemy_mine_laid : AudioStream
@export var enemy_mine_tracking : AudioStream
@export var enemy_bullet_spawn : AudioStream
