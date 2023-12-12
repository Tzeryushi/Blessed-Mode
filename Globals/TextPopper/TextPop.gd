extends Node2D

@export var velocity_init := 600.0
@export var grav_accel := 1300.0

@onready var pop_text := $PopText

var velocity := Vector2.ZERO
func _ready() -> void:
	var direction = Vector2(0, -1)
	direction = Vector2(direction.x*cos(randf_range(-PI/3,PI/3))-direction.y*sin(randf_range(-PI/3,PI/3)), direction.x*sin(randf_range(-PI/3,PI/3))+direction.y*cos(randf_range(-PI/3,PI/3)))
	velocity = direction * velocity_init

func _process(delta) -> void:
	velocity += Vector2(0, grav_accel) * delta
	pop_text.position += velocity * delta

func set_text(text:String, font_size:int=30, outline_size:int=8, color:Color=Color(1,1,1,1)) -> void:
	pop_text.set_text(text)
	pop_text.set_indexed("theme_override_font_sizes/normal_font_size", font_size)
	pop_text.set_indexed("theme_override_constants/outline_size", outline_size)
	pop_text.set_indexed("theme_override_colors/default_color", color)

func set_pop_time(time:float) -> void:
	#golden value=600-1300(1)^2=-700
	#so, x=-1300/t^2
	grav_accel = 1300/pow(time,2)
