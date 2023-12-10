extends Node2D

@onready var phrase_text := $Phrase
@onready var count_text := $Count

var current_combo : int = 0
var texts : Array[RichTextLabel] = []
var normal_size : Vector2
var time : float = 0

@export var bounce_size = Vector2(1.2,1.2)
@export var combo_text_source = [
	{
		"text" : "Combo",
		"scale" : Vector2(0.0, 0.0),
		"color" : Color(0.4,0.4,0.4,1.0)
	},{
		"text" : "Good",
		"scale" : Vector2(1.0, 1.0),
		"color" : Color(1.0,1.0,1.0,1.0)
	},{
		"text" : "Decent",
		"scale" : Vector2(1.0, 1.0),
		"color" : Color(1.0,1.0,1.0,1.0)
	},{
		"text" : "Noble",
		"scale" : Vector2(1.0, 1.0),
		"color" : Color(1.0,1.0,1.0,1.0)
	},{
		"text" : "Righteous",
		"scale" : Vector2(0.5, 0.5),
		"color" : Color(1.0,1.0,1.0,1.0)
	},{
		"text" : "Blessed",
		"scale" : Vector2(1.0, 1.0),
		"color" : Color(1.0,1.0,1.0,1.0)
	},{
		"text" : "Enlightened",
		"scale" : Vector2(0.8, 0.8),
		"color" : Color(1.0,1.0,1.0,1.0)
	},{
		"text" : "Divine",
		"scale" : Vector2(1.0, 1.0),
		"color" : Color(1.0,1.0,1.0,1.0)
	},{
		"text" : "Exalted",
		"scale" : Vector2(1.0, 1.0),
		"color" : Color(1.0,1.0,1.0,1.0)
	}
]

# Called when the node enters the scene tree for the first time.
func _ready():
	texts.append(phrase_text)
	texts.append(count_text)
	normal_size = scale
	set_combo(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	rotation = 0.15*cos(time*2)
	pass

func set_combo(combo_value:int) -> void:
	if combo_value <= 0:
		if current_combo > combo_value:
			#pop out combo
			pass
		phrase_text.text = ""
		count_text.text = ""
		current_combo = combo_value
		return
	var combo_tier : int = (combo_value/5)
	if combo_text_source.size() <= combo_tier:
		combo_tier = combo_text_source.size() - 1
	phrase_text.text = "[center]" + combo_text_source[combo_tier]["text"]
	phrase_text.scale = combo_text_source[combo_tier]["scale"]
	count_text.text = "[center]" + str(combo_value)
	for text in texts:
		text.add_theme_color_override("default_color", combo_text_source[combo_tier]["color"])
	current_combo = combo_value
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", bounce_size, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", normal_size, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
