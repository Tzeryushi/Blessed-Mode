extends BaseBullet

#will move out randomly from from center point for a time
#will then choose a target, activate, and beeline for it, ignoring other hitboxes
#if the target is lost, will continue to travel in the original direction, but can hit others again

@export var seek_area : Area2D
@export var float_time : float = 0.5
@export var float_distance : float = 50.0
@export var turning_power : float = 20.0
@export var turning_acceleration : float = 3.0

var target_body : Player
var mine_laid_sfx : AudioStream = GlobalSfx.enemy_mine_laid
var mine_tracking_sfx : AudioStream = GlobalSfx.enemy_mine_tracking

func _ready():
	life_timer.wait_time = lifetime
	spawn_sfx = GlobalSfx.enemy_bullet_spawn

func _physics_process(_delta) -> void:
	if target_body:
		direction = (target_body.global_position - global_position).normalized()
		speed = minf(speed + (acceleration), top_speed)
		global_position += direction * speed * _delta
		rotation = direction.angle()
	else:
		if monitoring == true:
			seek()
		speed = minf(speed + (acceleration), top_speed)
		global_position += direction * speed * _delta
		rotation = direction.angle()
	
func spawn(_position:Vector2, _direction:Vector2) -> void:
	#life_timer.start()
	monitoring = false
	global_position = _position
	direction = Vector2.RIGHT
	rotation = direction.angle()
	randomize()
	var rand_position = global_position + (direction.rotated(randf_range(-PI,PI))*float_distance)
	var tween : Tween = get_tree().create_tween()
	SoundManager.play(mine_laid_sfx)
	tween.tween_property(self, "global_position", rand_position, float_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	direction = Vector2.ZERO
	await tween.finished
	seek()

func seek() -> void:
	#await get_tree().process_frame
	var target_array = seek_area.get_overlapping_bodies()
	monitoring = true
	if target_array.is_empty():
		if life_timer.is_stopped():
			life_timer.start()
		return
	if target_array.front() and target_array.front() is Player and target_array.front().get_mode_color() == Globals.MODECOLOR.RED:
		SoundManager.play(mine_tracking_sfx, 0.6)
		target_body = target_array.front()
		target_body.tree_exiting.connect(clear_body_ref)

func _on_body_entered(body) -> void:
	if target_body and body == target_body:
		body.take_damage(damage, get_mode_color())
	elif target_body:
		return
	destroy()

func clear_body_ref() -> void:
	target_body = null
	#target_body.tree_exiting.disconnect(clear_body_ref)
