extends Node2D

@onready var pop_block := preload("res://Globals/TextPopper/TextPop.tscn")
@onready var jolt_block := preload("res://Globals/TextPopper/TextJolt.tscn")

func pop_text(text:String, _position:Vector2, calling_node:Node, size:float=1.0, time:float=1.0, font_size:int=30, outline_size:int=4, color:Color=Color(0.2,0.2,0.2,0.2)) -> void:
	var popper = pop_block.instantiate()
	calling_node.add_child(popper)
	popper.scale = popper.scale*size
	popper.position = _position
	popper.set_text(text,font_size,outline_size,color)
	popper.set_pop_time(time)
	
	await get_tree().create_timer(time/2).timeout
	if !is_instance_valid(popper):
		return
	var tween = create_tween()
	tween.tween_property(popper, "modulate:a", 0.0, time/2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	#await get_tree().create_timer(0.9).timeout
	if is_instance_valid(popper):
		popper.queue_free()

func root_pop_text(text:String, _position:Vector2, size:float=1.0, time:float=1.0, font_size:int=30, outline_size:int=7, color:Color=Color(0.2,0.2,0.2,0.2)) -> void:
	var popper = pop_block.instantiate()
	Globals.get_center_scene().add_child(popper)
	popper.scale = popper.scale*size
	popper.position = _position
	popper.set_text(text,font_size,outline_size,color)
	popper.set_pop_time(time)
	
	await get_tree().create_timer(time/2).timeout
	if !is_instance_valid(popper):
		return
	var tween = create_tween()
	tween.tween_property(popper, "modulate:a", 0.0, time/2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	#await get_tree().create_timer(0.9).timeout
	if is_instance_valid(popper):
		popper.queue_free()

func jolt_text(text:String, calling_node:Node, distance:float, _position:Vector2=Vector2.ZERO, size:float=1.0, time:float=1.0, font_size:int=30, outline_size:int=7, color:Color=Color(0.2,0.2,0.2,0.2)) -> void:
	var jolter = jolt_block.instantiate()
	calling_node.add_child(jolter)
	jolter.scale = jolter.scale*size
	jolter.position = _position
	jolter.jolt(text, distance, time, font_size, outline_size, color)
	await jolter.finished
	if is_instance_valid(jolter):
		jolter.destroy()

func root_jolt_text(text:String, _position:Vector2, distance:float, size:float=1.0, time:float=1.0, font_size:int=30, outline_size:int=4, color:Color=Color(0.2,0.2,0.2,0.2)) -> void:
	var jolter = jolt_block.instantiate()
	Globals.get_center_scene().add_child(jolter)
	jolter.scale = jolter.scale*size
	jolter.position = _position
	jolter.jolt(text, distance, time, font_size, outline_size, color)
	await jolter.finished
	if is_instance_valid(jolter):
		jolter.destroy()
