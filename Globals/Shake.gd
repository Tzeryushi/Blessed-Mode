extends Node

@export var decay = 1.2
@export var max_offset : Vector2 = Vector2(100, 75)
@export var max_roll = 0.1

@onready var noise : FastNoiseLite = FastNoiseLite.new()
var shake_camera : Camera2D = null
var shake_intensity : float = 0.0
var shake_duration : float = 0.0
var trauma = 0.0  # Current shake strength.
var trauma_power = 2 

func _ready() -> void:
	noise.seed = randi()
	noise.fractal_octaves = 5
	noise.frequency = 0.15

func _process(_delta) -> void:
	if !shake_camera:
		return
	if trauma:
		trauma = max(trauma - decay * _delta, 0)
		shake()
	##end if the duration is up
	#if shake_duration <= 0.0:
		#shake_intensity = 0.0
		#shake_duration = 0.0
		#shake_camera.offset = Vector2.ZERO
		#return
	#
	#shake_duration = shake_duration-_delta
	#
	#var time = Time.get_unix_time_from_system()
	#var time_msecs = (time - int(time))*1000.0
	#
	##shake_camera.offset = Vector2(sin(time_msecs * 0.03), sin(time_msecs * 0.07)) * shake_intensity * 0.5
	#
	#var noise_x : float = noise.get_noise_1d(time_msecs*0.1)
	#var noise_y : float = noise.get_noise_1d(time_msecs*0.1+100)
	#shake_camera.offset = Vector2(noise_x, noise_y) * shake_intensity * 2.0
func add_trauma(amount, trauma_max:float = 1.6):
	var new_trauma = clampf(trauma + amount, 0.0, trauma_max)
	if trauma < new_trauma:
		trauma = new_trauma

func set_camera(camera:Camera2D) -> void:
	shake_camera = camera

func shake() -> void:
	var amount = pow(trauma, trauma_power)
	shake_camera.rotation = max_roll * amount * randf_range(-1, 1)
	shake_camera.offset.x = max_offset.x * amount * randf_range(-1, 1)
	shake_camera.offset.y = max_offset.y * amount * randf_range(-1, 1)

	#if shake_intensity < intensity and shake_duration < duration:
		#shake_intensity = intensity
		#shake_duration = duration
