extends Sprite2D

func make_ghost(ghost_sprite:AnimatedSprite2D, ghost_rotation:float, fade_time:float = 0.5) -> void:
	texture = ghost_sprite.sprite_frames.get_frame_texture(ghost_sprite.animation, ghost_sprite.frame)
	scale = ghost_sprite.scale
	rotation = ghost_rotation
	modulate = Color(0.6,0.6,0.6,0.7)
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self,"modulate:a", 0.0, fade_time)
	await fade_tween.finished
	queue_free()
