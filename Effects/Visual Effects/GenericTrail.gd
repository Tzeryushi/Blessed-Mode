class_name GenericTrail
extends Line2D

@export var limited := false
@export var trail_length = 15

var generate : bool = false

func _process(_delta) -> void:
	if !generate:
		if get_point_count() != 0:
			remove_point(0)
	else:
		global_position = Vector2.ZERO
		global_rotation = 0
		var point : Vector2 = get_parent().global_position
		add_point(point)
		while get_point_count() > trail_length:
			remove_point(0)
