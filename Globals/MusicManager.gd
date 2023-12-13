extends Node

var bus : String = "Music"
var player : AudioStreamPlayer

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.finished.connect(player_finished.bind())
	player.bus = bus

func player_finished() -> void:
	finished.emit()

func play(sound:AudioStream) -> void:
	if sound == player.stream: # or !sound:
		return
	player.stream = sound
	player.play()

func stop() -> void:
	player.stop()

func reset():
	player.play(0.0)

func pause() -> void:
	player.stream_paused = true
func unpause() -> void:
	player.stream_paused = false
