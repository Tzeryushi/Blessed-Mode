class_name BaseBullet
extends Area2D

@export_category("Visuals")
@export var visuals_group : CanvasGroup
@export var particle_scene : PackedScene
@export var trail : Line2D
@export var trail_length : int = 15
@export var shake : float = 0.2
@export var shake_ceiling : float = 0.4

@export_category("Bullet Attributes")
@export var mode_color : Globals.MODECOLOR
@export var bullet_impact_color : Color = Color(0,0,0,1)
@export var damage : int = 1
@export var speed : float = 700.0
@export var top_speed : float = 700.0
@export var acceleration : float = 5.0

@export_category("Timer Attributes")
@export var life_timer : Timer
@export var lifetime : float = 2.0

@export_category("SFX")
@export var spawn_sfx : AudioStream
@export var hit_sfx : AudioStream

var direction : Vector2 = Vector2.ZERO
var has_hit : bool = false
var timed_out : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	life_timer.wait_time = lifetime

func _process(_delta) -> void:
	update_trail()

func _physics_process(_delta) -> void:
	speed = minf(speed + (acceleration), top_speed)
	global_position += direction * speed * _delta
	rotation = direction.angle()
	
func spawn(_position:Vector2, _direction:Vector2) -> void:
	life_timer.start()
	global_position = _position
	direction = _direction.normalized()
	rotation = direction.angle()
	Shake.add_trauma(shake, shake_ceiling)
	SoundManager.play(spawn_sfx)

func destroy() -> void:
	if !timed_out:	
		SoundManager.play(hit_sfx)
		spawn_blast_particle(global_position)
	queue_free()

func update_trail() -> void:
	trail.global_position = Vector2.ZERO
	trail.global_rotation = 0
	if has_hit:
		if trail.get_point_count() != 0:
			trail.remove_point(0)
	else:
		var point : Vector2 = global_position
		trail.add_point(point)
		while trail.get_point_count() > trail_length:
			trail.remove_point(0)
	pass

func spawn_blast_particle(_position:Vector2) -> void:
	var blast_particle : ParticleAnimation = particle_scene.instantiate()
	blast_particle.global_position = _position
	blast_particle.set_color(bullet_impact_color)
	get_parent().add_child(blast_particle)
	blast_particle.play()

func get_mode_color() -> Globals.MODECOLOR:
	return mode_color

func _on_life_timer_timeout():
	timed_out = true
	destroy()

func _on_body_entered(body) -> void:
	if body is BaseEnemy or body is Player:
		body.take_damage(damage, get_mode_color())
	destroy()
