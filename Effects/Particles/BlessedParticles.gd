extends ParticleAnimation

func play() -> void:
	$Orbit.emitting = true
	$Sparkles.emitting = true

func stop() -> void:
	$Orbit.emitting = false
	$Sparkles.emitting = false
	is_finished = true
	finished.emit()
	pass
