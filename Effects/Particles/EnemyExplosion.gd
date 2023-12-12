extends ParticleAnimation

@export var boom_particles : Array[GPUParticles2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for particle in boom_particles:
		if particle.emitting:
			return
	is_finished = true
	finished.emit()
	queue_free()

func play() -> void:
	for particle in boom_particles:
		particle.emitting = true

func stop() -> void:
	for particle in boom_particles:
		particle.emitting = false
