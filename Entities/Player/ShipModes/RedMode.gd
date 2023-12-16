extends ShipMode

@export var rocket_acceleration : float = 90.0
@export var rocket_max_speed : float = 2000.0
@export var rocket_damage : int = 10
@export var dash_hit_particles : PackedScene

@onready var red_trail = $RedTrail
@onready var dash_hitbox = $DashHitbox
@onready var dash_collision_sfx : AudioStream = GlobalSfx.player_red_dash_collision

var is_rocketing : bool = false

func _ready() -> void:
	shot_timer.timeout.connect(on_shot_timer_timeout)
	red_trail.generate = false
	dash_hitbox.monitoring = false
	swap_in_sfx = GlobalSfx.player_ship_swap_red
func _unhandled_input(_event) -> void:
	if is_rocketing and Input.is_action_just_released("special_action"):
		end_special_action()
func process_physics(_delta) -> void:
	super(_delta)
	if is_rocketing:
		player.set_juice(player.juice-special_depletion_rate)
	else:
		player.set_juice(player.juice+player.juice_regen_rate)
func idle(_delta:float) -> void:
	if is_rocketing:
		return
	player.velocity.x = move_toward(player.velocity.x, 0, decceleration)
	player.velocity.y = move_toward(player.velocity.y, 0, decceleration)
func move(_direction:Vector2, _delta:float) -> void:
	if is_rocketing:
		return
	player.velocity.x = move_toward(player.velocity.x, max_movement_speed*_direction.x, acceleration)
	player.velocity.y = move_toward(player.velocity.y, max_movement_speed*_direction.y, acceleration)

func shoot(_direction:Vector2, _mouse_location:Vector2) -> void:
	if !can_shoot or player.is_death_invincible: return
	if is_rocketing: return
	
	#handle timer logic
	can_shoot = false
	shot_timer.start()
	#spawn bullet
	var bullet : BaseBullet = bullet_scene.instantiate()
	player.get_parent().add_child(bullet)
	bullet.spawn(player.global_position+(_mouse_location.normalized()*bullet_spawn_distance), _mouse_location)

func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	if !player.can_use_special:
		if is_rocketing:
			end_special_action()
		return #TODO: visual feedback for inability
	if !is_special_activated:
		is_special_activated = true
	is_rocketing = true
	red_trail.generate = true
	player.set_dash_invincibility(true)
	dash_hitbox.monitoring = true
	var aim_vector = _mouse_location.normalized()
	player.velocity.x = move_toward(player.velocity.x, rocket_max_speed*aim_vector.x, rocket_acceleration)
	player.velocity.y = move_toward(player.velocity.y, rocket_max_speed*aim_vector.y, rocket_acceleration)

func end_special_action() -> void:
	is_rocketing = false
	red_trail.generate = false
	player.set_dash_invincibility(false)
	dash_hitbox.monitoring = false

func _on_dash_hitbox_body_entered(body):
	if body is BaseEnemy:
		body.take_damage(rocket_damage, get_mode_color())
		SoundManager.play(dash_collision_sfx)
		Shake.add_trauma(0.4, 1.5)
		var dash_part : ParticleAnimation = dash_hit_particles.instantiate()
		add_child(dash_part)
		(dash_part as ParticleAnimation).set_color(Color(1.0,0.3,0.3,0.9))
		(dash_part as ParticleAnimation).play()
