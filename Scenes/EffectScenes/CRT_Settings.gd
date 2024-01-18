class_name CRT_Settings
extends Resource

@export var is_roll_on : bool = true
@export_range(0.0, 1.0) var intensity : float = 1.0 : set = set_intensity

func set_intensity(value:float) -> void:
	intensity = value
