extends ParticleAnimation

#simple one and done ParticleAnimation that frees itself on end

@onready var sparks := $Blast
@onready var splode := $Splode
@onready var ring := $Ring
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_color(color:Color) -> void:
	modulate = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !sparks.emitting and !splode.emitting and !ring.emitting:
		is_finished = true
		finished.emit()
		queue_free()

func play() -> void:
	sparks.emitting = true
	splode.emitting = true
	ring.emitting = true
	pass

func stop() -> void:
	sparks.emitting = false
	splode.emitting = false
	ring.emitting = false
	pass
