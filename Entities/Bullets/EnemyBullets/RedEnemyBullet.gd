extends BaseBullet

func _ready() -> void:
	super()
	spawn_sfx = GlobalSfx.enemy_bullet_spawn

func spawn(_position:Vector2, _direction:Vector2) -> void:
	life_timer.start()
	global_position = _position
	direction = _direction.normalized()
	rotation = direction.angle()
	SoundManager.play(spawn_sfx)
