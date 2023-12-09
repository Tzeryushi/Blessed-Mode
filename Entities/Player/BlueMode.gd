extends ShipMode

@export var missile_timer : Timer
@export var missile_scene : PackedScene

#var missiles_active : bool = false
var can_shoot_missiles : bool = true

func _ready() -> void:
	super()
	missile_timer.timeout.connect(missile_timer_timeout)

func _unhandled_input(_event) -> void:
	if Input.is_action_just_released("special_action"):
		end_special_action()

func process_physics(_delta) -> void:
	super(_delta)
	player.set_juice(player.juice+player.juice_regen_rate)

func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	if !can_shoot_missiles or !player.can_use_special:
		return
	player.set_juice(player.juice-special_depletion_rate)
	can_shoot_missiles = false
	missile_timer.start()
	var bullet : BaseBullet = missile_scene.instantiate()
	player.get_parent().add_child(bullet)
	bullet.spawn(player.global_position+(_mouse_location.normalized()*bullet_spawn_distance), _mouse_location)
	
func missile_timer_timeout() -> void:
	can_shoot_missiles = true
	
func end_special_action() -> void:
	pass
