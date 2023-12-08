extends ShipMode

@export var repel_strength : float = 500.0

@onready var shield_sprite := $ShieldSprite
@onready var shield_hitbox := $ShieldHitbox

var shield_active : bool = false
var opacity_tween : Tween

func _ready() -> void:
	shot_timer.timeout.connect(on_shot_timer_timeout)
	shield_sprite.modulate.a = 0.0
	shield_hitbox.monitoring = false

func _unhandled_input(_event) -> void:
	if Input.is_action_just_released("special_action"):
		end_special_action()

func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	if shield_active:
		return
	shield_active = true
	shield_hitbox.monitoring = true
	if opacity_tween and opacity_tween.is_running():
		opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(shield_sprite, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	#shield_sprite.modulate.a = 1.0
	
func end_special_action() -> void:
	shield_active = false
	shield_hitbox.monitoring = false
	if opacity_tween and opacity_tween.is_running():
		opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(shield_sprite, "modulate:a", 0.0, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	#shield_sprite.modulate.a = 0.0

func _on_shield_hitbox_area_entered(area):
	if area is BaseBullet:
		area.destroy()

func _on_shield_hitbox_body_entered(body):
	if body is BaseEnemy:
		var bounce_vector : Vector2 = (body.global_position-player.global_position).normalized()
		body.velocity = bounce_vector*repel_strength
		#print("Repel Enemy!")
