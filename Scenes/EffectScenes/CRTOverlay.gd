extends CanvasLayer

@export var crt_resource : CRT_Settings

@onready var crt_material = $ColorRect.material as ShaderMaterial

func _ready() -> void:
	Events.update_effects.connect(update_effects)
	update_effects()

func _exit_tree() -> void:
	Events.update_effects.disconnect(update_effects)

func update_effects() -> void:
	set_values(crt_resource.intensity, crt_resource.is_roll_on)

func set_values(intensity:float=1.0,should_roll:bool=true) -> void:
	var clamped_intensity = clampf(intensity,0.0,1.0)
	#crt_material = crt_material as ShaderMaterial
	
	#handling roll
	crt_material.set_shader_parameter("roll", should_roll)
	crt_material.set_shader_parameter("roll_speed", 0.8)
	crt_material.set_shader_parameter("roll_size", 8.97)
	crt_material.set_shader_parameter("roll_variation", 5)
	
	#handling intensity
	crt_material.set_shader_parameter("grille_opacity", lerpf(0.0, 0.2, clamped_intensity))
	crt_material.set_shader_parameter("distort_intensity", lerpf(0.0, 0.023, clamped_intensity))
	crt_material.set_shader_parameter("noise_opacity", lerpf(0.0, 0.0232, clamped_intensity))
	crt_material.set_shader_parameter("static_noise_intensity", lerpf(0.0, 0.06, clamped_intensity))
	crt_material.set_shader_parameter("aberration", lerpf(0.0, 0.01, clamped_intensity))
	crt_material.set_shader_parameter("warp_amount", lerpf(0.0, 0.266, clamped_intensity))
	crt_material.set_shader_parameter("vignette_intensity", lerpf(0.0, 0.1, clamped_intensity))
	crt_material.set_shader_parameter("vignette_opacity", lerpf(0.0, 0.676, clamped_intensity))

#original values:
#overlay on
#scanlines opacity 0.595
#scanlines width 0.223
#grille opacity 0.3
#480*270
#pixelate on
#roll on
#roll speed 0.8
#roll size 8.97
#roll variation 5
#distort intensity 0.023
#noise opacity 0.232
#noise speed 5
#static noise itensity 0.06
#aberration 0.01
#brightness 1.4
#discolor off
#warp amount 0.266
#clip warp off
#vignette intensity 0.1
#vignette opacity 0.676

#intensity
#noise opacity 
#static noise = 0.0 to 0.06
#aberration = 0.0 top 0.01
#warp amount 0 to 0.266
#vignette intensity 0.0 to 0.1
#vignette opacity 0 to 0.676

#roll on
#roll speed 0.8
#roll size 8.97
#roll variation 5

#roll off
#roll speed 0.0
#roll size 0
#roll variation 0.1
