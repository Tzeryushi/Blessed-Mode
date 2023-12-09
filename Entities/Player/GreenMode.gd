extends ShipMode

@export var repel_strength : float = 500.0
@export var shield_hit_special_depletion : float = 3.0

@onready var shield_sprite := $ShieldSprite
@onready var shield_hitbox := $ShieldHitbox
@onready var shield_collision := $ShieldHitbox/ShieldCollision

var shield_active : bool = false
var shield_normal_scale : Vector2 = Vector2.ZERO
var opacity_tween : Tween

func _ready() -> void:
	shot_timer.timeout.connect(on_shot_timer_timeout)
	shield_sprite.modulate.a = 0.0
	shield_hitbox.monitoring = false
	shield_hitbox.monitorable = false
	shield_collision.disabled = true
	shield_normal_scale = shield_sprite.scale

func _unhandled_input(_event) -> void:
	if Input.is_action_just_released("special_action"):
		end_special_action()

func process_physics(_delta:float) -> void:
	super(_delta)
	if shield_active:
		player.set_juice(player.juice-special_depletion_rate)
	else:
		player.set_juice(player.juice+player.juice_regen_rate)

func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	if !player.can_use_special:
		if shield_active:
			end_special_action()
		return #TODO: visual feedback for inability
	if shield_active:
		return
	shield_active = true
	shield_hitbox.monitorable = true
	shield_hitbox.monitoring = true
	shield_collision.disabled = false
	if opacity_tween and opacity_tween.is_running():
		opacity_tween.kill()
	shield_sprite.scale = Vector2(1,1)
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(shield_sprite, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	opacity_tween.parallel().tween_property(shield_sprite, "scale", shield_normal_scale, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	#shield_sprite.modulate.a = 1.0
	
func end_special_action() -> void:
	shield_active = false
	shield_hitbox.monitorable = false
	shield_hitbox.monitoring = false
	shield_collision.disabled = true
	if opacity_tween and opacity_tween.is_running():
		opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(shield_sprite, "modulate:a", 0.0, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	opacity_tween.parallel().tween_property(shield_sprite, "scale", Vector2(1,1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	#shield_sprite.modulate.a = 0.0

func _on_shield_hitbox_area_entered(area):
	if area is BaseBullet:
		player.set_juice(player.juice - float(Globals.multiply_by_mode(area.damage, area.get_mode_color(), get_mode_color()))*0.5)
		area.destroy()

func _on_shield_hitbox_body_entered(body):
	if body is BaseEnemy:
		player.set_juice(player.juice - Globals.multiply_by_mode(body.body_damage, body.get_mode_color(), get_mode_color()))
		var bounce_vector : Vector2 = (body.global_position-player.global_position).normalized()
		body.velocity = bounce_vector*repel_strength
		#print("Repel Enemy!")
