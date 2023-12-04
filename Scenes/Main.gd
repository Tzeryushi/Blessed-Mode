extends Control

@export var subviewport : SubViewport

func _ready() -> void:
	MainPort.main_subviewport = subviewport
	print(MainPort.main_subviewport.get_visible_rect())
