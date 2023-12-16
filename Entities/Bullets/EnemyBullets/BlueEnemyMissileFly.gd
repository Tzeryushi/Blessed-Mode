extends BlueEnemyMissile

func spawn(_position:Vector2, _direction:Vector2) -> void:
	#life_timer.start()
	monitoring = false
	global_position = _position
	direction = _direction
	rotation = direction.angle()
	randomize()
	var rand_position = global_position + (direction.rotated(randf_range(-PI,PI))*float_distance)
	var tween : Tween = get_tree().create_tween()
	SoundManager.play(mine_laid_sfx)
	tween.tween_property(self, "global_position", rand_position, float_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	seek()
