extends Node2D

@onready var jolt_text := $JoltText

var jolt_tween : Tween

signal finished

func _process(_delta) -> void:
	if !is_instance_valid(self):
		jolt_tween.kill()

func jolt(text:String, distance:float=50.0, time:float=1.0, font_size:int=30, outline_size:int=7, color:Color=Color(1,1,1,1)) -> void:
	var new_pos : Vector2 = position + Vector2(0.0, -distance)
	jolt_text.text = text
	jolt_text.set_indexed("theme_override_font_sizes/normal_font_size", font_size)
	jolt_text.set_indexed("theme_override_constants/outline_size", outline_size)
	jolt_text.set_indexed("theme_override_colors/default_color", color)
	if !is_instance_valid(self):
		return
	jolt_tween = get_tree().create_tween()
	jolt_tween.tween_property(self, "position", new_pos, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await jolt_tween.tween_property(jolt_text, "modulate:a", 0.0, max(time-0.5, 0.1)).set_ease(Tween.EASE_OUT).finished
	finished.emit()
	destroy()

func destroy() -> void:
	if is_instance_valid(jolt_tween):
		jolt_tween.kill()
	queue_free()
