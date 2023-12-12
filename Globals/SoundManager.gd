extends Node

var num_players = 8
var bus : String = "SFX"

var available_players : Array[AudioStreamPlayer] = []  # The available players.
var queue = []  # The queue of sounds to play.

#We want to be able to pass references to players back to calling classes
#This allows us to utilize those tasty audio signals

func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		create_player()

func create_player() -> void:
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	new_player.finished.connect(return_player.bind(new_player))
	available_players.append(new_player)
	new_player.bus = bus

func get_player() -> AudioStreamPlayer:
	if available_players.is_empty():
		create_player()
	return available_players.pop_back()

func return_player(player:AudioStreamPlayer):
	# When finished playing a stream, make the player available again.
	available_players.append(player)

func play(sound:AudioStream):
	var player : AudioStreamPlayer = get_player()
	player.stream = sound
	player.play()

func play_and_get(sound:AudioStream) -> AudioStreamPlayer:
	var player : AudioStreamPlayer = get_player()
	player.stream = sound
	player.play()
	return player
#
#func _process(_delta):
	## Play a queued sound if any players are available.
	#if not queue.is_empty() and not available.is_empty():
		#available[0].stream = load(queue.pop_front())
		#available[0].play()
		#available.pop_front()
