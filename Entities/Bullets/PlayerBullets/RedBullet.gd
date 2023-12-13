extends BaseBullet

func _ready():
	super()
	spawn_sfx = GlobalSfx.bullet_fire_red
	hit_sfx = GlobalSfx.bullet_hit_red
