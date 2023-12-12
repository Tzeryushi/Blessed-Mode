class_name ParticleAnimation
extends Node2D

var is_finished : bool = false
signal finished
##At its base, a ParticleAnimation does little on its own
##Inheriting classes should make use of this "interface" to create their effects

func set_color(color:Color) -> void:
	modulate = color

func play() -> void:
	pass

func stop() -> void:
	is_finished = true
	finished.emit()
	pass
