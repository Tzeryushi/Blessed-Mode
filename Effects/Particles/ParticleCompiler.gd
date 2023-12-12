extends Node2D

@export var particle_scenes : Array[PackedScene] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	compile()

func compile() -> void:
	var particles : Array[ParticleAnimation] = []
	for part in particle_scenes:
		var p = part.instantiate()
		add_child(p)
		particles.append(p)
	for particle in particles:
		particle.play()
	await get_tree().process_frame
	for particle in particles:
		particle.stop()
		particle.queue_free()
