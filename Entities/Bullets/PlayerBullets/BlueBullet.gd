extends BaseBullet


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	spawn_sfx = GlobalSfx.bullet_fire_blue
	hit_sfx = GlobalSfx.bullet_hit_blue
	pass # Replace with function body.
